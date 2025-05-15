/*
 * Packge : Cmis
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 01/07/2013
 * Copyright :  S.Hamblett@OSCF
 *
 * 
 * The main CMIS Session class.
 * 
 * Note that only a subset of CMIS features are covered at the moment.
 * Please refer to the accompanying documentation for further details.
 * 
 * Cmis can be used as a standalone CMIS library but it is envisaged that it will
 * provide a core library for more advanced and/or specialised CMIS client libraries to 
 * wrap around.
 * 
 * A repository must be set for the majority of the API to work, typical usage is :
 * 
 * cmisSession.getRepositories() to get a list of repositories
 * cmisSession.repositoryId = xxxxxxx
 * 
 * Results of API calls are returned via completion functions supplied by the client. 
 * Clients then call CmisSession API's to determine the outcome of the request. This allows 
 * true async operation throughout the library.
 * 
 * An example of getting a document :-
 * 
 * void doDocInfo(Event e) {
  
  void completer() {
    
    jsonobject.JsonObjectLite cmisResponse = cmisSession.completionResponse;
    
    if ( cmisResponse.error ) {
    
      jsonobject.JsonObjectLite errorResponse = cmisResponse.jsonCmisResponse;
      int errorCode = cmisResponse.errorCode;
      String error = null;
      String reason = null;
      if ( errorCode == 0 ) {
        
        error = errorResponse.error;
        reason = errorResponse.reason;
        
      } else {
        
        error = errorResponse.message;
        reason = "CMIS Server Response";
      }
      
      String message = "Error - $error, Reason - $reason, Code - $errorCode";
      print(error);
      
    } else {
      
        Do whatever here with the success response ........... 
            outputDocInfoList(cmisResponse);
      
    }
    
  }
  
    cmisSession.getDocument(<document object id>);
  
}
 *
 *
 * CmisSession depends on the JSON Object class for its response processing.
 * 
 * See the API documentation for more details about individual methods, particularly the 
 * CmisNativeHTTPAdapter for the structure of the Cmis completion response.  
 * 
 */

part of '../cmis.dart';

/// CMIS session management
class CmisSession {
  /// Default constructor
  CmisSession(
    this._urlPrefix,
    this._httpAdapter,
    this._environmentSupport, [
    this._serviceUrlPrefix,
    this.repositoryId,
  ]);

  /// CMIS repository identifier
  String? repositoryId;

  /// CMIS root folder
  String? rootFolderId;

  final String? _urlPrefix;
  final String? _serviceUrlPrefix;

  /// URL
  String? get url => _urlPrefix;

  /// Service URL
  String? get serviceUrl => _serviceUrlPrefix;

  /// Root URL
  String? get rootUrl => _getRootFolderUrl();

  /// Root URL for proxy use
  String? get returnedRootUrl => _getRootFolderUrl(true);

  final CmisOperationContext _opCtx = CmisOperationContext();

  final CmisTypeCache _typeCache = CmisTypeCache();
  final Map<String, CmisPagingContext> _pagingContext =
      <String, CmisPagingContext>{};

  /// Search depth
  int depth = 5;

  /// User name
  String? _user;

  /// Password
  String? _password;

  /// Proxy indicator
  bool proxy = false;

  final CmisHttpAdapter _httpAdapter;
  final CmisEnvironmentSupport _environmentSupport;

  jsonobject.JsonObjectLite<dynamic> _repoInformation =
      jsonobject.JsonObjectLite<dynamic>();

  /// The internal HTTP request method. This wraps the
  /// HTTP adapter class.
  Future<void> _httpRequest(
    String method,
    String? url, {
    bool useServiceUrl = false,
    jsonobject.JsonObjectLite<dynamic>? data,
    Map<String, String>? headers,
    dynamic formData,
  }) async {
    // Build the request for the HttpAdapter */
    final cmisHeaders = <String, String>{};
    cmisHeaders['accept'] = 'application/json';
    if (headers != null) {
      cmisHeaders.addAll(headers);
    }

    // Build the URL if we are not passed one.
    var cmisUrl = url;
    Map<String?, String>? httpData = <String?, String>{};
    if (cmisUrl == null) {
      cmisUrl = '$_urlPrefix';
      if ((_serviceUrlPrefix!.isNotEmpty) && useServiceUrl) {
        cmisUrl = '$_serviceUrlPrefix';
      }

      if (repositoryId != null && repositoryId!.isNotEmpty) {
        cmisUrl = '$cmisUrl/$repositoryId';
      }
    }
    // Add any url parameters if this is a GET */
    if (method == 'GET') {
      if (data != null) {
        data.forEach((dynamic key, dynamic value) {
          cmisUrl = _setURLParameter(cmisUrl!, key, value);
        });
      }
    } else if (method == 'POST') {
      // Get the data as a map for POST
      if (data != null) {
        data.forEach((dynamic key, dynamic value) {
          httpData![key] = value.toString();
        });
      }
    } else {
      // Form data supplied
      httpData = null;
    }

    // Check for authentication
    if (_user != null) {
      final authStringToEncode = '$_user:$_password';
      final encodedAuthString = _environmentSupport.encodedAuthString(
        authStringToEncode,
      );
      final authString = 'Basic $encodedAuthString';
      cmisHeaders['authorization'] = authString;
    }

    // Execute the request
    if (method == 'GET') {
      _httpAdapter.httpRequest(
        method,
        cmisUrl,
        httpData.toString(),
        cmisHeaders,
      );
    } else {
      // Method is POST, normal or form data
      if (data != null) {
        _httpAdapter.httpFormRequest(method, cmisUrl, httpData, cmisHeaders);
      } else {
        // Methods is POST, multi part request
        _httpAdapter.httpFormDataRequest(
          method,
          cmisUrl,
          formData,
          cmisHeaders,
        );
      }
    }
  }

  /// Takes a URL and key/value pair for a URL parameter and adds this
  /// to the query parameters of the URL.
  String _setURLParameter(String url, String key, dynamic value) {
    final originalUrl = Uri.parse(url);
    final queryParams = originalUrl.queryParameters;
    final newQueryParams = Map<String, dynamic>.from(queryParams);
    newQueryParams[key] = value.toString();

    final newUrl = Uri(
      scheme: originalUrl.scheme,
      userInfo: originalUrl.userInfo,
      host: originalUrl.host,
      port: originalUrl.port,
      path: originalUrl.path,
      queryParameters: newQueryParams,
    );

    return _environmentSupport.decodeUrl(newUrl.toString());
  }

  /// If we are using a proxy, URL's returned form the repository
  /// need to be adjusted to cater for this.
  String _caterForProxyServer(String url) {
    // Cut the passed in URL at the end of the repo id
    final pattern = '$repositoryId/';
    final urlStrings = url.split(pattern);
    return urlStrings[1];
  }

  /// Getter for the root folder URL checking for proxy use
  String? _getRootFolderUrl([bool ignoreProxy = false]) {
    // Get the root folder URL for the selected repository
    dynamic repoInformation = jsonobject.JsonObjectLite<dynamic>();
    if (!_repoInformation.containsKey(repositoryId)) {
      throw CmisException('getRootFolderUrl() no repository information found');
    }
    repoInformation = _repoInformation[repositoryId];
    String? rootUrl;
    // Ignore the proxy check if we want the root url from the repository
    if ((!ignoreProxy) && proxy) {
      rootUrl = _caterForProxyServer(repoInformation.rootFolderUrl);
    } else {
      rootUrl = repoInformation.rootFolderUrl;
    }

    return rootUrl;
  }

  /// Completion callback
  set resultCompletion(dynamic completion) =>
      _httpAdapter.completion = completion;

  /// Response getter for completion callbacks
  jsonobject.JsonObjectLite<dynamic> get completionResponse =>
      _httpAdapter.jsonResponse;

  /// Add a paging context
  void addPagingContext(String elementId, int skipCount, int numItemsTotal) {
    _pagingContext[elementId] = CmisPagingContext(
      skipCount,
      numItemsTotal,
      _opCtx,
    );
  }

  /// Paging context
  CmisPagingContext? getPagingContext(String elementId) =>
      _pagingContext[elementId];

  /// Set the paging context offset
  bool setPagingContextOffset(String elementId, int offset) {
    if (_pagingContext.containsKey(elementId)) {
      _pagingContext[elementId]!.skipCount = offset;
      return true;
    }

    return false;
  }

  /// Get the paging context offset
  int getPagingContextOffset(String elementId) {
    if (_pagingContext.containsKey(elementId)) {
      return _pagingContext[elementId]!.skipCount;
    }

    return 0;
  }

  /// Delete the paging context offset
  void deletePagingContext(String elementId) {
    _pagingContext.remove(elementId);
  }

  /// Get a list of repositories
  void getRepositories() {
    // Save any found repositories
    final dynamic savedCompleter = _httpAdapter.completion;

    void localCompleter() {
      if (_httpAdapter.jsonResponse.error == false) {
        _repoInformation = jsonobject.JsonObjectLite<dynamic>.fromJsonString(
          _httpAdapter.jsonResponse.jsonCmisResponse.toString(),
        );
      }
      savedCompleter();
    }

    _httpAdapter.completion = localCompleter;
    _httpRequest('GET', null, useServiceUrl: true, data: null);
  }

  /// Get information for a supplied repository.
  /// The client must set repositoryId as returned by getRepositories()
  /// before calling this.
  void getRepositoryInfo() {
    if (repositoryId == null) {
      throw CmisException(
        'getRepositoryInfo() expects a non null repository Id',
      );
    }

    // Get the repository information if we have it
    jsonobject.JsonObjectLite<dynamic> repoInformation;
    if (_repoInformation.isNotEmpty) {
      repoInformation = jsonobject.JsonObjectLite<dynamic>.fromJsonString(
        _repoInformation.toString(),
      );
      if (repoInformation.isNotEmpty) {
        // Construct a success response
        final dynamic successAsJson = repoInformation;
        _httpAdapter.generateSuccessResponse(successAsJson);
      } else {
        // No repository info, construct an error response
        final dynamic errorAsJson = jsonobject.JsonObjectLite<dynamic>();
        _httpAdapter.generateErrorResponse(errorAsJson, 0);
      }
    } else {
      /* No repositories, construct an error response */
      final dynamic errorAsJson = jsonobject.JsonObjectLite<dynamic>();
      _httpAdapter.generateErrorResponse(errorAsJson, 0);
    }

    // Complete the call
    if (_httpAdapter.completion != null) {
      _httpAdapter.completion();
    }
  }

  /// Get checked out documents from the repository
  void getCheckedOutDocs() {
    if (repositoryId == null) {
      throw CmisException(
        'getCheckedOutDocs() expects a non null repository Id',
      );
    }
    final dynamic data = jsonobject.JsonObjectLite<dynamic>();
    data.cmisselector = 'checkedOut';
    data.includePropertyDefinitions = _opCtx.includePropertyDefinitions;
    data.maxItems = _opCtx.maxItems;
    data.skipCount = _opCtx.skipCount;
    data.propertyFilter = _opCtx.propertyFilter;
    data.renditionFilter = _opCtx.renditionFilter;
    data.includeAllowableActions = _opCtx.includeAllowableActions;
    data.includeRelationships = _opCtx.includeRelationships;
    data.succint = _opCtx.succint;

    _httpRequest('GET', null, data: data);
  }

  /// Get the contents of the root folder
  void getRootFolderContents() {
    if (repositoryId == null) {
      throw CmisException(
        'getRootFolderContents() expects a non null repository Id',
      );
    }

    final rootUrl = _getRootFolderUrl();

    _httpRequest('GET', rootUrl, data: null);
  }

  /// Create item, see the supporting documentation as to what this
  /// currently supports.
  void create(
    String name,
    String cmisAction, {
    String? typeId,
    String? parentId,
    String? parentPath,
    String? content,
    String? mimeType,
    Map<String, String>? customProperties,
  }) {
    if (repositoryId == null) {
      throw CmisException('create() expects a non null repository Id');
    }

    var url = _getRootFolderUrl();
    if (parentPath != null) {
      url = '$url/$parentPath';
    }
    dynamic data = jsonobject.JsonObjectLite<dynamic>();
    dynamic formData = _environmentSupport.formData();
    var useFormData = false;

    // Headers, we only create documents or folders */
    final headers = <String, String>{};

    if (typeId == 'cmis:folder') {
      headers['content-type'] = 'application/x-www-form-urlencoded';
    } else {
      if (formData != null) {
        useFormData = true;
      }
    }

    // Properties for normal POST submit
    if (!useFormData) {
      data.cmisaction = cmisAction;
      final properties = <String, String>{};
      properties['cmis:name'] = name;
      if (parentId != null) {
        properties['objectId'] = parentId;
      }
      if (typeId != null) {
        properties['cmis:objectTypeId'] = typeId;
      }
      if (content != null) {
        properties['content'] = content;
      }

      // Add any supplied custom properties
      if (customProperties != null) {
        properties.addAll(customProperties);
      }

      // Construct the final data set
      var index = 0;
      final jsonMap = <String, String>{};
      properties.forEach((dynamic key, dynamic value) {
        final propId = 'propertyId[$index]';
        final propValue = 'propertyValue[$index]';
        jsonMap[propId] = key;
        jsonMap[propValue] = value;
        index++;
      });

      data.addAll(jsonMap);
      formData = null;
    } else {
      // Form data interface for stream/content interfaces
      formData.append('cmisaction', cmisAction);
      formData.append('PropertyId[0]', 'cmis:name');
      formData.append('PropertyValue[0]', name);
      if (typeId != null) {
        formData.append('PropertyId[1]', 'cmis:objectTypeId');
        formData.append('PropertyValue[1]', typeId);
      }
      if (parentId != null) {
        formData.append('PropertyId[2]', 'objectId');
        formData.append('PropertyValue[2]', parentId);
      }
      final blobParts = <String?>[];
      blobParts.add(content);
      final dynamic theBlob = _environmentSupport.blob(blobParts, mimeType);
      formData.appendBlob('content', theBlob);
      data = null;
    }

    _httpRequest('POST', url, data: data, headers: headers, formData: formData);
  }

  /// Delete item.
  void delete(String objectId, {bool allVersions = false}) {
    if (repositoryId == null) {
      throw CmisException('delete() expects a non null repository Id');
    }

    final url = _getRootFolderUrl();

    final dynamic data = jsonobject.JsonObjectLite<dynamic>();
    data.cmisaction = 'delete';
    data.objectId = objectId;
    data.allVersions = allVersions.toString();

    // Headers, always the same for delete
    final headers = <String, String>{};
    headers['content-type'] = 'application/x-www-form-urlencoded';

    _httpRequest('POST', url, data: data, headers: headers);
  }

  /// Get document.
  ///  This returns the document contents as supplied by the repository.
  void getDocument(String documentId) {
    if (repositoryId == null) {
      throw CmisException('getDocument() expects a non null repository Id');
    }
    final dynamic data = jsonobject.JsonObjectLite<dynamic>();
    data.objectId = documentId;
    final rootUrl = _getRootFolderUrl();

    _httpRequest('GET', rootUrl, data: data);
  }

  /// Delete document
  void deleteDocument(String objectId, {bool allVersions = false}) {
    if (repositoryId == null) {
      throw CmisException('deleteDocument() expects a non null repository Id');
    }

    delete(objectId, allVersions: allVersions);
  }

  /// Create document.
  /// This allows content to be supplied as a string or
  /// a 'File' class and its associated file name to be used in which
  ///  case the file is read from the client.
  /// If content is not null it takes precedent over file upload.
  /// Will take a supplied type id, defaults to document.
  void createDocument(
    String name, {
    String? typeId,
    String? content,
    String? folderPath,
    String? fileName,
    dynamic file,
    Map<String, String>? customProperties,
  }) {
    if (repositoryId == null) {
      throw CmisException('createDocument() expects a non null repository Id');
    }

    // Declare the File Reader
    var serverside = false;
    final dynamic reader = _environmentSupport.fileReader();
    if (reader == null) {
      // Server side
      serverside = true;
    }
    // Initialise
    var intTypeId = typeId;
    if (typeId == null) {
      intTypeId = 'cmis:document';
    }
    String? mimeType;
    if (fileName != null) {
      mimeType = lookupMimeType(fileName);
    }

    // File read completer
    void fileRead() {
      final content = reader.result.toString();

      create(
        name,
        'createDocument',
        typeId: intTypeId,
        content: content,
        mimeType: mimeType,
        parentPath: folderPath,
        customProperties: customProperties,
      );
    }

    // File read for the server
    void fileReadServer() {
      final content = _environmentSupport.fileContents(fileName);

      create(
        name,
        'createDocument',
        typeId: intTypeId,
        content: content,
        mimeType: mimeType,
        parentPath: folderPath,
        customProperties: customProperties,
      );
    }

    void fileReadError() {
      throw CmisException('createDocument() error reading input file');
    }

    // See if we have a filename or content, get the file contents if needed
    if (content == null) {
      if (fileName == null) {
        throw CmisException('createDocument() expects content or a file name');
      }

      // Read the file
      if (!serverside) {
        reader.onLoadEnd.listen((dynamic e) => fileRead());
        reader.onError.listen((dynamic e) => fileReadError());

        //  We only do text here */
        reader.readAsText(file);
      } else {
        fileReadServer();
      }
    } else {
      // Create from content supplied as a string
      create(
        name,
        'createDocument',
        typeId: typeId,
        content: content,
        parentPath: folderPath,
        customProperties: customProperties,
      );
    }
  }

  /// Get folder children
  void getFolderChildren(String folderId) {
    if (repositoryId == null) {
      throw CmisException(
        'getFolderChildren() expects a non null repository Id',
      );
    }

    final dynamic data = jsonobject.JsonObjectLite<dynamic>();
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
    final rootUrl = _getRootFolderUrl();

    _httpRequest('GET', rootUrl, data: data);
  }

  /// Get folder descendants
  void getFolderDescendants(String folderId) {
    if (repositoryId == null) {
      throw CmisException(
        'getFolderDescendantss() expects a non null repository Id',
      );
    }

    final dynamic data = jsonobject.JsonObjectLite<dynamic>();
    data.objectId = folderId;
    data.cmisselector = 'descendants';
    data.includePropertyDefinitions = _opCtx.includePropertyDefinitions;
    data.depth = depth;
    data.propertyFilter = _opCtx.propertyFilter;
    data.renditionFilter = _opCtx.renditionFilter;
    data.includePathSegment = _opCtx.includePathSegment;
    data.includeAllowableActions = _opCtx.includeAllowableActions;
    data.includeRelationships = _opCtx.includeRelationships;
    data.succint = _opCtx.succint;
    final rootUrl = _getRootFolderUrl();

    _httpRequest('GET', rootUrl, data: data);
  }

  /// Get folder Tree.
  /// Note: not supported on all repositories.
  void getFolderTree(String folderId) {
    if (repositoryId == null) {
      throw CmisException('getFolderTree() expects a non null repository Id');
    }
    final dynamic data = jsonobject.JsonObjectLite<dynamic>();
    data.objectId = folderId;
    data.cmisselector = 'folderTree';
    data.includePropertyDefinitions = _opCtx.includePropertyDefinitions;
    data.depth = depth;
    data.propertyFilter = _opCtx.propertyFilter;
    data.renditionFilter = _opCtx.renditionFilter;
    data.includePathSegment = _opCtx.includePathSegment;
    data.includeAllowableActions = _opCtx.includeAllowableActions;
    data.includeRelationships = _opCtx.includeRelationships;
    data.succint = _opCtx.succint;
    final rootUrl = _getRootFolderUrl();

    _httpRequest('GET', rootUrl, data: data);
  }

  /// Get folder parent
  void getFolderParent(String folderId) {
    if (repositoryId == null) {
      throw CmisException('getFolderParent() expects a non null repository Id');
    }
    final dynamic data = jsonobject.JsonObjectLite<dynamic>();
    data.objectId = folderId;
    data.cmisselector = 'parent';
    data.propertyFilter = _opCtx.propertyFilter;
    data.succint = _opCtx.succint;
    final rootUrl = _getRootFolderUrl();

    _httpRequest('GET', rootUrl, data: data);
  }

  /// Get checked out documents in the supplied folder
  void getFolderCheckedOutDocs(String folderId) {
    if (repositoryId == null) {
      throw CmisException(
        'getFolderCheckedOutDocs() expects a non null repository Id',
      );
    }

    final dynamic data = jsonobject.JsonObjectLite<dynamic>();
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
    final rootUrl = _getRootFolderUrl();

    _httpRequest('GET', rootUrl, data: data);
  }

  /// Create folder.
  /// Will take a supplied type id, defaults to folder.
  void createFolder(
    String name, {
    String? typeId,
    String? parentId,
    String? parentPath,
    Map<String, String>? customProperties,
  }) {
    if (repositoryId == null) {
      throw CmisException('createFolder() expects a non null repository Id');
    }

    var intTypeId = typeId;
    if (typeId == null) {
      intTypeId = 'cmis:folder';
    }
    create(
      name,
      'createFolder',
      typeId: intTypeId,
      parentId: parentId,
      parentPath: parentPath,
      customProperties: customProperties,
    );
  }

  /// Delete folder
  void deleteFolder(String objectId, {bool allVersions = false}) {
    delete(objectId, allVersions: allVersions);
  }

  /// Get type definition
  void getTypeDefinition(String typeId) {
    // Add any found type to the cache */
    final dynamic savedCompleter = _httpAdapter.completion;

    void localCompleter() {
      if (_httpAdapter.jsonResponse.error == false) {
        _typeCache.addType(_httpAdapter.jsonResponse.jsonCmisResponse);
      }
      savedCompleter();
    }

    if (repositoryId == null) {
      throw CmisException(
        'getTypeDefinition() expects a non null repository Id',
      );
    }
    if (typeId.isEmpty) {
      throw CmisException('getTypeDefinition() expects a type id');
    }
    final dynamic data = jsonobject.JsonObjectLite<dynamic>();
    data.typeid = typeId;
    data.cmisselector = 'typeDefinition';

    // Try the cache initially
    final dynamic cachedTypeDef = _typeCache.getType(typeId);
    if (cachedTypeDef == null) {
      // Not found in cache get it from the server
      _httpAdapter.completion = localCompleter;
      _httpRequest('GET', null, data: data);
    } else {
      _httpAdapter.generateSuccessResponse(cachedTypeDef);
      if (_httpAdapter.completion != null) {
        _httpAdapter.completion();
      }
    }
  }

  /// Get type children
  void getTypeChildren([String? typeId]) {
    if (repositoryId == null) {
      throw CmisException('getTypeChildren() expects a non null repository Id');
    }
    final dynamic data = jsonobject.JsonObjectLite<dynamic>();
    data.cmisSelector = 'typeChildren';
    data.includePropertyDefinitions = _opCtx.includePropertyDefinitions;
    data.maxItems = _opCtx.maxItems;
    data.skipCount = _opCtx.skipCount;
    if (typeId != null) {
      data.typeId = typeId;
    }
    _httpRequest('GET', null, data: data);
  }

  /// Get type descendants
  void getTypeDescendants([String? typeId]) {
    if (repositoryId == null) {
      throw CmisException(
        'getTypeDescendants() expects a non null repository Id',
      );
    }
    final dynamic data = jsonobject.JsonObjectLite<dynamic>();
    data.cmisselector = 'typeDescendants';
    data.includePropertyDefinitions = _opCtx.includePropertyDefinitions;
    data.depth = depth;
    if (typeId != null) {
      data.typeId = typeId;
    }
    _httpRequest('GET', null, data: data);
  }

  /// CMIS query
  void query(String queryString) {
    if (repositoryId == null) {
      throw CmisException('query() expects a non null repository Id');
    }

    final dynamic data = jsonobject.JsonObjectLite<dynamic>();
    data.cmisselector = 'query';
    data.q = queryString;
    data.maxItems = _opCtx.maxItems;
    data.includeAllowableActions = _opCtx.includeAllowableActions;
    data.includeRelationships = _opCtx.includeRelationships;
    data.skipCount = _opCtx.skipCount;
    data.renditionFilter = _opCtx.renditionFilter;

    _httpRequest('GET', null, data: data);
  }

  /// Updates the login credentials in Cmis that will be used for all further
  /// requests to the CMIS server. Both user name and password must be set, even if one
  /// or the other is '' i.e empty. This must be called before the CMIS client
  /// can be used.
  void login(String user, String password) {
    _user = user;
    _password = password;
  }
}
