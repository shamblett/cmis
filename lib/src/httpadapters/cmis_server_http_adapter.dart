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

part of cmis_server_client;

// ignore_for_file: omit_local_variable_types
// ignore_for_file: unnecessary_final
// ignore_for_file: lines_longer_than_80_chars
// ignore_for_file: avoid_annotating_with_dynamic
// ignore_for_file: cascade_invocations

/// Server HTTP adapter
class CmisServerHttpAdapter extends CmisHttpAdapter {
  /// Default constructor
  CmisServerHttpAdapter();

  /// Optional completer
  CmisServerHttpAdapter.withCompleter([dynamic completion])
      : super.withCompletion(completion);

  final http.Client _client = http.Client();

  // We get an HttpRequestProgressEvent on error and process this
  //  to return a JSON Object.
  @override
  void onError(dynamic response) {
    // Process the error response
    final dynamic errorAsJson = jsonobject.JsonObjectLite<dynamic>();
    generateErrorResponse(errorAsJson, 0);

    // Clear the response headers
    allResponseHeaders = null;
  }

  /// Successful completion
  @override
  void onSuccess(dynamic response) {
    jsonResponse.jsonCmisResponse = jsonobject.JsonObjectLite<dynamic>();

    // If stringify fails we may have a document body returned, ie straight text,
    // in this case create a JsonObject with this as its value.
    try {
      final dynamic successAsJson =
          jsonobject.JsonObjectLite<dynamic>.fromJsonString(response.body);
      generateSuccessResponse(successAsJson);
    } on Exception {
      final dynamic successAsJson = jsonobject.JsonObjectLite<dynamic>();
      successAsJson['rawText'] = response.body;
      generateSuccessResponse(successAsJson);
    }

    // Set the response headers
    allResponseHeaders = response.headers.keys.toString();
  }

  /// Processes the HTTP request, returning the server's response
  /// via the completion callback.
  @override
  void httpRequest(String method, String url,
      [String data, Map<String, String> headers]) {
    // Query CMIS over HTTP
    if (method == 'GET') {
      _client
          .get(url, headers: headers)
          .then(onSuccess, onError: onError)
          .whenComplete(completion);
    } else if (method == 'PUT') {
      _client
          .put(url, headers: headers, body: data)
          .then(onSuccess, onError: onError)
          .whenComplete(completion);
    } else if (method == 'POST') {
      _client
          .post(url, headers: headers, body: data)
          .then(onSuccess, onError: onError)
          .whenComplete(completion);
    } else if (method == 'HEAD') {
      _client
          .head(url, headers: headers)
          .then(onSuccess, onError: onError)
          .whenComplete(completion);
    } else if (method == 'DELETE') {
      _client
          .delete(url, headers: headers)
          .then(onSuccess, onError: onError)
          .whenComplete(completion);
    }
  }

  /// Not used on the server
  @override
  void httpFormRequest(String method, String url,
      [Map<dynamic, dynamic> data, Map<String, String> headers]) {}

  /// Not used on the server
  @override
  void httpFormDataRequest(String method, String url,
      [dynamic formData, Map<String, String> headers]) {}

  /// Error response
  @override
  void generateErrorResponse(dynamic response, int status) {
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
