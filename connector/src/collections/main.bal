import ballerina/http;
import ballerina/time;
import ballerina/io;
import ballerina/crypto;
import ballerina/encoding;

public class Collections{

    public string baseUrl;
    public http:Client basicClient;
    http:Request authRequest;



    function init(AuthConfig opConf){
        self.baseUrl = opConf.baseUrl;

        self.basicClient = new (self.baseUrl, {
            secureSocket: {
                trustStore: {
                    path: "/usr/lib/ballerina/distributions/ballerina-slp4/bre/security/ballerinaTruststore.p12",
                    password: "ballerina"
                }
            }
        });


        self.authRequest = new;
       // self.authRequest.setHeader("Authorization",string `type%3Dmaster%26ver%3D1.0%26sig%3DuyiPReVbJCggOlc8JIdxwvdJo8NlhPeQV5BHV5tgt0U%3D`);
        self.authRequest.setHeader("x-ms-version","2016-07-11");
        self.authRequest.setHeader("User-Agent","PostmanRuntime/7.26.8");
        self.authRequest.setHeader("Host","sachinidbnewaccount.documents.azure.com:443");




    }


    public function getCollection() returns error?|http:Response{

        //io:println(timeString);
        time:Time time = time:currentTime();
        string timeString = check time:format(time, time:TIME_FORMAT_RFC_1123);
        
        self.authRequest.setHeader("Accept","application/json");
        self.authRequest.setHeader("x-ms-date",timeString);
        self.authRequest.setHeader("Connection","keep-alive");
        self.authRequest.setHeader("Accept-Encoding","gzip, deflate, br");
        //self.authRequest.setHeader("Cache-Control","no-cache");

        
        io:print(self.authRequest);

        http:Response? result = new;
        result = <http:Response>self.basicClient->get("/dbs/tempdb/colls",self.authRequest);

        //io:println(result);

        return result;


    }

}


public function generateToken(string verb, string resourceType, string resourceId, string keys, string keyType, string tokenVersion, string date) returns string?|error{
        
    string authorization;

    string payload = verb.toLowerAscii()+"\n" 
        +resourceType.toLowerAscii()+"\n"
        +resourceId+"\n"
        +date.toLowerAscii()+"\n"
        +""+"\n";


    var decoded = encoding:decodeBase64Url(keys);
    io:println("1.",decoded);
        
    if decoded is byte[]{

        byte[] k = crypto:hmacSha256(payload.toBytes(),decoded);
        string  t = k.toBase16();

        io:println("2.",k);


        string signature = encoding:encodeBase64Url(k);

        io:println("3.",signature);


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




public type AuthConfig record {
    string baseUrl;    
};
