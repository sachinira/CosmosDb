
# To create a custom error instance
# + return - returns error.  
function prepareError(string message, error? err = ()) returns error { 
    error azureError;
    if (err is error) {
        azureError = AzureError(message, err);
    } else {
        azureError = AzureError(message);
    }
    return azureError;
}