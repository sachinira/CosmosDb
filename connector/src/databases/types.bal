
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

public type AzureError distinct error;

