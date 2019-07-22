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
  /* All responses are JSON Objects */
  dynamic jsonResponse = new jsonobject.JsonObjectLite();

  /* Completion callback */
  dynamic completion = null;

  /* Optional completer */
  CmisXmlHttpAdapter([this.completion]);

  /* All response headers */
  String allResponseHeaders = null;

  /*
   * We get an HttpRequestProgressEvent on error and process this
   * to return a JSON Object.
   * 
   */
  void onError(html.HttpRequest response) {
    /* Process the error response */
    if (response.status != 0) {
      final dynamic errorAsJson =
          new jsonobject.JsonObjectLite.fromJsonString(response.responseText);
      generateErrorResponse(errorAsJson, response.status);
    } else {
      final dynamic errorAsJson = new jsonobject.JsonObjectLite();
      generateErrorResponse(errorAsJson, response.status);
    }

    /* Set the response headers */
    allResponseHeaders = response.getAllResponseHeaders();
  }

  /// Successful completion
  void onSuccess(html.HttpRequest response) {
    //TODO convert from XML
    final dynamic successAsJson =
        new jsonobject.JsonObjectLite.fromJsonString(response.responseText);
    generateSuccessResponse(successAsJson);

    /* Set the response headers */
    allResponseHeaders = response.getAllResponseHeaders();
  }

  /*
   * Processes the HTTP request, returning the server's response
   * via the completion callback.
   */
  void httpRequest(String method, String url,
      [String data = null, Map headers = null]) {
    /* Initialise */

    /* Query CMIS over HTTP */
    html.HttpRequest.request(url,
        method: method,
        withCredentials: false,
        responseType: null,
        requestHeaders: headers,
        sendData: data)
      ..then(onSuccess)
      ..catchError(onError)
      ..whenComplete(completion);
  }

  /*
   * Processes the HTTP POST(Form)request, returning the server's response
   * via the completion callback.
   */
  void httpFormRequest(String method, String url,
      [Map data = null, Map headers = null]) {
    /* Initialise */

    /* POST CMIS over HTTP */
    html.HttpRequest.postFormData(url, data,
        withCredentials: false, responseType: null, requestHeaders: headers)
      ..then(onSuccess)
      ..catchError(onError)
      ..whenComplete(completion);
  }

  /*
   * Processes the HTTP  POST(Form Multi Part) request, returning the server's response
   * via the completion callback.
   */
  void httpFormDataRequest(String method, String url,
      [html.FormData formData = null, Map headers = null]) {
    /* Initialise */

    /* Query CMIS over HTTP */
    html.HttpRequest.request(url,
        method: method,
        withCredentials: false,
        responseType: null,
        requestHeaders: headers,
        sendData: formData)
      ..then(onSuccess)
      ..catchError(onError)
      ..whenComplete(completion);
  }

  /*
   * Psuedo respose generators
   */
  void generateErrorResponse(dynamic response, int status) {
    /* Generate the error response */
    jsonResponse.error = true;
    jsonResponse.jsonCmisResponse = response;
    jsonResponse.errorCode = status;
    if (status == 0) {
      response.error = "Invalid HTTP response";
      response.reason = "HEAD or status code of 0";
    }
  }

  void generateSuccessResponse(jsonobject.JsonObjectLite response) {
    /* Generate the success response */
    jsonResponse.error = false;
    jsonResponse.errorCode = null;
    jsonResponse.jsonCmisResponse = response;
  }
}
