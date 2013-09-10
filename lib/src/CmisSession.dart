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
  String _rootFolderId = null; 
  
  set repositoryId(String repoId) => _repId = repoId;  
  get repositoryId => _repId;
  set rootFolderId(String rootFolderId) => _rootFolderId = rootFolderId;
  get rootFolderId => _rootFolderId;
  
  String _urlPrefix = null;
  String _serviceUrlPrefix = null;
  String get url => _urlPrefix;
  String get serviceUrl => _serviceUrlPrefix;
  get rootUrl => _getRootFolderUrl();
  get returnedRootUrl => _getRootFolderUrl(true);
  
  CmisOperationContext _opCtx = new CmisOperationContext();
  CmisOperationContext get operationalContext => _opCtx;
  set operationalContext(CmisOperationContext opCtx) => _opCtx = opCtx;
  
  CmisTypeCache _typeCache = new CmisTypeCache();    
  Map _pagingContext = new Map<String,CmisPagingContext>();
  
  int _depth = 5;
  set depth(int depth) => _depth = depth;
  get depth => _depth;
  
  /* Authentication */
  String _user = null;
  String _password = null;
  
  /* Proxy indicator */
  bool _proxy = false;
  bool get proxy => _proxy;
  set proxy(bool proxy) => _proxy = proxy;
  
  /* Http Adapter */
  CmisNativeHttpAdapter _httpAdapter = null;
  
  /* Repository Information */
  jsonobject.JsonObject _repoInformation = null;
  
  /* Constructor */
  CmisSession(this._urlPrefix, 
              [this._serviceUrlPrefix,
               this. _repId ] ) {
    
    
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
                     {bool useServiceUrl:false,
                     jsonobject.JsonObject data:null, 
                     Map headers:null,
                     html.FormData formData: null}) {
    
    
    /* Build the request for the HttpAdapter */
    Map cmisHeaders = new Map<String,String>();
    cmisHeaders["Accept"] = "application/json";
    if ( headers != null ) cmisHeaders.addAll(headers);
    
    /* Build the URL if we are not passed one. */
    String cmisUrl = null;
    Map httpData = new Map<String,String>();
      
    cmisUrl = "$_urlPrefix/";
    if ( (_serviceUrlPrefix != null) && useServiceUrl ) {    
    
      cmisUrl = "$_serviceUrlPrefix";
    }
    
    if ( _repId != null) cmisUrl = "$cmisUrl$_repId/"; 
    if ( url != null ) cmisUrl = "$cmisUrl$url";
    
    /* Add any url parameters if this is a GET */
    if ( method == 'GET') {
      
      if ( data != null ) {
        
        data.forEach((String key, dynamic  value){
       
          cmisUrl = _setURLParameter(cmisUrl, 
                               key, 
                               value);
         });
        
       }
      
    } else if( method == 'POST' ) {
      
      /* Get the data as a map for POST */
      if ( data != null ) {
        
        data.forEach((String key, dynamic value){
          
          httpData[key] = value.toString();
          
        });
        
      }
      
    } else {
      
        
        /* Form data supplied */
        httpData = null;
      
    }
      
    
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
    if ( method == 'GET' ) {
    
      _httpAdapter.httpRequest(method, 
                             cmisUrl, 
                             httpData.toString(), 
                             cmisHeaders);
    
    } else {
      
      /* Method is POST, normal or form data */
      if ( data != null ) {
        
        _httpAdapter.httpFormRequest(method, 
            cmisUrl, 
            httpData, 
            cmisHeaders);
        
      } else {
        
        _httpAdapter.httpFormDataRequest(method, 
            cmisUrl, 
            formData, 
            cmisHeaders);
      }
    }
  }
  

  /**
   * Takes a URL and key/value pair for a URL parameter and adds this
   * to the query parameters of the URL.
   */
  String _setURLParameter( String url, 
                           String key, 
                           dynamic value) {
    
    var originalUrl = Uri.parse(url);
    Map queryParams = originalUrl.queryParameters;
    Map newQueryParams = new  Map<String,String>.from(queryParams);
    newQueryParams[key] = value.toString();;
    
    var newUrl = new Uri(scheme:originalUrl.scheme,
                         userInfo:originalUrl.userInfo,
                         host:originalUrl.host,
                         port:originalUrl.port,
                         path:originalUrl.path,
                         queryParameters:newQueryParams);
                         
        
    String returnUrl = newUrl.toString();
    return returnUrl;
    
  }
  
  /**
   * If we are using a proxy, URL's returned form the repository
   * need to be adjusted to cater for this.
   */
  String _caterForProxyServer(String url) {
    
    /* Cut the passed in URL at the end of the repo id */
    String pattern = "$_repId/";
    List urlStrings = url.split(pattern);
    String proxiedUrl = urlStrings[1];
    return proxiedUrl;
    
  }
  
  /**
   * Getter for the root folder URL checking for proxy use
   */
  
  String _getRootFolderUrl([ bool ignoreProxy = false]) {
    
    /* Get the root folder URL for the selected repository */
    jsonobject.JsonObject repoInformation = new jsonobject.JsonObject();
    if ( !_repoInformation.containsKey(_repId)) {
      
      throw new CmisException('getRootFolderUrl() no repository information found');
    }
    repoInformation = _repoInformation[_repId];
    String rootUrl = null;
    /* Ignore the proxy check if we want the root url from the repository */
    if ( (!ignoreProxy) && _proxy ) {
      
      rootUrl = _caterForProxyServer(repoInformation.rootFolderUrl);
      
    } else {
      
     rootUrl = repoInformation.rootFolderUrl;
     
    }
    
    return rootUrl;
    
  }
  
  /**
   * Mime type checker, if text return true, otherwise false.
   */
  bool _isText(String mimeType) {
    
    if ( mimeType.contains('text/') ) return true;
    return false;
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
  void getRepositories() {
    
    /* Save any found repositories */
    var savedCompleter = _httpAdapter.completion;
    
    void localCompleter() {
      
      if ( _httpAdapter.jsonResponse.error == false ) {
        
       _repoInformation = _httpAdapter.jsonResponse.jsonCmisResponse;
            
       }
       savedCompleter();
     }
    
    _httpAdapter.completion = localCompleter;
    _httpRequest('GET',
        null,
        useServiceUrl:true,
        data:null);
  
  }
  
  void getRepositoryInfo() {
    
    
    if ( _repId == null ) {
      
      throw new CmisException('getRepositoryInfo() expects a non null repository Id');
    }
    
    /* Get the repository information if we have it */
    if ( _repoInformation != null ) {
      
      jsonobject.JsonObject repoInformation = new jsonobject.JsonObject();
      repoInformation = null;
      _repoInformation.forEach((var key, Map value){
      
        if ( key == _repId )  repoInformation = value;
          
      });
     
      if ( repoInformation != null ) {
        
        /* Construct a success response */
        jsonobject.JsonObject successAsJson = repoInformation; 
        _httpAdapter.generateSuccessResponse(successAsJson);
        
      } else {
        
        /* No repository info, construct an error response */
        jsonobject.JsonObject errorAsJson = new jsonobject.JsonObject();
        _httpAdapter.generateErrorResponse(errorAsJson, 0);
      }
  
    } else {
      
      /* No repositories, construct an error response */
      jsonobject.JsonObject errorAsJson = new jsonobject.JsonObject();
      _httpAdapter.generateErrorResponse(errorAsJson, 0);
    }

    /* Complete the call */
    if (  _httpAdapter.completion != null) _httpAdapter.completion();
    
   }
   
  void getCheckedOutDocs() {
    
    if ( _repId == null ) {
      
      throw new CmisException('getCheckedOutDocs() expects a non null repository Id');
    }
    jsonobject.JsonObject data = new jsonobject.JsonObject();
    data.cmisselector = 'checkedOut';
    data.includePropertyDefinitions = _opCtx.includePropertyDefinitions;
    data.maxItems = _opCtx.maxItems;   
    data.skipCount = _opCtx.skipCount;
    data.propertyFilter = _opCtx.propertyFilter;
    data.renditionFilter = _opCtx.renditionFilter;
    data.includeAllowableActions = _opCtx.includeAllowableActions;
    data.includeRelationships = _opCtx.includeRelationships;
    data.succint = _opCtx.succint;
    
    _httpRequest('GET',
        null,
        data:data);
    
  }
  
  /**
   * Root folder 
   */
  
  void getRootFolderContents() {
    
    if ( _repId == null ) {
      
      throw new CmisException('getRootFolderContents() expects a non null repository Id');
    }
    
    String rootUrl = _getRootFolderUrl();
    
    _httpRequest('GET',
        rootUrl,
        data:null);
    
    
  }
  
   /**
    * CMIS objects
    */
   void create(String name, 
               String cmisAction,
               {String typeId : null, 
                String parentId : null,
                String parentPath : null,
                String content : null,
                String mimeType : null,
                Map customProperties : null} ) {
     
     
     String url = _getRootFolderUrl();
     if ( parentPath != null ) url = "$url/$parentPath";
     jsonobject.JsonObject data = new jsonobject.JsonObject();
     html.FormData formData = new html.FormData();
     bool useFormData = false;
     
     /* Headers, we only create documents or folders */
     Map headers = new Map<String,String>();
     
     if ( typeId == 'cmis:folder' ) {
       
       headers['Content-Type'] = 'application/x-www-form-urlencoded';
       
     } else {
         
       useFormData = true;
       
     }
     
     /* Properties for normal POST submit */
     if ( !useFormData ) {
      
      data.cmisaction = cmisAction; 
      Map properties = new Map<String,String>();
      properties['cmis:name'] = name;
      if ( parentId != null ) properties['objectId'] = parentId;
      if ( typeId != null ) properties['cmis:objectTypeId'] = typeId;
      if ( content != null ) properties['content'] = content;
 
      /* Add any supplied custom properties */
      if ( customProperties != null ) {
       
        properties.addAll(customProperties);
      }
  
      /* Construct the final data set */
      int index = 0;
      Map jsonMap = new Map<String,String>();
      properties.forEach((String key,String value) {
       
       
       String propId = "propertyId[$index]";
       String propValue = "propertyValue[$index]";
       jsonMap["$propId"] = key;
       jsonMap["$propValue"] = value;
       index++;
       
      });
     
      data.addAll(jsonMap);
      formData = null;
      
     } else {
       
       /* Form data interface for stream/content interfaces */    
       formData.append('cmisaction', cmisAction);
       formData.append('PropertyId[0]', 'cmis:name');
       formData.append('PropertyValue[0]', name);   
       if ( typeId != null ) {
         
         formData.append('PropertyId[1]', 'cmis:objectTypeId');
         formData.append('PropertyValue[1]', typeId);
       }
      if ( parentId != null ) {
         
         formData.append('PropertyId[2]', 'objectId');
         formData.append('PropertyValue[2]', parentId);
       }
      List blobParts = new List<String>();
      blobParts.add(content);
      html.Blob theBlob = new html.Blob(blobParts, mimeType);
      formData.appendBlob('content', theBlob); 
      data = null;
       
     } 
     
     _httpRequest('POST',
         url,
         data:data,
         headers:headers,
         formData: formData); 
  
     
  }
   
   void delete(String objectId, 
               [bool allVersions = false]) {
     
     String url = _getRootFolderUrl();
     
     jsonobject.JsonObject data = new jsonobject.JsonObject();
     data.cmisaction = 'delete';
     data.objectId = objectId;
     data.allVersions = allVersions.toString();
     
     /* Headers, always the same for delete */
     Map headers = new Map<String,String>();
     headers['Content-Type'] = 'application/x-www-form-urlencoded';
       
     _httpRequest('POST',
         url,
         data:data,
         headers:headers); 
   }
   
   /**
    * Documents/Folders
    */
   
   /**
    * Documents
    */
   void getDocument(String documentId) {
     
     jsonobject.JsonObject data = new jsonobject.JsonObject();
     data.objectId = documentId;   
     String rootUrl = _getRootFolderUrl();
     
     _httpRequest('GET',
         rootUrl,
         data:data);
                         
   }
   
  
   void deleteDocument(String objectId, 
     [ bool allVersions = false ]) {

       delete(objectId,
           allVersions);
    
   
   } 
  
   
   void createDocument( String name, 
                        { String typeId : null, 
                        String content : null,
                        String folderPath : null,
                        String fileName : null,
                        html.File file : null,
                        Map customProperties : null} ) {
     
     
     /* Declare the File Reader */
     html.FileReader reader = new html.FileReader();
     
     /* Initialise */
     if ( typeId == null ) typeId = "cmis:document";
     String mimeType = null;
     if ( fileName != null ) mimeType = lookupMimeType(fileName);
     
     /* File read completers */
     void fileRead() {
         
       String content = reader.result.toString();
      
       create(name, 
           "createDocument",
           typeId : typeId,
           content: content,
           mimeType: mimeType,
           parentPath : folderPath,
           customProperties : customProperties );
       
     }
     
     void fileReadError() {
       
       throw new CmisException('createDocument() error reading input file');
       
     }
     
     /* See if we have a filename or content, get the file contents if needed */
     if ( content == null ) {
       
       if ( fileName == null ) throw new CmisException('createDocument() expects content or a file name');
        
       /* Read the file */
       reader.onLoadEnd.listen((e) => fileRead());
       reader.onError.listen((e) => fileReadError());
       
       /* We only do text here */ 
       reader.readAsText(file);
       
     } else {
     
      /* Create from content supplied as a string */
      create(name, 
         "createDocument",
         typeId : typeId,
         content: content,
         parentPath : folderPath,
         customProperties : customProperties );
     
     }
     
   }
   
   /**
    * Folders
    */
  
  void getFolderChildren(String folderId) {
     
    jsonobject.JsonObject data = new jsonobject.JsonObject();
    data.objectId = folderId; 
    data.cmisselector = 'children';
    data.includePropertyDefinitions = _opCtx.includePropertyDefinitions;
    data.maxItems = _opCtx.maxItems;   
    data.skipCount = _opCtx.skipCount;
    data.propertyFilter = _opCtx.propertyFilter;
    data.renditionFilter = _opCtx.renditionFilter;
    data.includePathSegment = _opCtx.includePathSegment;
    data.includeAllowableActions = _opCtx.includeAllowableActions;
    data.includeRelationships = _opCtx.includeRelationships;
    data.succint = _opCtx.succint;
    String rootUrl = _getRootFolderUrl();
    
    _httpRequest('GET',
        rootUrl,
        data:data);
    
  }
   
  void getFolderDescendants(String folderId) {
     
    jsonobject.JsonObject data = new jsonobject.JsonObject();
    data.objectId = folderId; 
    data.cmisselector = 'descendants';
    data.includePropertyDefinitions = _opCtx.includePropertyDefinitions;
    data.depth = _depth;
    data.propertyFilter = _opCtx.propertyFilter;
    data.renditionFilter = _opCtx.renditionFilter;
    data.includePathSegment = _opCtx.includePathSegment;
    data.includeAllowableActions = _opCtx.includeAllowableActions;
    data.includeRelationships = _opCtx.includeRelationships;
    data.succint = _opCtx.succint;
    String rootUrl = _getRootFolderUrl();
    
    _httpRequest('GET',
        rootUrl,
        data:data);
    
  }
  
  void getFolderTree(String folderId) {
    
    jsonobject.JsonObject data = new jsonobject.JsonObject();
    data.objectId = folderId; 
    data.cmisselector = 'folderTree';
    data.includePropertyDefinitions = _opCtx.includePropertyDefinitions;
    data.depth = _depth;
    data.propertyFilter = _opCtx.propertyFilter;
    data.renditionFilter = _opCtx.renditionFilter;
    data.includePathSegment = _opCtx.includePathSegment;
    data.includeAllowableActions = _opCtx.includeAllowableActions;
    data.includeRelationships = _opCtx.includeRelationships;
    data.succint = _opCtx.succint;
    String rootUrl = _getRootFolderUrl();
    
    _httpRequest('GET',
        rootUrl,
        data:data);
    
  }
  
  void getFolderParent(String folderId) {
    
    jsonobject.JsonObject data = new jsonobject.JsonObject();
    data.objectId = folderId; 
    data.cmisselector = 'parent';
    data.propertyFilter = _opCtx.propertyFilter;
    data.succint = _opCtx.succint;
    String rootUrl = _getRootFolderUrl();
    
    _httpRequest('GET',
        rootUrl,
        data:data);
  }

  void getFolderCheckedOutDocs(String folderId) {
  
    jsonobject.JsonObject data = new jsonobject.JsonObject();
    data.objectId = folderId; 
    data.cmisselector = 'checkedout';
    data.includePropertyDefinitions = _opCtx.includePropertyDefinitions;
    data.maxItems = _opCtx.maxItems;   
    data.skipCount = _opCtx.skipCount;
    data.propertyFilter = _opCtx.propertyFilter;
    data.renditionFilter = _opCtx.renditionFilter;
    data.includePathSegment = _opCtx.includePathSegment;
    data.includeAllowableActions = _opCtx.includeAllowableActions;
    data.includeRelationships = _opCtx.includeRelationships;
    data.succint = _opCtx.succint;
    String rootUrl = _getRootFolderUrl();
    
    _httpRequest('GET',
        rootUrl,
        data:data);
  
  }
  
   void createFolder(String name, 
                     { String typeId : null, 
                       String parentId : null,
                       String parentPath : null,
                       Map customProperties : null} ) {

     if ( typeId == null ) typeId = "cmis:folder";
     create(name, 
            "createFolder",
            typeId : typeId,
            parentId : parentId,
            parentPath : parentPath,
            customProperties : customProperties );
    }
  
   void deleteFolder(String objectId, 
                    [ bool allVersions = false ]) {

     delete(objectId,
            allVersions);
            
    }
  /**
   * Type definitions
   */
   
   void getTypeDefinition(String typeId) {
    
     /* Add any found type to the cache */
     var savedCompleter = _httpAdapter.completion;
     
     void localCompleter() {
       
       if ( _httpAdapter.jsonResponse.error == false ) {
         
        _typeCache.addType(_httpAdapter.jsonResponse.jsonCmisResponse);
            
       }
       savedCompleter();
     }
     
     if ( _repId == null ) {
       
       throw new CmisException('getTypeDefinitiion() expects a non null repository Id');
     }
     if ( typeId == null ) {
       
       throw new CmisException('getTypeChildren() expects a type id');
     }
     jsonobject.JsonObject data = new jsonobject.JsonObject();
     data.typeid = typeId;
     data.cmisselector = 'typeDefinition';

     /* Try the cache initially */  
     jsonobject.JsonObject cachedTypeDef = _typeCache.getType(typeId);
     if ( cachedTypeDef == null ) { 
       
      /* Not found in cache get it from the server */
       _httpAdapter.completion = localCompleter;
       _httpRequest('GET',
                    null,
                    data:data);
       
     } else {
       
       _httpAdapter.generateSuccessResponse(cachedTypeDef);
       if ( _httpAdapter.completion != null ) _httpAdapter.completion();
       
     }
     
     
   }
   
   void getTypeChildren([String typeId = null]) {
     
    if ( _repId == null ) {
       
       throw new CmisException('getTypeChildren() expects a non null repository Id');
     }
     jsonobject.JsonObject data = new jsonobject.JsonObject();
     data.cmisSelector = 'typeChildren';
     data.includePropertyDefinitions = _opCtx.includePropertyDefinitions;
     data.maxItems = _opCtx.maxItems;
     data.skipCount = _opCtx.skipCount;
     if ( typeId != null ) data.typeId = typeId;
     _httpRequest('GET',
         null,
         data:data);
     
   }
   
   void getTypeDescendants([String typeId = null]) {
     
     if ( _repId == null ) {
       
       throw new CmisException('getTypeDescendants() expects a non null repository Id');
     }
     jsonobject.JsonObject data = new jsonobject.JsonObject();
     data.cmisselector = 'typeDescendants';
     data.includePropertyDefinitions = _opCtx.includePropertyDefinitions;
     data.depth = _depth;
     if ( typeId != null ) data.typeId = typeId;
     _httpRequest('GET',
         null,
         data:data);
     
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