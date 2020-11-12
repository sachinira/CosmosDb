import ballerina/http;
import ballerina/time;
import ballerina/io;
import ballerina/crypto;
import ballerina/encoding;

public class Collections{

    public string baseUrl;
    public http:Client basicClient;
    http:Request authRequest;
    private string apiKey;
    private string resourceType;
    private string keyType;
    private string tokenVersion;


    function init(AuthConfig opConf){
        self.baseUrl = opConf.baseUrl;
        self.apiKey = opConf.masterKey;
        self.resourceType = "colls";
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
        self.authRequest.setHeader("x-ms-version","2018-12-31");
        self.authRequest.setHeader("Host","sachinidbnewaccount.documents.azure.com:443");

    }


    //create a collection
    public function createCollection(string dbname,string colname,json? indexingpolicy,json partitionkey,string? throughput) returns error?|http:Response{

        string varb = "POST"; 
        //portion of the string identifies the type of resource that the request is for, Eg. "dbs", "colls", "docs".
        //portion of the string is the identity property of the resource that the request is directed at. ResourceLink must maintain its case for the ID of the resource. 
        //Example, for a collection it looks like: "dbs/MyDatabase/colls/MyCollection".
        string resourceId = string `dbs/${dbname}`;
        string? date = check getTime();

         if date is string{
            string? s = check generateToken(varb,self.resourceType,resourceId,self.apiKey,self.keyType,self.tokenVersion,date);
            self.authRequest.setHeader("x-ms-date",date);
            if s is string{
                self.authRequest.setHeader("Authorization",s);

            }else{

                io:println("token is null");
                            //return the error


            }
        }else{
            io:println("date is null");
                        //return the error

        }
        
        if throughput is string{
            self.authRequest.setHeader("x-ms-offer-throughput",throughput);
        } 
       
        self.authRequest.setHeader("Accept","application/json");
        self.authRequest.setHeader("Connection","keep-alive");

        //http:Response? result = new;
        //result = <http:Response>self.basicClient->get("/dbs/tempdb/colls",self.authRequest);
        json body = {
            id: colname,
            partitionKey: partitionkey
        };


        self.authRequest.setJsonPayload(body);
        var result = self.basicClient->post(string `/dbs/${dbname}/colls`,self.authRequest);

        return result;
        
    }

    //public function createCollectionWithIndexingPolicy(string dbname,string colname,json? indexingpolicy,json partitionkey,string? throughput) returns error?|http:Response{

    public function createCollectionWithAutoscale(string dbname,string colname,json? indexingpolicy,json partitionkey,json autoscale) returns error?|http:Response{

        string varb = "POST"; 
        //portion of the string identifies the type of resource that the request is for, Eg. "dbs", "colls", "docs".
        //portion of the string is the identity property of the resource that the request is directed at. ResourceLink must maintain its case for the ID of the resource. 
        //Example, for a collection it looks like: "dbs/MyDatabase/colls/MyCollection".
        string resourceId = string `dbs/${dbname}`;
        string? date = check getTime();

         if date is string{
            string? s = check generateToken(varb,self.resourceType,resourceId,self.apiKey,self.keyType,self.tokenVersion,date);
            self.authRequest.setHeader("x-ms-date",date);
            if s is string{
                self.authRequest.setHeader("Authorization",s);

            }else{

                io:println("token is null");
                            //return the error


            }
        }else{
            io:println("date is null");
                        //return the error

        }

        self.authRequest.setHeader("x-ms-cosmos-offer-autopilot-settings",autoscale.toString());
        self.authRequest.setHeader("Accept","application/json");
        self.authRequest.setHeader("Connection","keep-alive");

        //http:Response? result = new;
        //result = <http:Response>self.basicClient->get("/dbs/tempdb/colls",self.authRequest);
        json body = {
            "id": colname,
            "partitionKey": partitionkey
        };

        self.authRequest.setJsonPayload(body);
        var result = self.basicClient->post(string `/dbs/${dbname}/colls`,self.authRequest);

        return result;
        
    }

    //List Collections returns an array of collections within the specified database.
    public function getAllCollections(string dbname) returns error?|http:Response{

        string varb = "GET"; 
        string resourceId = string `dbs/${dbname}`;
        string? date = check getTime();

        if date is string{
            string? s = check generateToken(varb,self.resourceType,resourceId,self.apiKey,self.keyType,self.tokenVersion,date);
            self.authRequest.setHeader("x-ms-date",date);
            if s is string{
                self.authRequest.setHeader("Authorization",s);

            }else{

                io:println("token is null");

            }
        }else{
            io:println("date is null");
        }
        
        self.authRequest.setHeader("Accept","application/json");
        self.authRequest.setHeader("Connection","keep-alive");

        //http:Response? result = new;
        //result = <http:Response>self.basicClient->get("/dbs/tempdb/colls",self.authRequest);

        var result = self.basicClient->get(string `/dbs/${dbname}/colls`,self.authRequest);


        return result;
    }

    public function getOneCollection(string dbname,string colname) returns error?|http:Response{

        string varb = "GET"; 
        string resourceId = string `dbs/${dbname}/colls/${colname}`;
        string? date = check getTime();

        self.authRequest.setHeader("Accept","application/json");
        self.authRequest.setHeader("Connection","keep-alive");

        if date is string{
            string? s = check generateToken(varb,self.resourceType,resourceId,self.apiKey,self.keyType,self.tokenVersion,date);
            self.authRequest.setHeader("x-ms-date",date);
            if s is string{
                self.authRequest.setHeader("Authorization",s);

            }else{

                io:println("token is null");

            }
        }else{
            io:println("date is null");
        }

        //http:Response? result = new;
        //result = <http:Response>self.basicClient->get("/dbs/tempdb/colls",self.authRequest);

        var result = self.basicClient->get(string `/dbs/${dbname}/colls/${colname}`,self.authRequest);

        return result;
    }

    public function deleteCollection(string dbname,string colname) returns error?|http:Response{

        string varb = "DELETE"; 
        string resourceId = string `dbs/${dbname}/colls/${colname}`;
        string? date = check getTime();

        self.authRequest.setHeader("Accept","application/json");
        self.authRequest.setHeader("Connection","keep-alive");

        if date is string{
            string? s = check generateToken(varb,self.resourceType,resourceId,self.apiKey,self.keyType,self.tokenVersion,date);
            self.authRequest.setHeader("x-ms-date",date);
            if s is string{
                self.authRequest.setHeader("Authorization",s);

            }else{

                io:println("token is null");

            }
        }else{
            io:println("date is null");
        }

        //http:Response? result = new;
        //result = <http:Response>self.basicClient->get("/dbs/tempdb/colls",self.authRequest);

        var result = self.basicClient->delete(string `/dbs/${dbname}/colls/${colname}`,self.authRequest);


        return result;
    }


    //Replace Collection supports changing the indexing policy of a collection after creation.
    public function ReplaceCollection(string dbname,string colname,json? indexingPol,json? partitionKey) returns error?|http:Response{

        string varb = "PUT"; 
        string resourceId = string `dbs/${dbname}/colls/${colname}`;
        string? date = check getTime();

        self.authRequest.setHeader("Accept","application/json");
        self.authRequest.setHeader("Connection","keep-alive");

        if date is string{
            string? s = check generateToken(varb,self.resourceType,resourceId,self.apiKey,self.keyType,self.tokenVersion,date);
            self.authRequest.setHeader("x-ms-date",date);
            if s is string{
                self.authRequest.setHeader("Authorization",s);

            }else{

                io:println("token is null");

            }
        }else{
            io:println("date is null");
        }

        json body = {
            id: colname,
            partitionKey:"",
            indexingPolicy: indexingPol
        };
        //http:Response? result = new;
        //result = <http:Response>self.basicClient->get("/dbs/tempdb/colls",self.authRequest);

        self.authRequest.setJsonPayload(body);
        var result = self.basicClient->put(string `/dbs/${dbname}/colls/${colname}`,self.authRequest);


        return result;
    }

    public function getPKRanges(string dbname,string colname) returns error?|http:Response{

        string varb = "GET"; 
        string reType = "pkranges";
        string resourceId = string `dbs/${dbname}/colls/${colname}`;
        string? date = check getTime();

        self.authRequest.setHeader("Accept","application/json");
        self.authRequest.setHeader("Connection","keep-alive");

        if date is string{
            string? s = check generateToken(varb,reType,resourceId,self.apiKey,self.keyType,self.tokenVersion,date);
            self.authRequest.setHeader("x-ms-date",date);
            if s is string{
                self.authRequest.setHeader("Authorization",s);

            }else{

                io:println("token is null");

            }
        }else{
            io:println("date is null");
        }

        //http:Response? result = new;
        //result = <http:Response>self.basicClient->get("/dbs/tempdb/colls",self.authRequest);

        var result = self.basicClient->get(string `/dbs/${dbname}/colls/${colname}/pkranges`,self.authRequest);

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
