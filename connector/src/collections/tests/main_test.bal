import ballerina/io;
import ballerina/test;


@test:Config{}
function testCallByCityName(){

    AuthConfig config = {
        baseUrl: "https://api.openweathermap.org/data/2.5/weather"
    };

    Collection openMapClient = new(config);

    io:println("\n ---------------------------------------------------------------------------");

    //json|error result = openMapClient.whedataOLCN("London",(),"uk");

   


}