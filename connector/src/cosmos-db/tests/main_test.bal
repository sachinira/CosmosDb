import ballerina/io;
import ballerina/test;
import ballerina/java;
import ballerina/config;
import ballerina/system;
import ballerina/log;

AzureCosmosConfiguration config = {
    baseUrl : getConfigValue("BASE_URL"),
    masterKey : getConfigValue("MASTER_KEY"),
    host : getConfigValue("HOST"),
    tokenType : getConfigValue("TOKEN_TYPE"),
    tokenVersion : getConfigValue("TOKEN_VERSION"),
    secureSocketConfig :{
                            trustStore: {
                            path: getConfigValue("b7a_home") + "/bre/security/ballerinaTruststore.p12",
                            password: getConfigValue("SSL_PASSWORD")
                            }
                        }
};

function createRandomUUID() returns handle = @java:Method {
    name : "randomUUID",
    'class : "java.util.UUID"
} external;

@tainted ResourceProperties properties = {
        databaseId: getConfigValue("TARGET_RESOURCE_DB"),
        containerId: getConfigValue("TARGET_RESOURCE_COLL")
};

var uuid = createRandomUUID();
Database database = {};
DatabaseList databaseList = {};

@test:Config{
    groups: ["database"]
}
function test_createDatabase(){
    log:printInfo("ACTION : createDatabase()");

    string createDatabaseId = string `database-${uuid.toString()}`;
    Client AzureCosmosClient = new(config);
    var result = AzureCosmosClient->createDatabase(createDatabaseId);
    if result is error {
        test:assertFail(msg = result.message());
    } else {
        database = <@untainted>result;
    }
}

@test:Config{
    groups: ["database"],
    dependsOn: ["test_createDatabase"]
}
function test_createDatabaseIfNotExist(){
    log:printInfo("ACTION : createIfNotExist()");

    Client AzureCosmosClient = new(config);
    string createDatabaseId = string `databasee-${uuid.toString()}`;
    var result = AzureCosmosClient->createDatabaseIfNotExist(createDatabaseId);
    if (result is Database?) {
        
    } else {
        test:assertFail(msg = result.message());
    }
}

@test:Config{
    groups: ["database"]
}
function test_createDatabaseWithManualThroughput(){
    log:printInfo("ACTION : createDatabaseWithManualThroughput()");

    string createDatabaseManualId = string `databasem-${uuid.toString()}`;
    ThroughputProperties manualThroughput = {
        throughput: 600
    };
    Client AzureCosmosClient = new(config); 
    var result = AzureCosmosClient->createDatabase(createDatabaseManualId, manualThroughput);
    if (result is Database) {

    } else {
        test:assertFail(msg = result.message());
    }
}

@test:Config{
    groups: ["database"]
}
function test_createDBWithAutoscalingThroughput(){
    log:printInfo("ACTION : createDBWithAutoscalingThroughput()");

    string createDatabaseAutoId = string `databasea-${uuid.toString()}`;
    ThroughputProperties tp = {
        maxThroughput: {"maxThroughput": 4000}
    };
    Client AzureCosmosClient = new(config);
    var result = AzureCosmosClient->createDatabase(createDatabaseAutoId, tp);
    if (result is Database) {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }
}

@test:Config{
    groups: ["database"]
}
function test_createDatabaseWithBothHeaders(){
    log:printInfo("ACTION : createDatabaseWithBothHeaders()");

    Client AzureCosmosClient = new(config);
    string createDatabaseBothId = string `database-${uuid.toString()}`;
    ThroughputProperties tp = {
        maxThroughput: {"maxThroughput" : 4000},
        throughput: 600
    };
    var result = AzureCosmosClient->createDatabase(createDatabaseBothId, tp);
    if (result is Database) {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }
}

@test:Config{
    groups: ["database"]
}
function test_listAllDatabases(){
    log:printInfo("ACTION : listAllDatabases()");

    Client AzureCosmosClient = new(config);
    var result = AzureCosmosClient->getAllDatabases();
    if (result is DatabaseList) {
        databaseList = <@untainted>result;
    } else {
        test:assertFail(msg = result.message());
    }
}

@test:Config{
    groups: ["database"],
    dependsOn: ["test_listAllDatabases"]
}
function test_listOneDatabase(){
    log:printInfo("ACTION : listOneDatabase()");

    Client AzureCosmosClient = new(config);
    var result = AzureCosmosClient->getDatabase(databaseList.databases[0].id);
    if (result is Database) {

    } else {
        test:assertFail(msg = result.message());
    }
}

@test:Config{
    groups: ["database"],
    dependsOn: ["test_createDatabase"]
}
function test_deleteDatabase(){
    log:printInfo("ACTION : deleteDatabase()");

    Client AzureCosmosClient = new(config);
    var result = AzureCosmosClient->deleteDatabase(databaseList.databases[databaseList.databases.length()-1].id);
    if result is error {
        test:assertFail(msg = result.message());
    } else {

    }
}

Container container = {};
ContainerList containerList = {};
//string throughput = "400";

@test:Config{
    groups: ["container"],
    dependsOn: ["test_createDatabase"]
}
function test_createContainer(){
    log:printInfo("ACTION : createContainer()");

    @tainted ResourceProperties propertiesNewCollection = {
            databaseId: database.id,
            containerId: string `container-${uuid.toString()}`
    };
    PartitionKey pk = {
        paths: ["/AccountNumber"],
        kind :"Hash",
        'version: 2
    };
    Client AzureCosmosClient = new(config);
    var result = AzureCosmosClient->createContainer(propertiesNewCollection,pk);
    if (result is Container) {
        container = <@untainted>result;
    } else {
        test:assertFail(msg = result.message());
    } 
}
 
@test:Config{
    groups: ["container"],
    dependsOn: ["test_createDatabase"]
}
function test_createContainerIfNotExist(string id){
    log:printInfo("ACTION : createContainerIfNotExist()");

    Client AzureCosmosClient = new(config);
    @tainted ResourceProperties propertiesNewCollectionIfNotExist = {
            databaseId: database.id,
            containerId: string `containere-${uuid.toString()}`
    };
    PartitionKey pk = {
        paths: ["/AccountNumber"],
        kind :"Hash",
        'version: 2
    };
    var result = AzureCosmosClient->createContainerIfNotExist(propertiesNewCollectionIfNotExist,pk);
    if (result is Container|error) {
        io:println(result);
    }
}

// @test:Config{
//     enable: false
// }
// function createCollectionWithManualThroughputAndIndexingPolicy(){
//     io:println("--------------Create Collection with manual throughput-----------------------\n\n");

//     Client AzureCosmosClient = new(config);
//     json indexingPolicy =   {  
//                                 "automatic": true,  
//                                 "indexingMode": "Consistent",  
//                                 "includedPaths": [  
//                                     {  
//                                         "path": "/*",  
//                                         "indexes": [  
//                                         {  
//                                             "dataType": "String",  
//                                             "precision": -1,  
//                                             "kind": "Range"  
//                                         }  
//                                         ]  
//                                     }  
//                                 ]  
//                             };
    
    
//     ThroughputProperties tp = {};
//     tp.throughput = 600; 
//     PartitionKey pk = {};
//     pk.paths = ["/AccountNumber"];
//     pk.kind = "Hash";
//     pk.'version = 2;
//     ContainerProperties con = {};
//     con.partitionKey = pk;
//     con.databaseId = "hikall";
//     con.containerId = "mycollect";
//     var result = AzureCosmosClient->createContainer(con, tp);
//     if (result is Container) {
//         io:println(result);
//     } else {
//         test:assertFail(msg = result.message());
//     } 
//     io:println("\n\n");
// }

//create collection with autoscale testcase comes here

@test:Config{
    groups: ["container"],
    dependsOn: ["test_createDatabase"]
}
function test_getAllContainers(){
    log:printInfo("ACTION : getAllContainers()");

    Client AzureCosmosClient = new(config);
    var result = AzureCosmosClient->getAllContainers(database.id);
    if (result is ContainerList) {
        containerList = <@untainted>result;
    } else {
        test:assertFail(msg = result.message());
    }
    io:println("\n\n");
}


@test:Config{
    groups: ["container"],
    dependsOn: ["test_createDatabase", "test_createContainer"]
}
function test_getOneContainer(){
    log:printInfo("ACTION : getAllContainers()");

    Client AzureCosmosClient = new(config);
    @tainted ResourceProperties getCollection = {
        databaseId: database.id,
        containerId: container.id
    };
    var result = AzureCosmosClient->getContainer(getCollection);
    if (result is Container) {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }
}

@test:Config{
    groups: ["container"],
    dependsOn: ["test_getAllContainers"]
}
function test_deleteContainer(){
    log:printInfo("ACTION : deleteContainer()");

    Client AzureCosmosClient = new(config); 
    @tainted ResourceProperties deleteCollectionData = {
            databaseId: database.id,
            containerId: containerList.containers[containerList.containers.length()-1].id
    };
    var result = AzureCosmosClient->deleteContainer(deleteCollectionData);
    if result is error {
        test:assertFail(msg = result.message());
    }
}

@test:Config{
    groups: ["partitionKey"]
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
}

string createDocumentId = "";//uuid.toString();
Document createDoc = {
        id:createDocumentId,
        documentBody :{
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
        },
        partitionKey : 1234  
    };


RequestHeaderOptions reqOptions = {
        isUpsertRequest:true
};

@test:Config{
    groups: ["document"]
}
function createDocument(){
    io:println("--------------Create One document------------------------\n\n");

    Client AzureCosmosClient = new(config);
    var result = AzureCosmosClient->createDocument(properties, createDoc, reqOptions);
    if result is Document {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
    
    io:println("\n\n");
}

//with indexing or upsert headers test case comes here
@test:Config{
    groups: ["document"]
}
function GetDocumentList(){
    io:println("--------------Get all documents in a collection------------------------\n\n");

    Client AzureCosmosClient = new(config);
    var result = AzureCosmosClient->getDocumentList(properties);
    if (result is DocumentList) {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }
    io:println("\n\n");
}

@tainted Document getDoc =  {
    id: "080b7d03-a0d4-48d8-9cfe-89760d2c04e5",
    partitionKey : 1234  
};
@test:Config{
    groups: ["document"]
}
function GetOneDocument(){
    io:println("--------------Get one document------------------------\n\n");

    Client AzureCosmosClient = new(config);
    var result = AzureCosmosClient->getDocument(properties,getDoc);
    if (result is Document) {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
    io:println("\n\n");
}

@tainted Document deleteDoc =  {
    id: "5e10b6e4-68ec-4fe6-ac14-452cc5864669",
    partitionKey : 1234  
};
@test:Config{
    groups: ["document"]
}
function deleteDocument(){
    io:println("--------------Delete one document------------------------\n\n");
    
    Client AzureCosmosClient = new(config);
    //dc.partitionKey = 1234;
    //dc.documentId = "69a2c93a-42e6-487e-b6f3-1a355f1afd19";
    var result = AzureCosmosClient->deleteDocument(properties,deleteDoc);  
    if result is boolean {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
    io:println("\n\n"); 
}

int partitionKey = 1234;
//QueryParameter[] params = [{name: "@id", value: "46c25391-e11d-4327-b7c5-28f44bcf3f2f"}];
Query sqlQuery = {
    query: "SELECT * FROM collection1 f WHERE f.Address.City = 'Seattle'",
    parameters: []
};

@test:Config{
    groups: ["document"]
}
function queryDocument(){
    io:println("--------------Query one document-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    var result = AzureCosmosClient->queryDocument(properties,partitionKey,sqlQuery);   
    if result is json {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }    
    io:println("\n\n");  
}

string sprocId = string `sproc-${uuid.toString()}`;
string createSprocBody = "function () {\r\n    var context = getContext();\r\n    var response = context.getResponse();\r\n\r\n    response.setBody(\"Hello, World\");\r\n}"; 
string replaceSprocId = "sproc-263791e9-a06a-4a47-b232-c3f7496d5557";
string replaceSprocBody = "function (personToGreet) {\r\n    var context = getContext();\r\n    var response = context.getResponse();\r\n\r\n    response.setBody(\"Hello, \" + personToGreet);\r\n}";
string deleteSprocId = "sproc-ac986086-a7b0-4c9b-a6c7-440d9a275e5d";
string executeSprocId = "sproc-263791e9-a06a-4a47-b232-c3f7496d5557";

@test:Config{
    groups: ["storedProcedure"]
}
function createSproc(){
    io:println("-----------------Create stored procedure-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    StoredProcedure sp = {
        id:sprocId,
        body:createSprocBody
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
    groups: ["storedProcedure"],
    dependsOn: ["createSproc"]
}
function replaceSproc(){
    io:println("-----------------Replace stored procedure-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    StoredProcedure sp = {
        id:replaceSprocId,
        body:replaceSprocBody
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
    groups: ["storedProcedure"]
}
function getAllSprocs(){
    io:println("-----------------Get All Stored Procedures-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    var result = AzureCosmosClient->listStoredProcedures(properties);   
    if result is StoredProcedureList {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
    io:println("\n\n"); 
}

@test:Config{
    groups: ["storedProcedure"]
}
function deleteOneSproc(){
    io:println("-----------------Delete Stored Procedure-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    var result = AzureCosmosClient->deleteStoredProcedure(properties,deleteSprocId);   
    if result is boolean {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }    
    io:println("\n\n");  
}

@test:Config{
    groups: ["storedProcedure"]
}
function executeOneSproc(){
    io:println("-----------------Execute Stored Procedure-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    string[] arrayofparameters = ["Sachi"];
    var result = AzureCosmosClient->executeStoredProcedure(properties,executeSprocId,arrayofparameters);   
    if result is json {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }        
    io:println("\n\n"); 
}

string udfId = string `udf-${uuid.toString()}`;
string createUDFBody = "function tax(income) {\r\n    if(income == undefined) \r\n        throw 'no input';\r\n    if (income < 1000) \r\n        return income * 0.1;\r\n    else if (income < 10000) \r\n        return income * 0.2;\r\n    else\r\n        return income * 0.4;\r\n}"; 
string replaceUDFId = "udf-2972a27c-a447-47f4-9a8d-0daa0fa3e37a";
string replaceUDFBody = "function taxIncome(income) {\r\n    if(income == undefined) \r\n        throw 'no input';\r\n    if (income < 1000) \r\n        return income * 0.1;\r\n    else if (income < 10000) \r\n        return income * 0.2;\r\n    else\r\n        return income * 0.4;\r\n}"; 
string deleteUDFId = "udf-7b6f4b7f-7782-47a6-8dad-1fcbf04e9ac7";

@test:Config{
    groups: ["userDefineFunction"]
}
function createUDF(){
    io:println("-----------------Create user defined function-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    UserDefinedFunction udf = {
        id:udfId,
        body:createUDFBody
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
    groups: ["userDefineFunction"]
}
function replaceUDF(){
    io:println("-----------------Replace user defined function-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    UserDefinedFunction udf = {
        id:replaceUDFId,
        body:replaceUDFBody
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
    groups: ["userDefineFunction"]
}
function listUDF(){
    io:println("-----------------List all user defined functions-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    var result = AzureCosmosClient->listUserDefinedFunctions(properties);  
    if result is UserDefinedFunctionList {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
    io:println("\n\n");  
}

@test:Config{
    groups: ["userDefineFunction"]
}
function deleteUDF(){
    io:println("-----------------Delete user defined function-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    var uuid = createRandomUUID();
    var result = AzureCosmosClient->deleteUserDefinedFunction(properties,deleteUDFId);  
    if result is boolean {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
    io:println("\n\n");  
}

string triggerId = string `trigger-${uuid.toString()}`;
string createTriggerBody = "function tax(income) {\r\n    if(income == undefined) \r\n        throw 'no input';\r\n    if (income < 1000) \r\n        return income * 0.1;\r\n    else if (income < 10000) \r\n        return income * 0.2;\r\n    else\r\n        return income * 0.4;\r\n}";
string createTriggerOperation = "All"; // All, Create, Replace, and Delete.
string createTriggerType = "Post"; // he acceptable values are: Pre and Post. 
string replaceTriggerId = "udf-1cf9a7bf-5d8e-47d8-b3e6-5804695cde5f";
string replaceTriggerBody = "function updateMetadata() {\r\n    var context = getContext();\r\n    var collection = context.getCollection();\r\n    var response = context.getResponse();\r\n    var createdDocument = response.getBody();\r\n\r\n    // query for metadata document\r\n    var filterQuery = 'SELECT * FROM root r WHERE r.id = \"_metadata\"';\r\n    var accept = collection.queryDocuments(collection.getSelfLink(), filterQuery,\r\n      updateMetadataCallback);\r\n    if(!accept) throw \"Unable to update metadata, abort\";\r\n\r\n    function updateMetadataCallback(err, documents, responseOptions) {\r\n      if(err) throw new Error(\"Error\" + err.message);\r\n           if(documents.length != 1) throw 'Unable to find metadata document';\r\n           var metadataDocument = documents[0];\r\n\r\n           // update metadata\r\n           metadataDocument.createdDocuments += 1;\r\n           metadataDocument.createdNames += \" \" + createdDocument.id;\r\n           var accept = collection.replaceDocument(metadataDocument._self,\r\n               metadataDocument, function(err, docReplaced) {\r\n                  if(err) throw \"Unable to update metadata, abort\";\r\n               });\r\n           if(!accept) throw \"Unable to update metadata, abort\";\r\n           return;          \r\n    }";
string replaceTriggerOperation = "All"; // All, Create, Replace, and Delete.
string replaceTriggerType = "Post"; // he acceptable values are: Pre and Post. 
string deleteTriggerId = "udf-8d3f5efc-aa33-490c-8dc8-6e91d1de1c7a";

@test:Config{
    groups: ["Trigger"]
}
function createTrigger(){
    io:println("-----------------Create trigger-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    var uuid = createRandomUUID();
    Trigger trigger = {
        id:triggerId,
        body:createTriggerBody,
        triggerOperation:createTriggerOperation,
        triggerType: createTriggerType
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
    groups: ["Trigger"]
}
function replaceTrigger(){
    io:println("-----------------Replace trigger-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    Trigger trigger = {
        id:replaceTriggerId,
        body:replaceTriggerBody,
        triggerOperation:replaceTriggerOperation,
        triggerType: replaceTriggerType
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
    groups: ["Trigger"]
}
function listTriggers(){
    io:println("-----------------List triggers-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    var result = AzureCosmosClient->listTriggers(properties);  
    if result is TriggerList {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
    io:println("\n\n");  
}

@test:Config{
    groups: ["Trigger"]
}
function deleteTrigger(){
    io:println("-----------------Delete trigger-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    var uuid = createRandomUUID();
    var result = AzureCosmosClient->deleteTrigger(properties,deleteTriggerId);  
    if result is boolean {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
    io:println("\n\n");  
}

string userId = string `user-${uuid.toString()}`;
string replaceUserId = "userr-c04de06a-df65-4c94-b7ae-8e9c5cf5611a";
string deleteUserId = "user-0b5df167-dc9f-4395-9ba3-f561fc166e97";
string getUserId = "user-af93f765-fad1-418d-98ef-9cad66886e36";

@test:Config{
    groups: ["user"]
}
function createUser(){
    io:println("-----------------Create user-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    var result = AzureCosmosClient->createUser(properties,userId);  
    if result is User {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
    io:println("\n\n");  
}

@test:Config{
    groups: ["user"]
}
function replaceUser(){
    io:println("-----------------Replace user id-----------------------\n\n");
    string newReplaceId = string `user-${uuid.toString()}`;

    Client AzureCosmosClient = new(config);
    var result = AzureCosmosClient->replaceUserId(properties,replaceUserId,newReplaceId);  
    if result is User {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
    io:println("\n\n");  
}

@test:Config{
    groups: ["user"]
}
function getUser(){
    io:println("-----------------Get user-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    var result = AzureCosmosClient->getUser(properties,getUserId);  
    if result is User {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
    io:println("\n\n");  
}

@test:Config{
    groups: ["user"]
}
function listUsers(){
    io:println("-----------------List users-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    var result = AzureCosmosClient->listUsers(properties);  
    if result is UserList {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
    io:println("\n\n");  
}

@test:Config{
    groups: ["user"]
}
function deleteUser(){
    io:println("-----------------Delete user-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    var uuid = createRandomUUID();
    var result = AzureCosmosClient->deleteUser(properties,deleteUserId);  
    if result is boolean {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
    io:println("\n\n");  
}

//different permissions cannot be created for same resource, already existing permissions can be replaced"
string permissionId = string `permission-${uuid.toString()}`;
string permissionModeCreate = "Read";
string createResource = "dbs/database1/colls/collection1";
string permissionUserId = "user-41a5c42e-2a54-45b0-90da-41da2abe8cd0";
string getPermissionId = "permission-81f21af0-221d-407d-b7d3-b1cd69a9b2e5";
string replacePermissionUser = "";
string replacePermissionId = "";
string permissionModeReplace = "All";
string replaceResource = "dbs/database1/colls/collection1";
string deletePermissionUserId = "user-010c59a5-065d-43df-862e-cb72966e0b19";
string deletePermissionId = "permission-2069981b-a529-438e-b8a6-a3d2546cdfdf";

@test:Config{
    groups: ["permission"]
}
function createPermission(){
    io:println("-----------------Create permission-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    Permission permission = {
        id:permissionId,
        permissionMode:permissionModeCreate,
        'resource:createResource
    };
    var result = AzureCosmosClient->createPermission(properties,permissionUserId,permission);  
    if result is Permission {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
    io:println("\n\n");  
}

@test:Config{
    groups: ["permission"]
}
function replacePermission(){
    io:println("-----------------Replace permission-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    Permission permission = {
        id:replacePermissionId,
        permissionMode:permissionModeReplace,
        'resource:replaceResource
    };
    var result = AzureCosmosClient->replacePermission(properties,replacePermissionUser,permission);  
    if result is Permission {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
    io:println("\n\n");  
}

@test:Config{
    groups: ["permission"]
}
function listPermissions(){
    io:println("-----------------list permissions-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    var result = AzureCosmosClient->listPermissions(properties,permissionUserId);  
    if result is PermissionList {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
    io:println("\n\n");  
}

@test:Config{
    groups: ["permission"]
}
function getPermission(){
    io:println("-----------------list one Permission-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    var result = AzureCosmosClient->getPermission(properties,permissionUserId,getPermissionId);  
    if result is Permission {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
    io:println("\n\n");  
}

@test:Config{
    groups: ["permission"],
    dependsOn: ["listPermissions","getPermission"]
}
function deletePermission(){
    io:println("-----------------Delete permission-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    var uuid = createRandomUUID();
    var result = AzureCosmosClient->deletePermission(properties,deletePermissionUserId,deletePermissionId);  
    if result is boolean {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
    io:println("\n\n");  
}

@test:Config{
    groups: ["offer"]
}
function listOffers(){
    io:println("-----------------list offers-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    var result = AzureCosmosClient->listOffers();  
    if result is OfferList {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
    io:println("\n\n");  
}

string getOfferId = "vHIQ";

@test:Config{
    groups: ["offer"]
}
function listOffer(){
    io:println("-----------------list one offer-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    var result = AzureCosmosClient->getOffer(getOfferId);  
    if result is Offer {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
    io:println("\n\n");  
}

Offer replaceOfferBody = {
    offerVersion: "V2",
    offerType: "Invalid",    
    content: {  
        "offerThroughput": 600
    }, 
    'resource: "dbs/InV1AA==/colls/InV1AOOYBOo=/",  
    offerResourceId: "InV1AJmRKts=",
    id: "vHIQ",
    _rid: "vHIQ" 
};
@test:Config{
    groups: ["offer"]
}
function replaceOffer(){
    io:println("-----------------Replace offer-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    var result = AzureCosmosClient->replaceOffer(replaceOfferBody);  
    if result is Offer {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
    io:println("\n\n");  
}

Query offerQuery = {
   query: string `SELECT * FROM collection1 WHERE (collection1["_self"]) = "dbs/InV1AA==/colls/InV1AItrS0w=/"`
};

@test:Config{
    groups: ["offer"]
}
function queryOffer(Query offer){
    io:println("--------------Query offer-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    var result = AzureCosmosClient->queryOffer(offerQuery);   
    if result is json {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }    
    io:println("\n\n");  
}

function getConfigValue(string key) returns string {
    return (system:getEnv(key) != "") ? system:getEnv(key) : config:getAsString(key);
}
