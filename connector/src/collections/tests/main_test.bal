import ballerina/io;
import ballerina/test;
import ballerina/http;


@test:Config{}
function testCallByCityName(){

  AuthConfig config = {
        baseUrl: "https://sachinidbnewaccount.documents.azure.com:443/"
    };

    Collections openMapClient = new(config);
    
    var t = openMapClient.getCollection();


    if t is http:Response{
       if (t.statusCode == http:STATUS_OK) {

            json payload = <json>t.getJsonPayload();
            //json lat = <json>payload.coord.lat;
            io:println(payload);

            } else {
            error err = error("error occurred while sending GET request");
            io:println(err.message(),", status code: ", t.statusCode,", reason: ", t.getTextPayload());

            io:println(err);

        }

    }else{
        io:println(t);

    }

}