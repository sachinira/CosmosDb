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
        self.authRequest.setHeader("x-ms-version","2016-07-11");
        self.authRequest.setHeader("User-Agent","PostmanRuntime/7.26.8");
        self.authRequest.setHeader("Host","sachinidbnewaccount.documents.azure.com:443");

    }


    //create a collection
    public function createCollection(string dbname,string colname,int? throughput,json? autoscale) returns error?|http:Response{

        string varb = "POST"; 
        //portion of the string identifies the type of resource that the request is for, Eg. "dbs", "colls", "docs".
        string resourceType = "colls";
        //portion of the string is the identity property of the resource that the request is directed at. ResourceLink must maintain its case for the ID of the resource. 
        //Example, for a collection it looks like: "dbs/MyDatabase/colls/MyCollection".
        string resourceId = string `dbs/${dbname}`;
        string keystring = "n2whnJ4vAsQ2KVXORsKakNsOqs6uvDkLJvETLt4K7AVzj2t06w8CxZ8JRoK984xq6kHtesfJ7KncIf9nqJr1lQ==";
        string keyType = "master";
        string tokenVersion = "1.0";
        string? date = check getTime();

         if date is string{
            string? s = check generateToken(varb,resourceType,resourceId,keystring,keyType,tokenVersion,date);
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
        self.authRequest.setHeader("Accept-Encoding","gzip, deflate, br");

        //http:Response? result = new;
        //result = <http:Response>self.basicClient->get("/dbs/tempdb/colls",self.authRequest);
        json body = {
            id: colname
        };

        self.authRequest.setJsonPayload(body);
        var result = self.basicClient->post(string `/dbs/${dbname}/colls`,self.authRequest);

        return result;
        
    }


    //List Collections returns an array of collections within the specified database.
    public function getAllCollections(string dbname) returns error?|http:Response{

        string varb = "GET"; 
        string resourceType = "colls";
        string resourceId = string `dbs/${dbname}`;
        string keystring = "n2whnJ4vAsQ2KVXORsKakNsOqs6uvDkLJvETLt4K7AVzj2t06w8CxZ8JRoK984xq6kHtesfJ7KncIf9nqJr1lQ==";
        string keyType = "master";
        string tokenVersion = "1.0";
        string? date = check getTime();

        if date is string{
            string? s = check generateToken(varb,resourceType,resourceId,keystring,keyType,tokenVersion,date);
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
        self.authRequest.setHeader("Accept-Encoding","gzip, deflate, br");

        //http:Response? result = new;
        //result = <http:Response>self.basicClient->get("/dbs/tempdb/colls",self.authRequest);

        var result = self.basicClient->get(string `/dbs/${dbname}/colls`,self.authRequest);


        return result;
    }

    public function getOneCollection(string dbname,string colname) returns error?|http:Response{

        string varb = "GET"; 
        string resourceType = "colls";
        string resourceId = string `dbs/${dbname}/colls/${colname}`;
        string keystring = "n2whnJ4vAsQ2KVXORsKakNsOqs6uvDkLJvETLt4K7AVzj2t06w8CxZ8JRoK984xq6kHtesfJ7KncIf9nqJr1lQ==";
        string keyType = "master";
        string tokenVersion = "1.0";
        string? date = check getTime();

        self.authRequest.setHeader("Accept","application/json");
        self.authRequest.setHeader("Connection","keep-alive");
        self.authRequest.setHeader("Accept-Encoding","gzip, deflate, br");

        if date is string{
            string? s = check generateToken(varb,resourceType,resourceId,keystring,keyType,tokenVersion,date);
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
        string resourceType = "colls";
        string resourceId = string `dbs/${dbname}/colls/${colname}`;
        string keystring = "n2whnJ4vAsQ2KVXORsKakNsOqs6uvDkLJvETLt4K7AVzj2t06w8CxZ8JRoK984xq6kHtesfJ7KncIf9nqJr1lQ==";
        string keyType = "master";
        string tokenVersion = "1.0";
        string? date = check getTime();

        self.authRequest.setHeader("Accept","application/json");
        self.authRequest.setHeader("Connection","keep-alive");
        self.authRequest.setHeader("Accept-Encoding","gzip, deflate, br");

        if date is string{
            string? s = check generateToken(varb,resourceType,resourceId,keystring,keyType,tokenVersion,date);
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
        string resourceType = "colls";
        string resourceId = string `dbs/${dbname}/colls/${colname}`;
        string keystring = "n2whnJ4vAsQ2KVXORsKakNsOqs6uvDkLJvETLt4K7AVzj2t06w8CxZ8JRoK984xq6kHtesfJ7KncIf9nqJr1lQ==";
        string keyType = "master";
        string tokenVersion = "1.0";
        string? date = check getTime();

        self.authRequest.setHeader("Accept","application/json");
        self.authRequest.setHeader("Connection","keep-alive");
        self.authRequest.setHeader("Accept-Encoding","gzip, deflate, br");

        if date is string{
            string? s = check generateToken(varb,resourceType,resourceId,keystring,keyType,tokenVersion,date);
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
        string resourceType = "colls";
        string resourceId = string `dbs/${dbname}/colls/${colname}/pkranges`;
        string keystring = "n2whnJ4vAsQ2KVXORsKakNsOqs6uvDkLJvETLt4K7AVzj2t06w8CxZ8JRoK984xq6kHtesfJ7KncIf9nqJr1lQ==";
        string keyType = "master";
        string tokenVersion = "1.0";
        string? date = check getTime();

        self.authRequest.setHeader("Accept","application/json");
        self.authRequest.setHeader("Connection","keep-alive");
        self.authRequest.setHeader("Accept-Encoding","gzip, deflate, br");

        if date is string{
            string? s = check generateToken(varb,resourceType,resourceId,keystring,keyType,tokenVersion,date);
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
};
