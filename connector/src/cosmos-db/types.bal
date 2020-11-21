
public type HeaderParamaters record {|
    string verb = "";
    string apiVersion = API_VERSION;
    string resourceType = "";
    string resourceId = "";
|};

public type Headers record {|
    string? continuationHeader?;
    string? sessionTokenHeader?;
    string? requestChargeHeader?;
    string? resourceUsageHeader?;
    string? itemCountHeader?;
    string? etagHeader?;
    string? dateHeader?;

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

public type DocumentProperties record {|
    string dbName = "";
    string colName = "";
    string? documentId = ();
    any? partitionKey = ();
|};

public type ContainerProperties record {|
    string dbName = "";
    string colName = "";
    json? partitionKey = ();
|};


//conflict resolution policy must be included
public type Collection record {
    string id = "";
    string _rid = "";
    int _ts = 0;
    string _self = "";
    string _etag = "";
    string _docs = "";
    string _sprocs = "";
    string _triggers ="";
    string _udfs="";
    string _conflicts="";
    boolean allowMaterializedViews?;
    IndexingPolicy indexingPolicy?;
    PartitionKey partitionKey?;
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
    int 'version?;
|};

public type ConflictResolutionPolicyType record {|
    string mode = "";
    string conflictResolutionPath = "";
    string conflictResolutionProcedure = "";
|};

public type CollectionList record {|
    string _rid = "";
    Collection[] DocumentCollections = [];
    int _count = 0;
|};

public type PartitionKeyList record {|
    string _rid = "";
    PartitionKeyRanges[] PartitionKeyRanges = [];
|};

public type PartitionKeyRanges record {|
    string _rid = "";
    string id = "";
    string _etag = "";
    string minInclusive = "";
    string maxExclusive = "";
    int ridPrefix?;
    string _self = "";
    int throughputFraction?;
    string status = "";
    int _ts = 0;
|};

public type Document record{|
    string id = "";
    any document ="";
    string _rid = "";
    int _ts = 0;
    string _self = "";
    string _etag = "";
    string _attachments = "";
  
|};

public type DocumentList record {|
    string _rid= "";
    Document[] documents = [];
    int _count = 0;
|};

public type DocumentListIterable record {|
    string _rid= "";
    Document[] documents = [];
    int _count = 0;
    string continuation = "";
|};

public type StoredProcedure record {
    string body = "";
    string id = "";
    Common common = {};
};

public type StoredProcedureList record {
    string _rid = "";
    StoredProcedure[] storedprocedures = [];
    int _count = 0;
};

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

public type AzureError distinct error;

