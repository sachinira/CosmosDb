import ballerina/http;
import ballerina/time;
import ballerina/io;

public class Collection{

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
        self.authRequest.setHeader("x-ms-version","2015-12-16");
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

public function main(){

    AuthConfig config = {
        baseUrl: "https://sachinidbnewaccount.documents.azure.com:443/"
    };

    Collection openMapClient = new(config);
    
    var t = openMapClient.getCollection();


    if t is http:Response{
       if (t.statusCode == http:STATUS_OK) {

            json payload = <json>t.getJsonPayload();
            //json lat = <json>payload.coord.lat;
            io:println(payload);

            } else {
            error err = error("error occurred while sending GET request");
            io:println(err.message(),", status code: ", t.statusCode,", reason: ", t.getTextPayload());

            io:println(err);

        }

    }else{
        io:println(t);

    }

}



public type AuthConfig record {
    string baseUrl;    
};
