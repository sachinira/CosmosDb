
function mapCommonElements(json jsonPayload)returns @tainted Common|error{
    Common comm = {};
    comm._rid = jsonPayload._rid.toString();
    comm._ts = convertToInt(jsonPayload._ts);
    comm._self  =jsonPayload._self.toString();
    comm._etag  = jsonPayload._etag.toString();
    return comm;
}

function mapJsonToDatabaseType(json jsonPayload) returns Database {
    Database db = {};
    db.id = jsonPayload.id.toString();
    db._rid = jsonPayload._rid.toString();
    db._ts = convertToInt(jsonPayload._ts);
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
    coll._ts = convertToInt(jsonPayload._ts);
    coll._self = jsonPayload._self.toString();
    coll._etag = jsonPayload._etag.toString();
    coll._docs = jsonPayload._docs.toString();
    coll._sprocs = jsonPayload._sprocs.toString();
    coll._triggers =jsonPayload._triggers.toString();
    coll._udfs=jsonPayload._udfs.toString();
    coll._conflicts=jsonPayload._conflicts.toString();
    coll.allowMaterializedViews = convertToBoolean(jsonPayload.allowMaterializedViews);
    coll.indexingPolicy = mapJsonToIndexingPolicy(<json>jsonPayload.indexingPolicy);
    coll.partitionKey = convertJsonToPartitionKey(<json>jsonPayload.partitionKey);
    return coll;
}

function mapJsonToIndexingPolicy(json jsonPayload) returns @tainted IndexingPolicy{
    IndexingPolicy indp = {};
    indp.indexingMode = jsonPayload.indexingMode.toString();
    indp.automatic = convertToBoolean(jsonPayload.automatic);
    indp.includedPaths =  convertToIncludedPathsArray(<json[]>jsonPayload.includedPaths);
    indp.excludedPaths =  convertToIncludedPathsArray(<json[]>jsonPayload.excludedPaths);
    return indp;
}

function mapJsonToIncludedPathsType(json jsonPayload) returns @tainted IncludedPath{
    IncludedPath ip = {};
    ip.path = jsonPayload.path.toString();
    if jsonPayload.indexes is error{
        return ip;
    }else{
        ip.indexes = convertToIndexArray(<json[]>jsonPayload.indexes);
    }
    return ip;
}

function mapJsonToIndexType(json jsonPayload) returns Index{
    Index ind = {};
    ind.kind = jsonPayload.kind.toString();
    ind.dataType = jsonPayload.dataType.toString();
    ind.precision = convertToInt(jsonPayload.precision);
    return ind; 
}

function convertJsonToPartitionKey(json jsonPayload) returns @tainted PartitionKey{
    PartitionKey pk = {};
    pk.paths = convertToStringArray(<json[]>jsonPayload.paths);
    pk.kind = jsonPayload.kind.toString();
    pk.'version = convertToInt(jsonPayload.'version);
    return pk;
}

function mapJsonToCollectionListType(json jsonPayload) returns @tainted CollectionList{
    CollectionList cll = {};
    cll._rid = jsonPayload._rid.toString();
    cll._count = convertToInt(jsonPayload._count);
    cll.DocumentCollections = convertToCollectionArray(<json[]>jsonPayload.DocumentCollections);
    return cll;
}

function mapJsonToPartitionKeyType(json jsonPayload) returns @tainted PartitionKeyList{
    PartitionKeyList pkl = {};
    pkl._rid = jsonPayload._rid.toString();
    pkl.PartitionKeyRanges = convertToPartitionKeyRangeArray(<json[]>jsonPayload.PartitionKeyRanges);
    return pkl;
}

function mapJsonToPartitionKeyRange(json jsonPayload) returns @tainted PartitionKeyRanges{
    PartitionKeyRanges pkr = {};
    pkr._rid = jsonPayload._rid.toString();
    pkr.id = jsonPayload.id.toString();
    pkr._etag = jsonPayload._etag.toString();
    pkr.minInclusive = jsonPayload.minInclusive.toString();
    pkr.maxExclusive = jsonPayload.maxExclusive.toString();
    pkr._self = jsonPayload._self.toString();
    pkr.status = jsonPayload.status.toString();
    pkr._ts = convertToInt(jsonPayload._ts);
    return pkr;
}

function mapJsonToDocument(json jsonPayload) returns @tainted Document|error{
    Document doc = {};
    doc.id = jsonPayload.id.toString();
    doc._rid = jsonPayload._rid.toString();
    doc._ts = convertToInt(jsonPayload._ts);
    doc._self  =jsonPayload._self.toString();
    doc._etag  = jsonPayload._etag.toString();
    doc._attachments  = jsonPayload._attachments.toString();
    doc.document = check jsonPayload.cloneWithType(anydata);
    return doc;
}

function mapJsonToDocumentList(json jsonPayload) returns @tainted DocumentList|error{
    DocumentList documentlist = {};
    documentlist._rid = jsonPayload._rid.toString();
    documentlist._count = convertToInt(jsonPayload._count);
    documentlist.documents = convertToDocumentArray(<json[]>jsonPayload.Documents);
    return documentlist;
} 

function mapJsonToSproc(json jsonPayload)returns @tainted StoredProcedure|error{
    StoredProcedure sproc = {};
    sproc.body = jsonPayload.body.toString();
    sproc.id = jsonPayload.id.toString();
    sproc.common = check mapCommonElements(jsonPayload);
    return sproc;
}

function mapJsonToSprocList(json jsonPayload)returns @tainted StoredProcedureList|error{
    StoredProcedureList sproclist = {};
    sproclist._rid = jsonPayload._rid.toString();
    sproclist.storedprocedures = convertToSprocArray(<json[]>jsonPayload.StoredProcedures);
    sproclist._count = convertToInt(jsonPayload._count);
    return sproclist;
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
        includedpaths[i] = <IncludedPath>mapJsonToIncludedPathsType(jsonPath);
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

function convertToStringArray(json[] sourcePathArrayJsonObject) returns @tainted string[]{
    string[] strings = [];
    int i = 0;
    foreach json str in sourcePathArrayJsonObject {
        strings[i] = str.toString();
        i = i + 1;
    }
    return strings;
}

function convertToCollectionArray(json[] sourceCollectionArrayJsonObject) returns @tainted Collection[] {
    Collection[] collections = [];
    int i = 0;
    foreach json jsonCollection in sourceCollectionArrayJsonObject {
        collections[i] = mapJsonToCollectionType(jsonCollection);
        i = i + 1;
    }
    return collections;
}

function convertToPartitionKeyRangeArray(json[] sourceCollectionArrayJsonObject) returns @tainted PartitionKeyRanges[]{
    PartitionKeyRanges[] pkranges = [];
    int i = 0;
    foreach json jsonCollection in sourceCollectionArrayJsonObject {
        pkranges[i] = mapJsonToPartitionKeyRange(jsonCollection);
        i = i + 1;
    }
    return pkranges;
}

function convertToDocumentArray(json[] sourceDocumentArrayJsonObject) returns @tainted Document[] {
    Document[] documents = [];
    int i = 0;
    foreach json doc in sourceDocumentArrayJsonObject { 
        documents[i] = <Document>mapJsonToDocument(doc);
        i = i + 1;
    }
    return documents;
}

function convertToSprocArray(json[] sourceSprocArrayJsonObject) returns @tainted StoredProcedure[] {
    StoredProcedure[] sprocs = [];
    int i = 0;
    foreach json sproc in sourceSprocArrayJsonObject { 
        sprocs[i] = <StoredProcedure>mapJsonToSproc(sproc);
        i = i + 1;
    }
    return sprocs;
}


