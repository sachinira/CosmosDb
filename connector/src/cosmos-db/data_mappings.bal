function mapParametersToHeaderType(string httpVerb, string url) returns HeaderParameters {
    HeaderParameters params = {};
    params.verb = httpVerb;
    params.resourceType = getResourceType(url);
    params.resourceId = getResourceId(url);
    return params;
}

function mapOfferHeaderType(string httpVerb, string url) returns HeaderParameters {
    HeaderParameters params = {};
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
    Database database = {};
    database.id = payload.id != ()? payload.id.toString() : EMPTY_STRING;
    database.resourceId = payload._rid != ()? payload._rid.toString() : EMPTY_STRING;
    database.selfReference = payload._self != ()? payload._self.toString() : EMPTY_STRING;
    if(headers is Headers) {
        database[RESPONSE_HEADERS] = headers;
    }    
    return database;
}

function mapJsonToDatabaseListType([json, Headers] jsonPayload) returns @tainted stream<Database> {
    json payload;
    Headers headers;
    [payload,headers] = jsonPayload;
    //DatabaseList databaseList = {};
    stream<Database> db = convertToDatabaseArray(<json[]>payload.Databases);
    //databaseList.reponseHeaders = headers;

    return db;
}

function mapJsonToContainerType([json, Headers?] jsonPayload) returns @tainted Container {
    json payload;
    Headers? headers;
    [payload,headers] = jsonPayload;
    Container container = {};
    container.id = payload.id.toString();
    container.resourceId = payload._rid != ()? payload._rid.toString() : EMPTY_STRING;
    container.selfReference = payload._self != ()? payload._self.toString() : EMPTY_STRING;
    container.allowMaterializedViews = convertToBoolean(payload.allowMaterializedViews);
    container.indexingPolicy = mapJsonToIndexingPolicy(<json>payload.indexingPolicy);
    container.partitionKey = convertJsonToPartitionKey(<json>payload.partitionKey);
    if(headers is Headers) {
        container[RESPONSE_HEADERS] = headers;
    }
    return container;
}

function mapJsonToIndexingPolicy(json jsonPayload) returns @tainted IndexingPolicy {
    IndexingPolicy indexingPolicy = {};
    indexingPolicy.indexingMode = jsonPayload.indexingMode != ()? jsonPayload.indexingMode.toString() : EMPTY_STRING;
    indexingPolicy.automatic = convertToBoolean(jsonPayload.automatic);
    indexingPolicy.includedPaths = convertToIncludedPathsArray(<json[]>jsonPayload.includedPaths);
    indexingPolicy.excludedPaths = convertToIncludedPathsArray(<json[]>jsonPayload.excludedPaths);
    return indexingPolicy;
}

function mapJsonToIncludedPathsType(json jsonPayload) returns @tainted IncludedPath {
    IncludedPath includedPath = {};
    includedPath.path = jsonPayload.path.toString();
    if(jsonPayload.indexes is error) {
        return includedPath;
    } else {
        includedPath.indexes = convertToIndexArray(<json[]>jsonPayload.indexes);
    }
    return includedPath;
}

function mapJsonToIndexType(json jsonPayload) returns Index {
    Index index = {};
    index.kind = jsonPayload.kind != () ? jsonPayload.kind.toString(): EMPTY_STRING;
    index.dataType = jsonPayload.dataType.toString();
    index.precision = convertToInt(jsonPayload.precision);
    return index; 
}

function convertJsonToPartitionKey(json jsonPayload) returns @tainted PartitionKey {
    PartitionKey partitionKey = {};
    partitionKey.paths = convertToStringArray(<json[]>jsonPayload.paths);
    partitionKey.kind = jsonPayload.kind != () ? jsonPayload.kind.toString(): EMPTY_STRING;
    partitionKey.keyVersion = convertToInt(jsonPayload.'version);
    return partitionKey;
}

function mapJsonToContainerListType([json, Headers] jsonPayload) returns @tainted ContainerList {
    ContainerList containerList = {};
    json payload;
    Headers headers;
    [payload,headers] = jsonPayload;
    containerList.resourceId = payload._rid != () ? payload._rid.toString(): EMPTY_STRING;
    containerList.count = convertToInt(payload._count);
    containerList.containers = convertToContainerArray(<json[]>payload.DocumentCollections);
    containerList.reponseHeaders = headers;
    return containerList;
}

function mapJsonToPartitionKeyListType([json, Headers] jsonPayload) returns @tainted PartitionKeyList {
    PartitionKeyList partitionKeyList = {};
    PartitionKeyRange pkr = {};
    json payload;
    Headers headers;
    [payload,headers] = jsonPayload;
    partitionKeyList.resourceId = payload._rid != () ? payload._rid.toString(): EMPTY_STRING;
    partitionKeyList.partitionKeyRanges = convertToPartitionKeyRangeArray(<json[]>payload.PartitionKeyRanges);
    partitionKeyList.reponseHeaders = headers;
    partitionKeyList.count = convertToInt(payload._count);
    return partitionKeyList;
}

function mapJsonToPartitionKeyRange([json, Headers] jsonPayload) returns @tainted PartitionKeyRange {
    PartitionKeyRange partitionKeyRange = {};
    json payload;
    Headers headers;
    [payload,headers] = jsonPayload;
    partitionKeyRange.id = payload.id.toString();
    partitionKeyRange.minInclusive = payload.minInclusive.toString();
    partitionKeyRange.maxExclusive = payload.maxExclusive.toString();
    partitionKeyRange.status = payload.status.toString();
    partitionKeyRange.reponseHeaders = headers;
    return partitionKeyRange;
}

function mapJsonToDocumentType([json, Headers?] jsonPayload) returns @tainted Document {  
    Document document = {};
    json payload;
    Headers? headers;
    [payload,headers] = jsonPayload;
    document.id = payload.id != () ? payload.id.toString(): EMPTY_STRING;
    document.resourceId = payload._rid != () ? payload._rid.toString(): EMPTY_STRING;
    document.selfReference = payload._self != () ? payload._self.toString(): EMPTY_STRING;
    JsonMap|error documentBodyJson = payload.cloneWithType(JsonMap);
    if(documentBodyJson is JsonMap) {
        document.documentBody = mapJsonToDocumentBody(documentBodyJson);
    }
    if(headers is Headers) {
        document[RESPONSE_HEADERS] = headers;
    }
    return document;
}

function mapJsonToDocumentListType([json, Headers] jsonPayload) returns @tainted DocumentList|error {
    DocumentList documentlist = {};
    json payload;
    Headers headers;
    [payload,headers] = jsonPayload;
    documentlist.resourceId = payload._rid != () ? payload._rid.toString(): EMPTY_STRING;
    documentlist.count = convertToInt(payload._count);
    documentlist.documents = check convertToDocumentArray(<json[]>payload.Documents);
    documentlist.reponseHeaders = headers;
    return documentlist;
} 

function mapJsonToStoredProcedureType([json, Headers?] jsonPayload) returns @tainted StoredProcedure {
    StoredProcedure storedProcedure = {};
    json payload;
    Headers? headers;
    [payload,headers] = jsonPayload;
    storedProcedure.resourceId = payload._rid != ()? payload._rid.toString() : EMPTY_STRING;
    storedProcedure.id = payload.id != () ? payload.id.toString(): EMPTY_STRING;
    storedProcedure.body = payload.body !=() ? payload.body.toString(): EMPTY_STRING;
    if(headers is Headers) {
        storedProcedure[RESPONSE_HEADERS] = headers;
    }
    return storedProcedure;
}

function mapJsonToStoredProcedureListType([json, Headers] jsonPayload) returns @tainted StoredProcedureList {
    StoredProcedureList storedProcedurelist = {};
    json payload;
    Headers headers;
    [payload,headers] = jsonPayload;
    storedProcedurelist.resourceId = payload._rid != () ? payload._rid.toString(): EMPTY_STRING;
    storedProcedurelist.storedProcedures = convertToStoredProcedureArray(<json[]>payload.StoredProcedures);
    storedProcedurelist.count = convertToInt(payload._count);
    storedProcedurelist[RESPONSE_HEADERS] = headers;
    return storedProcedurelist;
}

function mapJsonToUserDefinedFunctionType([json, Headers?] jsonPayload) returns @tainted UserDefinedFunction {
    UserDefinedFunction userDefinedFunction = {};
    json payload;
    Headers? headers;
    [payload,headers] = jsonPayload;
    userDefinedFunction.resourceId = payload._rid != () ? payload._rid.toString() : EMPTY_STRING;
    userDefinedFunction.id = payload.id != () ? payload.id.toString() : EMPTY_STRING;
    userDefinedFunction.body = payload.body != () ? payload.body.toString() : EMPTY_STRING;
    if(headers is Headers) {
        userDefinedFunction[RESPONSE_HEADERS] = headers;
    }
    return userDefinedFunction;
}

function mapJsonToUserDefinedFunctionListType([json, Headers] jsonPayload) returns @tainted UserDefinedFunctionList|error {
    UserDefinedFunctionList userDefinedFunctionList = {};
    json payload;
    Headers headers;
    [payload,headers] = jsonPayload;
    userDefinedFunctionList.resourceId = payload._rid != () ? payload._rid.toString() : EMPTY_STRING;
    userDefinedFunctionList.UserDefinedFunctions = userDefinedFunctionArray(<json[]>payload.UserDefinedFunctions);
    userDefinedFunctionList.count = convertToInt(payload._count);
    userDefinedFunctionList[RESPONSE_HEADERS] = headers;
    return userDefinedFunctionList;
}

function mapJsonToTriggerType([json, Headers?] jsonPayload) returns @tainted Trigger {
    Trigger trigger = {};
    json payload;
    Headers? headers;
    [payload,headers] = jsonPayload;
    trigger.resourceId = payload._rid != () ? payload._rid.toString() : EMPTY_STRING;
    trigger.id = payload.id != () ? payload.id.toString() : EMPTY_STRING;
    trigger.body = payload.body != () ? payload.body.toString() : EMPTY_STRING;
    trigger.triggerOperation = payload.triggerOperation != () ? payload.triggerOperation.toString() : EMPTY_STRING;
    trigger.triggerType = payload.triggerType != () ? payload.triggerType.toString() : EMPTY_STRING;
    if(headers is Headers) {
        trigger[RESPONSE_HEADERS] = headers;
    }
    return trigger;
}

function mapJsonToTriggerListType([json, Headers] jsonPayload) returns @tainted TriggerList|error {
    TriggerList triggerList = {};
    json payload;
    Headers headers;
    [payload,headers] = jsonPayload;
    triggerList.resourceId = payload._rid != () ? payload._rid.toString() : EMPTY_STRING;
    triggerList.triggers = ConvertToTriggerArray(<json[]>payload.Triggers);
    triggerList.count = convertToInt(payload._count);
    triggerList[RESPONSE_HEADERS] = headers;
    return triggerList;
}

function mapJsonToUserType([json, Headers?] jsonPayload) returns @tainted User {
    User user = {};
    json payload;
    Headers? headers;
    [payload,headers] = jsonPayload;
    user.resourceId = payload._rid != () ? payload._rid.toString() : EMPTY_STRING;
    user.id = payload.id != () ? payload.id.toString() : EMPTY_STRING;
    if(headers is Headers) {
        user[RESPONSE_HEADERS] = headers;
    }
    return user;
}

function mapJsonToUserListType([json, Headers?] jsonPayload) returns @tainted UserList {
    UserList userList = {};
    json payload;
    Headers? headers;
    [payload,headers] = jsonPayload;
    userList.resourceId = payload._rid != () ? payload._rid.toString() : EMPTY_STRING;
    userList.users = ConvertToUserArray(<json[]>payload.Users);
    userList.count = convertToInt(payload._count);
    userList[RESPONSE_HEADERS] = headers;
    return userList;
}

function mapJsonToPermissionType([json, Headers?] jsonPayload) returns @tainted Permission {
    Permission permission = {};
    json payload;
    Headers? headers;
    [payload,headers] = jsonPayload;
    permission.id = payload.id != () ? payload.id.toString() : EMPTY_STRING;
    permission.resourceId = payload._rid != () ? payload._rid.toString() : EMPTY_STRING;
    permission.permissionMode = payload.permissionMode != () ? payload.permissionMode.toString() : EMPTY_STRING;
    permission.token = payload._token != () ? payload._token.toString() : EMPTY_STRING;
    permission.resourcePath = payload.'resource != () ? payload.'resource.toString() : EMPTY_STRING;
    if(headers is Headers) {
        permission[RESPONSE_HEADERS] = headers;
    }
    return permission;
}

function mapJsonToPermissionListType([json, Headers?] jsonPayload) returns @tainted PermissionList {
    PermissionList permissionList = {};
    json payload;
    Headers? headers;
    [payload,headers] = jsonPayload;
    permissionList.resourceId = payload._rid != () ? payload._rid.toString() : EMPTY_STRING;
    permissionList.permissions = ConvertToPermissionArray(<json[]>payload.Permissions);
    permissionList.count = convertToInt(payload._count);
    permissionList[RESPONSE_HEADERS] = headers;
    return permissionList;
}

function mapJsonToOfferType([json, Headers?] jsonPayload) returns @tainted Offer {
    Offer offer = {};
    json payload;
    Headers? headers;
    [payload,headers] = jsonPayload;
    offer.resourceId = payload._rid != () ? payload._rid.toString() : EMPTY_STRING;
    offer.id = payload.id != () ? payload.id.toString() : EMPTY_STRING;
    offer.offerVersion = payload.offerVersion != () ? payload.offerVersion.toString() : EMPTY_STRING;
    offer.offerType = payload.offerType != () ? payload.offerType.toString() : EMPTY_STRING;
    offer.content = payload.content != () ? payload.content.toString() : EMPTY_STRING;
    offer.resourceSelfLink = payload.'resource != () ? payload.'resource.toString() : EMPTY_STRING;
    offer.offerResourceId = payload.offerResourceId != () ? payload.offerResourceId.toString() : EMPTY_STRING;
    if(headers is Headers) {
        offer[RESPONSE_HEADERS] = headers;
    }
    return offer;
}

function mapJsonToOfferListType([json, Headers?] jsonPayload) returns @tainted OfferList {
    OfferList offerList = {};
    json payload;
    Headers? headers;
    [payload,headers] = jsonPayload;
    offerList.resourceId = payload._rid != () ? payload._rid.toString() : EMPTY_STRING;
    offerList.offers = ConvertToOfferArray(<json[]>payload.Offers);
    offerList.count = convertToInt(payload._count);
    offerList[RESPONSE_HEADERS] = headers;
    return offerList;
}

function convertToDatabaseArray(json[] sourceDatabaseArrayJsonObject) returns @tainted stream<Database> {
    Database[] databases = [];
    int i = 0;
    foreach json jsonDatabase in sourceDatabaseArrayJsonObject {
        databases[i] = mapJsonToDatabaseType([jsonDatabase,()]);
        i = i + 1;
    }
    stream<Database> db = databases.toStream();
    return db;
}

function convertToIncludedPathsArray(json[] sourcePathArrayJsonObject) returns @tainted IncludedPath[] { 
    IncludedPath[] includedPaths = [];
    int i = 0;
    foreach json jsonPath in sourcePathArrayJsonObject {
        includedPaths[i] = <IncludedPath>mapJsonToIncludedPathsType(jsonPath);
        i = i + 1;
    }
    return includedPaths;
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

function convertToContainerArray(json[] sourceCollectionArrayJsonObject) returns @tainted Container[] {
    Container[] collections = [];
    int i = 0;
    foreach json jsonCollection in sourceCollectionArrayJsonObject {
        collections[i] = mapJsonToContainerType([jsonCollection,()]);
        i = i + 1;
    }
    return collections;
}

//
function convertToPartitionKeyRangeArray(json[] sourcePrtitionKeyArrayJsonObject) returns @tainted PartitionKeyRange[] { 
    PartitionKeyRange[] partitionKeyranges = [];
    int i = 0;
    foreach json jsonPartitionKey in sourcePrtitionKeyArrayJsonObject {
        partitionKeyranges[i].id = jsonPartitionKey.id.toString();
        partitionKeyranges[i].minInclusive = jsonPartitionKey.minInclusive.toString();
        partitionKeyranges[i].maxExclusive = jsonPartitionKey.maxExclusive.toString();
        partitionKeyranges[i].status = jsonPartitionKey.status.toString();
        i = i + 1;
    }
    return partitionKeyranges;
}

function convertToDocumentArray(json[] sourceDocumentArrayJsonObject) returns @tainted Document[]|error { 
    Document[] documents = [];
    int i = 0;
    foreach json document in sourceDocumentArrayJsonObject { 
        documents[i] = mapJsonToDocumentType([document,()]);
        i = i + 1;
    }
     //stream<Document> doc = documents.toStream();

    return documents;
}

function convertToStoredProcedureArray(json[] sourceSprocArrayJsonObject) returns @tainted StoredProcedure[] { 
    StoredProcedure[] storedProcedures = [];
    int i = 0;
    foreach json storedProcedure in sourceSprocArrayJsonObject { 
        storedProcedures[i] = mapJsonToStoredProcedureType([storedProcedure,()]);
        i = i + 1;
    }
    return storedProcedures;
}

function userDefinedFunctionArray(json[] sourceUdfArrayJsonObject) returns @tainted UserDefinedFunction[] { 
    UserDefinedFunction[] udfs = [];
    int i = 0;
    foreach json userDefinedFunction in sourceUdfArrayJsonObject { 
        udfs[i] = mapJsonToUserDefinedFunctionType([userDefinedFunction,()]);
        i = i + 1;
    }
    return udfs;
}

function ConvertToTriggerArray(json[] sourceTriggerArrayJsonObject) returns @tainted Trigger[] { 
    Trigger[] triggers = [];
    int i = 0;
    foreach json trigger in sourceTriggerArrayJsonObject { 
        triggers[i] = mapJsonToTriggerType([trigger,()]);
        i = i + 1;
    }
    return triggers;
}

function ConvertToUserArray(json[] sourceTriggerArrayJsonObject) returns @tainted User[] { 
    User[] users = [];
    int i = 0;
    foreach json user in sourceTriggerArrayJsonObject { 
        users[i] = mapJsonToUserType([user,()]);
        i = i + 1;
    }
    return users;
}

function ConvertToPermissionArray(json[] sourcePermissionArrayJsonObject) returns @tainted Permission[] { 
    Permission[] permissions = [];
    int i = 0;
    foreach json permission in sourcePermissionArrayJsonObject { 
        permissions[i] = mapJsonToPermissionType([permission,()]);
        i = i + 1;
    }
    return permissions;
}

function ConvertToOfferArray(json[] sourceOfferArrayJsonObject) returns @tainted Offer[] { 
    Offer[] offers = [];
    int i = 0;
    foreach json offer in sourceOfferArrayJsonObject { 
        offers[i] = mapJsonToOfferType([offer,()]);
        i = i + 1;
    }
    return offers;
}

function mapJsonToDocumentBody(map<json> reponsePayload) returns json {
    var deleteKeys = ["id", "_rid", "_self", "_etag", "_ts", "_attachments"];
    foreach var 'key in deleteKeys {
        if(reponsePayload.hasKey('key)) {
            var removedValue = reponsePayload.remove('key);
        }
    }
    return reponsePayload;
}
