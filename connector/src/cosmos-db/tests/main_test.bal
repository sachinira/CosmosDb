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

Database database = {};
DatabaseList databaseList = {};

@test:Config{
    groups: ["database"]
}
function test_createDatabase(){
    log:printInfo("ACTION : createDatabase()");

    var uuid = createRandomUUID();
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
    var uuid = createRandomUUID();
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

    var uuid = createRandomUUID();
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

    Client AzureCosmosClient = new(config);

    var uuid = createRandomUUID();
    string createDatabaseAutoId = string `databasea-${uuid.toString()}`;
    ThroughputProperties tp = {
        maxThroughput: {"maxThroughput": 4000}
    };
    var result = AzureCosmosClient->createDatabase(createDatabaseAutoId, tp);
    if (result is Database) {

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
    var uuid = createRandomUUID();
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

//everything depends except offers and permissions
@test:Config{
    groups: ["database"],
    dependsOn: ["test_createDatabase"],
    enable: false
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

@test:Config{
    groups: ["container"],
    dependsOn: ["test_createDatabase"]
}
function test_createContainer(){
    log:printInfo("ACTION : createContainer()");

    Client AzureCosmosClient = new(config);
    var uuid = createRandomUUID();
    @tainted ResourceProperties propertiesNewCollection = {
            databaseId: database.id,
            containerId: string `container-${uuid.toString()}`
    };
    PartitionKey pk = {
        paths: ["/AccountNumber"],
        kind :"Hash",
        'version: 2
    };
    var result = AzureCosmosClient->createContainer(propertiesNewCollection,pk);
    if (result is Container) {
        container = <@untainted>result;
    } else {
        test:assertFail(msg = result.message());
    } 
}

//@test:Config{
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
 
// @test:Config{
//     groups: ["container"],
//     dependsOn: ["test_createDatabase", "test_getOneContainer"]
// }
// function test_createContainerIfNotExist(string id){
//     log:printInfo("ACTION : createContainerIfNotExist()");
//     io:println(database.id);

//     Client AzureCosmosClient = new(config);
//     @tainted ResourceProperties propertiesNewCollectionIfNotExist = {
//             databaseId: database.id,
//             containerId: string `containere-${uuid.toString()}`
//     };
//     PartitionKey pk = {
//         paths: ["/AccountNumber"],
//         kind :"Hash",
//         'version: 2
//     };
//     var result = AzureCosmosClient->createContainerIfNotExist(propertiesNewCollectionIfNotExist,pk);
//     if (result is Container?) {
//         io:println(result);
//     } else {
//         test:assertFail(msg = result.message());
//     }
// }

@test:Config{
    groups: ["container"],
    dependsOn: ["test_createDatabase", "test_createContainer"]
}
function test_getOneContainer(){
    log:printInfo("ACTION : getOneContainer()");

    Client AzureCosmosClient = new(config);
    @tainted ResourceProperties getCollection = {
        databaseId: database.id,
        containerId: container.id
    };
    var result = AzureCosmosClient->getContainer(getCollection);
    if (result is Container) {

    } else {
        test:assertFail(msg = result.message());
    }
}

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
}

//everything depends except offers and permissions
@test:Config{
    groups: ["container"],
    dependsOn: ["test_getAllContainers"],
    enable: false
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

//not tested
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

//write testcase with requestoptions
// RequestHeaderOptions reqOptions = {
//         isUpsertRequest:true
// };
Document document = {};

@test:Config{
    groups: ["document"],
    dependsOn: ["test_createDatabase", "test_createContainer"]
}
function test_createDocument(){
    log:printInfo("ACTION : createDocument()");

    Client AzureCosmosClient = new(config);
    var uuid = createRandomUUID();
    @tainted ResourceProperties resourceProperty = {
        databaseId: database.id,
        containerId: container.id
    };
    Document createDoc = {
        id: string `document-${uuid.toString()}`,
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
    RequestHeaderOptions options = {
        isUpsertRequest: true
    };
    var result = AzureCosmosClient->createDocument(resourceProperty, createDoc, options);
    if result is Document {
        document = <@untainted>result;
    } else {
        test:assertFail(msg = result.message());
    }   
}

//with indexing or upsert headers test case comes here replace document
@test:Config{
    groups: ["document"],
    dependsOn: ["test_createDatabase", "test_createContainer", "test_createDocument"]
}
function test_getDocumentList(){
    log:printInfo("ACTION : getDocumentList()");

    Client AzureCosmosClient = new(config);
    @tainted ResourceProperties resourceProperty = {
        databaseId: database.id,
        containerId: container.id
    };
    var result = AzureCosmosClient->getDocumentList(resourceProperty);
    if (result is DocumentList) {

    } else {
        test:assertFail(msg = result.message());
    }
}

@test:Config{
    groups: ["document"],
    dependsOn: ["test_createDatabase", "test_createContainer", "test_createDocument"]
}
function test_GetOneDocument(){
    log:printInfo("ACTION : GetOneDocument()");

    Client AzureCosmosClient = new(config);
    @tainted ResourceProperties resourceProperty = {
        databaseId: database.id,
        containerId: container.id
    };
    @tainted Document getDoc =  {
        id: document.id,
        partitionKey : 1234  
    };
    var result = AzureCosmosClient->getDocument(resourceProperty,getDoc);
    if (result is Document) {
        
    } else {
        test:assertFail(msg = result.message());
    }   
}

//document operations depends
@test:Config{
    groups: ["document"],
    dependsOn: ["test_createDatabase", "test_createContainer", "test_GetOneDocument"]
}
function test_deleteDocument(){
    log:printInfo("ACTION : deleteDocument()");
    
    Client AzureCosmosClient = new(config);
    @tainted ResourceProperties resourceProperty = {
        databaseId: database.id,
        containerId: container.id
    };
    @tainted Document deleteDoc =  {
        id: document.id,
        partitionKey : 1234  
    };
    var result = AzureCosmosClient->deleteDocument(resourceProperty,deleteDoc);  
    if result is boolean {

    } else {
        test:assertFail(msg = result.message());
    }   
}

@test:Config{
    groups: ["document"],
    dependsOn: ["test_createDatabase", "test_createContainer"]
}
function test_queryDocuments(){
    log:printInfo("ACTION : queryDocuments()");

    Client AzureCosmosClient = new(config);
    @tainted ResourceProperties resourceProperty = {
        databaseId: database.id,
        containerId: container.id
    };
    int partitionKey = 1234;//get the pk from endpoint
    Query sqlQuery = {
        query: string `SELECT * FROM ${container.id.toString()} f WHERE f.Address.City = 'Seattle'`,
        parameters: []
    };
    //QueryParameter[] params = [{name: "@id", value: "46c25391-e11d-4327-b7c5-28f44bcf3f2f"}];
    var result = AzureCosmosClient->queryDocuments(resourceProperty,partitionKey,sqlQuery);   
    if result is json {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }    
}

StoredProcedure storedPrcedure = {};

@test:Config{
    groups: ["storedProcedure"],
    dependsOn: ["test_createDatabase", "test_createContainer"]
}
function test_createStoredProcedure(){
    log:printInfo("ACTION : createStoredProcedure()");

    Client AzureCosmosClient = new(config);
    var uuid = createRandomUUID();
    @tainted ResourceProperties resourceProperty = {
        databaseId: database.id,
        containerId: container.id
    };
    string createSprocBody = "function () {\r\n    var context = getContext();\r\n    var response = context.getResponse();\r\n\r\n    response.setBody(\"Hello, World\");\r\n}"; 
    StoredProcedure sp = {
        id: string `sproc-${uuid.toString()}`,
        body:createSprocBody
    };
    var result = AzureCosmosClient->createStoredProcedure(resourceProperty,sp);  
    if result is StoredProcedure {
        storedPrcedure = <@untainted> result;
    } else {
        test:assertFail(msg = result.message());
    }   
}

@test:Config{
    groups: ["storedProcedure"],
    dependsOn: ["test_createStoredProcedure"]
}
function test_replaceStoredProcedure(){
    log:printInfo("ACTION : replaceStoredProcedure()");

    Client AzureCosmosClient = new(config);
    @tainted ResourceProperties resourceProperty = {
        databaseId: database.id,
        containerId: container.id
    };
    string replaceSprocBody = "function heloo(personToGreet) {\r\n    var context = getContext();\r\n    var response = context.getResponse();\r\n\r\n    response.setBody(\"Hello, \" + personToGreet);\r\n}";
    StoredProcedure sp = {
        id: storedPrcedure.id,
        body: replaceSprocBody
    }; 
    var result = AzureCosmosClient->replaceStoredProcedure(resourceProperty,sp);  
    if result is StoredProcedure {

    } else {
        test:assertFail(msg = result.message());
    }   
}

@test:Config{
    groups: ["storedProcedure"],
    dependsOn: ["test_createDatabase", "test_createContainer"]
}
function test_getAllStoredProcedures(){
    log:printInfo("ACTION : replaceStoredProcedure()");

    Client AzureCosmosClient = new(config);
    @tainted ResourceProperties resourceProperty = {
        databaseId: database.id,
        containerId: container.id
    };
    var result = AzureCosmosClient->listStoredProcedures(resourceProperty);   
    if result is StoredProcedureList {
        
    } else {
        test:assertFail(msg = result.message());
    }   
}

@test:Config{
    groups: ["storedProcedure"],
    dependsOn: ["test_createStoredProcedure","test_replaceStoredProcedure"]
}
function test_executeOneStoredProcedure(){
    log:printInfo("ACTION : executeOneStoredProcedure()");

    Client AzureCosmosClient = new(config);
    @tainted ResourceProperties resourceProperty = {
        databaseId: database.id,
        containerId: container.id
    };
    string executeSprocId = storedPrcedure.id;
    string[] arrayofparameters = ["Sachi"];
    var result = AzureCosmosClient->executeStoredProcedure(resourceProperty,executeSprocId,arrayofparameters);   
    if result is json {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }        
}

@test:Config{
    groups: ["storedProcedure"],
    dependsOn: ["test_createStoredProcedure", "test_replaceStoredProcedure", "test_executeOneStoredProcedure"]
}
function test_deleteOneStoredProcedure(){
    log:printInfo("ACTION : deleteOneStoredProcedure()");

    Client AzureCosmosClient = new(config);
    @tainted ResourceProperties resourceProperty = {
        databaseId: database.id,
        containerId: container.id
    };
    string deleteSprocId = storedPrcedure.id;
    var result = AzureCosmosClient->deleteStoredProcedure(resourceProperty,deleteSprocId);   
    if result is boolean {

    } else {
        test:assertFail(msg = result.message());
    }    
}

UserDefinedFunction udf = {};

@test:Config{
    groups: ["userDefinedFunction"],
    dependsOn: ["test_createDatabase", "test_createContainer"]
}
function test_createUDF(){
    log:printInfo("ACTION : createUDF()");

    Client AzureCosmosClient = new(config);
    var uuid = createRandomUUID();
    @tainted ResourceProperties resourceProperty = {
        databaseId: database.id,
        containerId: container.id
    };
    string udfId = string `udf-${uuid.toString()}`;
    string createUDFBody = "function tax(income) {\r\n    if(income == undefined) \r\n        throw 'no input';\r\n    if (income < 1000) \r\n        return income * 0.1;\r\n    else if (income < 10000) \r\n        return income * 0.2;\r\n    else\r\n        return income * 0.4;\r\n}"; 
    UserDefinedFunction createUdf = {
        id: udfId,
        body: createUDFBody
    };
    var result = AzureCosmosClient->createUserDefinedFunction(resourceProperty,createUdf);  
    if result is UserDefinedFunction {
        udf = <@untainted> result;
    } else {
        test:assertFail(msg = result.message());
    }   
}

@test:Config{
    groups: ["userDefinedFunction"],
    dependsOn: ["test_createDatabase", "test_createContainer", "test_createUDF"]
}
function test_replaceUDF(){
    log:printInfo("ACTION : replaceUDF()");

    Client AzureCosmosClient = new(config);
    @tainted ResourceProperties resourceProperty = {
        databaseId: database.id,
        containerId: container.id
    };
    string replaceUDFBody = "function taxIncome(income) {\r\n    if(income == undefined) \r\n        throw 'no input';\r\n    if (income < 1000) \r\n        return income * 0.1;\r\n    else if (income < 10000) \r\n        return income * 0.2;\r\n    else\r\n        return income * 0.4;\r\n}"; 
    io:println(udf.id);
    UserDefinedFunction replacementUdf = {
        id: udf.id,
        body:replaceUDFBody
    };
    var result = AzureCosmosClient->replaceUserDefinedFunction(resourceProperty,replacementUdf);  
    if result is UserDefinedFunction {

    } else {
        test:assertFail(msg = result.message());
    }   
}


@test:Config{
    groups: ["userDefinedFunction"],
    dependsOn: ["test_createDatabase", "test_createContainer", "test_createUDF"]
}
function test_listAllUDF(){
    log:printInfo("ACTION : listAllUDF()");

    Client AzureCosmosClient = new(config);
    @tainted ResourceProperties resourceProperty = {
        databaseId: database.id,
        containerId: container.id
    };
    var result = AzureCosmosClient->listUserDefinedFunctions(resourceProperty);  
    if result is UserDefinedFunctionList {

    } else {
        test:assertFail(msg = result.message());
    }   
}

@test:Config{
    groups: ["userDefinedFunction"],
    dependsOn: ["test_createUDF", "test_replaceUDF", "test_listAllUDF"]
}
function test_deleteUDF(){
    log:printInfo("ACTION : deleteUDF()");

    Client AzureCosmosClient = new(config);
    var uuid = createRandomUUID();
    string deleteUDFId = udf.id;
    @tainted ResourceProperties resourceProperty = {
        databaseId: database.id,
        containerId: container.id
    };
    var result = AzureCosmosClient->deleteUserDefinedFunction(resourceProperty,deleteUDFId);  
    if result is boolean {

    } else {
        test:assertFail(msg = result.message());
    }   
}

var uuid = createRandomUUID();

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
