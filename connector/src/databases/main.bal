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


        //Autoscaling policy and the throughput policices are same as the collections        

    }
    //create a database
    public remote function createDatabase(string dbname,string? throughput,json? autoscale) returns @tainted Database|error{

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

        return mapJsonToDatabase(jsonreponse);
        

    }

    public remote function listDatabases() returns error?|http:Response{

        http:Request req = new;

        string verb = "GET"; 
        string resourceId = "";
       
        req = check setHeaders(req,self.apiVersion,self.host,verb,self.resourceType,resourceId,self.masterKey,self.keyType,self.tokenVersion);


        var result = self.basicClient->get("/dbs",req);

        return result;
        

    }

    public remote function listOneDatabase(string dbname) returns error?|http:Response{

        http:Request req = new;

        string verb = "GET"; 
        string resourceId = string `dbs/${dbname}`;
       
        req = check setHeaders(req,self.apiVersion,self.host,verb,self.resourceType,resourceId,self.masterKey,self.keyType,self.tokenVersion);


        var result = self.basicClient->get(string `/dbs/${dbname}`,req);

        return result;
        

    }

    public remote function deleteDatabase(string dbname) returns error?|http:Response{

        http:Request req = new;

        string verb = "DELETE"; 
        string resourceId = string `dbs/${dbname}`;
        
        req = check setHeaders(req,self.apiVersion,self.host,verb,self.resourceType,resourceId,self.masterKey,self.keyType,self.tokenVersion);


        var result = self.basicClient->delete(string `/dbs/${dbname}`,req);

        return result;
    }
}


 




public type AuthConfig record {
    string baseUrl;    
    string masterKey;
    string host;
    string apiVersion;
};