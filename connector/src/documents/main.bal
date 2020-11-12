import ballerina/http;
import ballerina/time;
import ballerina/io;
import ballerina/crypto;
import ballerina/encoding;

public class Documents{

    public string baseUrl;
    public http:Client basicClient;
    http:Request authRequest;
    private string apiKey;
    private string resourceType;
    private string keyType;
    private string tokenVersion;


    function init(AuthConfig opConf){
        self.baseUrl = opConf.baseUrl;
        self.apiKey = opConf.masterKey;
        self.resourceType = "docs";
        self.keyType = "master";
        self.tokenVersion = "1.0";

        self.basicClient = new (self.baseUrl, {
            secureSocket: {
                trustStore: {
                    path: "/usr/lib/ballerina/distributions/ballerina-slp4/bre/security/ballerinaTruststore.p12",
                    password: "ballerina"
                }
            }
        });


        self.authRequest = new;

        //********we have to specify the paertition key in the header for the api higher than 2018-12-31
        self.authRequest.setHeader("x-ms-version","2018-09-17");
        self.authRequest.setHeader("Host","sachinidbnewaccount.documents.azure.com:443");

    }


    //create a collection
    public function createDocument(string dbname,string colname,json document,boolean? upsert,string? indexingdir) returns error?|http:Response{
        

        json finalj;
        string varb = "POST"; 
        //portion of the string identifies the type of resource that the request is for, Eg. "dbs", "colls", "docs".
        //portion of the string is the identity property of the resource that the request is directed at. ResourceLink must maintain its case for the ID of the resource. 
        //Example, for a collection it looks like: "dbs/MyDatabase/colls/MyCollection".
        string resourceId = string `dbs/${dbname}/colls/${colname}`;
        string? date = check getTime();

         if date is string{
            string? s = check generateToken(varb,self.resourceType,resourceId,self.apiKey,self.keyType,self.tokenVersion,date);
            self.authRequest.setHeader("x-ms-date",date);
            if s is string{
                self.authRequest.setHeader("Authorization",s);

            }else{

                io:println("token is null");
                            //return the error


            }
        }else{
            io:println("date is null");
                        //return the error

        }
            

        if indexingdir is string{
            self.authRequest.setHeader("x-ms-indexing-directive",indexingdir);
        }

        //for upsert to work it must send true and if we use the same existing id upsert should be true.If not it will put an error 
        self.authRequest.setHeader("x-ms-documentdb-is-upsert",upsert.toString());

        self.authRequest.setHeader("Content-Type","application/json");
        self.authRequest.setHeader("Accept","application/json");
        self.authRequest.setHeader("Connection","keep-alive");

        //http:Response? result = new;
        //result = <http:Response>self.basicClient->get("/dbs/tempdb/colls",self.authRequest);

        


        self.authRequest.setJsonPayload(document);
        var result = self.basicClient->post(string `/dbs/${dbname}/colls/${colname}/docs`,self.authRequest);

        return result;
        
    }

     

}

public function generateToken(string verb, string resourceType, string resourceId, string keys, string keyType, string tokenVersion, string date) returns string?|error{
        
    string authorization;

    string payload = verb.toLowerAscii()+"\n" 
        +resourceType.toLowerAscii()+"\n"
        +resourceId+"\n"
        +date.toLowerAscii()+"\n"
        +""+"\n";


    var decoded = encoding:decodeBase64Url(keys);
        
    if decoded is byte[]{

        byte[] k = crypto:hmacSha256(payload.toBytes(),decoded);
        string  t = k.toBase16();

        string signature = encoding:encodeBase64Url(k);

        authorization = check encoding:encodeUriComponent(string `type=${keyType}&ver=${tokenVersion}&sig=${signature}=`, "UTF-8");
            
        return authorization;

    }else{
            
        io:println("Decoding error");
    }

}

public function getTime() returns string?|error{

    time:Time time1 = time:currentTime();
    var time2 = check time:toTimeZone(time1, "Europe/London");

    string|error timeString = time:format(time2, "EEE, dd MMM yyyy HH:mm:ss z");
    return timeString;
}



public type AuthConfig record {
    string baseUrl;  
    string masterKey;  
};

