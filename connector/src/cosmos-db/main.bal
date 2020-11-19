import ballerina/http;

# Azure Cosmos DB Client object.
# + azureCosmosClient - The HTTP Client
public  client class Client {
    
    private string baseUrl;
    private string masterKey;
    private string host;
    private string keyType;
    private string tokenVersion;

    public http:Client azureCosmosClient;

    function init(AzureCosmosConfiguration azureConfig){
        self.baseUrl = azureConfig.baseUrl;
        self.masterKey = azureConfig.masterKey;
        self.host = azureConfig.host;
        self.keyType = azureConfig.tokenType;
        self.tokenVersion = azureConfig.tokenVersion;

        self.azureCosmosClient = new (self.baseUrl, {
            secureSocket: {
                trustStore: {
                    path: "/usr/lib/ballerina/distributions/ballerina-slp4/bre/security/ballerinaTruststore.p12",
                    password: "ballerina"
                }
            }
        });
    }

    # To create a database inside a resource
    # + dbName -  id/name for the database
    # + throughput - Optional throughput parameter which will set 'x-ms-offer-throughput' header 
    # + autoscale - Optional throughput parameter which will set 'x-ms-cosmos-offer-autopilot-settings' header
    # + return - If successful, returns Database. Else returns error.  
    public remote function createDatabase(string dbName, int? throughput = (), json? autoscale = ()) returns 
    @tainted Database|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES]);
        HeaderParamaters header = mapParametersToHeaderType(POST,requestPath);
        json body = {
            id: dbName
        };

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req = check setThroughputOrAutopilotHeader(req,throughput,autoscale);
        req.setJsonPayload(body);
        var response = self.azureCosmosClient->post(requestPath,req);
        json jsonreponse = check parseResponseToJson(response);
        return mapJsonToDatabaseType(jsonreponse);   
    }

    # To list all databases inside a resource
    # + return - If successful, returns DBList. Else returns error.  
    public remote function listDatabases() returns @tainted DBList|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES]);
        HeaderParamaters header = mapParametersToHeaderType(GET,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        var response = self.azureCosmosClient->get(requestPath,req);
        json jsonresponse = check parseResponseToJson(response);
        return mapJsonToDbList(jsonresponse); 
    }

    # To retrive a given database inside a resource
    # + dbName -  id/name of the database to retrieve
    # + return - If successful, returns Database. Else returns error.  
    public remote function listOneDatabase(string dbName) returns @tainted Database|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,dbName]);
        HeaderParamaters header = mapParametersToHeaderType(GET,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        var response = self.azureCosmosClient->get(requestPath,req);
        json jsonresponse = check parseResponseToJson(response);
        return mapJsonToDatabaseType(jsonresponse);  
    }

    # To retrive a given database inside a resource
    # + dbName -  id/name of the database to retrieve
    # + return - If successful, returns string specifying delete is sucessfull. Else returns error.  
    public remote function deleteDatabase(string dbName) returns @tainted string|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,dbName]);
        HeaderParamaters header = mapParametersToHeaderType(DELETE,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        var response = self.azureCosmosClient->delete(requestPath,req);
        return check getDeleteResponse(response);
    }

    # To create a collection inside a database
    # + dbName -  id/name for the database
    # + colName - id/name for collection
    # + partitionKey - json object for specifying properties of partition key. If the REST API version is 
    # 2018-12-31 or higher, 
    #                   the collection must include a partitionKey definition.
    # + indexingPolicy - Optional json object to configure indexing policy. By default, the indexing is automatic 
    # for all document paths within the collection.
    # + throughput - Optional throughput parameter which will set 'x-ms-offer-throughput' header 
    # + autoscale - Optional throughput parameter which will set 'x-ms-cosmos-offer-autopilot-settings' header
    # + return - If successful, returns Collection. Else returns error.  
    public remote function createCollection(string dbName, string colName, json partitionKey, json? indexingPolicy = (), 
    int? throughput = (),json? autoscale = ()) returns @tainted Collection|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,dbName,RESOURCE_PATH_COLLECTIONS]);
        HeaderParamaters header = mapParametersToHeaderType(POST,requestPath);
        json body = {
            "id": colName,
            "partitionKey": partitionKey
        };
        json finalc = check body.mergeJson(indexingPolicy);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req = check setThroughputOrAutopilotHeader(req,throughput,autoscale);
        req.setJsonPayload(finalc);
        var response = self.azureCosmosClient->post(requestPath,req);
        json jsonresponse = check parseResponseToJson(response);
        return mapJsonToCollectionType(jsonresponse);
    }

    # To retrive  all collections inside a database
    # + dbName -  id/name of the database collections are in.
    # + return - If successful, returns CollectionList. Else returns error.  
    public remote function getAllCollections(string dbName) returns @tainted CollectionList|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,dbName,RESOURCE_PATH_COLLECTIONS]);
        HeaderParamaters header = mapParametersToHeaderType(GET,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        var response = self.azureCosmosClient->get(requestPath,req);
        json jsonresponse = check parseResponseToJson(response);
        return mapJsonToCollectionListType(jsonresponse);
    }

    # To retrive  one collection inside a database
    # + dbName -  id/name of the database which collection is in.
    # + colName - id/name of collection to retrive.
    # + return - If successful, returns Collection. Else returns error.  
    public remote function getOneCollection(string dbName,string colName) returns @tainted Collection|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,dbName,RESOURCE_PATH_COLLECTIONS,colName]);
        HeaderParamaters header = mapParametersToHeaderType(GET,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        var response = self.azureCosmosClient->get(requestPath,req);
        json jsonresponse = check parseResponseToJson(response);
        return mapJsonToCollectionType(jsonresponse);
    }

    # To delete one collection inside a database
    # + dbName -  id/name of the database which collection is in.
    # + colName - id/name of collection to delete.
    # + return - If successful, returns string specifying delete is sucessfull. Else returns error.   
    public remote function deleteCollection(string dbName, string colName) returns @tainted string|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,dbName,RESOURCE_PATH_COLLECTIONS,colName]);
        HeaderParamaters header = mapParametersToHeaderType(DELETE,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        var response = self.azureCosmosClient->delete(requestPath,req);
        return check getDeleteResponse(response);
    }

    # To retrieve a list of partition key ranges for the collection
    # + dbName -  id/name of the database which collection is in.
    # + colName - id/name of collection to where partition key range is in.
    # + return - If successful, returns PartitionKeyList. Else returns error.  
    public remote function getPartitionKeyRanges(string dbName, string colName) returns @tainted PartitionKeyList|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,dbName,RESOURCE_PATH_COLLECTIONS,colName,
        RESOURCE_PATH_PK_RANGES]);
        HeaderParamaters header = mapParametersToHeaderType(GET,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        var response = self.azureCosmosClient->get(requestPath,req);
        json jsonresponse = check parseResponseToJson(response);
        return mapJsonToPartitionKeyType(jsonresponse);
    }

    //Replace Collection supports changing the indexing policy of a collection after creation. must be implemented here


    # To create a Document inside a collection
    # + dbName -  id/name for the database
    # + colName - id/name for collection
    # + partitionKey -  value for the partition key field specified for the collection  to set 
    # x-ms-documentdb-partitionkey header.
    # + document - Any json content that will include as the document.
    # + isUpsert - Optional boolean value to specify if this request is updating an existing document 
    #               (If set to true, Cosmos DB creates the document with the ID (and partition key value if applicable) 
    #               if it doesn’t exist, or update the document if it exists.)
    # + indexingDir - Optional indexing directive parameter which will set 'x-ms-indexing-directive' header
    #                   The acceptable value is Include or Exclude. 
    #                   -Include adds the document to the index.
    #                   -Exclude omits the document from indexing.
    # + return - If successful, returns Document. Else returns error.  
    public remote function createDocument(string dbName, string colName, json document,any partitionKey, 
    boolean? isUpsert = (), string? indexingDir = ()) returns @tainted Document|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,dbName,RESOURCE_PATH_COLLECTIONS,colName,
        RESOURCE_PATH_DOCUMENTS]);
        HeaderParamaters header = mapParametersToHeaderType(POST,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req = check setPartitionKeyHeader(req,partitionKey);
        if indexingDir is string {
            req = check setIndexingHeader(req,indexingDir);
        }
        if isUpsert == true {
            req = check setUpsertHeader(req,isUpsert);
        }
        req.setJsonPayload(document);
        var response = self.azureCosmosClient->post(requestPath,req);
        json jsonresponse = check parseResponseToJson(response);
        return mapJsonToDocument(jsonresponse);
    }

    
    #To list all the documents inside a collection
    # x-ms-consistency-level, x-ms-session-token, A-IM, x-ms-continuation and If-None-Match headers are not handled**
    # + dbName -  id/name of the database which collection is in.
    # + colName - id/name of collection which documents are in.
    # + itemcount - Optional integer number of documents to be listed in document list (Default is 100)
    # + return - If successful, returns DocumentList. Else returns error. 
    public remote function listAllDocuments(string dbName, string colName, int? itemcount = ()) returns 
    @tainted DocumentList|error{ 
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,dbName,RESOURCE_PATH_COLLECTIONS,colName,
        RESOURCE_PATH_DOCUMENTS]);
        HeaderParamaters header = mapParametersToHeaderType(GET,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        if itemcount is int{
            req = check setHeadersforItemCount(req,itemcount);
        }
        var response = self.azureCosmosClient->get(requestPath,req);
        json jsonresponse = check parseResponseToJson(response);
        DocumentList list =  check mapJsonToDocumentList(jsonresponse); 
        return list;    
    }

    #A partially implemented function to handle 'x-ms-continuation' header value which is used for pagination
    # + dbName -  id/name of the database which collection is in.
    # + colName - id/name of collection to retrive.
    # + resp -
    # + req -
    # + list1 - 
    # + return - 
    public remote function createRequestAgain(http:Response resp, http:Request req, string dbName, string colName, 
    DocumentList list1) returns @tainted DocumentList|error{
        //if response is http:Response && response.hasHeader("x-ms-continuation") {

            //if there is continuation header

             //createRequestAgain(response,req,dbname,colname,l);
        //}
        
        DocumentList newd = {};
        string verb = "GET"; 
        string resourceId = string `dbs/${dbName}/colls/${colName}`;
        
        //var reqn = check setHeaders(req,self.apiVersion,self.host,verb,self.resourceTypedoc,resourceId,self.masterKey,
        //self.keyType,self.tokenVersion);
        //reqn.setHeader("x-ms-continuation",resp.getHeader("x-ms-continuation"));
        //var response2 = self.azureCosmosClient->get(string `/dbs/${dbName}/colls/${colName}/docs`,reqn);

        //json jsonresponse2 = check parseResponseToJson(response2);
        //DocumentList list2 =  check mapJsonToDocumentList(jsonresponse2);

        //Document[] l = <Document[]>mergeTwoArrays(list1.documents,list2.documents);
        //int count = list2._count + list1._count;

        //newd.documents = l;
        //newd._count =count;

        return newd;
    }

    #To list one document inside a collection
    # ********x-ms-consistency-level, x-ms-session-token and If-None-Match headers are not handled******
    # + dbName -  id/name of the database which collection is in.
    # + colName - id/name of collection which documents are in.
    # + documentId - id of the document to be retrieved
    # + partitionKey - the value in the partition key field specified for the collection to 
    # set x-ms-documentdb-partitionkey header
    # + return - If successful, returns a Document. Else returns error. 
    public remote function listOneDocument(string dbName, string colName, string documentId, any partitionKey) returns 
    @tainted Document|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,dbName,RESOURCE_PATH_COLLECTIONS,colName,
        RESOURCE_PATH_DOCUMENTS,documentId]);
        HeaderParamaters header = mapParametersToHeaderType(GET,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req = check setPartitionKeyHeader(req,partitionKey);
        var response = self.azureCosmosClient->get(requestPath,req);
        json jsonresponse = check parseResponseToJson(response);
        return mapJsonToDocument(jsonresponse);
    }

    #To replace a document inside a collection
    # *******x-ms-indexing-directive and If-Match headers are not handled******
    # + dbName -  id/name of the database which collection is in.
    # + colName - id/name of collection which document is in.
    # + document - json object for replacing the existing document
    # + documentId - id of the document to be replaced
    # + partitionKey - the value in the partition key field specified for the collection to 
    # set x-ms-documentdb-partitionkey header
    # + return - If successful, returns a Document. Else returns error. 
    public remote function replaceDocument(string dbName, string colName, json document, string documentId, 
    any partitionKey) returns @tainted Document|error{         
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,dbName,RESOURCE_PATH_COLLECTIONS,colName,
        RESOURCE_PATH_DOCUMENTS,documentId]);
        HeaderParamaters header = mapParametersToHeaderType(PUT,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req = check setPartitionKeyHeader(req,partitionKey);
        req.setJsonPayload(document);
        var response = self.azureCosmosClient->put(requestPath,req);
        json jsonresponse = check parseResponseToJson(response);
        return mapJsonToDocument(jsonresponse);
    }

    #To delete a document inside a collection
    # + dbName -  id/name of the database which collection is in.
    # + colName - id/name of collection which document is in.
    # + documentId - id of the document to be deleted
    # + partitionKey - the value in the partition key field specified for the collection to 
    # set x-ms-documentdb-partitionkey header
    # + return - If successful, returns a string giving sucessfully deleted. Else returns error. 
    public remote function deleteDocument(string dbName, string colName, string documentId, any partitionKey) returns 
    @tainted string|error{  
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,dbName,RESOURCE_PATH_COLLECTIONS,colName,
        RESOURCE_PATH_DOCUMENTS,documentId]);
        HeaderParamaters header = mapParametersToHeaderType(DELETE,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req = check setPartitionKeyHeader(req,partitionKey);
        var response = self.azureCosmosClient->delete(requestPath,req);
        return getDeleteResponse(response);
    }

    #To query documents inside a collection
    # *********Function does not work properly, x-ms-max-item-count header is not handled*********
    # + dbName -  id/name of the database which collection is in.
    # + colName - id/name of collection which document is in.
    # + sqlQuery - json object containing the sql query
    # + partitionKey - the value in the partition key field specified for the collection to 
    # set x-ms-documentdb-partitionkey header
    # + return - If successful, returns a json. Else returns error. 
    public remote function queryDocument(string dbName, string colName, json sqlQuery, any partitionKey) returns 
    @tainted json|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,dbName,RESOURCE_PATH_COLLECTIONS,colName,
        RESOURCE_PATH_DOCUMENTS]);
        HeaderParamaters header = mapParametersToHeaderType(POST,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req = check setHeadersForQuery(req);
        req = check setPartitionKeyHeader(req,partitionKey);
        req.setJsonPayload(sqlQuery);
        var response = self.azureCosmosClient->post(requestPath,req);
        json jsonresponse = check parseResponseToJson(response);
        return (jsonresponse);
    }

    #To create a new stored procedure inside a collection
    # A stored procedure is a piece of application logic written in JavaScript that 
    # is registered and executed against a collection as a single transaction.
    # + dbName -  id/name of the database which collection is in.
    # + colName - id/name of collection which stored procedure is in.
    # + sproc - 
    # + sprocId -
    # + return - If successful, returns a StoredProcedure. Else returns error. 
    public remote function createStoredProcedure(string dbName, string colName, string sproc, string sprocId) returns 
    @tainted StoredProcedure|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,dbName,RESOURCE_PATH_COLLECTIONS,colName,
        RESOURCE_PATH_STORED_POCEDURES]);
        HeaderParamaters header = mapParametersToHeaderType(POST,requestPath);
        json spbody = {
            id: sprocId,
            body:sproc
        };

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req.setJsonPayload(spbody);
        var response = self.azureCosmosClient->post(requestPath,req);
        json jsonreponse = check parseResponseToJson(response);
        return mapJsonToSproc(jsonreponse);    
    }

    #To replace a stored procedure with new one inside a collection
    # + dbName -  id/name of the database which collection is in.
    # + colName - id/name of collection which stored procedure is in.
    # + storedProcedure - 
    # + sprocId - 
    # + return - If successful, returns a StoredProcedure. Else returns error. 
    public remote function replaceStoredProcedure(string dbName, string colName, string storedProcedure, string sprocId) 
    returns @tainted StoredProcedure|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,dbName,RESOURCE_PATH_COLLECTIONS,colName,
        RESOURCE_PATH_STORED_POCEDURES,sprocId]);
        HeaderParamaters header = mapParametersToHeaderType(PUT,requestPath);
        json spbody = <@untainted> {
            id: sprocId,
            body:storedProcedure
        };

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req.setJsonPayload(spbody);
        var response = self.azureCosmosClient->put(requestPath,req);
        json jsonreponse = check parseResponseToJson(response);
        return mapJsonToSproc(jsonreponse);  
    }

    #To list all stored procedures inside a collection
    # + dbName -  id/name of the database which collection is in.
    # + colName - id/name of collection which stored procedures are in.
    # + return - If successful, returns a StoredProcedureList. Else returns error. 
    public remote function listStoredProcedures(string dbName, string colName) returns 
    @tainted StoredProcedureList|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,dbName,RESOURCE_PATH_COLLECTIONS,colName,
        RESOURCE_PATH_STORED_POCEDURES]);
        HeaderParamaters header = mapParametersToHeaderType(GET,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        var response = self.azureCosmosClient->get(requestPath,req);
        json jsonreponse = check parseResponseToJson(response);
        return mapJsonToSprocList(jsonreponse);  
    }

    #To delete a stored procedure inside a collection
    # + dbName -  id/name of the database which collection is in.
    # + colName - id/name of collection which stored procedure is in.
    # + sprocId - id of the stored procedure to be deleted
    # + return - If successful, returns string specifying delete is sucessfull. Else returns error. 
    public remote function deleteStoredProcedure(string dbName, string colName, string sprocId) returns 
    @tainted json|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,dbName,RESOURCE_PATH_COLLECTIONS,colName,RESOURCE_PATH_STORED_POCEDURES,sprocId]);
        HeaderParamaters header = mapParametersToHeaderType(DELETE,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        var response = self.azureCosmosClient->delete(requestPath,req);
        return getDeleteResponse(response);   
    }

    #To execute a stored procedure inside a collection
    # ***********function only works correctly for string parameters************
    # + dbName -  id/name of the database which collection is in.
    # + colName - id/name of collection which stored procedure is in.
    # + sprocId - id of the stored procedure to be executed
    # + parameters - The list of paramaters to pass to javascript function as an array.
    # + return - If successful, returns json with the output from the executed funxtion. Else returns error. 
    public remote function executeStoredProcedure(string dbName, string colName, string sprocId, any[]? parameters) 
    returns @tainted json|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,dbName,RESOURCE_PATH_COLLECTIONS,colName,RESOURCE_PATH_STORED_POCEDURES,sprocId]);
        HeaderParamaters header = mapParametersToHeaderType(POST,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req.setTextPayload(parameters.toString());
        var response = self.azureCosmosClient->post(requestPath,req);
        json jsonreponse = check parseResponseToJson(response);
        return jsonreponse;   
    }

}

public type AzureCosmosConfiguration record {|
    string baseUrl;    
    string masterKey;
    string host;
    string tokenType;
    string tokenVersion;
|};