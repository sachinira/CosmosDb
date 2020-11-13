import ballerina/http;

public  client class Databases{
    
    public string baseUrl;
    public string masterKey;
    public string host;
    public string apiVersion;
    
    public http:Client basicClient;

    private string resourceType;
    private string keyType;
    private string tokenVersion;



    function init(AuthConfig opConf){
        self.baseUrl = opConf.baseUrl;
        self.masterKey = opConf.masterKey;
        self.host = opConf.host;
        self.apiVersion = opConf.apiVersion;

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


    }

    //Create a database
    public remote function createDatabase(string dbname,string? throughput,json? autoscale) returns @tainted Database|error{

        //Autoscaling policy and the throughput policices are same as the collections they must be implemented  

        http:Request req = new;

        string verb = "POST"; 
        string resourceId = "";
        string requestPath = string `/dbs`;

        req = check setHeaders(req,self.apiVersion,self.host,verb,self.resourceType,resourceId,self.masterKey,self.keyType,self.tokenVersion);

        //self.authRequest.setHeader("x-ms-offer-throughput",throughput);
        //self.authRequest.setHeader("x-ms-cosmos-offer-autopilot-settings",autoscale);
        

        json body = {
            id: dbname
        };

        req.setJsonPayload(body);

        var response = self.basicClient->post(requestPath,req);

        json jsonreponse = check parseResponseToJson(response);

        return mapJsonToDatabaseType(jsonreponse);
        
    }

    public remote function listDatabases() returns @tainted DBList|error{

        http:Request req = new;

        string verb = "GET"; 
        string resourceId = "";
       
        req = check setHeaders(req,self.apiVersion,self.host,verb,self.resourceType,resourceId,self.masterKey,self.keyType,self.tokenVersion);

        var response = self.basicClient->get("/dbs",req);

        json jsonresponse = check parseResponseToJson(response);

        return mapJsonToDbList(jsonresponse);
        
    }

    public remote function listOneDatabase(string dbname) returns @tainted Database|error{

        http:Request req = new;

        string verb = "GET"; 
        string resourceId = string `dbs/${dbname}`;
       
        req = check setHeaders(req,self.apiVersion,self.host,verb,self.resourceType,resourceId,self.masterKey,self.keyType,self.tokenVersion);

        var response = self.basicClient->get(string `/dbs/${dbname}`,req);

        json jsonresponse = check parseResponseToJson(response);

        return mapJsonToDatabaseType(jsonresponse);
        
    }

    public remote function deleteDatabase(string dbname) returns @tainted json|error{

        http:Request req = new;

        string verb = "DELETE"; 
        string resourceId = string `dbs/${dbname}`;
        
        req = check setHeaders(req,self.apiVersion,self.host,verb,self.resourceType,resourceId,self.masterKey,self.keyType,self.tokenVersion);

        var response = self.basicClient->delete(string `/dbs/${dbname}`,req);

        json jsonresponse = check parseResponseToJson(response);

        return jsonresponse;
    }


    //*********************************************

    //Collections

    public remote function createCollection(string dbname,string colname,json? indexingpolicy,json partitionkey,string? throughput) returns @tainted error?|http:Response{

        http:Request req = new;

        string verb = "POST"; 
        string resourceId = string `dbs/${dbname}`;

        req = check setHeaders(req,self.apiVersion,self.host,verb,self.resourceType,resourceId,self.masterKey,self.keyType,self.tokenVersion);


        json body = {
            "id": colname,
            "partitionKey": partitionkey
        };

        json finalc = check body.mergeJson(indexingpolicy);


        req.setJsonPayload(finalc);

        var response = self.basicClient->post(string `/dbs/${dbname}/colls`,req);

        json jsonresponse = check parseResponseToJson(response);


        return response;
    }
}

public type AuthConfig record {
    string baseUrl;    
    string masterKey;
    string host;
    string apiVersion;
};