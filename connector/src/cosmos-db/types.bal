public type HeaderParamaters record {|
    string verb = "";
    string apiVersion = API_VERSION;
    string resourceType = "";
    string resourceId = "";
|};

public type RequestOptions record {|
    boolean? isUpsertRequest = ();
    string? indexingDirective = ();
    int? maxItemCount = ();
    string? continuationToken =();
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

public type Headers record {|
    string? continuationHeader = ();
    string? sessionTokenHeader = ();
    string? requestChargeHeader = ();
    string? resourceUsageHeader = ();
    string? itemCountHeader = ();
    string? etagHeader = ();
    string? dateHeader = ();

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

public type Document record{|
    string id = "";
    any document ="";
    Headers reponseHeaders?;
|};

public type DocumentList record {|
    string _rid= "";
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
    StoredProcedure[] storedprocedures = [];
    Headers reponseHeaders?;
    int _count = 0;
};


//common
public type Common record {|
    string _rid = "";
    int _ts = 0;
    string _self = "";
    string _etag = "";
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
    IncludedPath[] excludedPaths = [];
|};

public  type IncludedPath record {|
    string path = "";
    Index[] indexes?;
|};

public  type ExcludedPath record {|
    string path?;
|};

public type Index record {|
    string kind = "";
    string dataType = "";
    int precision =-1;
|};

public type PartitionKey record {|
    string[] paths = [];
    string kind = "";
    int 'Version?;
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


public type AzureError distinct error;

