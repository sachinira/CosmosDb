import ballerina/http;


function parseResponseToJson(http:Response|http:ClientError httpResponse) returns @tainted json|error {
    if (httpResponse is http:Response) {
        var jsonResponse = httpResponse.getJsonPayload();

        if(httpResponse.statusCode == http:STATUS_NO_CONTENT){
            return jsonResponse;
        }
        
        if (jsonResponse is json) {
            if (httpResponse.statusCode != http:STATUS_OK && httpResponse.statusCode != http:STATUS_CREATED) {
                string code = "";
                if (jsonResponse?.error_code != ()) {
                    code = jsonResponse.error_code.toString();
                } else if (jsonResponse?.'error != ()) {
                    code = jsonResponse.'error.toString();
                }

                string message = jsonResponse.message.toString();
                string errorMessage = httpResponse.statusCode.toString() + " " + httpResponse.reasonPhrase;
                if (code != "") {
                    errorMessage += " - " + code;
                }
                errorMessage += " : " + message;
                return prepareError(errorMessage);
            }
            return jsonResponse;
        } else {
            return prepareError("Error occurred while accessing the JSON payload of the response");
        }
    } else {
        return prepareError("Error occurred while invoking the REST API");
    }
}

function prepareError(string message, error? err = ()) returns error {
    error azureError;
    if (err is error) {
        azureError = AzureError(message, err);
    } else {
        azureError = AzureError(message);
    }
    return azureError;
}