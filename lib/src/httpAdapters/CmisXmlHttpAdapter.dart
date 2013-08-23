/*
 * Packge : Cmis
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 01/07/2013
 * Copyright :  S.Hamblett@OSCF
 *
 * XML HTTP adapter for Cmis.
 *  
 * This always returns a JSON Object for use by the completion function.
 * 
 * The format of the JSON Object returned is as follows :-
 * 
 * error              : true if an error has occured, false otherwise
 * responseText       : the response text from HTTP
 * errorCode          : the status code from HTTP
 * jsonCmisResponse   : The responseText from the CMIS server as a JSON Object,
 *                      this should be interpreted by the caller depending
 *                      on the request issued.
 *                      
 */

part of cmis;

class CmisXmlHttpAdapter implements CmisHttpAdapter {
  
 
  /* The method used */
  String _method = null;
  
  /* All responses are JSON Objects */
  jsonobject.JsonObject jsonResponse = new jsonobject.JsonObject();
  
  /* Completion callback */
  var completion = null;
  
 /* Optional completer */
 CmisXmlHttpAdapter([this.completion]);
    
  /* All response headers */
  String allResponseHeaders = null;
 
  /**
   * Convert the incoming XML data to JSON 
   */
  jsonobject.JsonObject _xml2Json(String xml){
    
    
    
  }
  /*
   * We get an HttpRequestProgressEvent on error and process this
   * to return a JSON Object.
   * 
   */
  void onError(html.HttpRequestProgressEvent response){
    
    /* Get the HTTP request from the progress event */
    html.HttpRequest req = response.target;
    
    /* Process the error response */
    if ( req.status != 0 ) {
      
      jsonobject.JsonObject errorAsJson = new jsonobject.JsonObject.fromJsonString(req.responseText);
      generateErrorResponse(errorAsJson, req.status);
      
    } else {
      
      jsonobject.JsonObject errorAsJson = new jsonobject.JsonObject();
      generateErrorResponse(errorAsJson, req.status);
      
    }
    
    /* Set the response headers */
    allResponseHeaders = req.getAllResponseHeaders();
  }
  
  /**
   * Successful completion
   */
  void onSuccess(html.HttpRequest response){
    
    //TODO convert from XML
    jsonobject.JsonObject successAsJson = new jsonobject.JsonObject.fromJsonString(response.responseText);
    generateSuccessResponse(successAsJson);
    
    /* Set the response headers */
    allResponseHeaders = response.getAllResponseHeaders();
    
  }
  
  
   
  /*
   * Processes the HTTP request, returning the server's response
   * via the completion callback.
   */
  void httpRequest(String method, 
                   String url, 
                   [String data = null,
                   Map headers = null]) {
    
     
     /* Initialise */
     _method = method;
    
    /* Query CMIS over HTTP */ 
    html.HttpRequest.request(url,
                        method:method,
                        withCredentials:false,
                        responseType:"json",
                        requestHeaders:headers,
                        sendData:data
        
        )
        ..then(onSuccess)
        ..catchError(onError)
        ..whenComplete(completion);
    
  }
  
  /*
   * Psuedo respose generators
   */
void generateErrorResponse(jsonobject.JsonObject response, int status) {
    
    /* Generate the error response */
    jsonResponse.error = true;
    jsonResponse.jsonCmisResponse = response;
    jsonResponse.errorCode = status;
    if ( status == 0 ) {
      
      response.error = "Invalid HTTP response";
      response.reason = "HEAD or status code of 0";
      
    }
    
  }
 
  void generateSuccessResponse(jsonobject.JsonObject response) {
    
    /* Generate the success response */
    jsonResponse.error = false;
    jsonResponse.errorCode = null;
    jsonResponse.jsonCmisResponse = response;
    
    
  }
  
}