import ballerina/io;
import ballerina/test;
import ballerina/http;


AuthConfig config = {
        baseUrl: BASE_URL,
        masterKey: MASTER_KEY
};

@test:Config{
    enable: false
}
function createDB(){

 

    Databases openMapClient = new(config);
    
    var t = openMapClient.createDatabase("hi",(),());


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


    Databases openMapClient = new(config);
    
    var t = openMapClient.deleteDatabase("Hellodb");


    if t is http:Response{

        //404 Not Found        
        //409 Conflict  
       if (t.statusCode == http:STATUS_NO_CONTENT) {

            //json payload = <json>t.getJsonPayload();
            //json lat = <json>payload.coord.lat;
            io:println(t.statusCode);

            } else {
            error err = error("error occurred while sending GET request\n");
            io:println(err.message(),"Status code: ", t.statusCode,", reason: ", t.getTextPayload());

        }

    }else{
        io:println(t);

    }

}