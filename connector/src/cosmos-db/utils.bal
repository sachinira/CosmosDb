import ballerina/java;
import ballerina/time;
import ballerina/io;
import ballerina/crypto;
import ballerina/encoding;
import ballerina/http;
import ballerina/stringutils;
import ballerina/lang.'string as str;

# To handle sucess or error reponses to requests
# + httpResponse - http:Response or http:ClientError returned from an http:Request
# + return - If successful, returns json. Else returns error.  
function parseResponseToJson(http:Response|http:ClientError httpResponse) returns @tainted json|error { 
    if (httpResponse is http:Response) {
        var jsonResponse = httpResponse.getJsonPayload();

        if (jsonResponse is json) {
            if (httpResponse.statusCode != http:STATUS_OK && httpResponse.statusCode != http:STATUS_CREATED) {
                string code = "";    
                if (jsonResponse?.error_code != ()) {
                    code = jsonResponse.error_code.toString();
                } else if (jsonResponse?.'error != ()) {
                    code = jsonResponse.'error.toString();
                }
                string message = jsonResponse.message.toString();
                string errorMessage = httpResponse.statusCode.toString() + " " + httpResponse.reasonPhrase; 
                if (code != "") {
                    errorMessage += " - " + code;
                }
                errorMessage += " : " + message;
                return prepareError(errorMessage);
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
function getDeleteResponse(http:Response|http:ClientError httpResponse) returns @tainted string|error{
    if (httpResponse is http:Response) {
        if(httpResponse.statusCode == http:STATUS_NO_CONTENT){
            return string `Deleted Sucessfully ${httpResponse.statusCode}`;
        } else {// if 404 error 401 error
            return prepareError(string `Error occurred while invoking the REST API"${httpResponse.statusCode}`);
        }
    } else {
        return prepareError("Error occurred while invoking the REST API");
    }
}

# To create a custom error instance
# + return - returns error.  
function prepareError(string message, error? err = ()) returns error { 
    error azureError;
    if (err is error) {
        azureError = AzureError(message, err);
    } else {
        azureError = AzureError(message);
    }
    return azureError;
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

function mergeTwoArrays(any[] array1, any[] array2) returns any[]{
    foreach any element in array2 {
       array1.push(element);
    }
    return array1;
}

public function setIndexingHeader(http:Request req, string indexingDirectory) returns http:Request|error{
    req.setHeader("x-ms-indexing-directive",indexingDirectory);
    return req;
}

public function setUpsertHeader(http:Request req, boolean? upsert= ()) returns http:Request|error{
    req.setHeader("x-ms-documentdb-is-upsert",upsert.toString());
    return req;
}

public function setThroughputOrAutopilotHeader(http:Request req,int? throughput = (),json? option =()) returns 
http:Request|error{
    if throughput is int &&  option is () {
        //validate throughput The minimum is 400 up to 1,000,000 (or higher by requesting a limit increase).
        req.setHeader("x-ms-offer-throughput",option.toString());
    } else if throughput is () &&  option != () {
        req.setHeader("x-ms-cosmos-offer-autopilot-settings",option.toString());
    } else if throughput is int &&  option != () {
        return 
        prepareError("Cannot set both x-ms-offer-throughput and x-ms-cosmos-offer-autopilot-settings headers at once");
    }
    return req;
}

public function setPartitionKeyHeader(http:Request req, any pk) returns http:Request|error{
    req.setHeader("x-ms-documentdb-partitionkey",string `[${pk.toString()}]`);
    return req;
}

public function setHeadersforItemCount(http:Request req, int? maxitemcount = ()) returns http:Request|error{
    req.setHeader("x-ms-max-item-count",maxitemcount.toString()); 
    return req;
}

public function setHeadersForConsistancy(http:Request req, string? consistancylevel = (), string? sessiontoken = ()) 
returns http:Request|error{
    //The override must be the same or weaker than the account’s configured consistency level.
    req.setHeader("x-ms-consistency-level",consistancylevel.toString());
    //Clients must echo the latest read value of this header during read requests for session consistency.
    req.setHeader("x-ms-session-token",sessiontoken.toString());
    return req;
}

public function setHeadersForChangeFeed(http:Request req, string? aim = (), string? nonmatch = ()) returns 
http:Request|error{
    req.setHeader("A-IM",aim.toString());
    req.setHeader("If-None-Match",nonmatch.toString());
    return req;
}

public function enableCrossPartitionKeyHeader(http:Request req, boolean isignore) returns http:Request|error{
    req.setHeader("x-ms-documentdb-query-enablecrosspartition",isignore.toString());
    return req;
}

public function setHeadersForQuery(http:Request req) returns http:Request|error{
    req.setHeader("Content-Type","application/query+json");
    req.setHeader("x-ms-documentdb-isquery","True");
    return req;
}

//PartitionKeyRanges this can be used for incremental readfeed with the x-ms-documentdb-partitionkeyrangeid header.
//x-ms-documentdb-partitionkeyrangeid

//x-ms-documentdb-query-enablecrosspartition


//If-Match
//---------------

# To attach required basic headers to call REST endpoint
# + req - http:Request to add headers to
# + host - 
# + keyToken - master or resource token
# + tokenType - denotes the type of token: master or resource.
# + tokenVersion - denotes the version of the token, currently 1.0.
# + params - an object of type HeaderParamaters
# + return - If successful, returns same http:Request with newly appended headers. Else returns error.  
public function setHeaders(http:Request req, string host, string keyToken, string tokenType, string tokenVersion,
HeaderParamaters params) returns http:Request|error{
    req.setHeader("x-ms-version",params.apiVersion);
    req.setHeader("Host",host);
    req.setHeader("Accept","*/*");
    req.setHeader("Connection","keep-alive");

    string? date = check getTime();
    if date is string
    {
        string? s = generateTokenNew(params.verb,params.resourceType,params.resourceId,keyToken,tokenType,tokenVersion);
        req.setHeader("x-ms-date",date);
        if s is string {
            req.setHeader("Authorization",s);
        } else {
            io:println("token is null");
        }
    } else {
        io:println("date is null");
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
string tokenVersion) returns string?{
    var token = generateTokenJ(java:fromString(verb),java:fromString(resourceType),java:fromString(resourceId),
    java:fromString(keyToken),java:fromString(tokenType),java:fromString(tokenVersion));
    return java:toString(token);

}

# To construct the hashed token signature for a token 
# + return - If successful, returns string representing UTC date and time 
#               (in "HTTP-date" format as defined by RFC 7231 Date/Time Formats). Else returns error.  
public function getTime() returns string?|error{
    time:Time time1 = time:currentTime();
    var time2 = check time:toTimeZone(time1, "Europe/London");
    string|error timeString = time:format(time2, "EEE, dd MMM yyyy HH:mm:ss z");
    return timeString;
}

# To construct resource type  which is used to create the hashed token signature 
# + url - string parameter part of url to extract the resource type
# + return - Returns the resource type extracted from url as a string  
public function getResourceType(string url) returns string{
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
public function getResourceId(string url) returns string{
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

public function generateToken(string verb, string resourceType, string resourceId, string keys, string keyType, 
string tokenVersion, string date) returns string?|error{    
    string authorization;
    string payload = verb.toLowerAscii()+"\n" 
        +resourceType.toLowerAscii()+"\n"
        +resourceId+"\n"
        +date.toLowerAscii()+"\n"
        +""+"\n";
    var decoded = encoding:decodeBase64Url(keys);

    if decoded is byte[]
    {
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

function generateTokenJ(handle verb, handle resourceType, handle resourceId, handle keyToken, handle tokenType, 
handle tokenVersion) returns handle = @java:Method {
    name: "generate",
    'class: "com.sachini.TokenCreate"
} external;