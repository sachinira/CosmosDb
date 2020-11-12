import ballerina/io;
import ballerina/test;
import ballerina/http;
import ballerina/java;


AuthConfig config = {
        baseUrl: BASE_URL,
        masterKey: MASTER_KEY
};

function createRandomUUID() returns handle = @java:Method {
    name: "randomUUID",
    'class: "java.util.UUID"
} external;

@test:Config{
}
function createDB(){

    Documents openMapClient = new(config);

    var uuid = createRandomUUID();

 
    json custom = {
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
  "IsRegistered": true  
    };

    //json body = {
          //  id: uuid.toString()     
       // };

    json body = {
            id: "a1965809-52d2-4bc6-917d-c59f271d254c"     
    };
        

    json|error finalj =  body.mergeJson(custom);


    if finalj is json{
        var t = openMapClient.createDocument("tempdb","tempcoll",finalj,true,());
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


    

}