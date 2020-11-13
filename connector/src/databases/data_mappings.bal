

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

function mapJsonToCollectionType(json jsonPayload)returns @tainted Collection{
    
    Collection coll = {};

    coll.id = jsonPayload.id.toString();
    coll._rid = jsonPayload._rid.toString();
    coll._ts = jsonPayload._ts.toString();
    coll._self = jsonPayload._self.toString();
    coll._etag = jsonPayload._etag.toString();
    coll._doc = jsonPayload._doc.toString();
    coll._sprocs = jsonPayload._sprocs.toString();
    coll._triggers =jsonPayload._triggers.toString();
    coll._udfs=jsonPayload._udfs.toString();
    coll._conflicts=jsonPayload._conflicts.toString();
    
    return coll;
}


function mapJsonToIndexingPolicy(json jsonPayload){

    IndexingPolicy indp = {};

    indp.indexingMode = jsonPayload.indexingMode.toString();
    indp.automatic = convertToBoolean(jsonPayload.indexingMode);
    //indp.includedPaths = 
}

function mapJsonToIncludedPathsType(json jsonPayload) returns @tainted IncludedPath{
    IncludedPath ip = {};

    ip.path = jsonPayload.path.toString();
    ip.indexes = convertToIndexArray(<json[]> jsonPayload.indexes);

    return ip;
}

function mapJsonToIndexType(json jsonPayload) returns Index{
    Index ind = {};

    ind.kind = jsonPayload.kind.toString();
    ind.dataType = jsonPayload.dataType.toString();
    ind.precision = convertToInt(jsonPayload.precision);

    return ind;
    
}

function convertToDatabaseArray(json[] sourceDatabaseArrayJsonObject) returns @tainted Database[] {
    Database[] databases = [];
    int i = 0;
    foreach json jsonDatabase in sourceDatabaseArrayJsonObject {
        databases[i] = mapJsonToDatabaseType(jsonDatabase);
        i = i + 1;
    }
    return databases;
}

function convertToIncludedPathsArray(json[] sourcePathArrayJsonObject) returns @tainted IncludedPath[]{
    IncludedPath[] includedpaths = [];
    int i = 0;
    foreach json jsonPath in sourcePathArrayJsonObject {
        includedpaths[i] = mapJsonToIncludedPathsType(jsonPath);
        i = i + 1;
    }
    return includedpaths;
}

function convertToIndexArray(json[] sourcePathArrayJsonObject) returns @tainted Index[]{
    Index[] indexes = [];
    int i = 0;
    foreach json index in sourcePathArrayJsonObject {
        indexes[i] = mapJsonToIndexType(index);
        i = i + 1;
    }
    return indexes;
}
