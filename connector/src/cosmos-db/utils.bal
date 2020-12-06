import ballerina/java;
import ballerina/time;
import ballerina/http;
import ballerina/stringutils;
import ballerina/lang.'string as str;
import ballerina/crypto;
import ballerina/encoding;
import ballerina/lang.array as array; 

function mapResponseToTuple(http:Response|http:ClientError httpResponse) returns @tainted [json, Headers]|error {
    var responseBody = check mapResponseToJson(httpResponse);
    var responseHeaders = check mapResponseHeadersToObject(httpResponse);
    return [responseBody,responseHeaders];
}
  
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

function createResponseFailMessage(http:Response httpResponse, json errorResponse) returns error {
    string message = errorResponse.message.toString();
    string errorMessage = httpResponse.statusCode.toString() + " " + httpResponse.reasonPhrase; 
    var stoppingIndex = message.indexOf("ActivityId");
    if stoppingIndex is int {
        errorMessage += " : " + message.substring(0,stoppingIndex);
    }
    return prepareError(errorMessage);
}

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

function getHeaderIfExist(http:Response httpResponse, string headername) returns @tainted string? {
    if httpResponse.hasHeader(headername) {
        return httpResponse.getHeader(headername);
    } else {
        return ();
    }
}

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

function setThroughputOrAutopilotHeader(http:Request request, ThroughputProperties? throughputProperties) returns 
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

function setPartitionKeyHeader(http:Request request, any partitionKey) returns http:Request {
    request.setHeader(PARTITION_KEY_HEADER, string `[${partitionKey.toString()}]`);
    return request;
}

function enableCrossPartitionKeyHeader(http:Request request, boolean isIgnore) returns http:Request|error {
    request.setHeader("x-ms-documentdb-query-enablecrosspartition", isIgnore.toString());
    return request;
}

function setHeadersForQuery(http:Request request) returns http:Request|error {
    var header = request.setContentType("application/query+json");
    request.setHeader(ISQUERY_HEADER, "True");
    return request;
}

function setRequestOptions(http:Request request, RequestHeaderOptions requestOptions) returns http:Request {
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
    if requestOptions.partitionKeyRangeId is string {
        request.setHeader(PARTITIONKEY_RANGE_HEADER, requestOptions.partitionKeyRangeId.toString());
    }
    if requestOptions.ifMatch is string {
        request.setHeader(IF_MATCH_HEADER, requestOptions.ifMatch.toString());
    }
    return request;
}

function setExpiryHeader(http:Request request, int validationPeriod) returns http:Request {
    request.setHeader(EXPIRY_HEADER, validationPeriod.toString());
    return request;
}
 
function setHeaders(http:Request request, string host, string keyToken, string tokenType, string tokenVersion,
HeaderParameters params) returns http:Request|error {
    request.setHeader(API_VERSION_HEADER,params.apiVersion);
    request.setHeader(HOST_HEADER,host);
    request.setHeader(ACCEPT_HEADER,"*/*");
    request.setHeader(CONNECTION_HEADER,"keep-alive");
    string?|error date = getTime();
    if date is string {
        string? signature = ();
        if tokenType.toLowerAscii() == TOKEN_TYPE_MASTER {
            signature = check generateMasterTokenSignature(params.verb, params.resourceType, params.resourceId, keyToken, tokenType, tokenVersion,date);
        } else if tokenType.toLowerAscii() == TOKEN_TYPE_RESOURCE {
            signature = check encoding:encodeUriComponent(keyToken, "UTF-8"); 
        } else {
            return prepareError("ResourceType is incorrect/null");
        }
        request.setHeader(DATE_HEADER,date);
        if signature is string {
            request.setHeader(AUTHORIZATION_HEADER,signature);
        } else {
            return prepareError("Authorization token is null");
        }
    } else {
        return prepareError("Date is invalid/null");
    }
    return request;
}

function generateTokenNew(string verb, string resourceType, string resourceId, string keyToken, string tokenType, 
string tokenVersion) returns string? {
    var token = generateTokenJ(java:fromString(verb), java:fromString(resourceType), java:fromString(resourceId),
    java:fromString(keyToken), java:fromString(tokenType), java:fromString(tokenVersion));
    return java:toString(token);
}

function generateMasterTokenSignature(string verb, string resourceType, string resourceId, string keyToken, string tokenType, 
string tokenVersion, string date) returns string?|error {    
    string authorization;
    string payload = verb.toLowerAscii()+"\n" + resourceType.toLowerAscii() + "\n" + resourceId + "\n"
    + date.toLowerAscii() +"\n" + "" + "\n";
    var decoded = array:fromBase64(keyToken);
    if decoded is byte[] {
        byte[] digest = crypto:hmacSha256(payload.toBytes(),decoded);
        string signature = array:toBase64(digest);
        authorization = 
        check encoding:encodeUriComponent(string `type=${tokenType}&ver=${tokenVersion}&sig=${signature}`, "UTF-8");   
        return authorization;
    } else {     
    }
}

function getTime() returns string?|error {
    time:Time time1 = time:currentTime();
    var timeWithZone = check time:toTimeZone(time1, GMT_ZONE);
    string|error timeString = time:format(timeWithZone, "EEE, dd MMM yyyy HH:mm:ss z");
    if timeString is string {
        return timeString;
    } else {
        return prepareError("Time string is not correct");
    }
}

function getResourceType(string url) returns string {
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

function getResourceId(string url) returns string {
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

function getResourceIdForOffer(string url) returns string {
    string resourceId = EMPTY_STRING;
    string[] urlParts = stringutils:split(url, FORWARD_SLASH);
    int count = urlParts.length()-1;
    int? i = str:lastIndexOf(url, FORWARD_SLASH);
    if i is int {
        resourceId = str:substring(url, i+1);
    }  
    return resourceId.toLowerAscii();
}

function generateTokenJ(handle verb, handle resourceType, handle resourceId, handle keyToken, handle tokenType, 
handle tokenVersion) returns handle = @java:Method {
    name: "generate",
    'class: "com.sachini.TokenCreate"
} external;
