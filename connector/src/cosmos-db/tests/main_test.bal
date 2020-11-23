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
    var result = AzureCosmosClient->createDatabase("hiiiii2");
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
function createDBWithManualThroughput(){
    io:println("--------------Create with manual throguput------------------------\n\n");

    Client AzureCosmosClient = new(config);
    ThroughputProperties tp = {};
    tp.throughput = 600; 
    var result = AzureCosmosClient->createDatabase("heloodb", tp);
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
    ThroughputProperties tp = {};
    tp.maxThroughput = {"maxThroughput": 4000};
    var result = AzureCosmosClient->createDatabase("helooauto", tp);
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
    var result = AzureCosmosClient->createDatabase("helooboth", tp);
    if (result is Database) {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }
    io:println("\n\n");
}

@test:Config{
   //enable: false
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
    //enable: false
}
function listOneDB(){
    io:println("--------------List one database------------------------\n\n");

    Client AzureCosmosClient = new(config); 
    var result = AzureCosmosClient->getDatabase("hikall");
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
    var result = AzureCosmosClient->deleteDatabase("tempdb2");
    io:println(result);
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
    pk.Version = 2;
    ContainerProperties con = {};
    con.partitionKey = pk;
    con.databaseId = "hikall";
    con.containerId = "new1";
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
    pk.Version = 2;
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
    //enable: false
}
function getOneCollection(){
    io:println("--------------Get One collection-----------------------\n\n");

    Client AzureCosmosClient = new(config);
    ContainerProperties con = {};
    con.databaseId = "hikall";
    con.containerId = "mycollection1";
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
    RequestOptions reqOptions = {
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
    RequestOptions options = {};
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
    StoredProcedureProperties properties = {};
    properties.databaseId = "hikall";
    properties.containerId = "mycollection1";
    properties.storedProcedureId = sprocId;
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
    StoredProcedureProperties properties = {};
    properties.databaseId = "hikall";
    properties.containerId = "mycollection1";
    properties.storedProcedureId = sprocId;
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
    StoredProcedureProperties properties = {};
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
    StoredProcedureProperties properties = {};
    properties.databaseId = "hikall";
    properties.containerId = "mycollection1";
    properties.storedProcedureId = sprocId; 
    var result = AzureCosmosClient->deleteStoredProcedure(properties);   
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
    StoredProcedureProperties properties = {};
    properties.databaseId = "hikall";
    properties.containerId = "mycollection1";
    properties.storedProcedureId = sprocId; 
    string[] arrayofparameters = ["Sachi"];
    var result = AzureCosmosClient->executeStoredProcedure(properties,arrayofparameters);   
    if result is json {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }        
    io:println("\n\n"); 
}






