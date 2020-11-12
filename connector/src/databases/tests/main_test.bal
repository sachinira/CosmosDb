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

    Databases AzureCosmosClient = new(config);
    
    var result = AzureCosmosClient->createDatabase("hikall",(),());

     if (result is Database) {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }
}


@test:Config{
    enable: false

}
function listAllDB(){

    Databases AzureCosmosClient = new(config);
    
    var result = AzureCosmosClient->listDatabases();

    if (result is DBList) {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }
}

@test:Config{
    enable: false

}
function listOneDB(){

    Databases AzureCosmosClient = new(config);
    
    var result = AzureCosmosClient->listOneDatabase("tempdb");

    if (result is Database) {
        io:println(result);
    } else {
        test:assertFail(msg = result.message());
    }

}

@test:Config{

}
function deleteDB(){

    Databases AzureCosmosClient = new(config);
    
    var result = AzureCosmosClient->deleteDatabase("tempdb2");

    io:println(result);
   

}