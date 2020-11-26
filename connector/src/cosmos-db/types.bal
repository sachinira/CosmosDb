import ballerina/http;

public type AzureCosmosConfiguration record {|
    string baseUrl;    
    string masterKey;
    string host;
    string tokenType;
    string tokenVersion;
    http:ClientSecureSocket? secureSocketConfig;
|};

public type HeaderParamaters record {|
    string verb = "";
    string apiVersion = API_VERSION;
    string resourceType = "";
    string resourceId = "";
|};

public type RequestHeaderOptions record {|
    boolean? isUpsertRequest = ();
    string? indexingDirective = ();
    int? maxItemCount = ();
    string? continuationToken = ();
    string? consistancyLevel = ();//This is the consistency level override. The override must be the same 
    //or weaker than the account’s configured consistency level.
    string? sessionToken = ();
    string? changeFeedOption = ();//Must be set to Incremental feed, or omitted otherwise. 
    string? ifNoneMatch = (); //No header: returns all changes from the beginning (collection creation)//"*": 
    //returns all new changes to data within the collection <etag>: If set to a collection ETag, returns all 
    //changes made since that logical timestamp.only for GET
    string? PartitionKeyRangeId = ();
    string? ifMatch = ();//Only for PUT and DELETE 
|};

public type ResourceProperties record {|
    string databaseId = "";
    string containerId = "";
|};

public type Headers record {|
    string? continuationHeader = ();
    string? sessionTokenHeader = ();
    string? requestChargeHeader = ();
    string? resourceUsageHeader = ();
    string? itemCountHeader = ();
    string? etagHeader = ();
    string? dateHeader = ();
|};

public type DatabaseProperties record {|
    string id = "";
|};

public type Database record {
    string id = "";
    Headers reponseHeaders?;
};

public type DatabaseList record {
    string _rid = "";
    Database[] Databases = [];
    Headers? reponseHeaders = ();
};


//conflict resolution policy must be included
public type ContainerProperties record {|
    string databaseId = "";
    string containerId = "";
    PartitionKey? partitionKey = ();
    IndexingPolicy? indexingPolicy = ();
|};


//conflict resolution policy must be included
public type Container record {
    string id = "";
    boolean allowMaterializedViews?;
    IndexingPolicy indexingPolicy?;
    PartitionKey partitionKey?;
    Headers reponseHeaders?;
};

public type ContainerList record {|
    string _rid = "";
    Container[] DocumentCollections = [];
    Headers reponseHeaders?;
    int _count = 0;
|};

public type DocumentProperties record {|
    string databaseId = "";
    string containerId = "";
    string? documentId = ();
    any? partitionKey = ();
|};

public type Document record {|
    string id = "";
    any document = "";
    Headers reponseHeaders?;
|};

public type DocumentList record {|
    string _rid = "";
    Document[] documents = [];
    Headers reponseHeaders?;
    int _count = 0;
|};

public type Query record {|
    string query = "";
    QueryParameter[] parameters = [];
|};

public type QueryParameter record {|
    string name = "";
    string value = "";
|};

//stired procedure and UDF are same
public type StoredProcedureProperties record {
    string databaseId = "";
    string containerId = "";
    string? storedProcedureId = ();
};

public type StoredProcedure record {
    string id = "";
    string body = "";
    Headers reponseHeaders?;
};

public type StoredProcedureList record {
    string _rid = "";
    StoredProcedure[] storedProcedures = [];
    Headers? reponseHeaders = ();
    int _count = 0;
};

public type UserDefinedFunctionProperties record {|
    string databaseId = "";
    string containerId = "";
    string? userDefinedFunctionId = ();
|};

public type UserDefinedFunction record {|
    string id = "";
    string body = "";
    Headers? reponseHeaders = ();
|};

public type UserDefinedFunctionList record {
    string _rid = "";
    UserDefinedFunction[] UserDefinedFunctions = [];
    Headers? reponseHeaders = ();
    int _count = 0;
};

public type TriggerProperties record {|
    string databaseId = "";
    string containerId = "";
    string? triggerId = ();
|};

public type Trigger record {|
    string? _rid = ();
    string id = "";
    string body = "";
    string triggerOperation = "";
    string triggerType = "";
    //Headers? reponseHeaders = ();
|};

public type TriggerList record {
    string _rid = "";
    Trigger[] triggers = [];
    Headers reponseHeaders?;
    int _count = 0;
};


//********************************************
public type ThroughputProperties record {
    int? throughput = ();
    json? maxThroughput = ();
};

public type DeleteResponse record {
    string message = "";
    Headers reponseHeaders?;
};

public type IndexingPolicy record {|
    string indexingMode = "";
    boolean automatic = true;
    IncludedPath[] includedPaths?;
    IncludedPath[] excludedPaths = [];
|};

public type IncludedPath record {|
    string path = "";
    Index[] indexes?;
|};

public type ExcludedPath record {|
    string path?;
|};

public type Index record {|
    string kind = "";
    string dataType = "";
    int precision = -1;
|};

public type PartitionKey record {|
    string[] paths = [];
    string kind = "";
    int? 'version = ();
|};

public type PartitionKeyList record {|
    string _rid = "";
    PartitionKeyRange[] PartitionKeyRanges = [];
    Headers reponseHeaders?;
    int _count = 0;
|};

public type PartitionKeyRange record {|
    string id = "";
    string minInclusive = "";
    string maxExclusive = "";
    int ridPrefix?;
    int throughputFraction?;
    string status = "";
    Headers reponseHeaders?;
|};

public type ConflictResolutionPolicyType record {|
    string mode = "";
    string conflictResolutionPath = "";
    string conflictResolutionProcedure = "";
|};

public type AzureError  distinct  error;
