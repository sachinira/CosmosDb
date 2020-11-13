import ballerina/io;
import ballerina/test;
//import ballerina/http;


AuthConfig config = {
        baseUrl: BASE_URL,
        masterKey: MASTER_KEY,
        host: HOST,
        apiVersion:API_VERSION
};

@test:Config{
    enable: false

}
function createDB(){


    io:println("--------------Create database------------------------\n\n");

    Databases AzureCosmosClient = new(config);
    
    var result = AzureCosmosClient->createDatabase("heloojava",(),());

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


    Databases AzureCosmosClient = new(config);
    
    var result = AzureCosmosClient->listDatabases();

    if (result is DBList) {
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

    Databases AzureCosmosClient = new(config);
    
    var result = AzureCosmosClient->listOneDatabase("tempdb");

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


    Databases AzureCosmosClient = new(config);
    
    var result = AzureCosmosClient->deleteDatabase("heloo");

    io:println(result);
   
    io:println("\n\n");

}

@test:Config{
    enable: false

}
function createCollection(){

    io:println("--------------Create Collection-----------------------\n\n");


    Databases AzureCosmosClient = new(config);

    json partitionkey = {  
                            "paths": ["/AccountNumber"], 
                            "kind": "Hash",
                            "Version": 2
                        };
    string throughput = "400";

    var result = AzureCosmosClient->createCollection("hikall","mycollection1",(),partitionkey,());


    if (result is Collection) {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
    io:println("\n\n");

}


@test:Config{
    enable: false

}
function getAllCollections(){

    io:println("--------------Get All collections-----------------------\n\n");


    Databases AzureCosmosClient = new(config);

    var result = AzureCosmosClient->getAllCollections("hikall");

    if (result is CollectionList) {
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

    io:println("--------------Get One collections-----------------------\n\n");


    Databases AzureCosmosClient = new(config);

    var result = AzureCosmosClient->getOneCollection("tempdb","tempcoll");

    if (result is Collection) {
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


    Databases AzureCosmosClient = new(config);
    
    var result = AzureCosmosClient->deleteCollection("tempdb","tempcoll5");

    io:println(result);
   
    io:println("\n\n");

}

@test:Config{
}
function GetPartitionKeyRanges(){

   io:println("--------------Get partition key------------------------\n\n");


    Databases AzureCosmosClient = new(config);
    
    var result = AzureCosmosClient->getPartitionKeyRanges("tempdb","tempcoll");

    if (result is PartitionKeyList) {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }   
    io:println("\n\n");



}
