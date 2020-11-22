
function mapCommonElements(json jsonPayload)returns @tainted Common|error{
    Common comm = {};
    comm._rid = jsonPayload._rid.toString();
    comm._ts = convertToInt(jsonPayload._ts);
    comm._self  =jsonPayload._self.toString();
    comm._etag  = jsonPayload._etag.toString();
    return comm;
}

function mapParametersToHeaderType(string httpVerb,string url) returns HeaderParamaters {
    HeaderParamaters params = {};
    params.verb = httpVerb;
    params.resourceType = getResourceType(url);
    params.resourceId = getResourceId(url);
    return params;
}

function mapJsonToDatabaseType([json,Headers] jsonPayload) returns Database {
    json payload;
    Headers headers;
    [payload,headers] = jsonPayload;
    
    Database db = {};
    db.id = payload.id.toString();
    db.reponseHeaders = headers;
    return db;
}

function mapJsonToDbList([json,Headers] jsonPayload) returns @tainted DatabaseList {
    json payload;
    Headers headers;
    [payload,headers] = jsonPayload;
    
    DatabaseList dbl = {};
    dbl._rid =payload._rid.toString();
    dbl.Databases =  convertToDatabaseArray(<json[]>payload.Databases);
    dbl.reponseHeaders = headers;
    return dbl;
}

function mapTupleToDeleteresponse([string,Headers] jsonPayload)returns @tainted DeleteResponse {
    string message;
    Headers headers;
    [message,headers] = jsonPayload;
    
    DeleteResponse deleteResponse = {};
    deleteResponse.message =message;
    deleteResponse.reponseHeaders = headers;
    return deleteResponse;
}

function mapJsonToCollectionType([json,Headers] jsonPayload)returns @tainted Container {
    json payload;
    Headers headers;
    [payload,headers] = jsonPayload;

    Container coll = {};
    coll.id = payload.id.toString();
    coll.allowMaterializedViews = convertToBoolean(payload.allowMaterializedViews);
    coll.indexingPolicy = mapJsonToIndexingPolicy(<json>payload.indexingPolicy);
    coll.partitionKey = convertJsonToPartitionKey(<json>payload.partitionKey);
    coll.reponseHeaders = headers;
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

function mapJsonToIncludedPathsType(json jsonPayload) returns @tainted IncludedPath {
    IncludedPath ip = {};
    ip.path = jsonPayload.path.toString();
    if jsonPayload.indexes is error {
        return ip;
    } else {
        ip.indexes = convertToIndexArray(<json[]>jsonPayload.indexes);
    }
    return ip;
}

function mapJsonToIndexType(json jsonPayload) returns Index {
    Index ind = {};
    ind.kind = jsonPayload.kind.toString();
    ind.dataType = jsonPayload.dataType.toString();
    ind.precision = convertToInt(jsonPayload.precision);
    return ind; 
}

function convertJsonToPartitionKey(json jsonPayload) returns @tainted PartitionKey {
    PartitionKey pk = {};
    pk.paths = convertToStringArray(<json[]>jsonPayload.paths);
    pk.kind = jsonPayload.kind.toString();
    pk.'Version = convertToInt(jsonPayload.'version);
    return pk;
}

function mapJsonToCollectionListType([json,Headers] jsonPayload) returns @tainted ContainerList {
    ContainerList cll = {};
    json payload;
    Headers headers;
    [payload,headers] = jsonPayload;

    cll._rid = payload._rid.toString();
    cll._count = convertToInt(payload._count);
    cll.DocumentCollections = convertToCollectionArray(<json[]>payload.DocumentCollections);
    cll.reponseHeaders = headers;
    return cll;
}

function mapJsonToPartitionKeyType([json,Headers] jsonPayload) returns @tainted PartitionKeyList {
    PartitionKeyList pkl = {};
    PartitionKeyRange pkr = {};
    json payload;
    Headers headers;
    [payload,headers] = jsonPayload;

    pkl._rid = payload._rid.toString();
    pkl.PartitionKeyRanges = convertToPartitionKeyRangeArray(<json[]>payload.PartitionKeyRanges);
    pkl.reponseHeaders = headers;
    pkl._count = convertToInt(payload._count);


    return pkl;
}

function mapJsonToPartitionKeyRange([json,Headers] jsonPayload) returns @tainted PartitionKeyRange {
    PartitionKeyRange pkr = {};
    json payload;
    Headers headers;
    [payload,headers] = jsonPayload;
    
    pkr.id = payload.id.toString();
    pkr.minInclusive = payload.minInclusive.toString();
    pkr.maxExclusive = payload.maxExclusive.toString();
    pkr.status = payload.status.toString();
    pkr.reponseHeaders = headers;
    return pkr;
}

function mapJsonToDocument([json,Headers] jsonPayload) returns @tainted Document|error {  
    Document doc = {};
    json payload;
    Headers headers;
    [payload,headers] = jsonPayload;
    
    doc.id = payload.id.toString();
    doc.document = check payload.cloneWithType(anydata);
    doc.reponseHeaders = headers;
    return doc;
}

function mapJsonToDocumentList([json,Headers] jsonPayload) returns @tainted DocumentList|error {
    DocumentList documentlist = {};
    json payload;
    Headers headers;
    [payload,headers] = jsonPayload;

    documentlist._rid = payload._rid.toString();
    documentlist._count = convertToInt(payload._count);
    documentlist.documents = check convertToDocumentArray(<json[]>payload.Documents);
    documentlist.reponseHeaders = headers;

    return documentlist;
} 

function mapJsonToStoredProcedure([json,Headers] jsonPayload)returns @tainted StoredProcedure|error {
    StoredProcedure sproc = {};
    json payload;
    Headers headers;
    [payload,headers] = jsonPayload;
    sproc.id = payload.id.toString();
    sproc.body = payload.body.toString();
    sproc.reponseHeaders = headers;
    return sproc;
}

function mapJsonToStoredProcedureList([json,Headers] jsonPayload)returns @tainted StoredProcedureList|error {
    StoredProcedureList sproclist = {};
    json payload;
    Headers headers;
    [payload,headers] = jsonPayload;
    sproclist._rid = payload._rid.toString();
    sproclist.storedprocedures = convertToStoredProcedureArray(<json[]>payload.StoredProcedures);
    sproclist._count = convertToInt(payload._count);//headers
    sproclist.reponseHeaders = headers;
    return sproclist;
}

function convertToDatabaseArray(json[] sourceDatabaseArrayJsonObject) returns @tainted Database[] {
    Database[] databases = [];
    int i = 0;
    foreach json jsonDatabase in sourceDatabaseArrayJsonObject {
        databases[i].id = <string>jsonDatabase.id;
        i = i + 1;
    }
    return databases;
}

function convertToIncludedPathsArray(json[] sourcePathArrayJsonObject) returns @tainted IncludedPath[] { 
    IncludedPath[] includedpaths = [];
    int i = 0;
    foreach json jsonPath in sourcePathArrayJsonObject {
        includedpaths[i] = <IncludedPath>mapJsonToIncludedPathsType(jsonPath);
        i = i + 1;
    }
    return includedpaths;
}

function convertToIndexArray(json[] sourcePathArrayJsonObject) returns @tainted Index[] {
    Index[] indexes = [];
    int i = 0;
    foreach json index in sourcePathArrayJsonObject {
        indexes[i] = mapJsonToIndexType(index);
        i = i + 1;
    }
    return indexes;
}

function convertToStringArray(json[] sourcePathArrayJsonObject) returns @tainted string[] {
    string[] strings = [];
    int i = 0;
    foreach json str in sourcePathArrayJsonObject {
        strings[i] = str.toString();
        i = i + 1;
    }
    return strings;
}

function convertToCollectionArray(json[] sourceCollectionArrayJsonObject) returns @tainted Container[] {
    Container[] collections = [];
    int i = 0;
    foreach json jsonCollection in sourceCollectionArrayJsonObject {
        collections[i].id = <string>jsonCollection.id;
        collections[i].allowMaterializedViews = convertToBoolean(jsonCollection.allowMaterializedViews);
        collections[i].indexingPolicy = mapJsonToIndexingPolicy(<json>jsonCollection.indexingPolicy);
        collections[i].partitionKey = convertJsonToPartitionKey(<json>jsonCollection.partitionKey);

        i = i + 1;
    }
    return collections;
}

function convertToPartitionKeyRangeArray(json[] sourceAprtitionKeyArrayJsonObject) returns @tainted PartitionKeyRange[] { 
    PartitionKeyRange[] pkranges = [];
    int i = 0;
    foreach json jsonPartitionKey in sourceAprtitionKeyArrayJsonObject {
        //pkranges[i] = mapJsonToPartitionKeyRange([jsonCollection,()]);
        pkranges[i].id = jsonPartitionKey.id.toString();
        pkranges[i].minInclusive = jsonPartitionKey.minInclusive.toString();
        pkranges[i].maxExclusive = jsonPartitionKey.maxExclusive.toString();
        pkranges[i].status = jsonPartitionKey.status.toString();
        i = i + 1;
    }
    return pkranges;
}

function convertToDocumentArray(json[] sourceDocumentArrayJsonObject) returns @tainted Document[]|error { 
    Document[] documents = [];
    int i = 0;
    foreach json document in sourceDocumentArrayJsonObject { 
        documents[i].id = document.id.toString();
        documents[i].document = check document.cloneWithType(anydata);
        documents[i].id = document.id.toString();
        i = i + 1;
    }
    return documents;
}

function convertToStoredProcedureArray(json[] sourceSprocArrayJsonObject) returns @tainted StoredProcedure[] { 
    StoredProcedure[] sprocs = [];
    int i = 0;
    foreach json storedProcedure in sourceSprocArrayJsonObject { 
        sprocs[i].id = storedProcedure.id.toString();
        sprocs[i].body = storedProcedure.body.toString();
        i = i + 1;

    }
    return sprocs;
}


