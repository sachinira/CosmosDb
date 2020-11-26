import ballerina/io;
import ballerina/test;
import ballerina/java;

AzureCosmosConfiguration config = {
    baseUrl : BASE_URL,
    masterKey : MASTER_KEY,
    host : HOST,
    tokenType : TOKEN_TYPE,
    tokenVersion : TOKEN_VERSION,
    secureSocketConfig : {
                trustStore: {
                    path: "/usr/lib/ballerina/distributions/ballerina-slp4/bre/security/ballerinaTruststore.p12",
                    password: "ballerina"
                }
            }
};

function createRandomUUID() returns handle = @java:Method {
    name : "randomUUID",
    'class : "java.util.UUID"
} external;

@test:Config{
    enable: false
}
function createDB(){
    io:println("--------------Create database------------------------\n\n");

    Client AzureCosmosClient = new(config);

    DatabaseProperties db = {};
    db.id = "database1";
    var result = AzureCosmosClient->createDatabase(<@untainted>db);
    if (result is Database) {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }
    io:println("\n\n");
}

@test:Config{
    enable: false
}
function createIfNotExist(){
    io:println("--------------Create database if not exist------------------------\n\n");

    Client AzureCosmosClient = new(config);
    DatabaseProperties db = {};
    db.id = "Heloo";
    var result = AzureCosmosClient->createDatabaseIfNotExist(db);
    if (result is Database?) {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }
    io:println("\n\n");
}

@test:Config{
    enable: false
}
function createDBWithManualThroughput(){
    io:println("--------------Create with manual throguput------------------------\n\n");

    Client AzureCosmosClient = new(config);
    ThroughputProperties tp = {};
    tp.throughput = 600; 
    DatabaseProperties db = {};
    db.id = "Heloo";
    var result = AzureCosmosClient->createDatabase(<@untainted>db, tp);
    if (result is Database) {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }
    io:println("\n\n");
}

@test:Config{
    enable: false
}
function createDBWithAutoscaling(){
    io:println("--------------Create with autoscaling throguput------------------------\n\n");

    Client AzureCosmosClient = new(config);
    DatabaseProperties db = {};
    db.id = "Heloo";
    ThroughputProperties tp = {};
    tp.maxThroughput = {"maxThroughput": 4000};
    var result = AzureCosmosClient->createDatabase(<@untainted>db, tp);
    if (result is Database) {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }
    io:println("\n\n");
}

@test:Config{
    enable: false
}
function createDBWithBothHeaders(){
    io:println("--------------Create with autoscaling and throguput headers------------------------\n\n");

    Client AzureCosmosClient = new(config);
    ThroughputProperties tp = {};
    tp.maxThroughput = {"maxThroughput" : 4000};
    tp.throughput = 600; 
    DatabaseProperties db = {};
    db.id = "Heloo";
    var result = AzureCosmosClient->createDatabase(<@untainted>db, tp);
    if (result is Database) {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }
    io:println("\n\n");
}

@test:Config{
   enable: false
}
function listAllDB(){
    io:println("--------------List All databases------------------------\n\n");

    Client AzureCosmosClient = new(config);
    var result = AzureCosmosClient->getAllDatabases();
    if (result is DatabaseList) {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }
    io:println("\n\n");
}

@test:Config{
    enable: false
}
function listOneDB(){
    io:println("--------------List one database------------------------\n\n");

    Client AzureCosmosClient = new(config);
    DatabaseProperties db = {};
    db.id = "database1"; 
    var result = AzureCosmosClient->getDatabase(db);
    if (result is Database) {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }
    io:println("\n\n");
}

@test:Config{
    enable: false
}
function deleteDB(){
    io:println("--------------Delete one databse------------------------\n\n");

    Client AzureCosmosClient = new(config);
    DatabaseProperties db = {};
    db.id = "";
    var result = AzureCosmosClient->deleteDatabase(db);
    if (result is DeleteResponse) {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }
    io:println("\n\n");
}

@test:Config{
    enable: false
}
function createContainer(){
    io:println("--------------Create Collection-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    string throughput = "400";
    PartitionKey pk = {};
    pk.paths = ["/AccountNumber"];
    pk.kind = "Hash";
    pk.'version = 2;
    ContainerProperties con = {};
    con.partitionKey = pk;
    con.databaseId = "database1";
    con.containerId = "collection1";
    var result = AzureCosmosClient->createContainer(con);
    if (result is Container) {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    } 
    io:println("\n\n");
}

@test:Config{
    enable: false
}
function createContainerIfNotExist(){
    io:println("--------------Create Collection-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    string throughput = "400";
    PartitionKey pk = {};
    pk.paths = ["/AccountNumber"];
    pk.kind = "Hash";
    pk.'version = 2;
    ContainerProperties con = {};
    con.partitionKey = pk;
    con.databaseId = "hikall";
    con.containerId = "new2";
    var result = AzureCosmosClient->createContainerIfNotExist(con);
    if (result is Container?) {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    } 
    io:println("\n\n");
}

@test:Config{
    enable: false
}
function createCollectionWithManualThroughputAndIndexingPolicy(){
    io:println("--------------Create Collection with manual throughput-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    json indexingPolicy =   {  
                                "automatic": true,  
                                "indexingMode": "Consistent",  
                                "includedPaths": [  
                                    {  
                                        "path": "/*",  
                                        "indexes": [  
                                        {  
                                            "dataType": "String",  
                                            "precision": -1,  
                                            "kind": "Range"  
                                        }  
                                        ]  
                                    }  
                                ]  
                            };
    
    
    ThroughputProperties tp = {};
    tp.throughput = 600; 
    PartitionKey pk = {};
    pk.paths = ["/AccountNumber"];
    pk.kind = "Hash";
    pk.'version = 2;
    ContainerProperties con = {};
    con.partitionKey = pk;
    con.databaseId = "hikall";
    con.containerId = "mycollect";
    var result = AzureCosmosClient->createContainer(con, tp);
    if (result is Container) {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    } 
    io:println("\n\n");
}

//create collection with autoscale testcase comes here

@test:Config{
   enable: false
}
function getAllCollections(){
    io:println("--------------Get All collections-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    var result = AzureCosmosClient->getAllContainers("hikall");
    if (result is ContainerList) {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }
    io:println("\n\n");
}

@test:Config{
    enable: false
}
function getOneCollection(){
    io:println("--------------Get One collection-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    ContainerProperties con = {};
    con.databaseId = "database1";
    con.containerId = "collection1";
    var result = AzureCosmosClient->getContainer(con);
    if (result is Container) {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }
    io:println("\n\n");
}

@test:Config{
   enable: false
}
function deleteCollection(){
    io:println("--------------Delete one collection------------------------\n\n");

    Client AzureCosmosClient = new(config); 
    ContainerProperties con = {};
    con.databaseId = "hikall";
    con.containerId = "mycollect";
    var result = AzureCosmosClient->deleteContainer(con);
    io:println(result);
    io:println("\n\n");
}

@test:Config{
   enable: false
}
function GetPartitionKeyRanges(){
    io:println("--------------Get partition key ranges------------------------\n\n");

    Client AzureCosmosClient = new(config);
    var result = AzureCosmosClient->getPartitionKeyRanges("hikall","mycollection1");
    if (result is PartitionKeyList) {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
    io:println("\n\n");
}

@test:Config{
  enable: false
}
function createDocument(){
    io:println("--------------Create One document------------------------\n\n");

    Client AzureCosmosClient = new(config);
    var uuid = createRandomUUID();
    string docid = uuid.toString();
    json custombody = {
        "LastName": "keeeeeee",  
        "Parents": [  
            {  
            "FamilyName": null,  
            "FirstName": "Thomas"  
            },  
            {  
            "FamilyName": null,  
            "FirstName": "Mary Kay"  
            }  
        ],  
        "Children": [  
            {  
            "FamilyName": null,  
            "FirstName": "Henriette Thaulow",  
            "Gender": "female",  
            "Grade": 5,  
            "Pets": [  
                {  
                "GivenName": "Fluffy"  
                }  
            ]  
            }  
        ],  
        "Address": {  
            "State": "WA",  
            "County": "King",  
            "City": "Seattle"  
        },  
        "IsRegistered": true,
        "AccountNumber": 1234  
    };
    json body = {
            id: docid    
    };   
    json|error finalj =  body.mergeJson(custombody);
    DocumentProperties dc = {};
    dc.databaseId="hikall";
    dc.containerId="mycollection1";
    dc.partitionKey=<json>custombody.AccountNumber;
    RequestHeaderOptions reqOptions = {
        isUpsertRequest:true
    };
    if finalj is json{
        var result = AzureCosmosClient->createDocument(dc, finalj, reqOptions);
        if result is Document {
            io:println(result);
        } else {
            test:assertFail(msg = result.message());
        }   
    } 
    io:println("\n\n");
}

//with indexing or upsert headers test case comes here
@test:Config{
   enable: false
}
function GetDocumentList(){
    io:println("--------------Get all documents in a collection------------------------\n\n");

    Client AzureCosmosClient = new(config);
    DocumentProperties dc = {};
    dc.databaseId = "hikall";
    dc.containerId = "mycollection1";
    var result = AzureCosmosClient->getDocumentList(dc);
    if (result is DocumentList) {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }
    io:println("\n\n");
}

@test:Config{
   enable: false
}
function getNextPageOfDocumentList(){
    io:println("--------------Get next page documents in a collection------------------------\n\n");

    Client AzureCosmosClient = new(config);
    DocumentProperties dc = {};
    dc.databaseId = "hikall";
    dc.containerId = "mycollection1";
    RequestHeaderOptions options = {};
    options.maxItemCount = 4;
    options.continuationToken = "{token:'nXh6ANTE4QoIAAAAAAAAAA==',range:{min:'',max:'FF'}}";//convert this to string
    var result = AzureCosmosClient->getDocumentList(dc,options);
    if (result is DocumentList) {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }
    io:println("\n\n");
}

@test:Config{
    enable: false
}
function GetOneDocument(){
    io:println("--------------Get one document------------------------\n\n");

    Client AzureCosmosClient = new(config);
    DocumentProperties dc = {};
    dc.databaseId = "hikall";
    dc.containerId = "mycollection1";
    dc.partitionKey = 1234;
    dc.documentId = "10b40edd-d94e-4677-aa0b-eeeab1f7c470";
    var result = AzureCosmosClient->getDocument(dc);
    if (result is Document) {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
    io:println("\n\n");
}

@test:Config{
    enable: false
}
function replaceDocument(){
    io:println("--------------Replace document------------------------\n\n");

    Client AzureCosmosClient = new(config);
    DocumentProperties dc = {};
    dc.databaseId = "hikall";
    dc.containerId = "mycollection1";
    dc.partitionKey = 1234;
    dc.documentId = "8f014bef-691e-4732-99f0-9b7af94cb9c2";
    json id = {
        "id": dc.documentId
    };
    json custom = {
        "LastName": "hi",  
        "Parents": [  
            {  
            "FamilyName": null,  
            "FirstName": "Thomas"  
            },  
            {  
            "FamilyName": null,  
            "FirstName": "Mary Kay"  
            }  
        ],  
        "Children": [  
            {  
            "FamilyName": null,  
            "FirstName": "Henriette Thaulow",  
            "Gender": "female",  
            "Grade": 5,  
            "Pets": [  
                {  
                "GivenName": "Fluffy"  
                }  
            ]  
            }  
        ],  
        "AccountNumber": <json>dc.partitionKey,
        "Address": {  
            "State": "WA",  
            "County": "King",  
            "City": "Seattle"  
        },  
        "IsRegistered": true
    };
    json|error finalj = custom.mergeJson(id);
    var result = AzureCosmosClient->replaceDocument(dc,<json>custom);  
    if result is Document {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
    io:println("\n\n"); 
}

@test:Config{
    enable: false
}
function deleteDocument(){
    io:println("--------------Delete one document------------------------\n\n");
    
    Client AzureCosmosClient = new(config);
    DocumentProperties dc = {};
    dc.databaseId = "hikall";
    dc.containerId = "mycollection1";
    dc.partitionKey = 1234;
    dc.documentId = "69a2c93a-42e6-487e-b6f3-1a355f1afd19";
    var result = AzureCosmosClient->deleteDocument(dc);  
    if result is DeleteResponse {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
    io:println("\n\n"); 
}

@test:Config{
    enable: false
}
function queryDocument(){
    io:println("--------------Query one document-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    DocumentProperties dc = {};
    dc.databaseId = "hikall";
    dc.containerId = "mycollection1";
    dc.partitionKey = 1234;
    Query sqlQuery = {};
    QueryParameter[] params = [{name: "@familyId", value: "AndersenFamily"}];
    sqlQuery.query = "SELECT * FROM mycollection1 f WHERE f.id = @familyId";
    sqlQuery.parameters = params;
    var result = AzureCosmosClient->queryDocument(dc,sqlQuery);   
    if result is json {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }    
    io:println("\n\n");  
}

@test:Config{
   enable: false
}
function createSproc(){
    io:println("-----------------Create stored procedure-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    var uuid = createRandomUUID();
    string sprocId = string `sproc-${uuid.toString()}`;
    ResourceProperties properties = {};
    properties.databaseId = "hikall";
    properties.containerId = "mycollection1";
    string sproc = "function () {\r\n    var context = getContext();\r\n    var response = context.getResponse();\r\n\r\n    response.setBody(\"Hello, World\");\r\n}"; 
    StoredProcedure sp = {
        id:sprocId,
        body:sproc
    };
    var result = AzureCosmosClient->createStoredProcedure(properties,sp);  
    if result is StoredProcedure {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
    io:println("\n\n");  
}

@test:Config{
   enable: false
}
function replaceSproc(){
    io:println("-----------------Replace stored procedure-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    string sprocId = "sproc-50c4f0df-b25d-48ef-b936-d31a55798193";
    ResourceProperties properties = {};
    properties.databaseId = "hikall";
    properties.containerId = "mycollection1";
    string sproc = "function (personToGreet) {\r\n    var context = getContext();\r\n    var response = context.getResponse();\r\n\r\n    response.setBody(\"Hello, \" + personToGreet);\r\n}";
    StoredProcedure sp = {
        id:sprocId,
        body:sproc
    }; 
    var result = AzureCosmosClient->replaceStoredProcedure(properties,sp);  
    if result is StoredProcedure {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
    io:println("\n\n"); 
}

@test:Config{
   enable: false
}
function getAllSprocs(){
    io:println("-----------------Get All Stored Procedures-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    ResourceProperties properties = {};
    properties.databaseId = "hikall";
    properties.containerId = "mycollection1";
    var result = AzureCosmosClient->listStoredProcedures(properties);   
    if result is StoredProcedureList {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
    io:println("\n\n"); 
}

@test:Config{
    enable: false
}
function deleteOneSproc(){
    io:println("-----------------Delete Stored Procedure-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    string sprocId = "sproc-50c4f0df-b25d-48ef-b936-d31a55798193";
    ResourceProperties properties = {};
    properties.databaseId = "hikall";
    properties.containerId = "mycollection1";
    var result = AzureCosmosClient->deleteStoredProcedure(properties,sprocId);   
    if result is DeleteResponse {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }    
    io:println("\n\n");  
}

@test:Config{
    enable: false
}
function executeOneSproc(){
    io:println("-----------------Execute Stored Procedure-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    string sprocId = "sproc-6ddd056a-0846-430d-9dff-a35425b346ad";
    ResourceProperties properties = {};
    properties.databaseId = "hikall";
    properties.containerId = "mycollection1";
    string[] arrayofparameters = ["Sachi"];
    var result = AzureCosmosClient->executeStoredProcedure(properties,sprocId,arrayofparameters);   
    if result is json {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }        
    io:println("\n\n"); 
}

@test:Config{
   enable: false
}
function createUDF(){
    io:println("-----------------Create user defined function-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    var uuid = createRandomUUID();
    string udfId = string `udf-${uuid.toString()}`;
    UserDefinedFunctionProperties properties = {};
    properties.databaseId = "database1";
    properties.containerId = "collection1";
    properties.userDefinedFunctionId = udfId;
    string udfbody = "function tax(income) {\r\n    if(income == undefined) \r\n        throw 'no input';\r\n    if (income < 1000) \r\n        return income * 0.1;\r\n    else if (income < 10000) \r\n        return income * 0.2;\r\n    else\r\n        return income * 0.4;\r\n}"; 
    UserDefinedFunction udf = {
        id:udfId,
        body:udfbody
    };
    var result = AzureCosmosClient->createUserDefinedFunction(properties,udf);  
    if result is UserDefinedFunction {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
    io:println("\n\n");  
}

@test:Config{
   enable: false
}
function replaceUDF(){
    io:println("-----------------Replace user defined function-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    string udfId = "udf-7b6f4b7f-7782-47a6-8dad-1fcbf04e9ac7";
    UserDefinedFunctionProperties properties = {};
    properties.databaseId = "database1";
    properties.containerId = "collection1";
    properties.userDefinedFunctionId = udfId;
    string udfbody = "function taxIncome(income) {\r\n    if(income == undefined) \r\n        throw 'no input';\r\n    if (income < 1000) \r\n        return income * 0.1;\r\n    else if (income < 10000) \r\n        return income * 0.2;\r\n    else\r\n        return income * 0.4;\r\n}"; 
    UserDefinedFunction udf = {
        id:udfId,
        body:udfbody
    };
    var result = AzureCosmosClient->replaceUserDefinedFunction(properties,udf);  
    if result is UserDefinedFunction {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
    io:println("\n\n");  
}

@test:Config{
   enable: false
}
function listUDF(){
    io:println("-----------------List all user defined functions-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    UserDefinedFunctionProperties properties = {};
    properties.databaseId = "database1";
    properties.containerId = "collection1";
   
    var result = AzureCosmosClient->listUserDefinedFunction(properties);  
    if result is UserDefinedFunctionList {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
    io:println("\n\n");  
}

@test:Config{
   enable: false
}
function deleteUDF(){
    io:println("-----------------Delete user defined function-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    var uuid = createRandomUUID();
    string udfId = "udf-7b6f4b7f-7782-47a6-8dad-1fcbf04e9ac7";
    UserDefinedFunctionProperties properties = {};
    properties.databaseId = "database1";
    properties.containerId = "collection1";
    properties.userDefinedFunctionId = udfId;

    var result = AzureCosmosClient->deleteUserDefinedFunction(properties);  
    if result is DeleteResponse {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
    io:println("\n\n");  
}

@test:Config{
   enable: false
}
function createTrigger(){
    io:println("-----------------Create trigger-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    var uuid = createRandomUUID();
    string triggerId = string `trigger-${uuid.toString()}`;
    TriggerProperties properties = {};
    
    properties.databaseId = "database1";
    properties.containerId = "collection1";
    properties.triggerId = triggerId;
    string triggerBody = "function tax(income) {\r\n    if(income == undefined) \r\n        throw 'no input';\r\n    if (income < 1000) \r\n        return income * 0.1;\r\n    else if (income < 10000) \r\n        return income * 0.2;\r\n    else\r\n        return income * 0.4;\r\n}";
    string triggerOperation = "All"; // All, Create, Replace, and Delete.
    string triggerType = "Post"; // he acceptable values are: Pre and Post. 
    Trigger trigger = {
        id:triggerId,
        body:triggerBody,
        triggerOperation:triggerOperation,
        triggerType: triggerType
    };
    var result = AzureCosmosClient->createTrigger(properties,trigger);  
    if result is Trigger {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
    io:println("\n\n");  
}

@test:Config{
   //enable: false
}
function replaceTrigger(){
    io:println("-----------------Replace trigger-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    TriggerProperties properties = {};
    string triggerId = "udf-1cf9a7bf-5d8e-47d8-b3e6-5804695cde5f";

    properties.databaseId = "database1";
    properties.containerId = "collection1";
    properties.triggerId = triggerId;
    string triggerBody = "function updateMetadata() {\r\n    var context = getContext();\r\n    var collection = context.getCollection();\r\n    var response = context.getResponse();\r\n    var createdDocument = response.getBody();\r\n\r\n    // query for metadata document\r\n    var filterQuery = 'SELECT * FROM root r WHERE r.id = \"_metadata\"';\r\n    var accept = collection.queryDocuments(collection.getSelfLink(), filterQuery,\r\n      updateMetadataCallback);\r\n    if(!accept) throw \"Unable to update metadata, abort\";\r\n\r\n    function updateMetadataCallback(err, documents, responseOptions) {\r\n      if(err) throw new Error(\"Error\" + err.message);\r\n           if(documents.length != 1) throw 'Unable to find metadata document';\r\n           var metadataDocument = documents[0];\r\n\r\n           // update metadata\r\n           metadataDocument.createdDocuments += 1;\r\n           metadataDocument.createdNames += \" \" + createdDocument.id;\r\n           var accept = collection.replaceDocument(metadataDocument._self,\r\n               metadataDocument, function(err, docReplaced) {\r\n                  if(err) throw \"Unable to update metadata, abort\";\r\n               });\r\n           if(!accept) throw \"Unable to update metadata, abort\";\r\n           return;          \r\n    }";
    string triggerOperation = "All"; // All, Create, Replace, and Delete.
    string triggerType = "Post"; // he acceptable values are: Pre and Post. 
    Trigger trigger = {
        id:triggerId,
        body:triggerBody,
        triggerOperation:triggerOperation,
        triggerType: triggerType
    };
    var result = AzureCosmosClient->replaceTrigger(properties,trigger);  
    if result is Trigger {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
    io:println("\n\n");  
}

@test:Config{
   enable: false
}
function listTriggers(){
    io:println("-----------------List triggers-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    TriggerProperties properties = {};
    properties.databaseId = "database1";
    properties.containerId = "collection1";
   
    var result = AzureCosmosClient->listTriggers(properties);  
    if result is TriggerList {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
    io:println("\n\n");  
}

@test:Config{
   enable: false
}
function deleteTrigger(){
    io:println("-----------------Delete user defined function-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    var uuid = createRandomUUID();
    string triggerId = "udf-8d3f5efc-aa33-490c-8dc8-6e91d1de1c7a";
    TriggerProperties properties = {};
    properties.databaseId = "database1";
    properties.containerId = "collection1";
    properties.triggerId = triggerId;

    var result = AzureCosmosClient->deleteTrigger(properties);  
    if result is DeleteResponse {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
    io:println("\n\n");  
}