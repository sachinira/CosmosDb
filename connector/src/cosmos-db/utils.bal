import ballerina/java;
import ballerina/time;
import ballerina/crypto;
import ballerina/encoding;
import ballerina/http;
import ballerina/stringutils;
import ballerina/lang.'string as str;
import ballerina/io;

# To handle sucess or error reponses to requests
# + httpResponse - http:Response or http:ClientError returned from an http:Request
# + return - If successful, returns a tuple containing [json, Headers]
function mapResponseToTuple(http:Response|http:ClientError httpResponse) returns @tainted [json, Headers]|error {
    var responseBody = check mapResponseToJson(httpResponse);
    var responseHeaders = check mapResponseHeadersToObject(httpResponse);
    return [responseBody,responseHeaders];
}

# To handle sucess or error reponses to requests
# + httpResponse - http:Response or http:ClientError returned from an http:Request
# + return - If successful, returns json. Else returns error.  
function mapResponseToJson(http:Response|http:ClientError httpResponse) returns @tainted json|error { 
    if (httpResponse is http:Response) {
        var jsonResponse = httpResponse.getJsonPayload();
        if (jsonResponse is json) {
            if (httpResponse.statusCode != http:STATUS_OK && httpResponse.statusCode != http:STATUS_CREATED) {
                return createResponseFailMessage(httpResponse, jsonResponse);
            }
            return jsonResponse;
        } else {
            return prepareError("Error occurred while accessing the JSON payload of the response");
        }
    } else {
        return prepareError("Error occurred while invoking the REST API");
    }
}

# To handle the delete responses which return without a json payload
# + httpResponse - http:Response or http:ClientError returned from an http:Request
# + return - If successful, returns boolean. Else returns error.  
function getDeleteResponse(http:Response|http:ClientError httpResponse) returns @tainted boolean|error {
    if (httpResponse is http:Response) {
        if(httpResponse.statusCode == http:STATUS_NO_CONTENT) {
            return true;
        } else {
            var jsonResponse = httpResponse.getJsonPayload();
            if jsonResponse is json {
                return createResponseFailMessage(httpResponse,jsonResponse);
            } else {
                return prepareError("Error occurred while accessing the JSON payload of the response");
            }
        }
    } else {
        return prepareError("Error occurred while invoking the REST API");
    }
}

# To handle the delete responses which return without a json payload
# + httpResponse - http:Response or http:ClientError returned from an http:Request
# + errorResponse - the error response returned from the Azure endpoint
# + return -  returns error.
function createResponseFailMessage(http:Response httpResponse, json errorResponse) returns error {
    string message = errorResponse.message.toString();
    string errorMessage = httpResponse.statusCode.toString() + " " + httpResponse.reasonPhrase; 
    var stoppingIndex = message.indexOf("ActivityId");
    if stoppingIndex is int {
        errorMessage += " : " + message.substring(0,stoppingIndex);
    }
    return prepareError(errorMessage);
}

# To return the response headers which are useful for the users for future operations
# + httpResponse - http:Response or http:ClientError returned from an http:Request
# + return -  returns object of type Headers.
function mapResponseHeadersToObject(http:Response|http:ClientError httpResponse) returns @tainted Headers|error {
    Headers responseHeaders = {};
    if (httpResponse is http:Response) {
        responseHeaders.continuationHeader = getHeaderIfExist(httpResponse,CONTINUATION_HEADER);
        responseHeaders.sessionTokenHeader = getHeaderIfExist(httpResponse,SESSION_TOKEN_HEADER);
        responseHeaders.requestChargeHeader = getHeaderIfExist(httpResponse,REQUEST_CHARGE_HEADER);
        responseHeaders.resourceUsageHeader = getHeaderIfExist(httpResponse,RESOURCE_USAGE_HEADER);
        responseHeaders.itemCountHeader = getHeaderIfExist(httpResponse,ITEM_COUNT_HEADER);
        responseHeaders.etagHeader = getHeaderIfExist(httpResponse,ETAG_HEADER);
        responseHeaders.dateHeader = getHeaderIfExist(httpResponse,RESPONSE_DATE_HEADER);
        return responseHeaders;

    } else {
        return prepareError("Error occurred while invoking the REST API");
    }
}

# To check if  the givn response header exist
# + httpResponse - http:Response or http:ClientError returned from an http:Request
# + headername - the name of header to check
# + return -  returns the header value in string.
function getHeaderIfExist(http:Response httpResponse, string headername) returns @tainted string? {
    if httpResponse.hasHeader(headername) {
        return httpResponse.getHeader(headername);
    } else {
        return ();
    }
}

# Returns the prepared URL.
# + paths - An array of paths prefixes
# + return - The prepared URL
function prepareUrl(string[] paths) returns string {
    string url = EMPTY_STRING;
    if (paths.length() > 0) {
        foreach var path in paths {
            if (!path.startsWith(FORWARD_SLASH)) {
                url = url + FORWARD_SLASH;
            }
            url = url + path;
        }
    }
    return <@untainted> url;
}

# Convert json string values to boolean
# + value - json value which has reprsents boolean value
# + return - boolean value of specified json
function convertToBoolean(json|error value) returns boolean { 
    if (value is json) {
        boolean|error result = 'boolean:fromString(value.toString());
        if (result is boolean) {
            return result;
        }
    }
    return false;
}

# Convert json string values to int
# + value - json value which has reprsents int value
# + return - int value of specified json
function convertToInt(json|error value) returns int {
    if (value is json) {
        int|error result = 'int:fromString(value.toString());
        if (result is int) {
            return result;
        }
    }
    return 0;
}

// function mergeTwoArrays(any[] array1, any[] array2) returns any[] {
//     foreach any element in array2 {
//        array1.push(element);
//     }
//     return array1;
// }

# To set the optional headers related to throughput
# + request - http:Request to set the header
# + throughputProperties - an object of type ThroughputProperties
# + return -  returns the header value in string.
public function setThroughputOrAutopilotHeader(http:Request request, ThroughputProperties? throughputProperties) returns 
http:Request|error {
  if throughputProperties is ThroughputProperties {
        if throughputProperties.throughput is int &&  throughputProperties.maxThroughput is () {
            request.setHeader(THROUGHPUT_HEADER, throughputProperties.maxThroughput.toString());
        } else if throughputProperties.throughput is () &&  throughputProperties.maxThroughput != () {
            request.setHeader(AUTOPILET_THROUGHPUT_HEADER, throughputProperties.maxThroughput.toString());
        } else if throughputProperties.throughput is int &&  throughputProperties.maxThroughput != () {
            return 
            prepareError("Cannot set both x-ms-offer-throughput and x-ms-cosmos-offer-autopilot-settings headers at once");
        }
    }
    return request;
}

# To set the optional header related to partitionkey value
# + request - http:Request to set the header
# + partitionKey - the value of the partition key
# + return -  returns the header value in string.
public function setPartitionKeyHeader(http:Request request, any partitionKey) returns http:Request {
    request.setHeader(PARTITION_KEY_HEADER, string `[${partitionKey.toString()}]`);
    return request;
}

# To set the optional header related to cross partition value
# + request - http:Request to set the header
# + isIgnore - boolean value if user enable or disable cross partitioning
# + return -  returns the header value in string.
public function enableCrossPartitionKeyHeader(http:Request request, boolean isIgnore) returns http:Request|error {
    request.setHeader("x-ms-documentdb-query-enablecrosspartition", isIgnore.toString());
    return request;
}

# To set the required headers related to query operations
# + request - http:Request to set the header
# + return -  returns the header value in string.
public function setHeadersForQuery(http:Request request) returns http:Request|error {
    var header = request.setContentType("application/query+json");
    request.setHeader(ISQUERY_HEADER, "True");
    return request;
}

# To set the optional headers
# + request - http:Request to set the header
# + requestOptions - object of type RequestHeaderOptions containing the values for optional headers
# + return -  returns the header value in string.
public function setRequestOptions(http:Request request, RequestHeaderOptions requestOptions) returns http:Request {
    if requestOptions.indexingDirective is string {
        request.setHeader(INDEXING_DIRECTIVE_HEADER, requestOptions.indexingDirective.toString());
    }
    if requestOptions.isUpsertRequest == true {
        request.setHeader(IS_UPSERT_HEADER, requestOptions.isUpsertRequest.toString());
    }
    if requestOptions.maxItemCount is int{
        request.setHeader(MAX_ITEM_COUNT_HEADER, requestOptions.maxItemCount.toString()); 
    }
    if requestOptions.continuationToken is string {
        request.setHeader(CONTINUATION_HEADER, requestOptions.continuationToken.toString());
    }
    if requestOptions.consistancyLevel is string {
        request.setHeader(CONSISTANCY_LEVEL_HEADER, requestOptions.consistancyLevel.toString());
    }
    if requestOptions.sessionToken is string {
        request.setHeader(SESSION_TOKEN_HEADER, requestOptions.sessionToken.toString());
    }
    if requestOptions.changeFeedOption is string {
        request.setHeader(A_IM_HEADER, requestOptions.changeFeedOption.toString()); 
    }
    if requestOptions.ifNoneMatch is string {
        request.setHeader(NON_MATCH_HEADER, requestOptions.ifNoneMatch.toString());
    }
    if requestOptions.PartitionKeyRangeId is string {
        request.setHeader(PARTITIONKEY_RANGE_HEADER, requestOptions.PartitionKeyRangeId.toString());
    }
    if requestOptions.PartitionKeyRangeId is string {
        request.setHeader(IF_MATCH_HEADER, requestOptions.PartitionKeyRangeId.toString());
    }
    return request;
}

# To attach required basic headers to call REST endpoint
# + request - http:Request to add headers to
# + host - the host of the Azure resource
# + keyToken - master or resource token
# + tokenType - denotes the type of token: master or resource.
# + tokenVersion - denotes the version of the token, currently 1.0.
# + params - an object of type HeaderParameters
# + return - If successful, returns same http:Request with newly appended headers. Else returns error.  
public function setHeaders(http:Request request, string host, string keyToken, string tokenType, string tokenVersion,
HeaderParameters params) returns http:Request|error {
    request.setHeader(API_VERSION_HEADER,params.apiVersion);
    request.setHeader(HOST_HEADER,host);
    request.setHeader(ACCEPT_HEADER,"*/*");
    request.setHeader(CONNECTION_HEADER,"keep-alive");
    string?|error date = getTime();
    if date is string {
        string? s = generateTokenNew(params.verb, params.resourceType, params.resourceId, keyToken, tokenType, tokenVersion);
        request.setHeader(DATE_HEADER,date);
        if s is string {
            request.setHeader(AUTHORIZATION_HEADER,s);
        } else {
            return prepareError("Authorization token is null");
        }
    } else {
        return prepareError("Date is invalid/null");
    }
    return request;
}

# To construct the hashed token signature for a token to set  'Authorization' header
# + verb - HTTP verb, such as GET, POST, or PUT
# + resourceType - identifies the type of resource that the request is for, Eg. "dbs", "colls", "docs"
# + resourceId -dentity property of the resource that the request is directed at
# + keyToken - master or resource token
# + tokenType - denotes the type of token: master or resource.
# + tokenVersion - denotes the version of the token, currently 1.0.
# + return - If successful, returns string which is the  hashed token signature. Else returns ().  
public function generateTokenNew(string verb, string resourceType, string resourceId, string keyToken, string tokenType, 
string tokenVersion) returns string? {
    var token = generateTokenJ(java:fromString(verb), java:fromString(resourceType), java:fromString(resourceId),
    java:fromString(keyToken), java:fromString(tokenType), java:fromString(tokenVersion));
    return java:toString(token);
}

# To construct the hashed token signature for a token 
# + return - If successful, returns string representing UTC date and time 
#   (in "HTTP-date" format as defined by RFC 7231 Date/Time Formats). Else returns error.  
public function getTime() returns string?|error {
    time:Time time1 = time:currentTime();
    var timeWithZone = check time:toTimeZone(time1, GMT_ZONE);
    string|error timeString = time:format(timeWithZone, "EEE, dd MMM yyyy HH:mm:ss z");
    if timeString is string {
        return timeString;
    } else {
        return prepareError("Time string is not correct");
    }
}

# To construct resource type  which is used to create the hashed token signature 
# + url - string parameter part of url to extract the resource type
# + return - Returns the resource type extracted from url as a string  
public function getResourceType(string url) returns string {
    string resourceType = EMPTY_STRING;
    string[] urlParts = stringutils:split(url, FORWARD_SLASH);
    int count = urlParts.length()-1;
    if count % 2 != 0 {
        resourceType = urlParts[count];
        if count > 1 {
            int? i = str:lastIndexOf(url, FORWARD_SLASH);
        }
    } else {
        resourceType = urlParts[count-1];
    }
    return resourceType;
}

# To construct resource id  which is used to create the hashed token signature 
# + url - string parameter part of url to extract the resource id
# + return - Returns the resource id extracted from url as a string 
public function getResourceId(string url) returns string {
    string resourceId = EMPTY_STRING;
    string[] urlParts = stringutils:split(url, FORWARD_SLASH);
    int count = urlParts.length()-1;
    if count % 2 != 0 {
        if count > 1 {
            int? i = str:lastIndexOf(url, FORWARD_SLASH);
            if i is int {
                resourceId = str:substring(url,1,i);
            }
        }
    } else {
        resourceId = str:substring(url, 1);
    }
    return resourceId;
}

# To construct resource id for offers which is used to create the hashed token signature 
# + url - string parameter part of url to extract the resource id
# + return - Returns the resource id extracted from url as a string 
public function getResourceIdForOffer(string url) returns string {
    string resourceId = EMPTY_STRING;
    string[] urlParts = stringutils:split(url, FORWARD_SLASH);
    int count = urlParts.length()-1;
    int? i = str:lastIndexOf(url, FORWARD_SLASH);
    if i is int {
        resourceId = str:substring(url, i+1);
    }  
    return resourceId.toLowerAscii();
}

//***********************************Ballerina token generators***********************************
public function generateToken(string verb, string resourceType, string resourceId, string keys, string keyType, 
string tokenVersion, string date) returns string?|error {    
    string authorization;
    string payload = verb.toLowerAscii()+"\n" + resourceType.toLowerAscii() + "\n" + resourceId + "\n"
    + date.toLowerAscii() +"\n" + "" + "\n";
    var decoded = encoding:decodeBase64Url(keys);
    if decoded is byte[] {
        byte[] k = crypto:hmacSha256(payload.toBytes(),decoded);
        string  t = k.toBase16();
        string signature = encoding:encodeBase64Url(k);
        authorization = 
        check encoding:encodeUriComponent(string `type=${keyType}&ver=${tokenVersion}&sig=${signature}=`, "UTF-8");   
        return authorization;
    } else {     
        io:println("Decoding error");
    }
}

public function generateTokenNewBl(string verb, string resourceType, string resourceId, string keys, string keyType, 
string tokenVersion, string date) returns string?|error {    
    string authorization;
    string payload = verb.toLowerAscii()+"\n" + resourceType.toLowerAscii() + "\n" + resourceId + "\n"
    + date.toLowerAscii() +"\n" + "" + "\n";
    var decoded = encoding:decodeBase64Url(keys);
    if decoded is byte[] {
        byte[] digest = crypto:hmacSha256(payload.toBytes(),decoded);
        string signature = encoding:encodeBase64Url(digest);
        authorization = 
        check encoding:encodeUriComponent(string `type=${keyType}&ver=${tokenVersion}&sig=${signature}`, "UTF-8");   
        return authorization;
    } else {     
        io:println("Decoding error");
    }
}

function generateTokenJ(handle verb, handle resourceType, handle resourceId, handle keyToken, handle tokenType, 
handle tokenVersion) returns handle = @java:Method {
    name: "generate",
    'class: "com.sachini.TokenCreate"
} external;
