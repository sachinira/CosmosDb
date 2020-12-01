import ballerina/java;
import ballerina/time;
import ballerina/crypto;
import ballerina/encoding;
import ballerina/http;
import ballerina/stringutils;
import ballerina/lang.'string as str;
import ballerina/io;

function parseResponseToTuple(http:Response|http:ClientError httpResponse) returns @tainted [json, Headers]|error {
    var responseBody = check parseResponseToJson(httpResponse);
    var responseHeaders = check parseHeadersToObject(httpResponse);
    return [responseBody,responseHeaders];
}

// function parseDeleteResponseToTuple(http:Response|http:ClientError httpResponse) returns  @tainted 
// [string,Headers]|error{
//     var responseBody = check getDeleteResponse(httpResponse);
//     var responseHeaders = check parseHeadersToObject(httpResponse);
//     return [responseBody,responseHeaders];
// }

# To handle sucess or error reponses to requests
# + httpResponse - http:Response or http:ClientError returned from an http:Request
# + return - If successful, returns json. Else returns error.  
function parseResponseToJson(http:Response|http:ClientError httpResponse) returns @tainted json|error { 
    if (httpResponse is http:Response) {
        var jsonResponse = httpResponse.getJsonPayload();
        if (jsonResponse is json) {
            if (httpResponse.statusCode != http:STATUS_OK && httpResponse.statusCode != http:STATUS_CREATED) {
                return createResponseFailMessage(httpResponse,jsonResponse);
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
# + return - If successful, returns string. Else returns error.  
function getDeleteResponse(http:Response|http:ClientError httpResponse) returns @tainted boolean|error {
    if (httpResponse is http:Response) {
        if(httpResponse.statusCode == http:STATUS_NO_CONTENT) {
            return true;
        } else {
            var jsonResponse = httpResponse.getJsonPayload();
            if jsonResponse is json {
                return createResponseFailMessage(httpResponse,jsonResponse);
            }else {
                return prepareError("Error occurred while accessing the JSON payload of the response");
            }
        }
    } else {
        return prepareError("Error occurred while invoking the REST API");
    }
}

function createResponseFailMessage(http:Response httpResponse, json errorResponse) returns error {
    string message = errorResponse.message.toString();
    string errorMessage = httpResponse.statusCode.toString() + " " + httpResponse.reasonPhrase; 
    var stoppingIndex = message.indexOf("ActivityId");
    if stoppingIndex is int {
        errorMessage += " : " + message.substring(0,stoppingIndex);
    }
    return prepareError(errorMessage);
}

function parseHeadersToObject(http:Response|http:ClientError httpResponse) returns @tainted Headers|error {
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

function getHeaderIfExist(http:Response httpResponse, string headername) returns @tainted string? {
    if httpResponse.hasHeader(headername) {
        return httpResponse.getHeader(headername);
    }else {
        return ();
    }
}

function mapRequest(http:Request? req) returns http:Request { 
    http:Request newRequest = new;
    if req is http:Request{
        return req;
    } else {
        return newRequest;
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

function convertToBoolean(json|error value) returns boolean { 
    if (value is json) {
        boolean|error result = 'boolean:fromString(value.toString());
        if (result is boolean) {
            return result;
        }
    }
    return false;
}

function convertToInt(json|error value) returns int {
    if (value is json) {
        int|error result = 'int:fromString(value.toString());
        if (result is int) {
            return result;
        }
    }
    return 0;
}

function mergeTwoArrays(any[] array1, any[] array2) returns any[] {
    foreach any element in array2 {
       array1.push(element);
    }
    return array1;
}

public function setThroughputOrAutopilotHeader(http:Request req, ThroughputProperties? throughputProperties) returns 
http:Request|error {
  if throughputProperties is ThroughputProperties {
        if throughputProperties.throughput is int &&  throughputProperties.maxThroughput is () {
            req.setHeader(THROUGHPUT_HEADER, throughputProperties.maxThroughput.toString());
        } else if throughputProperties.throughput is () &&  throughputProperties.maxThroughput != () {
            req.setHeader(AUTOPILET_THROUGHPUT_HEADER, throughputProperties.maxThroughput.toString());
        } else if throughputProperties.throughput is int &&  throughputProperties.maxThroughput != () {
            return 
            prepareError("Cannot set both x-ms-offer-throughput and x-ms-cosmos-offer-autopilot-settings headers at once");
        }
    }
    return req;
}

public function setPartitionKeyHeader(http:Request req, any partitionKey) returns http:Request|error {
    req.setHeader("x-ms-documentdb-partitionkey",string `[${partitionKey.toString()}]`);
    return req;
}

public function enableCrossPartitionKeyHeader(http:Request req, boolean isignore) returns http:Request|error {
    req.setHeader("x-ms-documentdb-query-enablecrosspartition",isignore.toString());
    return req;
}

public function setHeadersForQuery(http:Request req) returns http:Request|error {
    var header = req.setContentType("application/query+json");
    req.setHeader("x-ms-documentdb-isquery","True");
    return req;
}

public function setRequestOptions(http:Request req, RequestHeaderOptions requestOptions) returns http:Request|error {
    if requestOptions.indexingDirective is string {
        req.setHeader("x-ms-indexing-directive",requestOptions.indexingDirective.toString());
    }
    if requestOptions.isUpsertRequest == true {
        req.setHeader("x-ms-documentdb-is-upsert",requestOptions.isUpsertRequest.toString());
    }
    if requestOptions.maxItemCount is int{
        req.setHeader("x-ms-max-item-count",requestOptions.maxItemCount.toString()); 
    }
    if requestOptions.continuationToken is string {
        req.setHeader("x-ms-continuation",requestOptions.continuationToken.toString());
    }
    if requestOptions.consistancyLevel is string {
        req.setHeader("x-ms-consistency-level",requestOptions.consistancyLevel.toString());
    }
    if requestOptions.sessionToken is string {
        req.setHeader("x-ms-session-token",requestOptions.sessionToken.toString());
    }
    if requestOptions.changeFeedOption is string {
        req.setHeader("A-IM",requestOptions.changeFeedOption.toString()); 
    }
    if requestOptions.ifNoneMatch is string {
        req.setHeader("If-None-Match",requestOptions.ifNoneMatch.toString());
    }
    if requestOptions.PartitionKeyRangeId is string {
        req.setHeader("x-ms-documentdb-partitionkeyrangeid",requestOptions.PartitionKeyRangeId.toString());
    }
    if requestOptions.PartitionKeyRangeId is string {
        req.setHeader("If-Match",requestOptions.PartitionKeyRangeId.toString());
    }
    return req;
}

# To attach required basic headers to call REST endpoint
# + req - http:Request to add headers to
# + host - 
# + keyToken - master or resource token
# + tokenType - denotes the type of token: master or resource.
# + tokenVersion - denotes the version of the token, currently 1.0.
# + params - an object of type HeaderParamaters
# + return - If successful, returns same http:Request with newly appended headers. Else returns error.  
public function setHeaders(http:Request req, string host, string keyToken, string tokenType, string tokenVersion,
HeaderParamaters params) returns http:Request|error {
    req.setHeader(API_VERSION_HEADER,params.apiVersion);
    req.setHeader(HOST_HEADER,host);
    req.setHeader(ACCEPT_HEADER,"*/*");
    req.setHeader(CONNECTION_HEADER,"keep-alive");
    string?|error date = getTime();
    if date is string {
        string?|error s = generateTokenNew(params.verb,params.resourceType,params.resourceId,keyToken,tokenType,tokenVersion);
        req.setHeader(DATE_HEADER,date);
        if s is string {
            req.setHeader(AUTHORIZATION_HEADER,s);
        } else {
            return prepareError("Authorization token is null");
        }
    } else {
        return prepareError("Date header is invalid/null");
    }
    return req;
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
    var token = generateTokenJ(java:fromString(verb),java:fromString(resourceType),java:fromString(resourceId),
    java:fromString(keyToken),java:fromString(tokenType),java:fromString(tokenVersion));
    return java:toString(token);
}

# To construct the hashed token signature for a token 
# + return - If successful, returns string representing UTC date and time 
#               (in "HTTP-date" format as defined by RFC 7231 Date/Time Formats). Else returns error.  
public function getTime() returns string?|error {
    time:Time time1 = time:currentTime();
    var time2 = check time:toTimeZone(time1, GMT_ZONE);
    string|error timeString = time:format(time2, "EEE, dd MMM yyyy HH:mm:ss z");
    return timeString;
}

# To construct resource type  which is used to create the hashed token signature 
# + url - string parameter part of url to extract the resource type
# + return - Returns the resource type extracted from url as a string  
public function getResourceType(string url) returns string {
    string resourceType = EMPTY_STRING;
    string[] urlParts = stringutils:split(url,FORWARD_SLASH);
    int count = urlParts.length()-1;
    if count % 2 != 0{
        resourceType = urlParts[count];
        if count > 1{
            int? i = str:lastIndexOf(url,FORWARD_SLASH);
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
    string[] urlParts = stringutils:split(url,FORWARD_SLASH);
    int count = urlParts.length()-1;
    if count % 2 != 0{
        if count > 1{
            int? i = str:lastIndexOf(url,FORWARD_SLASH);
            if i is int {
                resourceId = str:substring(url,1,i);
            }
        }
    } else {
        resourceId = str:substring(url,1);
    }
    return resourceId;
}

public function getResourceIdForOffer(string url) returns string {
    string resourceId = EMPTY_STRING;
    string[] urlParts = stringutils:split(url,FORWARD_SLASH);
    int count = urlParts.length()-1;
    int? i = str:lastIndexOf(url,FORWARD_SLASH);
    if i is int {
        resourceId = str:substring(url,i+1);
    }  
    return resourceId.toLowerAscii();
}

public function generateToken(string verb, string resourceType, string resourceId, string keys, string keyType, 
string tokenVersion, string date) returns string?|error {    
    string authorization;
    string payload = verb.toLowerAscii()+"\n" + resourceType.toLowerAscii() + "\n" + resourceId + "\n"
    + date.toLowerAscii() +"\n" + "" + "\n";
    var decoded = encoding:decodeBase64Url(keys);
    if decoded is byte[]{
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
    if decoded is byte[]{
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
