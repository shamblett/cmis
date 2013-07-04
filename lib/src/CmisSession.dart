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
  Map _pagingContext = new Map<String,CmisPagingContext>();
  
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
  
  /**
   *  Completion callback 
   */  
  set resultCompletion (var completion )  => _httpAdapter.completion = completion;
  
  
  /**
   *  Response getter for completion callbacks 
   */
  jsonobject.JsonObject get completionResponse => _httpAdapter.jsonResponse;

  /**
   * URL handling
   */
  String get url => _urlPrefix;
  String get rootUrl => _rootUrl;
  set rootUrl(String url) => _rootUrl = url;
  
  /**
   * Paging context
   */
  void addPagingContext(String elementId, 
                        int skipCount, 
                        int numItemsTotal) { 
    
    _pagingContext[elementId] = new CmisPagingContext(skipCount, 
                                                      numItemsTotal, 
                                                      _opCtx);
  }
  
  CmisPagingContext getPagingContext(String elementId) {
    
    return _pagingContext[elementId];
    
  }
  
  bool setPagingContextOffset(String elementId, 
                              int offset) {
    
    if ( _pagingContext.containsKey(elementId) ) {
    
      _pagingContext[elementId].skipCount = offset;
      return true;
      
    }
    
    return false;
    
  }
    
  int getPagingContextOffset(String elementId) {
  
    if ( _pagingContext.containsKey(elementId) ) {
      
      return _pagingContext[elementId].skipCount;
    }
    
    return 0;
      
   }
  
  void deletePagingContext(String elementId) {
    
    _pagingContext.remove(elementId);
    
   }
  
  /**
   * Repository 
   */
  
   void getRepositoryInfo() {
    
    String data = 'cmisSelector: "repositoryInfo"';
    _httpRequest('GET',
                 null,
                 data:data);
    
    }
   
   /**
    * CMIS objects
    */
   void create(String name, 
               String typeId, 
               String folderId,
               String cmisAction,
               [ Map customProperties ] ) {
     
     
     String url = rootUrl;
     jsonobject.JsonObject data = new jsonobject.JsonObject();
     data.cmisaction = cmisAction;
     data.objectId = folderId;
     data.suppressResponseCodes = true;
     
     /* Properties */
     Map properties = new Map<String,String>();
     properties['cmis:name'] = name;
     properties['cmis:objectTypeId'] = typeId;
     
     /* Add any supplied custom properties */
     if ( customProperties != null ) {
       
       properties.addAll(customProperties);
     }
     
     /* Construct the final data set */
     properties.forEach((String key,String value) {
       
       data.key = value;
       
     });
     
     String dataString = data.toString();
     _httpRequest('POST',
         url,
         data:dataString); 
   }
   
   /**
    * Documents
    */
   void getDocument(String id) {
     
     String url = rootUrl;
     jsonobject.JsonObject data = new jsonobject.JsonObject();
     data.objectId = id;
     data.cmisSelector = 'object';
     data.filter = _opCtx.propertyFilter;
     data.includeAllowableActions = _opCtx.includeAllowableActions;           
     data.includeRelationships = _opCtx.includeRelationships;        
     data.includePolicyIds =  _opCtx.includePolicies;          
     data.includeACL = _opCtx.includeAcls;            
     data.suppressResponseCodes = true; 
     
     String dataString = data.toString();
     _httpRequest('GET',
         url,
         data:dataString);
                         
   }
   
   void getChildren(String id) {
     
     String url = rootUrl;
     jsonobject.JsonObject data = new jsonobject.JsonObject();
     data.objectId = id;
     data.cmisSelector = 'children';
     data.filter = _opCtx.propertyFilter;
     data.includeAllowableActions = _opCtx.includeAllowableActions;           
     data.includeRelationships = _opCtx.includeRelationships;        
     data.includePolicyIds =  _opCtx.includePolicies;          
     data.includeACL = _opCtx.includeAcls; 
     data.includePathSegment = _opCtx.includePathSegments;
     data.skipCount = _opCtx.skipCount;
     data.maxItems = _opCtx.maxItems;
     data.suppressResponseCodes = true; 
     
     String dataString = data.toString();
     _httpRequest('GET',
         url,
         data:dataString);
                         
   }
  
   void deleteDocument(String id) {
    
    String url = rootUrl;
    jsonobject.JsonObject data = new jsonobject.JsonObject();
    data.objectId = id;
    data.cmisSelector = 'delete';
    data.suppressResponseCodes = true; 
    
    String dataString = data.toString();
    _httpRequest('POST',
        url,
        data:dataString);
    
   
   } 
  
   void createDocument(String name, 
                      String typeId, 
                      String folderId,
                      [ Map customProperties ] ) {
    
     create(name, 
            typeId, 
            folderId, 
            "createDocument",
            customProperties );
   }
   
   void createFolder(String name, 
                     String typeId, 
                     String folderId,
                     [ Map customProperties ] ) {
    
     create(name, 
            typeId, 
            folderId, 
            "createFolder",
            customProperties );
    }
  
  /**
   * Type definitions
   */
   void getTypeDefinition(String typeId) {
    
     /* Add any found type to the cache */
     var savedCompleter = _httpAdapter.completion;
     
     void localCompleter() {
       
       if ( _httpAdapter.jsonResponse.error == false ) {
         
        _typeCache.addType(_httpAdapter.jsonResponse.jsonCmisResponse.type);
            
       }
       savedCompleter();
     }
     
     jsonobject.JsonObject data = new jsonobject.JsonObject();
     data.typeId = typeId;
     data.cmisSelector = 'typeDefinition';
     data.includePropertyDefinitions = _opCtx.includePropertyDefinitions;
     data.suppressResponseCodes = true; 

     /* Try the cache initially */  
     jsonobject.JsonObject cachedTypeDef = _typeCache.getType(typeId);
     if ( cachedTypeDef == null ) { 
       
      /* Not found in cache get it from the server */
       String dataString = data.toString();
       _httpAdapter.completion = localCompleter;
       _httpRequest('GET',
                    null,
                    data:dataString);
       
     } else {
       
       _httpAdapter.jsonResponse.error = false;
       _httpAdapter.jsonResponse.jsonCmisResponse.type = cachedTypeDef; 
       if ( _httpAdapter.completion != null ) _httpAdapter.completion();
       
     }
     
     
   }
   
   void getTypeChildren(String typeId) {
     
     jsonobject.JsonObject data = new jsonobject.JsonObject();
     data.typeId = typeId;
     data.cmisSelector = 'typeChildren';
     data.includePropertyDefinitions = _opCtx.includePropertyDefinitions;
     data.skipCount = _opCtx.skipCount;
     data.suppressResponseCodes = true; 

     String dataString = data.toString();
     _httpRequest('GET',
         null,
         data:dataString);
     
   }
   
  /**
   * Queries
   */
   
  
   
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