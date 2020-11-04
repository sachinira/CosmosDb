import ballerina/io;
import ballerina/test;
import ballerina/http;



@test:Config{
    enable: false
}
function createCollection(){

  AuthConfig config = {
        baseUrl: "https://sachinidbnewaccount.documents.azure.com:443/"
    };

    Collections openMapClient = new(config);
    
    var t = openMapClient.createCollection("tempdb","mycollection",(),());


    if t is http:Response{

        //400 Bad Request
        //409 Conflict  
        //404 with a sub status code of 1013
       if (t.statusCode == http:STATUS_OK) {

            json payload = <json>t.getJsonPayload();
            //json lat = <json>payload.coord.lat;
            io:println(payload.id);

            } else {
            error err = error("error occurred while sending GET request\n");
            io:println(err.message(),"Status code: ", t.statusCode,", reason: ", t.getTextPayload());

        }

    }else{
        io:println(t);

    }

}

@test:Config{
    enable: false
}
function listAllCollections(){

  AuthConfig config = {
        baseUrl: "https://sachinidbnewaccount.documents.azure.com:443/"
    };

    Collections openMapClient = new(config);
    
    var t = openMapClient.getAllCollections("tempdb");


    if t is http:Response{
        //400 Bad Request
        //409 Conflict  
        //404 with a sub status code of 1013
       if (t.statusCode == http:STATUS_OK) {

            json payload = <json>t.getJsonPayload();
            //json lat = <json>payload.coord.lat;
            io:println(payload._rid);

            } else {
            error err = error("error occurred while sending GET request\n");
            io:println(err.message(),"Status code: ", t.statusCode,", reason: ", t.getTextPayload());

        }

    }else{
        io:println(t);

    }

}


@test:Config{

    enable: false
}
function getOneCollecion(){

  AuthConfig config = {
        baseUrl: "https://sachinidbnewaccount.documents.azure.com:443/"
    };

    Collections openMapClient = new(config);
    
    var t = openMapClient.getOneCollection("tempdb","tempcoll");


    if t is http:Response{
        //404 Not Found
       if (t.statusCode == http:STATUS_OK) {

            json payload = <json>t.getJsonPayload();
            //json lat = <json>payload.coord.lat;
            io:println(payload.id);

            } else {
            error err = error("error occurred while sending GET request\n");
            io:println(err.message(),"Status code: ", t.statusCode,", reason: ", t.getTextPayload());

        }

    }else{
        io:println(t);

    }

}

@test:Config{
    enable: false
}
function deleteCollecion(){

  AuthConfig config = {
        baseUrl: "https://sachinidbnewaccount.documents.azure.com:443/"
    };

    Collections openMapClient = new(config);
    
    var t = openMapClient.deleteCollection("tempdb","tempcoll");


    if t is http:Response{
        //404 Not Found
       if (t.statusCode == http:STATUS_NO_CONTENT) {

            var payload = t.getJsonPayload();
            //json lat = <json>payload.coord.lat;
            io:println(payload);

            } else {
            error err = error("error occurred while sending GET request\n");
            io:println(err.message(),"Status code: ", t.statusCode,", reason: ", t.getTextPayload());

        }

    }else{
        io:println(t);

    }

}

@test:Config{
    enable: false
}
function replceCollection(){

  AuthConfig config = {
        baseUrl: "https://sachinidbnewaccount.documents.azure.com:443/"
    };

    Collections openMapClient = new(config);

    json ind = {  
    "indexingMode": "consistent",  
    "automatic": true,  
    "includedPaths": [  
      {  
        "path": "/*",  
        "indexes": [  
          {  
            "dataType": "Number",  
            "precision": -1,  
            "kind": "Range"  
          },  
          {  
            "dataType": "String",  
            "precision": 3,  
            "kind": "Hash"  
          }  
        ]  
      }  
    ],  
    "excludedPaths": []  
  };
    
    var t = openMapClient.ReplaceCollection("tempdb","mycollection",(),());


    if t is http:Response{

        //400 Bad Request
       
       if (t.statusCode == http:STATUS_OK) {

            json payload = <json>t.getJsonPayload();
            //json lat = <json>payload.coord.lat;
            io:println(payload.id);

            } else {
            error err = error("error occurred while sending GET request\n");
            io:println(err.message(),"Status code: ", t.statusCode,", reason: ", t.getTextPayload());

        }

    }else{
        io:println(t);

    }

}

@test:Config{
    enable: false
}
function GetPartitionKeyRanges(){

  AuthConfig config = {
        baseUrl: "https://sachinidbnewaccount.documents.azure.com:443/"
    };

    Collections openMapClient = new(config);
    
    var t = openMapClient.getPKRanges("tempdb","tempcoll1");


    if t is http:Response{
        //404 Not Found
       if (t.statusCode == http:STATUS_OK) {

            json payload = <json>t.getJsonPayload();
            //json lat = <json>payload.coord.lat;
            io:println(payload._rid);

            } else {
            error err = error("error occurred while sending GET request\n");
            io:println(err.message(),"Status code: ", t.statusCode,", reason: ", t.getTextPayload());

        }

    }else{
        io:println(t);

    }

}
