import ballerina/http;
import ballerina/io;

public  client class Databases{
    
    public string baseUrl;
    public string masterKey;
    public string host;
    public string apiVersion;
    
    public http:Client basicClient;

    private string resourceTypedb;
    private string resourceTypecoll;
    private string resourceTypedoc;

    private string keyType;
    private string tokenVersion;



    function init(AuthConfig opConf){
        self.baseUrl = opConf.baseUrl;
        self.masterKey = opConf.masterKey;
        self.host = opConf.host;
        self.apiVersion = opConf.apiVersion;

        self.resourceTypedb = "dbs";
        self.resourceTypecoll= "colls";
        self.resourceTypedoc = "docs";

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
    public remote function createDatabase(string dbname,int? throughput,json? autoscale) returns @tainted Database|error{


        http:Request req = new;

        string verb = "POST"; 
        string resourceId = "";
        string requestPath = string `/dbs`;

        req = check setHeaders(req,self.apiVersion,self.host,verb,self.resourceTypedb,resourceId,self.masterKey,self.keyType,self.tokenVersion);
        req = check setThroughputOrAutopilotHeader(req,throughput,autoscale);

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
       
        req = check setHeaders(req,self.apiVersion,self.host,verb,self.resourceTypedb,resourceId,self.masterKey,self.keyType,self.tokenVersion);

        var response = self.basicClient->get("/dbs",req);

        json jsonresponse = check parseResponseToJson(response);

        return mapJsonToDbList(jsonresponse);
        
    }

    public remote function listOneDatabase(string dbname) returns @tainted Database|error{

        http:Request req = new;

        string verb = "GET"; 
        string resourceId = string `dbs/${dbname}`;
       
        req = check setHeaders(req,self.apiVersion,self.host,verb,self.resourceTypedb,resourceId,self.masterKey,self.keyType,self.tokenVersion);

        var response = self.basicClient->get(string `/dbs/${dbname}`,req);

        json jsonresponse = check parseResponseToJson(response);

        return mapJsonToDatabaseType(jsonresponse);
        
    }

    public remote function deleteDatabase(string dbname) returns @tainted string|error{

        http:Request req = new;

        string verb = "DELETE"; 
        string resourceId = string `dbs/${dbname}`;
        
        req = check setHeaders(req,self.apiVersion,self.host,verb,self.resourceTypedb,resourceId,self.masterKey,self.keyType,self.tokenVersion);

        var response = self.basicClient->delete(string `/dbs/${dbname}`,req);

        return check getDeleteResponse(response);
    }

    //Autoscaling policy and the throughput policices are same as the collections they must be implemented  

    //*********************************************

    //Collections

    public remote function createCollection(string dbname,string colname,json partitionkey,json? indexingpolicy,int? throughput,json? autoscale) returns @tainted Collection|error{

        http:Request req = new;

        string verb = "POST"; 
        string resourceId = string `dbs/${dbname}`;

        req = check setHeaders(req,self.apiVersion,self.host,verb,self.resourceTypecoll,resourceId,self.masterKey,self.keyType,self.tokenVersion);
        req = check setThroughputOrAutopilotHeader(req,throughput,autoscale);


        json body = {
            "id": colname,
            "partitionKey": partitionkey
        };

        json finalc = check body.mergeJson(indexingpolicy);

        req.setJsonPayload(finalc);

        var response = self.basicClient->post(string `/dbs/${dbname}/colls`,req);

        json jsonresponse = check parseResponseToJson(response);


        return mapJsonToCollectionType(jsonresponse);
    }


    public remote function getAllCollections(string dbname) returns @tainted CollectionList|error{


        http:Request req = new;

        string verb = "GET"; 
        string resourceId = string `dbs/${dbname}`;

        req = check setHeaders(req,self.apiVersion,self.host,verb,self.resourceTypecoll,resourceId,self.masterKey,self.keyType,self.tokenVersion);


        var response = self.basicClient->get(string `/dbs/${dbname}/colls`,req);

        json jsonresponse = check parseResponseToJson(response);

        return mapJsonToCollectionListType(jsonresponse);
    }

    public remote function getOneCollection(string dbname,string colname) returns @tainted Collection|error{


        http:Request req = new;

        string verb = "GET"; 
        string resourceId = string `dbs/${dbname}/colls/${colname}`;

        req = check setHeaders(req,self.apiVersion,self.host,verb,self.resourceTypecoll,resourceId,self.masterKey,self.keyType,self.tokenVersion);


        var response = self.basicClient->get(string `/dbs/${dbname}/colls/${colname}`,req);

        json jsonresponse = check parseResponseToJson(response);

        return mapJsonToCollectionType(jsonresponse);
    }

    public remote function deleteCollection(string dbname,string colname) returns @tainted string|error{

        http:Request req = new;

        string verb = "DELETE"; 
        string resourceId = string `dbs/${dbname}/colls/${colname}`;

        req = check setHeaders(req,self.apiVersion,self.host,verb,self.resourceTypecoll,resourceId,self.masterKey,self.keyType,self.tokenVersion);


        var response = self.basicClient->delete(string `/dbs/${dbname}/colls/${colname}`,req);

        
        return check getDeleteResponse(response);
    }

    public remote function getPartitionKeyRanges(string dbname,string colname) returns @tainted PartitionKeyList|error{

        http:Request req = new;

        string verb = "GET"; 
        string reType = "pkranges";
        string resourceId = string `dbs/${dbname}/colls/${colname}`;
        
        req = check setHeaders(req,self.apiVersion,self.host,verb,reType,resourceId,self.masterKey,self.keyType,self.tokenVersion);

        var response = self.basicClient->get(string `/dbs/${dbname}/colls/${colname}/pkranges`,req);


        json jsonresponse = check parseResponseToJson(response);

        return mapJsonToPartitionKeyType(jsonresponse);
    }

        //Replace Collection supports changing the indexing policy of a collection after creation.


    public remote function createDocument(string dbname,string colname,json document,boolean? upsert,string? indexingdir,json partitionkey) returns @tainted Document|error{
        
        http:Request req = new;

        string verb = "POST"; 
        string resourceId = string `dbs/${dbname}/colls/${colname}`;
        
        req = check setHeaders(req,self.apiVersion,self.host,verb,self.resourceTypedoc,resourceId,self.masterKey,self.keyType,self.tokenVersion);
        req = check setPartitionKeyHeader(req,partitionkey);

        if indexingdir is string {
            req = check setIndexingHeader(req,indexingdir);
        }
       
        if upsert == true {
            req = check setUpsertHeader(req,upsert);
        }


        req.setJsonPayload(document);
        var response = self.basicClient->post(string `/dbs/${dbname}/colls/${colname}/docs`,req);

        json jsonresponse = check parseResponseToJson(response);

        
        return mapJsonToDocument(jsonresponse);
    }

    public remote function listAllDocuments(string dbname,string colname,int? itemcount) returns @tainted DocumentList|error{
        
        http:Request req = new;

        string verb = "GET"; 
        string resourceId = string `dbs/${dbname}/colls/${colname}`;
        
        req = check setHeaders(req,self.apiVersion,self.host,verb,self.resourceTypedoc,resourceId,self.masterKey,self.keyType,self.tokenVersion);

        if itemcount is int{
            req = check setHeadersforItemCount(req,itemcount);
        }

        var response = self.basicClient->get(string `/dbs/${dbname}/colls/${colname}/docs`,req);

        json jsonresponse = check parseResponseToJson(response);
        DocumentList l =  check mapJsonToDocumentList(jsonresponse); 


        if response is http:Response && response.hasHeader("x-ms-continuation") {

            //if there is continuation header

             //createRequestAgain(response,req,dbname,colname,l);
        }


        return l;    
    }

    public remote function createRequestAgain(http:Response resp, http:Request req,string dbname,string colname, DocumentList list1) returns @tainted DocumentList|error{

        DocumentList newd = {};

        string verb = "GET"; 
        string resourceId = string `dbs/${dbname}/colls/${colname}`;
        
        var reqn = check setHeaders(req,self.apiVersion,self.host,verb,self.resourceTypedoc,resourceId,self.masterKey,self.keyType,self.tokenVersion);

        reqn.setHeader("x-ms-continuation",resp.getHeader("x-ms-continuation"));

        var response2 = self.basicClient->get(string `/dbs/${dbname}/colls/${colname}/docs`,reqn);

        json jsonresponse2 = check parseResponseToJson(response2);
        DocumentList list2 =  check mapJsonToDocumentList(jsonresponse2);

        Document[] l = <Document[]>mergeTwoArrays(list1.documents,list2.documents);
        int count = list2._count + list1._count;

        newd.documents = l;
        newd._count =count;

        return newd;

    }

    public remote function listOneDocument(string dbname,string colname,string id,any partitionkey) returns @tainted Document|error{
        
        http:Request req = new;

        string verb = "GET"; 
        string resourceId = string `dbs/${dbname}/colls/${colname}/docs/${id}`;
        
        req = check setHeaders(req,self.apiVersion,self.host,verb,self.resourceTypedoc,resourceId,self.masterKey,self.keyType,self.tokenVersion);
        req = check setPartitionKeyHeader(req,partitionkey);


        var response = self.basicClient->get(string `/dbs/${dbname}/colls/${colname}/docs/${id}`,req);

        json jsonresponse = check parseResponseToJson(response);

        
        return mapJsonToDocument(jsonresponse);
    }

    public remote function replaceDocument(string dbname,string colname,json document,string docid,any partitionkeyvalue) returns @tainted Document|error{
        

        //x-ms-indexing-directive
        
        http:Request req = new;

        string verb = "PUT"; 
        string resourceId = string `dbs/${dbname}/colls/${colname}/docs/${docid}`;
        
        req = check setHeaders(req,self.apiVersion,self.host,verb,self.resourceTypedoc,resourceId,self.masterKey,self.keyType,self.tokenVersion);
        req = check setPartitionKeyHeader(req,partitionkeyvalue);

        req.setJsonPayload(document);

        var response = self.basicClient->put(string `/dbs/${dbname}/colls/${colname}/docs/${docid}`,req);

        json jsonresponse = check parseResponseToJson(response);

        
        return mapJsonToDocument(jsonresponse);
    }

    public remote function deleteDocument(string dbname,string colname,string docid,any partitionkeyvalue) returns @tainted string|error{
        
        http:Request req = new;

        string verb = "DELETE"; 
        string resourceId = string `dbs/${dbname}/colls/${colname}/docs/${docid}`;
        
        req = check setHeaders(req,self.apiVersion,self.host,verb,self.resourceTypedoc,resourceId,self.masterKey,self.keyType,self.tokenVersion);
        req = check setPartitionKeyHeader(req,partitionkeyvalue);


        var response = self.basicClient->delete(string `/dbs/${dbname}/colls/${colname}/docs/${docid}`,req);
        
        return getDeleteResponse(response);
    }


    public remote function queryDocument(string dbname,string colname,json query,any partitionkeyvalue) returns @tainted json|error{
        
        http:Request req = new;

        string verb = "POST"; 
        string resourceId = string `dbs/${dbname}/colls/${colname}`;

        req = check setHeadersForQuery(req);
        req = check setHeaders(req,self.apiVersion,self.host,verb,self.resourceTypedoc,resourceId,self.masterKey,self.keyType,self.tokenVersion);
        req = check setPartitionKeyHeader(req,partitionkeyvalue);

        req.setJsonPayload(query);

        var response = self.basicClient->post(string `/dbs/${dbname}/colls/${colname}/docs`,req);

        json jsonresponse = check parseResponseToJson(response);

                io:println(jsonresponse);

        return (jsonresponse);
    }

}

public type AuthConfig record {
    string baseUrl;    
    string masterKey;
    string host;
    string apiVersion;
};