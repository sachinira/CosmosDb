import ballerina/io;
import ballerina/test;
import ballerina/http;


@test:Config{
    enable: false
}
function createDB(){

  AuthConfig config = {
        baseUrl: "https://sachinidbnewaccount.documents.azure.com:443/"
    };

    Databases openMapClient = new(config);
    
    var t = openMapClient.createDatabase("mydb",(),());


    if t is http:Response{

        //400 Bad Request
        //409 Conflict  
       if (t.statusCode == http:STATUS_CREATED) {

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
function listAllDB(){

  AuthConfig config = {
        baseUrl: "https://sachinidbnewaccount.documents.azure.com:443/"
    };

    Databases openMapClient = new(config);
    
    var t = openMapClient.listDatabases();


    if t is http:Response{

        //400 Bad Request
        //409 Conflict  
       if (t.statusCode == http:STATUS_OK) {

            json payload = <json>t.getJsonPayload();
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
function listOneDB(){

  AuthConfig config = {
        baseUrl: "https://sachinidbnewaccount.documents.azure.com:443/"
    };

    Databases openMapClient = new(config);
    
    var t = openMapClient.listOneDatabase("mydb");


    if t is http:Response{

        //400 Bad Request
        //409 Conflict  
       if (t.statusCode == http:STATUS_OK) {

            json payload = <json>t.getJsonPayload();
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

}
function deleteDB(){

  AuthConfig config = {
        baseUrl: "https://sachinidbnewaccount.documents.azure.com:443/"
    };

    Databases openMapClient = new(config);
    
    var t = openMapClient.deleteDatabase("mydb");


    if t is http:Response{

        //404 Not Found        
        //409 Conflict  
       if (t.statusCode == http:STATUS_NO_CONTENT) {

            json payload = <json>t.getJsonPayload();
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