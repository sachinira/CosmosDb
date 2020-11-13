import ballerina/java;
import ballerina/time;
import ballerina/io;
import ballerina/crypto;
import ballerina/encoding;
import ballerina/http;


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

function getDeleteResponse(http:Response|http:ClientError httpResponse) returns @tainted string|error{

    if (httpResponse is http:Response) {

        if(httpResponse.statusCode == http:STATUS_NO_CONTENT){
                return string `Deleted Sucessfully ${httpResponse.statusCode}`;
        }else{
            return prepareError(string `Error occurred while invoking the REST API"${httpResponse.statusCode}`);

        }

    }else{
        return prepareError("Error occurred while invoking the REST API");

    }
}

function prepareError(string message, error? err = ()) returns error {
    error azureError;
    if (err is error) {
        azureError = AzureError(message, err);
    } else {
        azureError = AzureError(message);
    }
    return azureError;
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
    return -1;
}

public function generateToken(string verb, string resourceType, string resourceId, string keys, string keyType, string tokenVersion, string date) returns string?|error{
        
    string authorization;

    string payload = verb.toLowerAscii()+"\n" 
        +resourceType.toLowerAscii()+"\n"
        +resourceId+"\n"
        +date.toLowerAscii()+"\n"
        +""+"\n";


    var decoded = encoding:decodeBase64Url(keys);
        
    if decoded is byte[]{

        byte[] k = crypto:hmacSha256(payload.toBytes(),decoded);
        string  t = k.toBase16();

        string signature = encoding:encodeBase64Url(k);

        authorization = check encoding:encodeUriComponent(string `type=${keyType}&ver=${tokenVersion}&sig=${signature}=`, "UTF-8");
            
        return authorization;

    }else{
            
        io:println("Decoding error");
    }

}

public function getTime() returns string?|error{

    time:Time time1 = time:currentTime();
    var time2 = check time:toTimeZone(time1, "Europe/London");

    string|error timeString = time:format(time2, "EEE, dd MMM yyyy HH:mm:ss z");
    return timeString;
}


public function setHeaders(http:Request req,string apiversion,string host,string verb, string resourceType, string resourceId, string keys, string keyType, string tokenVersion) returns http:Request|error{

    req.setHeader("x-ms-version",apiversion);
    req.setHeader("Host",host);
    req.setHeader("Accept","application/json");
    req.setHeader("Connection","keep-alive");

    string? date = check getTime();

    //var uuid = createRandomUUID();
 
    //io:println(uuid);
    
    if date is string{
            //string? s = check generateToken(verb,resourceType,resourceId,keys,keyType,tokenVersion,date);

            string? s = generateTokenNew(verb,resourceType,resourceId,keys,keyType,tokenVersion);

            req.setHeader("x-ms-date",date);
            if s is string{
                req.setHeader("Authorization",s);

            }else{

                io:println("token is null");

            }
        }else{
            io:println("date is null");
        }

    return req;
}

public function generateTokenNew(string verb, string resourceType, string resourceId, string keys, string keyType, string tokenVersion) returns string?{
    var token = generateTokenJ(java:fromString(verb),java:fromString(resourceType),java:fromString(resourceId),java:fromString(keys),java:fromString(keyType),java:fromString(tokenVersion));
    return java:toString(token);

}

function generateTokenJ(handle verb, handle resourceType, handle resourceId, handle keys, handle keyType, handle tokenVersion) returns handle = @java:Method {
    name: "generate",
    'class: "com.sachini.TokenCreate"
} external;