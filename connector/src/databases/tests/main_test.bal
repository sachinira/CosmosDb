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

    Databases AzureCosmosClient = new(config);

    json partitionkey = {  
                            "paths": ["/AccountNumber"], 
                            "kind": "Hash",
                            "Version": 2
                        };
    string throughput = "400";

    var t = AzureCosmosClient->createCollection("tempdb","mycollection3",(),partitionkey,());



}
