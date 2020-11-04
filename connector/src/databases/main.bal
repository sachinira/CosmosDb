import ballerina/io;
import ballerina/http;


# Prints `Hello World`.

public function main() {
    io:println("Hello World!");
}


 //create a database
    public function createDatabase(string dbname,int? throughput,json? autoscale) returns error?|http:Response{

        string varb = "POST"; 
        //portion of the string identifies the type of resource that the request is for, Eg. "dbs", "colls", "docs".
        string resourceType = "dbs";
        //portion of the string is the identity property of the resource that the request is directed at. ResourceLink must maintain its case for the ID of the resource. 
        //Example, for a collection it looks like: "dbs/MyDatabase/colls/MyCollection".
        string resourceId = "dbs/tempdb";
        string keystring = "n2whnJ4vAsQ2KVXORsKakNsOqs6uvDkLJvETLt4K7AVzj2t06w8CxZ8JRoK984xq6kHtesfJ7KncIf9nqJr1lQ==";
        string keyType = "master";
        string tokenVersion = "1.0";
        //string? date = check getTime();


        

    }