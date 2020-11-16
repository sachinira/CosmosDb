
public type Database record {
    string id = "";
    string _rid = "";
    int _ts = 0;
    string _self = "";
    string _etag = "";
    string _colls = "";
    string _users = "";
};

public type DBList record {
    string _rid = "";
    Database[] Databases = [];
};


//conflict rresolution policy must be included
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

public type Document record {|
    string id = "";
    any document?;
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

public type StoredProcedure record {
    string body = "";
    string id = "";
    Common common = {};
};

public type Common record {|
    string _rid = "";
    int _ts = 0;
    string _self = "";
    string _etag = "";
|};

public type AzureError distinct error;

