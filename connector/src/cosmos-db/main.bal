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
    # + properties -  id/name for the database
    # + throughputProperties - Optional throughput parameter which will set 'x-ms-offer-throughput' header 
    # + return - If successful, returns Database. Else returns error.  
    public remote function createDatabase(@tainted DatabaseProperties properties, ThroughputProperties? throughputProperties = ()) returns 
    @tainted Database|error{
        json jsonPayload;
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES]);
        HeaderParamaters header = mapParametersToHeaderType(POST,requestPath);
        if properties.id == "" {
            return prepareError("Invalid database id: Cannot be empty");
        }
        json|error payload = properties.cloneWithType(json);
        if payload is json {
            req.setJsonPayload(payload);
        }
        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req = check setThroughputOrAutopilotHeader(req,throughputProperties);
        var response = self.azureCosmosClient->post(requestPath,req);
        [json,Headers] jsonreponse = check parseResponseToTuple(response);
        return mapJsonToDatabaseType(jsonreponse);   
    }

    # To create a database inside a resource
    # + properties -  id/name for the database
    # + throughputProperties - Optional throughput parameter which will set 'x-ms-offer-throughput' header 
    # + return - If successful, returns Database. Else returns error.  
    public remote function createDatabaseIfNotExist(@tainted DatabaseProperties properties, ThroughputProperties? throughputProperties = ()) 
    returns @tainted Database?|error{
        var result = self->getDatabase(properties);
        if result is error{
            return self->createDatabase(<@untainted>properties,throughputProperties);
        }
        return ();  
    }

    # To retrive a given database inside a resource
    # + properties -  id/name of the database to retrieve
    # + return - If successful, returns Database. Else returns error.  
    public remote function getDatabase(@tainted DatabaseProperties properties) returns @tainted Database|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.id]);
        HeaderParamaters header = mapParametersToHeaderType(GET,requestPath);
        if properties.id == "" {
            return prepareError("Invalid database id: Cannot be empty");
        }
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
    # + properties -  id/name of the database to retrieve
    # + return - If successful, returns DeleteResponse specifying delete is sucessfull. Else returns error.  
    public remote function deleteDatabase(@tainted DatabaseProperties properties) returns @tainted DeleteResponse|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.id]);
        HeaderParamaters header = mapParametersToHeaderType(DELETE,requestPath);
        if properties.id == "" {
            return prepareError("Invalid database id: Cannot be empty");
        }
        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        var response = self.azureCosmosClient->delete(requestPath,req);
        [string,Headers] jsonresponse = check parseDeleteResponseToTuple(response);
        return  mapTupleToDeleteresponse(jsonresponse);
    }

    # To create a collection inside a database
    # + properties - object of type ContainerProperties
    # + throughputProperties - Optional throughput parameter which will set 'x-ms-offer-throughput' header 
    # + return - If successful, returns Container. Else returns error.  
    public remote function createContainer(@tainted ContainerProperties properties, 
    ThroughputProperties? throughputProperties = ()) returns @tainted Container|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,
        RESOURCE_PATH_COLLECTIONS]);
        HeaderParamaters header = mapParametersToHeaderType(POST,requestPath);
        
        json body = {
            "id": properties.containerId,
            "partitionKey": <json>properties.partitionKey.cloneWithType(json)
        };
        json finalc = check body.mergeJson(<json>properties.indexingPolicy.cloneWithType(json));
        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req = check setThroughputOrAutopilotHeader(req,throughputProperties);
        req.setJsonPayload(<@untainted>finalc);//??
        var response = self.azureCosmosClient->post(requestPath,req);
        [json,Headers] jsonreponse = check parseResponseToTuple(response);
        return mapJsonToCollectionType(jsonreponse);
    }

    # To create a database inside a resource
    # + properties -  object of type ContainerProperties
    # + throughputProperties - Optional throughput parameter which will set 'x-ms-offer-throughput' header 
    # + return - If successful, returns Database. Else returns error.  
    public remote function createContainerIfNotExist(@tainted ContainerProperties properties, 
    ThroughputProperties? throughputProperties = ()) returns @tainted Container?|error{
        var result = self->getContainer(properties);
        if result is error{
            return self->createContainer(properties,throughputProperties);
        }
        return ();  
    }

    # To create a collection inside a database
    # + properties - object of type ContainerProperties
    # + throughputProperties - Optional throughput parameter which will set 'x-ms-offer-throughput' header 
    # + return - If successful, returns Container. Else returns error. 
    public remote function replaceProvisionedThroughput(@tainted ContainerProperties properties, ThroughputProperties 
    throughputProperties) returns @tainted Container|error {
        return self->createContainer(properties,throughputProperties);
    }

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
    public remote function getContainer(@tainted ContainerProperties properties) returns @tainted Container|error{
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
    public remote function deleteContainer(@tainted ContainerProperties properties) returns @tainted DeleteResponse|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_COLLECTIONS,
        properties.containerId]);
        HeaderParamaters header = mapParametersToHeaderType(DELETE,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        var response = self.azureCosmosClient->delete(requestPath,req);
        [string,Headers] jsonresponse = check parseDeleteResponseToTuple(response);
        return  mapTupleToDeleteresponse(jsonresponse);
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
    public remote function createDocument(@tainted DocumentProperties properties,json document,
    RequestHeaderOptions? requestOptions) returns @tainted Document|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_COLLECTIONS,
        properties.containerId,RESOURCE_PATH_DOCUMENTS]);
        HeaderParamaters header = mapParametersToHeaderType(POST,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req = check setPartitionKeyHeader(req,properties.partitionKey);
        if requestOptions is RequestHeaderOptions{
            req = check setRequestOptions(req,requestOptions);
        }        
        req.setJsonPayload(document);
        var response = self.azureCosmosClient->post(requestPath,req);
        [json,Headers] jsonreponse = check parseResponseToTuple(response);
        return mapJsonToDocument(jsonreponse);
    }

    #To list one document inside a collection
    # x-ms-consistency-level, x-ms-session-token and If-None-Match headers are supported
    # + properties - object of type DocumentProperties
    # + requestOptions - object of type RequestHeaderOptions
    # + return - If successful, returns a Document. Else returns error. 
    public remote function getDocument(@tainted DocumentProperties properties,RequestHeaderOptions? requestOptions = ()) 
    returns @tainted Document|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_COLLECTIONS,
        properties.containerId,RESOURCE_PATH_DOCUMENTS,properties.documentId.toString()]);
        HeaderParamaters header = mapParametersToHeaderType(GET,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req = check setPartitionKeyHeader(req,properties.partitionKey);
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
    public remote function getDocumentList(@tainted DocumentProperties properties,RequestHeaderOptions? requestOptions = ()) 
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
    # + newDocument - json object for replacing the existing document
    # + requestOptions - object of type RequestHeaderOptions
    # set x-ms-documentdb-partitionkey header
    # + return - If successful, returns a Document. Else returns error. 
    public remote function replaceDocument(@tainted DocumentProperties properties, json newDocument,
    RequestHeaderOptions? requestOptions = ()) returns @tainted Document|error{         
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_COLLECTIONS,
        properties.containerId,RESOURCE_PATH_DOCUMENTS,<string>properties.documentId]);//error
        HeaderParamaters header = mapParametersToHeaderType(PUT,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req = check setPartitionKeyHeader(req,properties.partitionKey);
        if requestOptions is RequestHeaderOptions{
            req = check setRequestOptions(req,requestOptions);
        }
        req.setJsonPayload(newDocument);
        var response = self.azureCosmosClient->put(requestPath,req);
        [json,Headers] jsonreponse = check parseResponseToTuple(response);
        return mapJsonToDocument(jsonreponse);
    }

    #To delete a document inside a collection
    # + properties - object of type DocumentProperties
    # + return - If successful, returns a DeleteResponse giving sucessfully deleted. Else returns error. 
    public remote function deleteDocument(@tainted DocumentProperties properties) returns 
    @tainted DeleteResponse|error{  
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_COLLECTIONS,
        properties.containerId,RESOURCE_PATH_DOCUMENTS,<string>properties.documentId]);//error
        HeaderParamaters header = mapParametersToHeaderType(DELETE,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req = check setPartitionKeyHeader(req,properties.partitionKey);
        var response = self.azureCosmosClient->delete(requestPath,req);
        [string,Headers] jsonresponse = check parseDeleteResponseToTuple(response);
        return  mapTupleToDeleteresponse(jsonresponse);
    }

    #To query documents inside a collection
    # Function does not work properly, x-ms-max-item-count header handled
    # + properties - object of type DocumentProperties
    # + sqlQuery - json object containing the sql query
    # + requestOptions - object of type RequestOptions
    # + return - If successful, returns a json. Else returns error. 
    public remote function queryDocument(@tainted DocumentProperties properties, Query sqlQuery, 
    RequestHeaderOptions? requestOptions = ()) returns @tainted json|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_COLLECTIONS,
        properties.containerId,RESOURCE_PATH_DOCUMENTS]);
        HeaderParamaters header = mapParametersToHeaderType(POST,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req = check setHeadersForQuery(req);
        req = check setPartitionKeyHeader(req,properties.partitionKey);
        req.setPayload(sqlQuery);
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
        req.setJsonPayload(<json>storedProcedure.cloneWithType(json));//error
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
        req.setJsonPayload(<@untainted><json>storedProcedure.cloneWithType(json));//error
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
    # + properties - object of type StoredProcedureProperties
    # + return - If successful, returns DeleteResponse specifying delete is sucessfull. Else returns error. 
    public remote function deleteStoredProcedure(@tainted ResourceProperties properties,string storedProcedureId) returns 
    @tainted DeleteResponse|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_COLLECTIONS,
        properties.containerId,RESOURCE_PATH_STORED_POCEDURES,storedProcedureId]);//check error        
        HeaderParamaters header = mapParametersToHeaderType(DELETE,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        var response = self.azureCosmosClient->delete(requestPath,req);
        [string,Headers] jsonresponse = check parseDeleteResponseToTuple(response);
        return  mapTupleToDeleteresponse(jsonresponse);
    }

    #To execute a stored procedure inside a collection
    # ***********function only works correctly for string parameters************
    # + properties - object of type StoredProcedureProperties
    # + parameters - The list of paramaters to pass to javascript function as an array.
    # + return - If successful, returns json with the output from the executed funxtion. Else returns error. 
    public remote function executeStoredProcedure(@tainted ResourceProperties properties, string storedProcedureId, any[]? parameters) 
    returns @tainted json|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_COLLECTIONS,
        properties.containerId,RESOURCE_PATH_STORED_POCEDURES,storedProcedureId]);//check error        
        HeaderParamaters header = mapParametersToHeaderType(POST,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req.setTextPayload(parameters.toString());
        var response = self.azureCosmosClient->post(requestPath,req);
        json jsonreponse = check parseResponseToJson(response);
        return jsonreponse;   
    }

    public remote function createUserDefinedFunction(@tainted UserDefinedFunctionProperties properties, 
    UserDefinedFunction userDefinedFunction) returns @tainted UserDefinedFunction|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_COLLECTIONS,
        properties.containerId,RESOURCE_PATH_UDF]);       
        HeaderParamaters header = mapParametersToHeaderType(POST,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req.setJsonPayload(<json>userDefinedFunction.cloneWithType(json));//error
        var response = self.azureCosmosClient->post(requestPath,req);
        [json,Headers] jsonResponse = check parseResponseToTuple(response);
        return mapJsonToUserDefinedFunction(jsonResponse);      
    }
    //only the path is different those two functions

    public remote function replaceUserDefinedFunction(@tainted UserDefinedFunctionProperties properties, 
    UserDefinedFunction userDefinedFunction) returns @tainted UserDefinedFunction|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_COLLECTIONS,
        properties.containerId,RESOURCE_PATH_UDF,<string>properties.userDefinedFunctionId]);//check error        
        HeaderParamaters header = mapParametersToHeaderType(PUT,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req.setJsonPayload(<json>userDefinedFunction.cloneWithType(json));//error
        var response = self.azureCosmosClient->put(requestPath,req);
        [json,Headers] jsonResponse = check parseResponseToTuple(response);
        return mapJsonToUserDefinedFunction(jsonResponse);      
    }

    public remote function listUserDefinedFunction(@tainted UserDefinedFunctionProperties properties) returns @tainted UserDefinedFunctionList|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_COLLECTIONS,
        properties.containerId,RESOURCE_PATH_UDF]);
        HeaderParamaters header = mapParametersToHeaderType(GET,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        var response = self.azureCosmosClient->get(requestPath,req);
        [json,Headers] jsonResponse = check parseResponseToTuple(response);
        return mapJsonToUserDefinedFunctionList(jsonResponse);      
    }

    public remote function deleteUserDefinedFunction(@tainted UserDefinedFunctionProperties properties) returns @tainted DeleteResponse|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_COLLECTIONS,
        properties.containerId,RESOURCE_PATH_UDF,<string>properties.userDefinedFunctionId]);//check error        
        HeaderParamaters header = mapParametersToHeaderType(DELETE,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        var response = self.azureCosmosClient->delete(requestPath,req);
        [string,Headers] jsonresponse = check parseDeleteResponseToTuple(response);
        return  mapTupleToDeleteresponse(jsonresponse);     
    }

    public remote function createTrigger(@tainted TriggerProperties properties, Trigger trigger) returns @tainted 
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
    
    public remote function replaceTrigger(@tainted TriggerProperties properties, Trigger trigger) returns @tainted 
    Trigger|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_COLLECTIONS,
        properties.containerId,RESOURCE_PATH_TRIGGER,<string>properties.triggerId]);       
        HeaderParamaters header = mapParametersToHeaderType(PUT,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        req.setJsonPayload(<json>trigger.cloneWithType(json));//error
        var response = self.azureCosmosClient->put(requestPath,req);
        [json,Headers] jsonResponse = check parseResponseToTuple(response);
        any output = mapJsonToType(jsonResponse); 
        io:println(output);
        return  <Trigger>output;
    }

    public remote function listTriggers(@tainted TriggerProperties properties) returns @tainted TriggerList|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_COLLECTIONS,
        properties.containerId,RESOURCE_PATH_TRIGGER]);
        HeaderParamaters header = mapParametersToHeaderType(GET,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        var response = self.azureCosmosClient->get(requestPath,req);
        [json,Headers] jsonResponse = check parseResponseToTuple(response);
        return mapJsonToTriggerList(jsonResponse);      
    }

    public remote function deleteTrigger(@tainted TriggerProperties properties) returns 
    @tainted DeleteResponse|error{
        http:Request req = new;
        string requestPath =  prepareUrl([RESOURCE_PATH_DATABASES,properties.databaseId,RESOURCE_PATH_COLLECTIONS,
        properties.containerId,RESOURCE_PATH_TRIGGER,<string>properties.triggerId]);//check error        
        HeaderParamaters header = mapParametersToHeaderType(DELETE,requestPath);

        req = check setHeaders(req,self.host,self.masterKey,self.keyType,self.tokenVersion,header);
        var response = self.azureCosmosClient->delete(requestPath,req);
        [string,Headers] jsonresponse = check parseDeleteResponseToTuple(response);
        return  mapTupleToDeleteresponse(jsonresponse);
    }

}
