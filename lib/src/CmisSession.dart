/*
 * Packge : Cmis
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 01/07/2013
 * Copyright :  S.Hamblett@OSCF
 *
 * 
 * The main CMIS Session class.
 * 
 * Note that only the most important CMIS features are covered at the moment.
 * Please refer to the accompanying documentation for further details.
 * 
 * It can be used as a standalone CMISlibrary but it is envisaged that it will
 * provide a core library for more advanced and/or specialised CMIS client libraries to 
 * wrap around.
 * 
 * Results of API calls are returned via completion functions supplied by the client. 
 * Clients then call CmisSession API's to determine the outcome of the request. This allows 
 * true async operation throughout the library.
 * 
 * An example of getting a document :-
 * 
 * void completer(){
       
       jsonobject.JsonObject res = cmisSession.completionResponse;
       /* Check for error */
       try {
         expect(res.error, isFalse);
       } catch(e) {
         
         jsonobject.JsonObject errorResponse = res.jsonCmisResponse;
         String errorText = errorResponse.error;
         String reasonText = errorResponse.reason;
         int statusCode = res.errorCode;
         return;
       }
       
       /* Get the success response*/
       jsonobject.JsonObject successResponse = res.jsonCmisResponse;
       .......
  }
 *
 *
 * CmisSessiondepends on the JSON Object library for its response processing.
 * 
 * See the API documentation for more details about individual methods, particularly the 
 * WiltNativeHTTPAdapter for the structure of the Wilt completion response.  
 * 
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
  CmisSession(this._urlPrefix, 
              [this. _repId ] ) {
    
    
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
  set repositoryId(String repoId) => _repId = repoId;  
  get repositoryId => _repId;
  set rootFolderId(String rootFolderId) => _rootFolderId = rootFolderId;
  get rootFolderId => _rootFolderId;
  
  void getRepositories() {
    
    _httpRequest('GET',
        null,
        data:null);
  
  }
  
  void getRepositoryInfo() {
    
    
    if ( _repId == null ) {
      
      throw new CmisException('getRepositoryInfo() expects a non null repository Id');
    }
    
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
   void doQuery(String queryString) {
     
     jsonobject.JsonObject data = new jsonobject.JsonObject();
     data.q = queryString;
     data.cmisSelector = 'query';
     data.maxItems = _opCtx.maxItems;
     data.searchAllVersions = _opCtx.searchAllVersions;
     data.includeAllowableActions = _opCtx.includeAllowableActions;           
     data.includeRelationships = _opCtx.includeRelationships;        
     data.skipCount = _opCtx.skipCount;
     data.suppressResponseCodes = true; 
     
     String dataString = data.toString();
     _httpRequest('POST',
                   null,
                   data:dataString); 
     
   }
  
   void doQueryPaged(String queryString, 
                     String elementId) {
     
     /* Add any found paging contexts */
     var savedCompleter = _httpAdapter.completion;
     
     void localCompleter() {
       
       if ( _httpAdapter.jsonResponse.error == false ) {
         
        if ( _httpAdapter.jsonResponse.error == false ) {
         
           CmisPagingContext pgCtx = getPagingContext(elementId);
           if ( pgCtx == null ) {
            
            addPagingContext(elementId, 
                             0, 
                             _httpAdapter.jsonResponse.jsonCmisResponse.numItems);
           
          } else {
           
           
           _pagingContext[elementId].totalItems = 
               _httpAdapter.jsonResponse.jsonCmisResponse.numItems;
            
          }
           
        }
            
       }
       
       savedCompleter();
     } 
     
     jsonobject.JsonObject data = new jsonobject.JsonObject();
     data.q = queryString;
     data.cmisSelector = 'query';
     data.maxItems = _opCtx.maxItems;
     data.searchAllVersions = _opCtx.searchAllVersions;
     data.includeAllowableActions = _opCtx.includeAllowableActions;           
     data.includeRelationships = _opCtx.includeRelationships;        
     data.skipCount = getPagingContextOffset(elementId);;
     data.suppressResponseCodes = true; 
     
     String dataString = data.toString();
     _httpAdapter.completion = localCompleter;
     _httpRequest('POST',
         null,
         data:dataString);
     
   }
   
   /**
    * Transactions
    */
   void getObjectFromTransaction(String transId) {
     
     jsonobject.JsonObject data = new jsonobject.JsonObject();
     data.token = transId;
     data.cmisSelector = 'lastResult';
     data.suppressResponseCodes = true; 
     
     String dataString = data.toString();
     _httpRequest('GET',
         null,
         data:dataString);
     
     
   }
   
   
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