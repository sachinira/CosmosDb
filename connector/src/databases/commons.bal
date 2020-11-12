import ballerina/time;
import ballerina/io;
import ballerina/crypto;
import ballerina/encoding;
import ballerina/http;
//import ballerina/java;

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
            string? s = check generateToken(verb,resourceType,resourceId,keys,keyType,tokenVersion,date);


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

