function mapParametersToHeaderType(string httpVerb, string url) returns HeaderParamaters {
    HeaderParamaters params = {};
    params.verb = httpVerb;
    params.resourceType = getResourceType(url);
    params.resourceId = getResourceId(url);
    return params;
}

function mapOfferHeaderType(string httpVerb, string url) returns HeaderParamaters {
    HeaderParamaters params = {};
    params.verb = httpVerb;
    params.resourceType = getResourceType(url);
    params.resourceId = getResourceIdForOffer(url);
    return params;
}

function mapTupleToDeleteresponse([string, Headers] jsonPayload)returns @tainted DeleteResponse {
    string message;
    Headers headers;
    [message,headers] = jsonPayload;
    DeleteResponse deleteResponse = {};
    deleteResponse.message = message;
    deleteResponse.reponseHeaders = headers;
    return deleteResponse;
}

function mapJsonToDatabaseType([json, Headers?] jsonPayload) returns Database {
    json payload;
    Headers? headers;
    [payload,headers] = jsonPayload;
    Database db = {};
    db.id = payload.id != ()? payload.id.toString() : EMPTY_STRING;
    db._rid = payload._rid != ()? payload._rid.toString() : EMPTY_STRING;
    db._self = payload._self != ()? payload._self.toString() : EMPTY_STRING;
    if headers is Headers {
        db["reponseHeaders"] = headers;
    }    
    return db;
}

function mapJsonToDbList([json, Headers] jsonPayload) returns @tainted DatabaseList {
    json payload;
    Headers headers;
    [payload,headers] = jsonPayload;
    DatabaseList dbl = {};
    dbl._rid = payload._rid != ()? payload._rid.toString() : EMPTY_STRING;
    dbl.databases =  convertToDatabaseArray(<json[]>payload.Databases);
    dbl.reponseHeaders = headers;
    return dbl;
}

function mapJsonToCollectionType([json, Headers?] jsonPayload) returns @tainted Container {
    json payload;
    Headers? headers;
    [payload,headers] = jsonPayload;
    Container coll = {};
    coll.id = payload.id.toString();
    coll._rid = payload._rid != ()? payload._rid.toString() : EMPTY_STRING;
    coll._self = payload._self != ()? payload._self.toString() : EMPTY_STRING;
    coll.allowMaterializedViews = convertToBoolean(payload.allowMaterializedViews);
    coll.indexingPolicy = mapJsonToIndexingPolicy(<json>payload.indexingPolicy);
    coll.partitionKey = convertJsonToPartitionKey(<json>payload.partitionKey);
    if headers is Headers {
        coll["reponseHeaders"] = headers;
    }
    return coll;
}

//
function mapJsonToIndexingPolicy(json jsonPayload) returns @tainted IndexingPolicy {
    IndexingPolicy indp = {};
    indp.indexingMode = jsonPayload.indexingMode.toString();
    indp.automatic = convertToBoolean(jsonPayload.automatic);
    indp.includedPaths =  convertToIncludedPathsArray(<json[]>jsonPayload.includedPaths);
    indp.excludedPaths =  convertToIncludedPathsArray(<json[]>jsonPayload.excludedPaths);
    return indp;
}

//
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

//
function mapJsonToIndexType(json jsonPayload) returns Index {
    Index ind = {};
    ind.kind = jsonPayload.kind != () ? jsonPayload.kind.toString(): EMPTY_STRING;
    ind.dataType = jsonPayload.dataType.toString();
    ind.precision = convertToInt(jsonPayload.precision);
    return ind; 
}

//
function convertJsonToPartitionKey(json jsonPayload) returns @tainted PartitionKey {
    PartitionKey pk = {};
    pk.paths = convertToStringArray(<json[]>jsonPayload.paths);
    pk.kind = jsonPayload.kind != () ? jsonPayload.kind.toString(): EMPTY_STRING;
    pk.'version = convertToInt(jsonPayload.'version);
    return pk;
}

//
function mapJsonToCollectionListType([json, Headers] jsonPayload) returns @tainted ContainerList {
    ContainerList cll = {};
    json payload;
    Headers headers;
    [payload,headers] = jsonPayload;
    cll._rid = payload._rid != () ? payload._rid.toString(): EMPTY_STRING;
    cll._count = convertToInt(payload._count);
    cll.DocumentCollections = convertToCollectionArray(<json[]>payload.DocumentCollections);
    cll.reponseHeaders = headers;
    return cll;
}

//
function mapJsonToPartitionKeyType([json, Headers] jsonPayload) returns @tainted PartitionKeyList {
    PartitionKeyList pkl = {};
    PartitionKeyRange pkr = {};
    json payload;
    Headers headers;
    [payload,headers] = jsonPayload;
    pkl._rid = payload._rid != () ? payload._rid.toString(): EMPTY_STRING;
    pkl.PartitionKeyRanges = convertToPartitionKeyRangeArray(<json[]>payload.PartitionKeyRanges);
    pkl.reponseHeaders = headers;
    pkl._count = convertToInt(payload._count);
    return pkl;
}

//
function mapJsonToPartitionKeyRange([json, Headers] jsonPayload) returns @tainted PartitionKeyRange {
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

function mapJsonToDocument([json, Headers?] jsonPayload) returns @tainted Document {  
    Document doc = {};
    json payload;
    Headers? headers;
    [payload,headers] = jsonPayload;
    doc.id = payload.id != () ? payload.id.toString(): EMPTY_STRING;
    doc._rid = payload._rid != () ? payload._rid.toString(): EMPTY_STRING;
    doc._self = payload._self != () ? payload._self.toString(): EMPTY_STRING;
    JsonMap|error document = payload.cloneWithType(JsonMap);
    if document is JsonMap {
        doc.documentBody = mapJsonToDocumentBody(document);
    }
    if headers is Headers {
        doc["reponseHeaders"] = headers;
    }
    return doc;
}

function mapJsonToDocumentList([json, Headers] jsonPayload) returns @tainted DocumentList|error {
    DocumentList documentlist = {};
    json payload;
    Headers headers;
    [payload,headers] = jsonPayload;
    documentlist._rid = payload._rid != () ? payload._rid.toString(): EMPTY_STRING;
    documentlist._count = convertToInt(payload._count);
    documentlist.documents = check convertToDocumentArray(<json[]>payload.Documents);
    documentlist.reponseHeaders = headers;
    return documentlist;
} 

function mapJsonToStoredProcedure([json, Headers?] jsonPayload) returns @tainted StoredProcedure {
    StoredProcedure sproc = {};
    json payload;
    Headers? headers;
    [payload,headers] = jsonPayload;
    sproc._rid = payload._rid != ()? payload._rid.toString() : EMPTY_STRING;
    sproc.id = payload.id != () ? payload.id.toString(): EMPTY_STRING;
    sproc.body = payload.body !=() ? payload.body.toString(): EMPTY_STRING;
    if headers is Headers {
        sproc["reponseHeaders"] = headers;
    }
    return sproc;
}

function mapJsonToStoredProcedureList([json, Headers] jsonPayload) returns @tainted StoredProcedureList {
    StoredProcedureList sproclist = {};
    json payload;
    Headers headers;
    [payload,headers] = jsonPayload;
    sproclist._rid = payload._rid != () ? payload._rid.toString(): EMPTY_STRING;
    sproclist.storedProcedures = convertToStoredProcedureArray(<json[]>payload.StoredProcedures);
    sproclist._count = convertToInt(payload._count);
    sproclist["reponseHeaders"] = headers;
    return sproclist;
}

function mapJsonToUserDefinedFunction([json, Headers?] jsonPayload) returns @tainted UserDefinedFunction {
    UserDefinedFunction udf = {};
    json payload;
    Headers? headers;
    [payload,headers] = jsonPayload;
    udf._rid = payload._rid != () ? payload._rid.toString() : EMPTY_STRING;
    udf.body = payload.body != () ? payload.body.toString() : EMPTY_STRING;
    if headers is Headers {
        udf["reponseHeaders"] = headers;
    }
    return udf;
}

function mapJsonToUserDefinedFunctionList([json, Headers] jsonPayload) returns @tainted UserDefinedFunctionList|error {
    UserDefinedFunctionList udflist = {};
    json payload;
    Headers headers;
    [payload,headers] = jsonPayload;
    udflist._rid = payload._rid != () ? payload._rid.toString() : EMPTY_STRING;
    udflist.UserDefinedFunctions = userDefinedFunctionArray(<json[]>payload.UserDefinedFunctions);
    udflist._count = convertToInt(payload._count);
    udflist["reponseHeaders"] = headers;
    return udflist;
}

function mapJsonToTrigger([json, Headers?] jsonPayload) returns @tainted Trigger {
    Trigger trigger = {};
    json payload;
    Headers? headers;
    [payload,headers] = jsonPayload;
    trigger._rid = payload._rid != () ? payload._rid.toString() : EMPTY_STRING;
    trigger.id = payload.id != () ? payload.id.toString() : EMPTY_STRING;
    trigger.body = payload.body != () ? payload.body.toString() : EMPTY_STRING;
    trigger.triggerOperation = payload.triggerOperation != () ? payload.triggerOperation.toString() : EMPTY_STRING;
    trigger.triggerType = payload.triggerType != () ? payload.triggerType.toString() : EMPTY_STRING;
    if headers is Headers {
        trigger["reponseHeaders"] = headers;
    }
    return trigger;
}

function mapJsonToTriggerList([json, Headers] jsonPayload) returns @tainted TriggerList|error {
    TriggerList triggerlist = {};
    json payload;
    Headers headers;
    [payload,headers] = jsonPayload;
    triggerlist._rid = payload._rid != () ? payload._rid.toString() : EMPTY_STRING;
    triggerlist.triggers = ConvertToTriggerArray(<json[]>payload.Triggers);
    triggerlist._count = convertToInt(payload._count);
    triggerlist["reponseHeaders"] = headers;
    return triggerlist;
}

function mapJsonToUser([json, Headers?] jsonPayload) returns @tainted User {
    User user = {};
    json payload;
    Headers? headers;
    [payload,headers] = jsonPayload;
    user._rid = payload._rid != () ? payload._rid.toString() : EMPTY_STRING;
    user.id = payload.id != () ? payload.id.toString() : EMPTY_STRING;
    if headers is Headers {
        user["reponseHeaders"] = headers;
    }
    return user;
}

function mapJsonToUserList([json, Headers?] jsonPayload) returns @tainted UserList {
    UserList userlist = {};
    json payload;
    Headers? headers;
    [payload,headers] = jsonPayload;
    userlist._rid = payload._rid != () ? payload._rid.toString() : EMPTY_STRING;
    userlist.users = ConvertToUserArray(<json[]>payload.Users);
    userlist._count = convertToInt(payload._count);
    userlist["reponseHeaders"] = headers;
    return userlist;
}

function mapJsonToPermission([json, Headers?] jsonPayload) returns @tainted Permission {
    Permission permission = {};
    json payload;
    Headers? headers;
    [payload,headers] = jsonPayload;
    permission.id = payload.id != () ? payload.id.toString() : EMPTY_STRING;
    permission._rid = payload._rid != () ? payload._rid.toString() : EMPTY_STRING;
    permission.permissionMode = payload.permissionMode != () ? payload.permissionMode.toString() : EMPTY_STRING;
    permission.'resource = payload.'resource != () ? payload.'resource.toString() : EMPTY_STRING;
    if headers is Headers {
        permission["reponseHeaders"] = headers;
    }
    return permission;
}

function mapJsonToPermissionList([json, Headers?] jsonPayload) returns @tainted PermissionList {
    PermissionList permissionList = {};
    json payload;
    Headers? headers;
    [payload,headers] = jsonPayload;
    permissionList._rid = payload._rid != () ? payload._rid.toString() : EMPTY_STRING;
    permissionList.permissions = ConvertToPermissionArray(<json[]>payload.Permissions);
    permissionList._count = convertToInt(payload._count);
    permissionList["reponseHeaders"] = headers;
    return permissionList;
}

function mapJsonToOffer([json, Headers?] jsonPayload) returns @tainted Offer {
    Offer offer = {};
    json payload;
    Headers? headers;
    [payload,headers] = jsonPayload;
    offer._rid = payload._rid != () ? payload._rid.toString() : EMPTY_STRING;
    offer.id = payload.id != () ? payload.id.toString() : EMPTY_STRING;
    offer.offerVersion = payload.offerVersion != () ? payload.offerVersion.toString() : EMPTY_STRING;
    offer.offerType = payload.offerType != () ? payload.offerType.toString() : EMPTY_STRING;
    offer.content = payload.content != () ? payload.content.toString() : EMPTY_STRING;
    offer.'resource = payload.'resource != () ? payload.'resource.toString() : EMPTY_STRING;
    offer.offerResourceId = payload.offerResourceId != () ? payload.offerResourceId.toString() : EMPTY_STRING;
    if headers is Headers {
        offer["reponseHeaders"] = headers;
    }
    return offer;
}

function mapJsonToOfferList([json, Headers?] jsonPayload) returns @tainted OfferList {
    OfferList offerList = {};
    json payload;
    Headers? headers;
    [payload,headers] = jsonPayload;
    offerList._rid = payload._rid != () ? payload._rid.toString() : EMPTY_STRING;
    offerList.offers = ConvertToOfferArray(<json[]>payload.Offers);
    offerList._count = convertToInt(payload._count);
    offerList["reponseHeaders"] = headers;
    return offerList;
}

function convertToDatabaseArray(json[] sourceDatabaseArrayJsonObject) returns @tainted Database[] {
    Database[] databases = [];
    int i = 0;
    foreach json jsonDatabase in sourceDatabaseArrayJsonObject {
        databases[i] = mapJsonToDatabaseType([jsonDatabase,()]);
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
        collections[i] = mapJsonToCollectionType([jsonCollection,()]);
        i = i + 1;
    }
    return collections;
}

//
function convertToPartitionKeyRangeArray(json[] sourcePrtitionKeyArrayJsonObject) returns @tainted PartitionKeyRange[] { 
    PartitionKeyRange[] pkranges = [];
    int i = 0;
    foreach json jsonPartitionKey in sourcePrtitionKeyArrayJsonObject {
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
        documents[i] = mapJsonToDocument([document,()]);
        i = i + 1;
    }
    return documents;
}

function convertToStoredProcedureArray(json[] sourceSprocArrayJsonObject) returns @tainted StoredProcedure[] { 
    StoredProcedure[] sprocs = [];
    int i = 0;
    foreach json storedProcedure in sourceSprocArrayJsonObject { 
        sprocs[i] = mapJsonToStoredProcedure([storedProcedure,()]);
        i = i + 1;
    }
    return sprocs;
}

function userDefinedFunctionArray(json[] sourceUdfArrayJsonObject) returns @tainted UserDefinedFunction[] { 
    UserDefinedFunction[] udfs = [];
    int i = 0;
    foreach json userDefinedFunction in sourceUdfArrayJsonObject { 
        udfs[i] = mapJsonToUserDefinedFunction([userDefinedFunction,()]);
        i = i + 1;
    }
    return udfs;
}

function ConvertToTriggerArray(json[] sourceTriggerArrayJsonObject) returns @tainted Trigger[] { 
    Trigger[] triggers = [];
    int i = 0;
    foreach json trigger in sourceTriggerArrayJsonObject { 
        triggers[i] = mapJsonToTrigger([trigger,()]);
        i = i + 1;
    }
    return triggers;
}

function ConvertToUserArray(json[] sourceTriggerArrayJsonObject) returns @tainted User[] { 
    User[] users = [];
    int i = 0;
    foreach json user in sourceTriggerArrayJsonObject { 
        users[i] = mapJsonToUser([user,()]);
        i = i + 1;
    }
    return users;
}

function ConvertToPermissionArray(json[] sourcePermissionArrayJsonObject) returns @tainted Permission[] { 
    Permission[] permissions = [];
    int i = 0;
    foreach json permission in sourcePermissionArrayJsonObject { 
        permissions[i] = mapJsonToPermission([permission,()]);
        i = i + 1;
    }
    return permissions;
}

function ConvertToOfferArray(json[] sourceOfferArrayJsonObject) returns @tainted Offer[] { 
    Offer[] offers = [];
    int i = 0;
    foreach json offer in sourceOfferArrayJsonObject { 
        offers[i] = mapJsonToOffer([offer,()]);
        i = i + 1;
    }
    return offers;
}

function mapJsonToDocumentBody(map<json> reponsePayload) returns json {
    var deleteKeys = ["id","_rid","_self","_etag","_ts","_attachments"];
    foreach var 'key in deleteKeys {
        if reponsePayload.hasKey('key) {
            var removedValue = reponsePayload.remove('key);
        }
    }
    return reponsePayload;
}
