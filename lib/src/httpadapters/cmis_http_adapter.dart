/*
* Package : Cmis
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 01/07/2013
* Copyright :  S.Hamblett@OSCF
*
* Provides a common interface for Cmis to connect over HTTP,
* allowing for different HTTP adapters to be used.
*/

part of '../../cmis.dart';

/// HTTP Adapter interface
abstract class CmisHttpAdapter {
  /// Completion callback
  dynamic completion;

  /// All responses are JSON Objects
  dynamic jsonResponse = jsonobject.JsonObjectLite<dynamic>();

  /// All response headers
  String? allResponseHeaders;

  /// Default constructor
  CmisHttpAdapter();

  /// Constructor with completer
  CmisHttpAdapter.withCompletion([this.completion]);

  /// Processes the HTTP request returning the server's response as
  /// a JSON Object
  void httpRequest(
    String method,
    String? url, [
    String? data,
    Map<String, String>? headers,
  ]);

  /// Processes the HTTP POST(Form)request returning the server's response as
  /// a JSON Object
  void httpFormRequest(
    String method,
    String? url, [
    Map<dynamic, dynamic>? data,
    Map<String, String>? headers,
  ]);

  /// Processes the HTTP POST(Form Multi Part)request returning
  /// the server's response as a JSON Object.
  void httpFormDataRequest(
    String method,
    String? url, [
    dynamic formData,
    Map<String, String>? headers,
  ]);

  // Result Handling

  /// Error
  void onError(dynamic response);

  /// Success
  void onSuccess(dynamic response);

  // Psuedo response generators

  /// Error
  void generateErrorResponse(
    jsonobject.JsonObjectLite<dynamic> response,
    int status,
  );

  /// Success
  void generateSuccessResponse(jsonobject.JsonObjectLite<dynamic> response);
}
