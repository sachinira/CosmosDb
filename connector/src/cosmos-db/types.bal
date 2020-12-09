import ballerina/http;

public type AzureCosmosConfiguration record {|
    string baseUrl;
    string keyOrResourceToken;
    string host;
    string tokenType;
    string tokenVersion;
    http:ClientSecureSocket? secureSocketConfig;
|};

type HeaderParameters record {|
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
    string? partitionKeyRangeId = ();
    boolean? enableCrossPartition = ();
    string? ifMatch = ();//Only for PUT and DELETE 
|};

public type ResourceProperties record {|
    string databaseId = "";
    string containerId = "";
|};

public type Headers record {|
    string continuationHeader?;
    string sessionTokenHeader?;
    string requestChargeHeader?;
    string resourceUsageHeader?;
    string itemCountHeader?;
    string etagHeader?;
    string dateHeader?;
|};

public type Common record {|
    string resourceId?;
    string selfReference?;
    string timeStamp?;
    string eTag?;
|};

public type Database record {|
    string id = "";
    *Common;
    string collections?;
    string users?;
    Headers?...;
|};

public type DatabaseList record {
    *Common;
    Database[] databases = [];
    Headers? reponseHeaders = ();
    int count?;
};

//conflict resolution policy must be included
public type Container record {|
    string id = "";
    *Common;
    string collections?;
    string storedProcedures?;
    string triggers?;
    string userDefinedFunctions?;
    string conflicts?;
    boolean allowMaterializedViews?;
    IndexingPolicy indexingPolicy?;
    PartitionKey partitionKey?;
    Headers?...;
|};

public type ContainerList record {|
    *Common;
    Container[] containers = [];
    Headers reponseHeaders?;
    int count?;
|};

public type Document record {|
    string id = "";
    *Common;
    string attachments?;
    json? documentBody =     {};
    string? documentId?;
    any[]? partitionKey = [];
    Headers?...;
|};

public type DocumentList record {|
    *Common;
    Document[] documents = [];
    int count?;
    Headers reponseHeaders?;
|};

public type Query record {|
    string query = "";
    QueryParameter[]? parameters = [];
|};

public type QueryParameter record {|
    string name = "";
    string value = "";
|};

public type StoredProcedure record {|
    string id = "";
    *Common;
    string body = "";
    Headers?...;
|};

public type StoredProcedureList record {|
    *Common;
    StoredProcedure[] storedProcedures = [];
    int count = 0;
    Headers?...;
|};

public type UserDefinedFunction record {|
    *StoredProcedure;
    Headers?...;
|};

public type UserDefinedFunctionList record {|
    *Common;
    UserDefinedFunction[] UserDefinedFunctions = [];
    int count = 0;
    Headers?...;
|};

public type Trigger record {|
    *StoredProcedure;
    string triggerOperation = "";
    string triggerType = "";
    Headers?...;
|};

public type TriggerList record {|
    *Common;
    Trigger[] triggers = [];
    int count = 0;
    Headers?...;
|};

public type User record {|
    *Database;
    string permissions?;
    Headers?...;
|};

public type UserList record {|
    *Common;
    User[] users = [];
    int count?;
    Headers? reponseHeaders = ();
|};

public type Permission record {|
    string id = "";
    *Common;
    string permissionMode = "";
    string resourcePath = "";
    int validityPeriod?;
    string? token?;
    Headers?...;
|};

public type PermissionList record {|
    *Common;
    Permission[] permissions = [];
    int count = 0;
    Headers? reponseHeaders = ();
|};

public type Offer record {|
    string id = "";
    *Common;
    string offerVersion = "";//It can be V1 for the legacy S1, S2, and S3 levels and V2 for user-defined throughput levels (recommended).
    string? offerType?;  //This property is only applicable in the V1 offer version. Set it to S1, S2, or S3 for V1 offer types. 
    //It is invalid for user-defined performance levels or provisioned throughput based model.
    json content = {};
    string offerResourceId = "";
    string resourceSelfLink = "";
    Headers?...;
|};

public type OfferList record {|
    *Common;
    Offer[] offers = [];
    int count = 0;
    Headers?...;
|};

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
    IncludedPath[] excludedPaths?;
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
    int precision?;
|};

public type PartitionKey record {|
    string[] paths = [];
    string kind = "";
    int? keyVersion?;
|};

public type PartitionKeyList record {|
    string resourceId = "";
    PartitionKeyRange[] partitionKeyRanges = [];
    Headers reponseHeaders?;
    int count = 0;
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

public type AzureError distinct error;

type JsonMap  map<json>;
