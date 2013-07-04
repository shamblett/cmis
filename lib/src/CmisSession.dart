/*
 * Packge : Cmis
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 01/07/2013
 * Copyright :  S.Hamblett@OSCF
 *
 * 
 * The main CMIS Session class
 */

part of cmis;

class CmisSession{
  

  /* CMIS data structures */
  String _repId = null;
  String _urlPrefix = null;
  String _rootUrl = null;
  CmisOperationContext _opCtx = new CmisOperationContext();
  String _rootFolderId = null; 
  CmisTypeCache _typeCache = new CmisTypeCache();    
  CmisPagingContext _pagingContext = null;
  
  /* Authentication */
  String _user = null;
  String _password = null;
  
  /* Http Adapter */
  CmisNativeHttpAdapter _httpAdapter = null;
  
  /* Constructor */
  CmisSession(_urlPrefix, 
              [ _repId ] ) {
    
    
    /* Get our HTTP adapter */
    _httpAdapter = new CmisNativeHttpAdapter(null);
    
  }
  
  
  /* Private */
  
  /**
   *  The internal HTTP request method. This wraps the
   *  HTTP adapter class. 
  */
  void _httpRequest( String method, 
                     String url, 
                     {String data:null, 
                     Map headers:null}) {
    
    
    /* Build the request for the HttpAdapter*/
    Map cmisHeaders = new Map<String,String>();
    cmisHeaders["Accept"] = "application/json";
    if ( headers != null ) cmisHeaders.addAll(headers);
    
    /* Build the URL */
    String cmisUrl = "$_urlPrefix/";
    if ( _repId != null) cmisUrl = "$cmisUrl$_repId/"; 
    if ( url != null ) cmisUrl = "$cmisUrl/url";
    
    /* Check for authentication */
    if ( _user != null ) {
                
          
      String authStringToEncode = "$_user:$_password";
      String encodedAuthString = html.window.btoa(authStringToEncode);
      String authString = "Basic $encodedAuthString";
      cmisHeaders['Authorization'] = authString;
      
    } else {
      
      throw new CmisException('HttpRequest() expects a non null user name and password');
      
    }
    
    /* Execute the request*/
    _httpAdapter.httpRequest(method, 
                             cmisUrl, 
                             data, 
                             cmisHeaders);
    
  }
  

  /**
   * Takes a URL and key/value pair for a URL parameter and adds this
   * to the query parameters of the URL.
   */
  String _setURLParameter( String url, 
                           String key, 
                           String value) {
    
    var originalUrl = Uri.parse(url);
    Map queryParams = originalUrl.queryParameters;
    Map newQueryParams = new  Map<String,String>.from(queryParams);
    newQueryParams[key] = value;
    
    var newUrl = new Uri(scheme:originalUrl.scheme,
                         userInfo:originalUrl.userInfo,
                         host:originalUrl.host,
                         port:originalUrl.port,
                         path:originalUrl.path,
                         queryParameters:newQueryParams);
                         
        
    String returnUrl = newUrl.toString();
    return returnUrl;
    
  }
  
  /* Public */
  
  /* Getters and Setter */
  
  /**
   *  Completion callback 
   */  
  set resultCompletion (var completion )  {
    
    _httpAdapter.completion = completion;
  }
  
  
  /**
   *  Response getter for completion callbacks 
   */
  jsonobject.JsonObject get completionResponse => _httpAdapter.jsonResponse;
  
  
  
  
  
  /* Updates the login credentials in Cmis that will be used for all further
   * requests to the CMIS server. Both user name and password must be set, even if one
   * or the other is '' i.e empty. This must be called before the CMIS client
   * can be used.
   */
  void login(String user, 
             String password) {
    
    
   if ( (user == null ) || (password == null) ) {
     
     throw new CmisException('Login() expects a non null user name and password');
   }
     
    _user = user;
    _password = password;
    
    
  }
  
  
}