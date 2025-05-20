/*
 * Package : Cmis
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 01/07/2013
 * Copyright :  S.Hamblett@OSCF
 *
 * Native(JSON) HTTP adapter for Cmis.
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

part of '../../cmis_browser_client.dart';

/// Browser HTTP adapter
class CmisBrowserHttpAdapter extends CmisHttpAdapter {
  /// Default constructor
  CmisBrowserHttpAdapter();

  /// Optional completer
  CmisBrowserHttpAdapter.withCompleter([super.completion])
    : super.withCompletion();

  // We get an HttpRequestProgressEvent on error and process this
  //  to return a JSON Object.
  @override
  FutureOr<XMLHttpRequest> onError(final response) {
    final completer = Completer<XMLHttpRequest>();
    // Process the error response
    if (response.target.status != 0) {
      try {
        final dynamic errorAsJson =
            jsonobject.JsonObjectLite<dynamic>.fromJsonString(
              response.target.responseText,
            );
        generateErrorResponse(errorAsJson, response.target.status);
        allResponseHeaders = response.target.getAllResponseHeaders();
        completer.complete(response.target);
        return completer.future;
      } on Exception {
        final dynamic errorAsJson = jsonobject.JsonObjectLite<dynamic>();
        errorAsJson.message = 'JSON Decode failure';
        generateErrorResponse(errorAsJson, response.target.status);
        allResponseHeaders = response.target.getAllResponseHeaders();
        completer.complete(response.target);
        return completer.future;
      }
    } else {
      final dynamic errorAsJson = jsonobject.JsonObjectLite<dynamic>();
      generateErrorResponse(errorAsJson, response.target.status);
      completer.complete(response.target);
      return completer.future;
    }
  }

  /// Successful completion
  @override
  void onSuccess(dynamic response) {
    jsonResponse.jsonCmisResponse = jsonobject.JsonObjectLite<dynamic>();

    // If stringify fails we may have a document body returned, ie straight text,
    // in this case create a JsonObject with this as its value.
    try {
      final dynamic successAsJson =
          jsonobject.JsonObjectLite<dynamic>.fromJsonString(
            response.responseText,
          );
      generateSuccessResponse(successAsJson);
    } on Exception {
      final dynamic successAsJson = jsonobject.JsonObjectLite<dynamic>();
      successAsJson['rawText'] = response.responseText;
      generateSuccessResponse(successAsJson);
    }

    // Set the response headers
    allResponseHeaders = response.getAllResponseHeaders();
  }

  /// Processes the HTTP request, returning the server's response
  /// via the completion callback.
  @override
  void httpRequest(
    String method,
    String? url, [
    String? data,
    Map<String, String>? headers,
  ]) {
    // Query CMIS over HTTP
    HttpRequest.request(
        url!,
        method: method,
        withCredentials: false,
        responseType: null,
        requestHeaders: headers,
        sendData: data,
      )
      ..then(onSuccess)
      ..catchError(onError)
      ..whenComplete(completion);
  }

  /// Processes the HTTP POST(Form)request, returning the server's response
  /// via the completion callback.
  @override
  void httpFormRequest(
    String method,
    String? url, [
    Map<dynamic, dynamic>? data,
    Map<String, String>? headers,
  ]) {
    // POST CMIS over HTTP
    HttpRequest.postFormData(
        url!,
        data as Map<String, String>,
        withCredentials: false,
        responseType: null,
        requestHeaders: headers,
      )
      ..then(onSuccess)
      ..catchError(onError)
      ..whenComplete(completion);
  }

  /// Processes the HTTP POST(Form Multi Part) request, returning the server's response
  /// via the completion callback.
  @override
  void httpFormDataRequest(
    String method,
    String? url, [
    dynamic formData,
    Map<String, String>? headers,
  ]) {
    // Query CMIS over HTTP
    HttpRequest.request(
        url!,
        method: method,
        withCredentials: false,
        responseType: null,
        requestHeaders: headers,
        sendData: formData,
      )
      ..then(onSuccess)
      ..catchError(onError)
      ..whenComplete(completion);
  }

  /// Error response
  @override
  void generateErrorResponse(dynamic response, int? status) {
    /* Generate the error response */
    jsonResponse.error = true;
    jsonResponse.jsonCmisResponse = response;
    jsonResponse.errorCode = status;
    if (status == 0) {
      response.error = 'Invalid HTTP response';
      response.reason = 'HEAD or status code of 0';
    }
  }

  /// Success response
  @override
  void generateSuccessResponse(jsonobject.JsonObjectLite<dynamic> response) {
    jsonResponse.error = false;
    jsonResponse.errorCode = null;
    jsonResponse.jsonCmisResponse = response;
  }
}
