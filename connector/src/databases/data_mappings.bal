

function mapJsonToDatabaseType(json jsonPayload) returns Database {

    Database db = {};
    db.id = jsonPayload.id.toString();
    db._rid = jsonPayload._rid.toString();
    db._ts  = jsonPayload._ts.toString();
    db._self  =jsonPayload._self.toString();
    db._etag  = jsonPayload._etag.toString();
    db._colls  = jsonPayload._colls.toString();
    db._users  = jsonPayload._users.toString();

    return db;
}

function mapJsonToDbList(json jsonPayload) returns @tainted DBList{
    DBList dbl = {};
    dbl._rid =jsonPayload._rid.toString();
    dbl.Databases =  convertToDatabaseArray(<json[]>jsonPayload.Databases);
    
    return dbl;
}

function convertToDatabaseArray(json[] sourceMessageArrayJsonObject) returns @tainted Database[] {
    Database[] databases = [];
    int i = 0;
    foreach json jsonDatabase in sourceMessageArrayJsonObject {
        databases[i] = mapJsonToDatabaseType(jsonDatabase);
        i = i + 1;
    }
    return databases;
}

