/*
 * Packge : Cmis
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 01/07/2013
 * Copyright :  S.Hamblett@OSCF
 *
 * Provides a common interface for Cmis to connect over HTTP,
 * allowing for different HTTP adapters to be used. 
 */

part of cmis;

abstract class CmisHttpAdapter {
  
  
  CmisHttpAdapter();
  
  
  /*
   * Processes the HTTP request returning the server's response as
   * a JSON Object
   */
  void httpRequest(String method, 
                   String url, 
                   [String data = null,
                   Map headers = null]);
  
  /*
   * Result Handling
   */
  void onError(html.HttpRequestProgressEvent response);
  void onSuccess(html.HttpRequest response);
  
  /*
   * Psuedo respose generators
   */
  void generateErrorResponse(jsonobject.JsonObject response, int status);
  void generateSuccessResponse(jsonobject.JsonObject response);
  
}