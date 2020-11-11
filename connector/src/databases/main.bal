import ballerina/http;
import ballerina/time;
import ballerina/io;
import ballerina/crypto;
import ballerina/encoding;

public class Databases{
    
    private string baseUrl;
    public http:Client basicClient;
    http:Request authRequest;
    private string masterKey;
    private string resourceType;
    private string keyType;
    private string tokenVersion;



    function init(AuthConfig opConf){
        self.baseUrl = opConf.baseUrl;
        self.masterKey = opConf.masterKey;
        self.resourceType = "dbs";
        self.keyType = "master";
        self.tokenVersion = "1.0";

        self.basicClient = new (self.baseUrl, {
            secureSocket: {
                trustStore: {
                    path: "/usr/lib/ballerina/distributions/ballerina-slp4/bre/security/ballerinaTruststore.p12",
                    password: "ballerina"
                }
            }
        });


        self.authRequest = new;
        self.authRequest.setHeader("x-ms-version","2016-07-11");
        self.authRequest.setHeader("Host","sachinidbnewaccount.documents.azure.com:443");

    }
    //create a database
    public function createDatabase(string dbname,int? throughput,json? autoscale) returns error?|http:Response{

        string varb = "POST"; 
        //portion of the string identifies the type of resource that the request is for, Eg. "dbs", "colls", "docs".
        //portion of the string is the identity property of the resource that the request is directed at. ResourceLink must maintain its case for the ID of the resource. 
        //Example, for a collection it looks like: "dbs/MyDatabase/colls/MyCollection".
        string resourceId = "";
        string? date = check getTime();

        if date is string{
            string? s = check generateToken(varb,self.resourceType,resourceId,self.masterKey,self.keyType,self.tokenVersion,date);
            self.authRequest.setHeader("x-ms-date",date);
            if s is string{
                self.authRequest.setHeader("Authorization",s);

            }else{

                io:println("token is null");

            }
        }else{
            io:println("date is null");
        }
        
        //self.authRequest.setHeader("x-ms-offer-throughput",throughput);
        //self.authRequest.setHeader("x-ms-cosmos-offer-autopilot-settings",autoscale);
        self.authRequest.setHeader("Accept","application/json");
        self.authRequest.setHeader("Connection","keep-alive");

        //http:Response? result = new;
        //result = <http:Response>self.basicClient->get("/dbs/tempdb/colls",self.authRequest);
        json body = {
            id: dbname
        };

        self.authRequest.setJsonPayload(body);
        var result = self.basicClient->post(string `/dbs`,self.authRequest);

        return result;
        

    }

    public function listDatabases() returns error?|http:Response{

        string varb = "GET"; 
        //portion of the string identifies the type of resource that the request is for, Eg. "dbs", "colls", "docs".
        //portion of the string is the identity property of the resource that the request is directed at. ResourceLink must maintain its case for the ID of the resource. 
        //Example, for a collection it looks like: "dbs/MyDatabase/colls/MyCollection".
        string resourceId = "";
        string? date = check getTime();

        if date is string{
            string? s = check generateToken(varb,self.resourceType,resourceId,self.masterKey,self.keyType,self.tokenVersion,date);
            self.authRequest.setHeader("x-ms-date",date);
            if s is string{
                self.authRequest.setHeader("Authorization",s);

            }else{

                io:println("token is null");

            }
        }else{
            io:println("date is null");
        }
        
        //self.authRequest.setHeader("x-ms-offer-throughput",throughput);
        //self.authRequest.setHeader("x-ms-cosmos-offer-autopilot-settings",autoscale);
        self.authRequest.setHeader("Accept","application/json");
        self.authRequest.setHeader("Connection","keep-alive");

        //http:Response? result = new;
        //result = <http:Response>self.basicClient->get("/dbs/tempdb/colls",self.authRequest);
        

        var result = self.basicClient->get("/dbs",self.authRequest);

        return result;
        

    }

    public function listOneDatabase(string dbname) returns error?|http:Response{

        string varb = "GET"; 
        //portion of the string identifies the type of resource that the request is for, Eg. "dbs", "colls", "docs".
        //portion of the string is the identity property of the resource that the request is directed at. ResourceLink must maintain its case for the ID of the resource. 
        //Example, for a collection it looks like: "dbs/MyDatabase/colls/MyCollection".
        string resourceId = string `dbs/${dbname}`;
        string? date = check getTime();

        if date is string{
            string? s = check generateToken(varb,self.resourceType,resourceId,self.masterKey,self.keyType,self.tokenVersion,date);
            self.authRequest.setHeader("x-ms-date",date);
            if s is string{
                self.authRequest.setHeader("Authorization",s);

            }else{

                io:println("token is null");

            }
        }else{
            io:println("date is null");
        }
        
        //self.authRequest.setHeader("x-ms-offer-throughput",throughput);
        //self.authRequest.setHeader("x-ms-cosmos-offer-autopilot-settings",autoscale);
        self.authRequest.setHeader("Accept","application/json");
        self.authRequest.setHeader("Connection","keep-alive");

        //http:Response? result = new;
        //result = <http:Response>self.basicClient->get("/dbs/tempdb/colls",self.authRequest);
        

        var result = self.basicClient->get(string `/dbs/${dbname}`,self.authRequest);

        return result;
        

    }

    public function deleteDatabase(string dbname) returns error?|http:Response{

        string varb = "DELETE"; 
        //portion of the string identifies the type of resource that the request is for, Eg. "dbs", "colls", "docs".
        //portion of the string is the identity property of the resource that the request is directed at. ResourceLink must maintain its case for the ID of the resource. 
        //Example, for a collection it looks like: "dbs/MyDatabase/colls/MyCollection".
        string resourceId = string `dbs/${dbname}`;
        string? date = check getTime();

        if date is string{
            string? s = check generateToken(varb,self.resourceType,resourceId,self.masterKey,self.keyType,self.tokenVersion,date);
            self.authRequest.setHeader("x-ms-date",date);
            if s is string{
                self.authRequest.setHeader("Authorization",s);

            }else{

                io:println("token is null");

            }
        }else{
            io:println("date is null");
        }
        
        //self.authRequest.setHeader("x-ms-offer-throughput",throughput);
        //self.authRequest.setHeader("x-ms-cosmos-offer-autopilot-settings",autoscale);
        self.authRequest.setHeader("Accept","application/json");
        self.authRequest.setHeader("Connection","keep-alive");

        //http:Response? result = new;
        //result = <http:Response>self.basicClient->get("/dbs/tempdb/colls",self.authRequest);
        

        var result = self.basicClient->delete(string `/dbs/${dbname}`,self.authRequest);

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


public type AuthConfig record {
    string baseUrl;    
    string masterKey;
};