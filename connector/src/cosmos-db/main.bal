import ballerina/http;
import ballerina/io;
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
        http:ClientConfiguration httpClientConfig = {secureSocket: azureConfig.secureSocketConfig};
        self.azureCosmosClient = new (self.baseUrl,httpClientConfig);
    }

    # To create a database inside a resource
    # + databaseId -  id/name for the database
    # + throughputProperties - Optional throughput parameter which will set 'x-ms-offer-throughput' header 
    # + return - If successful, returns Database. Else returns error.  
    public remote function createDatabase(string databaseId, ThroughputProperties? throughputProperties = ()) returns 
    @tainted Database|error{
        json jsonPayload;
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES]);
        HeaderParamaters header = mapParametersToHeaderType(POST,requestPath);
        json body = {
            id:databaseId
        };
        req.setJsonPayload(body);
        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req = check setThroughputOrAutopilotHeader(req,throughputProperties);
        var response = self.azureCosmosClient->post(requestPath,req);
        [json,Headers] jsonreponse = check parseResponseToTuple(response);
        return mapJsonToDatabaseType(jsonreponse);   
    }

    # To create a database inside a resource
    # + databaseId -  id/name for the database
    # + throughputProperties - Optional throughput parameter which will set 'x-ms-offer-throughput' header 
    # + return - If successful, returns Database. Else returns error.  
    public remote function createDatabaseIfNotExist(string databaseId, ThroughputProperties? throughputProperties = ()) 
    returns @tainted Database?|error{
        var result = self->getDatabase(databaseId);
        if result is error{
            return self->createDatabase(databaseId,throughputProperties);
        }
        return ();  
    }

    # To retrive a given database inside a resource
    # + databaseId -  id/name of the database to retrieve
    # + return - If successful, returns Database. Else returns error.  
    public remote function getDatabase(string databaseId) returns @tainted Database|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,databaseId]);
        HeaderParamaters header = mapParametersToHeaderType(GET,requestPath);
        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        var response = self.azureCosmosClient->get(requestPath,req);
        [json,Headers] jsonreponse = check parseResponseToTuple(response);
        return mapJsonToDatabaseType(jsonreponse);  
    }

    # To list all databases inside a resource
    # + return - If successful, returns DatabaseList. Else returns error.  
    public remote function getAllDatabases() returns @tainted DatabaseList|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES]);
        HeaderParamaters header = mapParametersToHeaderType(GET,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        var response = self.azureCosmosClient->get(requestPath,req);
        [json,Headers] jsonresponse = check parseResponseToTuple(response);
        return mapJsonToDbList(jsonresponse); 
    }

    # To retrive a given database inside a resource
    # + databaseId -  id/name of the database to retrieve
    # + return - If successful, returns DeleteResponse specifying delete is sucessfull. Else returns error.  
    public remote function deleteDatabase(string databaseId) returns @tainted boolean|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,databaseId]);
        HeaderParamaters header = mapParametersToHeaderType(DELETE,requestPath);
        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        var response = self.azureCosmosClient->delete(requestPath,req);
        return check getDeleteResponse(response);
    }

    # To create a collection inside a database
    # + properties - object of type ContainerProperties
    # + partitionKey - 
    # + indexingPolicy -
    # + throughputProperties - Optional throughput parameter which will set 'x-ms-offer-throughput' header 
    # + return - If successful, returns Container. Else returns error.  
    public remote function createContainer(@tainted ResourceProperties properties,PartitionKey partitionKey,
    IndexingPolicy? indexingPolicy = (), ThroughputProperties? throughputProperties = ()) returns @tainted Container|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_COLLECTIONS]);
        HeaderParamaters header = mapParametersToHeaderType(POST,requestPath);
        
        json body = {
            "id": properties.containerId,
            "partitionKey": <json>partitionKey.cloneWithType(json)
        };
        json finalc = check body.mergeJson(<json>indexingPolicy.cloneWithType(json));
        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req = check setThroughputOrAutopilotHeader(req,throughputProperties);
        req.setJsonPayload(<@untainted>finalc);
        var response = self.azureCosmosClient->post(requestPath,req);
        [json,Headers] jsonreponse = check parseResponseToTuple(response);
        return mapJsonToCollectionType(jsonreponse);
    }

    # To create a database inside a resource
    # + properties -  object of type ContainerProperties
    # + partitionKey - 
    # + indexingPolicy -
    # + throughputProperties - Optional throughput parameter which will set 'x-ms-offer-throughput' header 
    # + return - If successful, returns Database. Else returns error.  
    public remote function createContainerIfNotExist(@tainted ResourceProperties properties,PartitionKey partitionKey,
    IndexingPolicy? indexingPolicy = (), ThroughputProperties? throughputProperties = ()) returns @tainted Container?|error{
        var result = self->getContainer(properties);
        if result is error{
            return self->createContainer(properties,partitionKey);
        } else {
            return prepareError("The collection with specific id alrady exist");
        }
    }

    // # To create a collection inside a database
    // # + properties - object of type ContainerProperties
    // # + throughputProperties - Optional throughput parameter which will set 'x-ms-offer-throughput' header 
    // # + return - If successful, returns Container. Else returns error. 
    // public remote function replaceProvisionedThroughput(@tainted ContainerProperties properties, ThroughputProperties 
    // throughputProperties) returns @tainted Container|error {
    //     return self->createContainer(properties,throughputProperties);
    // }

    # To retrive  all collections inside a database
    # + databaseId -  id/name of the database collections are in.
    # + return - If successful, returns ContainerList. Else returns error.  
    public remote function getAllContainers(string databaseId) returns @tainted ContainerList|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,databaseId,RESOURCE_PATH_COLLECTIONS]);
        HeaderParamaters header = mapParametersToHeaderType(GET,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        var response = self.azureCosmosClient->get(requestPath,req);
        [json,Headers] jsonreponse = check parseResponseToTuple(response);
        return mapJsonToCollectionListType(jsonreponse);
    }

    # To retrive  one collection inside a database
    # + properties - object of type ContainerProperties
    # + return - If successful, returns Container. Else returns error.  
    public remote function getContainer(@tainted ResourceProperties properties) returns @tainted Container|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_COLLECTIONS,
        properties.containerId]);
        HeaderParamaters header = mapParametersToHeaderType(GET,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        var response = self.azureCosmosClient->get(requestPath,req);
        [json,Headers] jsonreponse = check parseResponseToTuple(response);
        return mapJsonToCollectionType(jsonreponse);
    }

    # To delete one collection inside a database
    # + properties - object of type ContainerProperties
    # + return - If successful, returns DeleteResponse specifying delete is sucessfull. Else returns error.   
    public remote function deleteContainer(@tainted ResourceProperties properties) returns @tainted json|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_COLLECTIONS,
        properties.containerId]);
        HeaderParamaters header = mapParametersToHeaderType(DELETE,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        var response = self.azureCosmosClient->delete(requestPath,req);
        return check getDeleteResponse(response);
    }

    # To retrieve a list of partition key ranges for the collection
    # + databaseId -  id/name of the database which collection is in.
    # + collectionId - id/name of collection to where partition key range is in.
    # + return - If successful, returns PartitionKeyList. Else returns error.  
    public remote function getPartitionKeyRanges(string databaseId, string collectionId) returns @tainted 
    PartitionKeyList|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,databaseId,RESOURCE_PATH_COLLECTIONS,collectionId,
        RESOURCE_PATH_PK_RANGES]);
        HeaderParamaters header = mapParametersToHeaderType(GET,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        var response = self.azureCosmosClient->get(requestPath,req);
        [json,Headers] jsonreponse = check parseResponseToTuple(response);
        return mapJsonToPartitionKeyType(jsonreponse);
    }

    //Replace Collection supports changing the indexing policy of a collection after creation. must be implemented here

    # To create a Document inside a collection
    # + properties - object of type DocumentProperties
    # + document - Any json content that will include as the document.
    # + requestOptions - object of type RequestHeaderOptions
    # + return - If successful, returns Document. Else returns error.  
    public remote function createDocument(@tainted ResourceProperties properties,Document document,
    RequestHeaderOptions? requestOptions) returns @tainted Document|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_COLLECTIONS,
        properties.containerId,RESOURCE_PATH_DOCUMENTS]);
        HeaderParamaters header = mapParametersToHeaderType(POST,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req = check setPartitionKeyHeader(req,document.partitionKey);
        if requestOptions is RequestHeaderOptions{
            req = check setRequestOptions(req,requestOptions);
        }
        json requestBodyId = {
            id: document.id
        };  
        json Final = check requestBodyId.mergeJson(document.documentBody);     
        req.setJsonPayload(Final);
        var response = self.azureCosmosClient->post(requestPath,req);
        [json,Headers] jsonreponse = check parseResponseToTuple(response);
        return mapJsonToDocument(jsonreponse);
    }

    #To list one document inside a collection
    # x-ms-consistency-level, x-ms-session-token and If-None-Match headers are supported
    # + properties - object of type DocumentProperties
    # + document -
    # + requestOptions - object of type RequestHeaderOptions
    # + return - If successful, returns a Document. Else returns error. 
    public remote function getDocument(@tainted ResourceProperties properties, @tainted Document document,RequestHeaderOptions? requestOptions = ()) 
    returns @tainted Document|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_COLLECTIONS,
        properties.containerId,RESOURCE_PATH_DOCUMENTS,document.id]);
        HeaderParamaters header = mapParametersToHeaderType(GET,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req = check setPartitionKeyHeader(req,document.partitionKey);
        if requestOptions is RequestHeaderOptions{
            req = check setRequestOptions(req,requestOptions);
        }
        var response = self.azureCosmosClient->get(requestPath,req);
        [json,Headers] jsonreponse = check parseResponseToTuple(response);
        return mapJsonToDocument(jsonreponse);
    }

    #To list all the documents inside a collection
    # + properties - object of type DocumentProperties
    # + requestOptions - The continuation token returned from previous document request******
    # + return - If successful, returns DocumentList. Else returns error. 
    public remote function getDocumentList(@tainted ResourceProperties properties,RequestHeaderOptions? requestOptions = ()) 
    returns @tainted DocumentList|error{ 
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_COLLECTIONS,
        properties.containerId,RESOURCE_PATH_DOCUMENTS]);
        HeaderParamaters header = mapParametersToHeaderType(GET,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        if requestOptions is RequestHeaderOptions{
            req = check setRequestOptions(req,requestOptions);
        }
        var response = self.azureCosmosClient->get(requestPath,req);
        [json,Headers] jsonreponse = check parseResponseToTuple(response);
        DocumentList list =  check mapJsonToDocumentList(jsonreponse); 
        return list;    
    }

    #To replace a document inside a collection
    # + properties - object of type DocumentProperties
    # + document - json object for replacing the existing document
    # + requestOptions - object of type RequestHeaderOptions
    # set x-ms-documentdb-partitionkey header
    # + return - If successful, returns a Document. Else returns error. 
    public remote function replaceDocument(@tainted ResourceProperties properties,@tainted Document document,
    RequestHeaderOptions? requestOptions = ()) returns @tainted Document|error{         
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_COLLECTIONS,
        properties.containerId,RESOURCE_PATH_DOCUMENTS,document.id]);//error
        HeaderParamaters header = mapParametersToHeaderType(PUT,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req = check setPartitionKeyHeader(req,document.partitionKey);
        if requestOptions is RequestHeaderOptions{
            req = check setRequestOptions(req,requestOptions);
        }
        json requestBodyId = {
            id: document.id
        };  
        json Final = check requestBodyId.mergeJson(document.documentBody); 
        req.setJsonPayload(<@untainted>Final);
        var response = self.azureCosmosClient->put(requestPath,req);
        [json,Headers] jsonreponse = check parseResponseToTuple(response);
        return mapJsonToDocument(jsonreponse);
    }

    #To delete a document inside a collection
    # + properties - object of type DocumentProperties
    # + document -
    # + return - If successful, returns a DeleteResponse giving sucessfully deleted. Else returns error. 
    public remote function deleteDocument(@tainted ResourceProperties properties, @tainted Document document) returns 
    @tainted boolean|error{  
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_COLLECTIONS,
        properties.containerId,RESOURCE_PATH_DOCUMENTS,document.id]);//error
        HeaderParamaters header = mapParametersToHeaderType(DELETE,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req = check setPartitionKeyHeader(req,document.partitionKey);
        var response = self.azureCosmosClient->delete(requestPath,req);
        return check getDeleteResponse(response);
    }

    #To query documents inside a collection
    # Function does not work properly, x-ms-max-item-count header handled
    # + properties - object of type DocumentProperties
    # + sqlQuery - json object containing the sql query
    # + requestOptions - object of type RequestOptions
    # + partitionKey - 
    # + return - If successful, returns a json. Else returns error. 
    public remote function queryDocument(@tainted ResourceProperties properties, any partitionKey, Query sqlQuery, 
    RequestHeaderOptions? requestOptions = ()) returns @tainted json|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_COLLECTIONS,
        properties.containerId,RESOURCE_PATH_DOCUMENTS]);
        HeaderParamaters header = mapParametersToHeaderType(POST,requestPath);
        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req = check setHeadersForQuery(req);
        req = check setPartitionKeyHeader(req,partitionKey);
        io:println(sqlQuery);
        req.setPayload(<json>sqlQuery.cloneWithType(json));
        var response = self.azureCosmosClient->post(requestPath,req);
        json jsonresponse = check parseResponseToJson(response);
        return (jsonresponse);
    }

    #To create a new stored procedure inside a collection
    # A stored procedure is a piece of application logic written in JavaScript that 
    # is registered and executed against a collection as a single transaction.
    # + properties - object of type StoredProcedureProperties
    # + storedProcedure - object of Type storedProcedure
    # + return - If successful, returns a StoredProcedure. Else returns error. 
    public remote function createStoredProcedure(@tainted ResourceProperties properties, 
    StoredProcedure storedProcedure) returns @tainted StoredProcedure|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_COLLECTIONS,
        properties.containerId,RESOURCE_PATH_STORED_POCEDURES]);
        HeaderParamaters header = mapParametersToHeaderType(POST,requestPath);
        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req.setJsonPayload(<json>storedProcedure.cloneWithType(json));
        var response = self.azureCosmosClient->post(requestPath,req);
        [json,Headers] jsonResponse = check parseResponseToTuple(response);
        return mapJsonToStoredProcedure(jsonResponse);    
    }

    #To replace a stored procedure with new one inside a collection
    # + properties - object of type StoredProcedureProperties
    # + storedProcedure - object of Type storedProcedure
    # + return - If successful, returns a StoredProcedure. Else returns error. 
    public remote function replaceStoredProcedure(@tainted ResourceProperties properties, 
    @tainted StoredProcedure storedProcedure) returns @tainted StoredProcedure|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_COLLECTIONS,
        properties.containerId,RESOURCE_PATH_STORED_POCEDURES,storedProcedure.id]);
        HeaderParamaters header = mapParametersToHeaderType(PUT,requestPath);
        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req.setJsonPayload(<@untainted><json>storedProcedure.cloneWithType(json));
        var response = self.azureCosmosClient->put(requestPath,req);
        [json,Headers] jsonResponse = check parseResponseToTuple(response);
        return mapJsonToStoredProcedure(jsonResponse);  
    }

    #To list all stored procedures inside a collection
    # + properties - object of type StoredProcedureProperties
    # + return - If successful, returns a StoredProcedureList. Else returns error. 
    public remote function listStoredProcedures(@tainted ResourceProperties properties) returns 
    @tainted StoredProcedureList|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_COLLECTIONS,
        properties.containerId,RESOURCE_PATH_STORED_POCEDURES]);
        HeaderParamaters header = mapParametersToHeaderType(GET,requestPath);
        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        var response = self.azureCosmosClient->get(requestPath,req);
        [json,Headers] jsonResponse = check parseResponseToTuple(response);
        return mapJsonToStoredProcedureList(jsonResponse);  
    }

    #To delete a stored procedure inside a collection
    # + properties - object of type ResourceProperties
    # + storedProcedureId - id of the stored procedure to delete
    # + return - If successful, returns DeleteResponse specifying delete is sucessfull. Else returns error. 
    public remote function deleteStoredProcedure(@tainted ResourceProperties properties,string storedProcedureId) returns 
    @tainted boolean|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_COLLECTIONS,
        properties.containerId,RESOURCE_PATH_STORED_POCEDURES,storedProcedureId]);        
        HeaderParamaters header = mapParametersToHeaderType(DELETE,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        var response = self.azureCosmosClient->delete(requestPath,req);
        return check getDeleteResponse(response);
    }

    #To execute a stored procedure inside a collection
    # ***********function only works correctly for string parameters************
    # + properties - object of type ResourceProperties
    # + storedProcedureId - id of the stored procedure to delete
    # + parameters - The list of paramaters to pass to javascript function as an array.
    # + return - If successful, returns json with the output from the executed funxtion. Else returns error. 
    public remote function executeStoredProcedure(@tainted ResourceProperties properties, string storedProcedureId, any[]? parameters) 
    returns @tainted json|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_COLLECTIONS,
        properties.containerId,RESOURCE_PATH_STORED_POCEDURES,storedProcedureId]);       
        HeaderParamaters header = mapParametersToHeaderType(POST,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req.setTextPayload(parameters.toString());
        var response = self.azureCosmosClient->post(requestPath,req);
        json jsonreponse = check parseResponseToJson(response);
        return jsonreponse;   
    }

    public remote function createUserDefinedFunction(@tainted ResourceProperties properties, 
    UserDefinedFunction userDefinedFunction) returns @tainted UserDefinedFunction|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_COLLECTIONS,
        properties.containerId,RESOURCE_PATH_UDF]);       
        HeaderParamaters header = mapParametersToHeaderType(POST,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req.setJsonPayload(<json>userDefinedFunction.cloneWithType(json));
        var response = self.azureCosmosClient->post(requestPath,req);
        [json,Headers] jsonResponse = check parseResponseToTuple(response);
        return mapJsonToUserDefinedFunction(jsonResponse);      
    }

    public remote function replaceUserDefinedFunction(@tainted ResourceProperties properties, 
    @tainted UserDefinedFunction userDefinedFunction) returns @tainted UserDefinedFunction|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_COLLECTIONS,
        properties.containerId,RESOURCE_PATH_UDF,userDefinedFunction.id]);      
        HeaderParamaters header = mapParametersToHeaderType(PUT,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req.setJsonPayload(<@untainted><json>userDefinedFunction.cloneWithType(json));
        var response = self.azureCosmosClient->put(requestPath,req);
        [json,Headers] jsonResponse = check parseResponseToTuple(response);
        return mapJsonToUserDefinedFunction(jsonResponse);      
    }

    public remote function listUserDefinedFunction(@tainted ResourceProperties properties) returns @tainted UserDefinedFunctionList|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_COLLECTIONS,
        properties.containerId,RESOURCE_PATH_UDF]);
        HeaderParamaters header = mapParametersToHeaderType(GET,requestPath);
        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        var response = self.azureCosmosClient->get(requestPath,req);
        [json,Headers] jsonResponse = check parseResponseToTuple(response);
        return mapJsonToUserDefinedFunctionList(jsonResponse);      
    }

    public remote function deleteUserDefinedFunction(@tainted ResourceProperties properties,string userDefinedFunctionid) returns @tainted boolean|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_COLLECTIONS,
        properties.containerId,RESOURCE_PATH_UDF,userDefinedFunctionid]);        
        HeaderParamaters header = mapParametersToHeaderType(DELETE,requestPath);
        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        var response = self.azureCosmosClient->delete(requestPath,req);
        return check getDeleteResponse(response);
    }

    public remote function createTrigger(@tainted ResourceProperties properties, Trigger trigger) returns @tainted 
    Trigger|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_COLLECTIONS,
        properties.containerId,RESOURCE_PATH_TRIGGER]);       
        HeaderParamaters header = mapParametersToHeaderType(POST,requestPath);
        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req.setJsonPayload(<json>trigger.cloneWithType(json));//error
        var response = self.azureCosmosClient->post(requestPath,req);
        [json,Headers] jsonResponse = check parseResponseToTuple(response);
        return mapJsonToTrigger(jsonResponse);      
    }
    
    public remote function replaceTrigger(@tainted ResourceProperties properties, @tainted Trigger trigger) returns @tainted 
    Trigger|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_COLLECTIONS,
        properties.containerId,RESOURCE_PATH_TRIGGER,trigger.id]);       
        HeaderParamaters header = mapParametersToHeaderType(PUT,requestPath);
        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req.setJsonPayload(<@untainted><json>trigger.cloneWithType(json));//error
        var response = self.azureCosmosClient->put(requestPath,req);
        [json,Headers] jsonResponse = check parseResponseToTuple(response);
        return mapJsonToTrigger(jsonResponse); 
      }

    public remote function listTriggers(@tainted ResourceProperties properties) returns @tainted TriggerList|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_COLLECTIONS,
        properties.containerId,RESOURCE_PATH_TRIGGER]);
        HeaderParamaters header = mapParametersToHeaderType(GET,requestPath);
        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        var response = self.azureCosmosClient->get(requestPath,req);
        [json,Headers] jsonResponse = check parseResponseToTuple(response);
        return mapJsonToTriggerList(jsonResponse);      
    }

    public remote function deleteTrigger(@tainted ResourceProperties properties,string triggerId) returns 
    @tainted boolean|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_COLLECTIONS,
        properties.containerId,RESOURCE_PATH_TRIGGER,triggerId]);       
        HeaderParamaters header = mapParametersToHeaderType(DELETE,requestPath);
        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        var response = self.azureCosmosClient->delete(requestPath,req);
        return check getDeleteResponse(response);
    }

    public remote function createUser(@tainted ResourceProperties properties, string userId) returns @tainted 
    User|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_USER]);       
        HeaderParamaters header = mapParametersToHeaderType(POST,requestPath);
        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        json reqBody = {
            id:userId
        };
        req.setJsonPayload(reqBody);
        var response = self.azureCosmosClient->post(requestPath,req);
        [json,Headers] jsonResponse = check parseResponseToTuple(response);
        return mapJsonToUser(jsonResponse);     
    }
    
    public remote function replaceUser(@tainted ResourceProperties properties, string userId, string newUserId) returns @tainted 
    User|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_USER,userId]);       
        HeaderParamaters header = mapParametersToHeaderType(PUT,requestPath);
        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        json reqBody = {
            id:newUserId
        };
        req.setJsonPayload(reqBody);
        var response = self.azureCosmosClient->put(requestPath,req);
        [json,Headers] jsonResponse = check parseResponseToTuple(response);
        return mapJsonToUser(jsonResponse); 
    }

    public remote function getUser(@tainted ResourceProperties properties, string userId) returns @tainted User|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_USER,userId]);
        HeaderParamaters header = mapParametersToHeaderType(GET,requestPath);
        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        var response = self.azureCosmosClient->get(requestPath,req);
        [json,Headers] jsonResponse = check parseResponseToTuple(response);
        return mapJsonToUser(jsonResponse);      
    }

    public remote function listUsers(@tainted ResourceProperties properties) returns @tainted UserList|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_USER]);
        HeaderParamaters header = mapParametersToHeaderType(GET,requestPath);
        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        var response = self.azureCosmosClient->get(requestPath,req);
        [json,Headers] jsonResponse = check parseResponseToTuple(response);
        return mapJsonToUserList(jsonResponse);     
    }

    public remote function deleteUser(@tainted ResourceProperties properties,string userId) returns 
    @tainted boolean|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_USER,userId]);       
        HeaderParamaters header = mapParametersToHeaderType(DELETE,requestPath);
        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        var response = self.azureCosmosClient->delete(requestPath,req);
        return check getDeleteResponse(response);
    }

//handle the ttl
    public remote function createPermission(@tainted ResourceProperties properties,string userId, Permission permission)
    returns @tainted Permission|error {
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_USER,userId,RESOURCE_PATH_PERMISSION]);       
        HeaderParamaters header = mapParametersToHeaderType(POST,requestPath);
        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req.setJsonPayload(<@untainted><json>permission.cloneWithType(json));
        var response = self.azureCosmosClient->post(requestPath,req);
        [json,Headers] jsonResponse = check parseResponseToTuple(response);
        return mapJsonToPermission(jsonResponse);
    }

    public remote function replacePermission(@tainted ResourceProperties properties,string userId,@tainted Permission permission)
    returns @tainted Permission|error {
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_USER,userId,RESOURCE_PATH_PERMISSION,permission.id]);       
        HeaderParamaters header = mapParametersToHeaderType(PUT,requestPath);
        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req.setJsonPayload(<@untainted><json>permission.cloneWithType(json));
        var response = self.azureCosmosClient->put(requestPath,req);
        [json,Headers] jsonResponse = check parseResponseToTuple(response);
        return mapJsonToPermission(jsonResponse);
    }

    public remote function listPermissions(@tainted ResourceProperties properties,string userId)
    returns @tainted PermissionList|error {
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_USER,userId,RESOURCE_PATH_PERMISSION]);       
        HeaderParamaters header = mapParametersToHeaderType(GET,requestPath);
        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        var response = self.azureCosmosClient->get(requestPath,req);
        [json,Headers] jsonResponse = check parseResponseToTuple(response);
        return mapJsonToPermissionList(jsonResponse);
    }

    public remote function getPermission(@tainted ResourceProperties properties,string userId,string permissionId)
    returns @tainted Permission|error {
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_USER,userId,RESOURCE_PATH_PERMISSION,permissionId]);       
        HeaderParamaters header = mapParametersToHeaderType(GET,requestPath);
        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        var response = self.azureCosmosClient->get(requestPath,req);
        [json,Headers] jsonResponse = check parseResponseToTuple(response);
        return mapJsonToPermission(jsonResponse);
    }

    public remote function deletePermission(@tainted ResourceProperties properties,string userId, string permissionId) returns 
    @tainted boolean|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_USER,userId,RESOURCE_PATH_PERMISSION,permissionId]);       
        HeaderParamaters header = mapParametersToHeaderType(DELETE,requestPath);
        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        var response = self.azureCosmosClient->delete(requestPath,req);
        return check getDeleteResponse(response);
    }
}
