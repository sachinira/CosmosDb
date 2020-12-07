import ballerina/lang.'object as lang;

public class Listener {
    *lang:Listener;

    private Client azureClient;

    public isolated function init(AzureCosmosConfiguration connectionConfig) {
    }

    public isolated function __attach(service s, string? name = ()) returns error? {
    }

 
    public isolated function __start() returns error? {
    }


    public isolated function __detach(service s) returns error? {
    }

 
    public isolated function __gracefulStop() returns error? {
    }

 
    public isolated function __immediateStop() returns error? {
    }
}  