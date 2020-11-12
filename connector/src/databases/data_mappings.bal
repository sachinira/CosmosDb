

function mapJsonToDatabase(json jsonPayload) returns Database {

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