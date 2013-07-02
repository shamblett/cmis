
/*
 * Packge : Cmis
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 01/07/2013
 * Copyright :  S.Hamblett@OSCF
 *
 * The Cmis class provides core functionality for interacting with CMIS servers from
 * the browser.
 * 
 * The class itself is based on the cmislib.js library from the Apache Chemistry project..
 * 
 */

part of cmis;

class Cmis {
  
  /**
   * Authentication type constants 
   * 
   * AUTH_BASIC denotes Basic HTTP authentication. 
   * If login is called AUTH_BASIC is set, otherwise it defaults to AUTH_NONE
   * 
   */

  static const String AUTH_BASIC = 'basic';
  static const String AUTH_NONE = 'none';
  
  
  /* Http parameter set */
  String db = null;                 //Database name
  String host = null;              //Host to connect to.
  String port = null;              //Port to connect to.
  String scheme = null;            //Scheme
  CmisNativeHttpAdapter _httpAdapter;
  
  
  /* Completion function */
  var clientCompletion = null;
  
  /* Authentication, both user and password must be set together */
  String _user = null;                      //Username to authenticate with.
  String _password = null;                  //Password to authenticate with.
  String authenticationType = AUTH_NONE;   //Authentication type
   
 /* Constructor */
  Cmis(this.host,
       this.port,
       this.scheme,
       [this.clientCompletion = null]) {
    
    if ( (host == null) ||
         (port == null)  ||
         (scheme == null )) {
      
      throw new CmisException('Bad construction - some or all required parameters are null');
      
    }
    
    /* Get our HTTP adapter */
    _httpAdapter = new CmisNativeHttpAdapter(this.clientCompletion);
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
    String cmisUrl = "$scheme$host:$port$url";
    
    /* Check for authentication */
    if ( _user != null ) {
      
      switch (authenticationType) {
                
        case AUTH_BASIC :
          
          String authStringToEncode = "$_user:$_password";
          String encodedAuthString = html.window.btoa(authStringToEncode);
          String authString = "Basic $encodedAuthString";
          cmisHeaders['Authorization'] = authString;
          break;
          
        case AUTH_NONE :
          
          break;
      }
      
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
    
    clientCompletion = completion;
    _httpAdapter.completion = completion;
  }
  
  /**
   *  Response getter for completion callbacks 
   */
  jsonobject.JsonObject get completionResponse => _httpAdapter.jsonResponse;
    
  
  
  /**
   * Authentication
   */
  
  /* Updates the login credentials in Cmis that will be used for all further
   * requests to the CMIS serevr. Both user name and password must be set, even if one
   * or the other is '' i.e empty. After logging in all communication with the CMIS server
   * is made using the selected auithentication method.
   */
  void login(String user, 
             String password) {
    
    
   if ( (user == null ) || (password == null) ) {
     
     throw new CmisException('Login() expects a non null user name and password');
   }
     
    _user = user;
    _password = password;
    authenticationType = AUTH_BASIC;
    
  }
  
  
  
}