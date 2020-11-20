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
    # + throughputProperties - Optional throughput parameter which will set 'x-ms-offer-throughput' header 
    # + return - If successful, returns Database. Else returns error.  
    public remote function createDatabase(string dbName, ThroughputProperties? throughputProperties = ()) returns 
    @tainted Database|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES]);
        HeaderParamaters header = mapParametersToHeaderType(POST,requestPath);
        json body = {
            id: dbName
        };

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req = check setThroughputOrAutopilotHeader(req,throughputProperties);
        req.setJsonPayload(body);
        var response = self.azureCosmosClient->post(requestPath,req);
        json jsonreponse = check parseResponseToJson(response);
        return mapJsonToDatabaseType(jsonreponse);   
    }

    # To list all databases inside a resource
    # + return - If successful, returns DBList. Else returns error.  
    public remote function getAllDatabases() returns @tainted DBList|error{
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
    public remote function getDatabase(string dbName) returns @tainted Database|error{
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
    # + properties - object of type ContainerProperties
    # + indexingPolicy - Optional json object to configure indexing policy. By default, the indexing is automatic 
    # for all document paths within the collection.
    # + throughputProperties - Optional throughput parameter which will set 'x-ms-offer-throughput' header 
    # + return - If successful, returns Collection. Else returns error.  
    public remote function createContainer(@tainted ContainerProperties properties, json? indexingPolicy = (), 
    ThroughputProperties? throughputProperties = ()) returns @tainted Collection|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,<string>properties.dbName,RESOURCE_PATH_COLLECTIONS]);
        HeaderParamaters header = mapParametersToHeaderType(POST,requestPath);
        json body = {
            "id": properties.colName,
            "partitionKey": properties.partitionKey
        };
        json finalc = check body.mergeJson(indexingPolicy);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req = check setThroughputOrAutopilotHeader(req,throughputProperties);
        req.setJsonPayload(<@untainted>finalc);
        var response = self.azureCosmosClient->post(requestPath,req);
        json jsonresponse = check parseResponseToJson(response);
        return mapJsonToCollectionType(jsonresponse);
    }

    # To retrive  all collections inside a database
    # + dbName -  id/name of the database collections are in.
    # + return - If successful, returns CollectionList. Else returns error.  
    public remote function getAllContainers(string dbName) returns @tainted CollectionList|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,dbName,RESOURCE_PATH_COLLECTIONS]);
        HeaderParamaters header = mapParametersToHeaderType(GET,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        var response = self.azureCosmosClient->get(requestPath,req);
        json jsonresponse = check parseResponseToJson(response);
        return mapJsonToCollectionListType(jsonresponse);
    }

    # To retrive  one collection inside a database
    # + properties - object of type ContainerProperties
    # + return - If successful, returns Collection. Else returns error.  
    public remote function getContainer(@tainted ContainerProperties properties) returns @tainted Collection|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.dbName,RESOURCE_PATH_COLLECTIONS,properties.colName]);
        HeaderParamaters header = mapParametersToHeaderType(GET,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        var response = self.azureCosmosClient->get(requestPath,req);
        json jsonresponse = check parseResponseToJson(response);
        return mapJsonToCollectionType(jsonresponse);
    }

    # To delete one collection inside a database
    # + properties - object of type ContainerProperties
    # + return - If successful, returns string specifying delete is sucessfull. Else returns error.   
    public remote function deleteContainer(@tainted ContainerProperties properties) returns @tainted string|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.dbName,RESOURCE_PATH_COLLECTIONS,properties.colName]);
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
    # + properties - object of type ContainerProperties
    # + document - Any json content that will include as the document.
    # + isUpsert - Optional boolean value to specify if this request is updating an existing document 
    #               (If set to true, Cosmos DB creates the document with the ID (and partition key value if applicable) 
    #               if it doesn’t exist, or update the document if it exists.)
    # + indexingDir - Optional indexing directive parameter which will set 'x-ms-indexing-directive' header
    #                   The acceptable value is Include or Exclude. 
    #                   -Include adds the document to the index.
    #                   -Exclude omits the document from indexing.
    # + return - If successful, returns Document. Else returns error.  
    public remote function createDocument(@tainted DocumentProperties properties,json document,boolean? isUpsert = (), 
    string? indexingDir = ()) returns @tainted Document|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.dbName,RESOURCE_PATH_COLLECTIONS,properties.colName,
        RESOURCE_PATH_DOCUMENTS]);
        HeaderParamaters header = mapParametersToHeaderType(POST,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req = check setPartitionKeyHeader(req,properties.partitionKey);
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
    # + properties - object of type ContainerProperties
    # + itemcount - Optional integer number of documents to be listed in document list (Default is 100)
    # + return - If successful, returns DocumentList. Else returns error. 
    public remote function getDocumentList(@tainted DocumentProperties properties, int? itemcount = ()) returns 
    @tainted DocumentList|DocumentListIterable|error{ 
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.dbName,RESOURCE_PATH_COLLECTIONS,
        properties.colName,RESOURCE_PATH_DOCUMENTS]);
        HeaderParamaters header = mapParametersToHeaderType(GET,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        if itemcount is int{
            req = check setHeadersforItemCount(req,itemcount);
        }
        var response = self.azureCosmosClient->get(requestPath,req);
        json jsonresponse = check parseResponseToJson(response);
        if response is http:Response{
            var continuation = getHeaderIfExist(response,"x-ms-continuation");
            if response.hasHeader("x-ms-continuation") {
                DocumentListIterable list =  check mapJsonToDocumentListIterable(jsonresponse); 
                return list;    
            }
        }
        DocumentList list =  check mapJsonToDocumentList(jsonresponse); 
        return list;    
    }

    #A function to handle 'x-ms-continuation' header value which is used for pagination
    # + properties - object of type ContainerProperties
    # + continuationToken - The continuation token returned from previous document request
    # + itemcount - Optional integer number of documents to be listed in document list (Default is 100)
    # + return - 
    public remote function documentListGetNextPage(@tainted DocumentProperties properties,string continuationToken, 
    int? itemcount = ()) returns @tainted DocumentList|DocumentListIterable|error{

        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.dbName,RESOURCE_PATH_COLLECTIONS,properties.colName,
        RESOURCE_PATH_DOCUMENTS]);
        HeaderParamaters header = mapParametersToHeaderType(GET,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req.setHeader("x-ms-continuation",continuationToken);
        if itemcount is int{
            req = check setHeadersforItemCount(req,itemcount);
        }
        var response = self.azureCosmosClient->get(requestPath,req);
        json jsonresponse = check parseResponseToJson(response);
        if response is http:Response{
            var continuation = getHeaderIfExist(response,"x-ms-continuation");
            if response.hasHeader("x-ms-continuation") {
                DocumentListIterable list =  check mapJsonToDocumentListIterable(jsonresponse); 
                return list;    
            }
        }
        DocumentList list =  check mapJsonToDocumentList(jsonresponse); 
        return list;  
        
    }

    #To list one document inside a collection
    # ********x-ms-consistency-level, x-ms-session-token and If-None-Match headers are not handled******
    # + properties - the value in the partition key field specified for the collection to 
    # set x-ms-documentdb-partitionkey header
    # + return - If successful, returns a Document. Else returns error. 
    public remote function getDocument(@tainted DocumentProperties properties) returns 
    @tainted Document|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.dbName,RESOURCE_PATH_COLLECTIONS,properties.colName,
        RESOURCE_PATH_DOCUMENTS,<string>properties.documentId]);
        HeaderParamaters header = mapParametersToHeaderType(GET,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req = check setPartitionKeyHeader(req,properties.partitionKey);
        var response = self.azureCosmosClient->get(requestPath,req);
        json jsonresponse = check parseResponseToJson(response);
        return mapJsonToDocument(jsonresponse);
    }

    #To replace a document inside a collection
    # *******x-ms-indexing-directive and If-Match headers are not handled******
    # + properties - object of type ContainerProperties
    # + document - json object for replacing the existing document
    # set x-ms-documentdb-partitionkey header
    # + return - If successful, returns a Document. Else returns error. 
    public remote function replaceDocument(@tainted DocumentProperties properties, json document) 
    returns @tainted Document|error{         
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.dbName,RESOURCE_PATH_COLLECTIONS,properties.colName,
        RESOURCE_PATH_DOCUMENTS,<string>properties.documentId]);
        HeaderParamaters header = mapParametersToHeaderType(PUT,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req = check setPartitionKeyHeader(req,properties.partitionKey);
        req.setJsonPayload(document);
        var response = self.azureCosmosClient->put(requestPath,req);
        json jsonresponse = check parseResponseToJson(response);
        return mapJsonToDocument(jsonresponse);
    }

    #To delete a document inside a collection
    # + properties - object of type ContainerProperties
    # set x-ms-documentdb-partitionkey header
    # + return - If successful, returns a string giving sucessfully deleted. Else returns error. 
    public remote function deleteDocument(@tainted DocumentProperties properties) returns 
    @tainted string|error{  
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.dbName,RESOURCE_PATH_COLLECTIONS,properties.colName,
        RESOURCE_PATH_DOCUMENTS,<string>properties.documentId]);
        HeaderParamaters header = mapParametersToHeaderType(DELETE,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req = check setPartitionKeyHeader(req,properties.partitionKey);
        var response = self.azureCosmosClient->delete(requestPath,req);
        return getDeleteResponse(response);
    }

    #To query documents inside a collection
    # *********Function does not work properly, x-ms-max-item-count header is not handled*********
    # + properties - object of type ContainerProperties
    # + sqlQuery - json object containing the sql query
    # set x-ms-documentdb-partitionkey header
    # + return - If successful, returns a json. Else returns error. 
    public remote function queryDocument(@tainted DocumentProperties properties, json sqlQuery) returns 
    @tainted json|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.dbName,RESOURCE_PATH_COLLECTIONS,properties.colName,
        RESOURCE_PATH_DOCUMENTS]);
        HeaderParamaters header = mapParametersToHeaderType(POST,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req = check setHeadersForQuery(req);
        req = check setPartitionKeyHeader(req,properties.partitionKey);
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