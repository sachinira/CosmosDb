
public type Database record {
    string id = "";
    string _rid = "";
    string _ts = "";
    string _self = "";
    string _etag = "";
    string _colls = "";
    string _users = "";
};

public type DBList record {
    string _rid = "";
    Database[] Databases = [];
};

public type Collection record {
    string id = "";
    string _rid = "";
    string _ts = "";
    string _self = "";
    string _etag = "";
    string _doc = "";
    string _sprocs = "";
    string _triggers ="";
    string _udfs="";
    string _conflicts="";
    IndexingPolicy indexingPolicy?;
    PartitionKey partitionKey?;

};

public type IndexingPolicy record {|
    string indexingMode = "";
    boolean automatic = true;
    IncludedPath[] includedPaths = [];
|};

public  type IncludedPath record {|
    string path = "";
    Index[] indexes = [];
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
    string 'version?;
|};

public type AzureError distinct error;

