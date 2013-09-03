/*
 * Packge : Cmis
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 05/07/2013
 * Copyright :  S.Hamblett@OSCF
 *
 * The Cmis class provides core functionality for interacting with CMIS servers from
 * the browser.
 * 
 * This is the CMIS client interactive test suite
 * 
 */

import 'dart:async';
import 'dart:html';
import 'dart:math';

import '../lib/cmis.dart';
import 'package:json_object/json_object.dart' as jsonobject;
import 'cmis_test_config.dart';

/* Initialise */
Cmis cmisClient = new Cmis();
CmisSession cmisSession = null;


/* Alert Handling */
void clearAlertSection(DivElement section) {
  
  section.children.clear();
  
}

void addErrorAlert(DivElement section,
                     String alertText) {
  
  DivElement alert = new DivElement();
  alert.classes.add("alert alert-error");
  alert.text = alertText;
  clearAlertSection(section);
  section.children.add(alert);
  
}

void addInfoAlert(DivElement section,
                  String alertText) {
  
  DivElement alert = new DivElement();
  alert.classes.add("alert alert-info");
  alert.text = alertText;
  clearAlertSection(section);
  section.children.add(alert);
  
}

void addSuccessAlert(DivElement section,
                     String alertText) {
  
  DivElement alert = new DivElement();
  alert.classes.add("alert alert-success");
  alert.text = alertText;
  clearAlertSection(section);
  section.children.add(alert);
  
}

/* Elements and event handlers */

/* Connect */
InputElement cmisUrl =  query('#cmis-url'); 
InputElement cmisServiceUrl =  query('#cmis-service-url'); 
InputElement cmisUser =  query('#cmis-user');
InputElement cmisPassword = query('#cmis-password'); 
InputElement cmisProxy = query('#cmis-proxy'); 
DivElement connectAlertSection = query('#cmis-alertsection-connect');
void doConnect(Event e){
  
  repoId = null;
  
  /* Must have a url */
  String url = cmisUrl.value;
  if ( url.isEmpty ) {
    
    addErrorAlert(connectAlertSection,
                  "You must specify a URL");
    return;
    
  }
  String serviceUrl = cmisServiceUrl.value;
  if ( serviceUrl.isEmpty) serviceUrl = null;
  String userName = cmisUser.value;
  if ( userName.isEmpty) userName = null;
  String password = cmisPassword.value;
  if ( password.isEmpty) password = null;
  if ( !cmisRepositoryId.value.isEmpty ) {
    
    repoId = cmisRepositoryId.value;
    
  }
  
  
  try {
  
    cmisSession = cmisClient.getCmisSession(url,
                                            serviceUrl,
                                            userName,
                                            password,
                                            repoId);
    
    if ( cmisProxy.value == 'yes' ) cmisSession.proxy = true;
    
    addSuccessAlert(connectAlertSection,
                    "Cmis Session successfully created");
    
  } catch(e) {
    
    addErrorAlert(connectAlertSection,
                  e); 
  }
  
}


/* Repository */
InputElement cmisRepositoryId =  query('#cmis-repository-id'); 
String repoId = null;
DivElement repositoryAlertSection = query('#cmis-alertsection-repository');
DivElement repositoryDetailsSection = query('#cmis-repository-details');
void outputRepositoryInfo(jsonobject.JsonObject response){
  
  jsonobject.JsonObject repositoryInfo = response.jsonCmisResponse;
  
  repositoryDetailsSection.children.clear();
  UListElement uList = new UListElement();
  LIElement repoDescription = new LIElement();
  repoDescription.innerHtml = "Repository Description : ${repositoryInfo.repositoryDescription}";
  uList.children.add(repoDescription);
  LIElement vendorName = new LIElement();
  vendorName.innerHtml = "Vendor Name :  ${repositoryInfo.vendorName}";
  uList.children.add(vendorName);
  LIElement productName = new LIElement();
  productName.innerHtml  = "Product Name : ${repositoryInfo.productName}";
  uList.children.add(productName);
  LIElement productVersion = new LIElement();
  productVersion.innerHtml = "Product Version : ${repositoryInfo.productVersion}";
  uList.children.add(productVersion);
  LIElement rootFolderId = new LIElement();
  rootFolderId.innerHtml = "Root Folder Id : ${repositoryInfo.rootFolderId}";
  uList.children.add(rootFolderId);
  cmisSession.rootFolderId = repositoryInfo.rootFolderId;
  LIElement rootFolderUrl = new LIElement();
  rootFolderUrl.innerHtml = "Root Folder URL : ${repositoryInfo.rootFolderUrl}";
  uList.children.add(rootFolderUrl);
  LIElement repositoryUrl = new LIElement();
  repositoryUrl.innerHtml = "Repository URL : ${repositoryInfo.repositoryUrl}";
  uList.children.add(repositoryUrl);

  repositoryDetailsSection.children.add(uList);
   
}


DivElement repositoryListSection = query('#cmis-repository-list');
void outputRepositoryList(jsonobject.JsonObject response){
  
  void onRepoSelect(Event e ){
    
    var radioElement = e.target;
    cmisRepositoryId.value = radioElement.value;
    
  }
  jsonobject.JsonObject repositoryInfo = response.jsonCmisResponse;
  
  repositoryListSection.children.clear();
  int id = 0;
  repositoryInfo.forEach((var key, Map value){
    
    DivElement div = new DivElement();
    div.classes.add("radio");
    
    LabelElement repoLabel = new LabelElement();
    repoLabel.htmlFor = "cmis-repoId-$id";
    repoLabel.text = "${value['repositoryId']} -- ${value['repositoryName']}";
   
    RadioButtonInputElement repoEntry = new RadioButtonInputElement();
    repoEntry.value = "${value['repositoryId']}";
    repoEntry.name = "repoId";
    repoEntry.id = "cmis-repoId-$id";
    repoEntry.title = "${value['repositoryId']} ${value['repositoryName']}";
    repoEntry.onClick.listen(onRepoSelect);
    repoLabel.children.add(repoEntry);
    
    div.children.add(repoLabel);
    repositoryListSection.children.add(div);
    id++;
    
  });
  
}
void doRepositoryInfoClear(Event e) {
  
  repositoryAlertSection.children.clear();
  repositoryDetailsSection.children.clear();
  
}
void doRepositoryInfo(Event e) {
  
  void completer() {
    
    jsonobject.JsonObject cmisResponse = cmisSession.completionResponse;
    
    if ( cmisResponse.error ) {
    
      jsonobject.JsonObject errorResponse = cmisResponse.jsonCmisResponse;
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
      addErrorAlert(repositoryAlertSection,
                    message);
      
    } else {
      
      if ( cmisSession.repositoryId != null ) {
        
        outputRepositoryInfo(cmisResponse);
        
      } else {
      
        outputRepositoryList(cmisResponse);
      }
      
    }
    
  }
  
  clearAlertSection(repositoryAlertSection);
  cmisSession.resultCompletion = completer;
  if ( cmisRepositoryId.value.isEmpty ) {
    
    cmisSession.getRepositories();
    
  } else {
    
    cmisSession.repositoryId = cmisRepositoryId.value;
    cmisSession.getRepositoryInfo();
  }
  
}

void outputCheckedOutDocs(jsonobject.JsonObject response) {
  
  UListElement uList = new UListElement();
  
  if ( response.jsonCmisResponse.isNotEmpty ) {
  
    /* Get the first 4 children */
    if ( response.jsonCmisResponse.objects.isNotEmpty) {
            
      jsonobject.JsonObject properties = response.jsonCmisResponse.objects[0].properties;
          
      LIElement displayName = new LIElement();
      displayName.innerHtml = "Display Name: ${properties['cmis:contentStreamFileName'].displayName}";
      uList.children.add(displayName);
      LIElement id = new LIElement();
      id.innerHtml = "Id: ${properties['cmis:contentStreamFileName'].id}";
      uList.children.add(id);
      LIElement docValue = new LIElement();
      docValue.innerHtml = "Value: ${properties['cmis:contentStreamFileName'].value}";
      uList.children.add(docValue);
       
    } else {
             
        LIElement noChildren = new LIElement();
        noChildren.innerHtml = "There are no checked out documents";
        uList.children.add(noChildren);
             
   }
         
      
  } else {
    
    LIElement noChildren = new LIElement();
    noChildren.innerHtml = "There are no checked out documents";
    uList.children.add(noChildren);
  }
  
  repositoryDetailsSection.children.add(uList);
  
}

void doCheckedOutDocs(Event e) {
  
  void completer() {
    
    jsonobject.JsonObject cmisResponse = cmisSession.completionResponse;
    
    if ( cmisResponse.error ) {
    
      jsonobject.JsonObject errorResponse = cmisResponse.jsonCmisResponse;
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
      addErrorAlert(typeAlertSection,
                    message);
      
    } else {
      
        outputCheckedOutDocs(cmisResponse);
      
    }
    
  }
  
  cmisSession.resultCompletion = completer;
  cmisSession.getCheckedOutDocs();
    
 }

/* Root folder */
InputElement cmisRootInfoId =  query('#cmis-rootinfo-id'); 
DivElement rootInfoAlertSection = query('#cmis-alertsection-rootinfo');
DivElement rootInfoListSection = query('#cmis-rootinfo-list');
String rootFilterSelection = 'both';

void doRootInfoClear(Event e) {
  
  rootInfoAlertSection.children.clear();
  rootInfoListSection.children.clear();
  
}

void onRootFilterSelect(Event e ){
  
  var target = e.target;
  rootFilterSelection = target.value;
  
}
void outputRootInfo(jsonobject.JsonObject response) {
  
  UListElement uList = new UListElement();
  
  if ( response.jsonCmisResponse.isNotEmpty ) {
  
    if ( response.jsonCmisResponse.objects.isNotEmpty) {
            
      List objects = response.jsonCmisResponse.objects;
      int numItems = response.jsonCmisResponse.numItems;
      
      if ( numItems > 0 ) {
        
        objects.forEach((jsonobject.JsonObject object){
        
          jsonobject.JsonObject properties = object.object.properties;
          
          bool outputInfo = false;
          
          if ( rootFilterSelection == 'both') {
            
              outputInfo = true;
              
          } else if ( (rootFilterSelection == 'document') &&
              ( properties['cmis:objectTypeId'].value == 'cmis:document') ){
            
              outputInfo = true;
            
          } else if ( (rootFilterSelection == 'folder') &&
              ( properties['cmis:objectTypeId'].value == 'cmis:folder') ){
            
              outputInfo = true;
          }
          
          if ( outputInfo ) {
            
            LIElement name = new LIElement();
            name.innerHtml = "Name: ${properties['cmis:name'].value}";
            uList.children.add(name);
            LIElement objectId = new LIElement();
            objectId.innerHtml = "Object Id: ${properties['cmis:objectId'].value}";
            uList.children.add(objectId);
            LIElement objectTypeId = new LIElement();
            objectTypeId.innerHtml = "Object Type Id: ${properties['cmis:objectTypeId'].value}";
            uList.children.add(objectTypeId);
            if ( properties['cmis:parentId'] != null ) {
              LIElement parentId = new LIElement();
              parentId.innerHtml = "Parent Id: ${properties['cmis:parentId'].value}";
              uList.children.add(parentId);
            }
            if ( properties['cmis:path'] != null ) {
              LIElement path = new LIElement();
              path.innerHtml = "Path: ${properties['cmis:path'].value}";
              uList.children.add(path);
            }
            LIElement spacer = new LIElement();
            spacer.innerHtml = "  ....... ";
            uList.children.add(spacer);
          }
          
        });
        
      } else {
        
        LIElement noChildren = new LIElement();
        noChildren.innerHtml = "There are no objects in the root folder";
        uList.children.add(noChildren);
        
      }
       
       
    } else {
             
        LIElement noChildren = new LIElement();
        noChildren.innerHtml = "There are no objects in the root folder";
        uList.children.add(noChildren);
             
   }
         
      
  } else {
    
    LIElement noChildren = new LIElement();
    noChildren.innerHtml = "There are no objects in the root folder";
    uList.children.add(noChildren);
  }
  
  rootInfoListSection.children.add(uList);
  
}

void doRootInfo(Event e) {
  
  void completer() {
    
    jsonobject.JsonObject cmisResponse = cmisSession.completionResponse;
    
    if ( cmisResponse.error ) {
    
      jsonobject.JsonObject errorResponse = cmisResponse.jsonCmisResponse;
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
      addErrorAlert(rootInfoAlertSection,
                    message);
      
    } else {
      
        outputRootInfo(cmisResponse);
      
    }
    
  }
  
  cmisSession.resultCompletion = completer;
  cmisSession.getRootFolderContents();
    
 }


/* Type information */
InputElement cmisType =  query('#cmis-type-id'); 
DivElement typeAlertSection = query('#cmis-alertsection-type');
DivElement typeListSection = query('#cmis-type-list');
void outputTypeListDescendants(jsonobject.JsonObject response) {
  
  UListElement uList = new UListElement();
  
  if ( response.jsonCmisResponse.isNotEmpty ) {
  
    /* Get a random type if no type id specified */
    int childIndex = 0;
    int typeIndex = 0;
    if ( cmisType.value.isEmpty ) {
      
      int length = response.jsonCmisResponse.length;
      Random randomizer = new Random();
      childIndex = randomizer.nextInt(length);
      
    }   
    /* Check for a 'children' property, if none announce this and go.
     * We can't cater for all possibilties in this relatively simple test
     * harness */
    try {
      var test = response.jsonCmisResponse[childIndex].children;
    } catch(e) {
      LIElement noDescendants = new LIElement();
      noDescendants.innerHtml = "No 'children' property, try again";
      uList.children.add(noDescendants);
      typeListSection.children.add(uList);
      return;
    }
    if ( response.jsonCmisResponse[childIndex].children.isNotEmpty) {
        
        if ( response.jsonCmisResponse[childIndex].children.length > 0 ) {
            
          if ( cmisType.value.isEmpty ) {
            
            int length = response.jsonCmisResponse[childIndex].children.length;
            Random randomizer = new Random();
            typeIndex = randomizer.nextInt(length);
            
          }  
          jsonobject.JsonObject children = response.jsonCmisResponse[childIndex].children[typeIndex];
          
          jsonobject.JsonObject typeInfo = children.type;
          LIElement localName = new LIElement();
          localName.innerHtml = "Local Name: ${typeInfo.localName}";
          uList.children.add(localName);
          LIElement description = new LIElement();
          description.innerHtml = "Description: ${typeInfo.description}";
          uList.children.add(description);
          LIElement id = new LIElement();
          id.innerHtml = "Type Id: ${typeInfo.id}";
          uList.children.add(id);
          LIElement parentId = new LIElement();
          parentId.innerHtml = "Parent Id: ${typeInfo.parentId}";
          uList.children.add(parentId);
          LIElement spacer = new LIElement();
          spacer.innerHtml = "  ....... ";
          uList.children.add(spacer);
    
        } else {
    
          LIElement noDescendants = new LIElement();
          noDescendants.innerHtml = "The children record id empty in this repository";
          uList.children.add(noDescendants);
        }
        
       
      } else {
        
        LIElement noDescendants = new LIElement();
        noDescendants.innerHtml = "There are no type children records in this repository";
        uList.children.add(noDescendants);
      }
      
  } else {
    
    LIElement noDescendants = new LIElement();
    if ( cmisType.value.isEmpty ) {
      noDescendants.innerHtml = "There are no more type descendants in this repository";
    } else {
      noDescendants.innerHtml = "There are no more type descendants for this type";
    }
    uList.children.add(noDescendants);
  }
  
  typeListSection.children.add(uList);
  
}
void doTypeInfoClear(Event e) {
  
  typeListSection.children.clear();
  typeAlertSection.children.clear();
  
}
void doTypeInfoDescendants(Event e) {
  
  void completer() {
    
    jsonobject.JsonObject cmisResponse = cmisSession.completionResponse;
    
    if ( cmisResponse.error ) {
    
      jsonobject.JsonObject errorResponse = cmisResponse.jsonCmisResponse;
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
      addErrorAlert(typeAlertSection,
                    message);
      
    } else {
      
        outputTypeListDescendants(cmisResponse);
      
    }
    
  }
  
  clearAlertSection(typeAlertSection);
  cmisSession.resultCompletion = completer;
  cmisSession.depth = 1;
  if ( cmisType.value.isEmpty ) {
    
    cmisSession.getTypeDescendants(null);
    
  } else {
    
    cmisSession.getTypeDescendants(cmisType.value.trim());
  }
  
}

void outputTypeListChildren(jsonobject.JsonObject response) {
  
  UListElement uList = new UListElement();
  
  if ( response.jsonCmisResponse.isNotEmpty ) {
  
    /* Get the first 4 children */
    if ( response.jsonCmisResponse.types.isNotEmpty) {
        
        int length = response.jsonCmisResponse.types.length;
        if (  length > 0 ) {
            
          List types = response.jsonCmisResponse.types;
          
          BRElement br = new BRElement();
          int children = length;
          if (children > 4 ) children = 4;
          for(int i=0; i<=children-1; i++) {
            
            LIElement localName = new LIElement();
            localName.innerHtml = "Local Name: ${types[i].localName}";
            uList.children.add(localName);
            LIElement description = new LIElement();
            description.innerHtml = "Description: ${types[i].description}";
            uList.children.add(description);
            LIElement id = new LIElement();
            id.innerHtml = "Type Id: ${types[i].id}";
            uList.children.add(id);
            LIElement spacer = new LIElement();
            spacer.innerHtml = "  ....... ";
            uList.children.add(spacer);
          
          };
    
        } else {
    
          LIElement noChildren = new LIElement();
          noChildren.innerHtml = "The children types are empty in this repository";
          uList.children.add(noChildren);
        }
        
       
      } else {
        
        LIElement noChildren = new LIElement();
        noChildren.innerHtml = "There are no children types";
        uList.children.add(noChildren);
      }
      
  } else {
    
    LIElement noChildren = new LIElement();
    if ( cmisType.value.isEmpty ) {
      noChildren.innerHtml = "There are no more children types in this repository";
    } else {
      noChildren.innerHtml = "There are no more children types for this type";
    }
    uList.children.add(noChildren);
  }
  
  typeListSection.children.add(uList);
  
}

void doTypeInfoChildren(Event e) {
  
  void completer() {
    
    jsonobject.JsonObject cmisResponse = cmisSession.completionResponse;
    
    if ( cmisResponse.error ) {
    
      jsonobject.JsonObject errorResponse = cmisResponse.jsonCmisResponse;
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
      addErrorAlert(typeAlertSection,
                    message);
      
    } else {
      
        outputTypeListChildren(cmisResponse);
      
    }
    
  }
  
  clearAlertSection(typeAlertSection);
  cmisSession.resultCompletion = completer;
  cmisSession.depth = 1;
  if ( cmisType.value.isEmpty ) {
    
    cmisSession.getTypeChildren(null);
    
  } else {
    
    cmisSession.getTypeChildren(cmisType.value.trim());
  }
  
}

void outputTypeListDefinition(jsonobject.JsonObject response) {
  
  UListElement uList = new UListElement();
  
  if ( response.jsonCmisResponse.isNotEmpty ) {
  
    LIElement localName = new LIElement();
    localName.innerHtml = "Local Name: ${response.jsonCmisResponse.localName}";
    uList.children.add(localName);
    LIElement queryName = new LIElement();
    queryName.innerHtml = "Description: ${response.jsonCmisResponse.queryName}";
    uList.children.add(queryName);
      
  } else {
    
    LIElement noDefinition = new LIElement();
    noChildren.innerHtml = "There is no definition for this type";
    uList.children.add(noDefinition);
  }
  
  typeListSection.children.add(uList);
  
}

void doTypeInfoDefinition(Event e) {
  
  void completer() {
    
    jsonobject.JsonObject cmisResponse = cmisSession.completionResponse;
    
    if ( cmisResponse.error ) {
    
      jsonobject.JsonObject errorResponse = cmisResponse.jsonCmisResponse;
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
      addErrorAlert(typeAlertSection,
                    message);
      
    } else {
      
        outputTypeListDefinition(cmisResponse);
      
    }
    
  }
  
  clearAlertSection(typeAlertSection);
  if (cmisType.value.isEmpty ) {
    
    String message = "You must supply a Type Id for this function";
    addErrorAlert(typeAlertSection,
        message);
    return;
    
  }
  cmisSession.resultCompletion = completer;
  cmisSession.depth = 1;
  cmisSession.getTypeDefinition(cmisType.value.trim());
  
}


/* Document Information */
InputElement cmisDocInfo =  query('#cmis-docinfo-id'); 
DivElement docInfoAlertSection = query('#cmis-alertsection-docinfo');
DivElement docInfoListSection = query('#cmis-docinfo-list');
void doDocInfoClear(Event e) {
  
  docInfoListSection.children.clear();
  docInfoAlertSection.children.clear();
  
}

void outputDocInfoList(jsonobject.JsonObject response) {
  
  UListElement uList = new UListElement();
  
  if ( response.jsonCmisResponse.isNotEmpty ) {
  
    try {
      
      int numItems = response.jsonCmisResponse.numItems;
          
    } catch(e) {
      
      String rawText = response.jsonCmisResponse.rawText;
      PreElement theText = new PreElement();
      theText.innerHtml = rawText;
      docInfoListSection.children.add(theText);
      
    }
      
  } else {
    
    addErrorAlert(docInfoAlertSection,
    "This is not a document type object");
  }
  
  
}

void doDocInfo(Event e) {
  
  void completer() {
    
    jsonobject.JsonObject cmisResponse = cmisSession.completionResponse;
    
    if ( cmisResponse.error ) {
    
      jsonobject.JsonObject errorResponse = cmisResponse.jsonCmisResponse;
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
      addErrorAlert(typeAlertSection,
                    message);
      
    } else {
      
        outputDocInfoList(cmisResponse);
      
    }
    
  }
  
  clearAlertSection(docInfoAlertSection);
  cmisSession.resultCompletion = completer;
  if ( cmisDocInfo.value.isEmpty ) {
    
    addErrorAlert(docInfoAlertSection,
                  "You must supply a valid document Id");
    
    
  } else {
    
      cmisSession.getDocument(cmisDocInfo.value.trim());
  }
  
}
void doDocDelete(Event e) {
  
  void completer() {
    
    jsonobject.JsonObject cmisResponse = cmisSession.completionResponse;
    
    if ( cmisResponse.error ) {
    
      jsonobject.JsonObject errorResponse = cmisResponse.jsonCmisResponse;
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
      addErrorAlert(typeAlertSection,
                    message);
      
    } else {
      
      addSuccessAlert(docInfoAlertSection,
                    "Document Deleted");
      
    }
    
  }
  
  clearAlertSection(docInfoAlertSection);
  cmisSession.resultCompletion = completer;
  if ( cmisDocInfo.value.isEmpty ) {
    
    addErrorAlert(docInfoAlertSection,
                  "You must supply a document Id");;
    
    
  } else {
    
      cmisSession.deleteDocument(cmisDocInfo.value);
  }
  
}


/* Main here */
main() {
  
  /* Initialise the page */
  clearAlertSection(connectAlertSection);
  clearAlertSection(repositoryAlertSection);
  
  /* Initialise the HTML from the config file */
  if ( configInUse ) {
    
    cmisRepositoryId.value = configRepositoryId;
    cmisUrl.value = configUrl;
    cmisServiceUrl.value = serviceUrl;
    cmisUser.value = configUser;
    cmisPassword.value = configPassword;      
    cmisProxy.checked = configProxy;
  
  }
  
  /* Get our working element set and add event handlers */
  
  /* Connect */
  ButtonElement connectBtn = query('#cmis-connect-btn');
  connectBtn.onClick.listen(doConnect);
 
  /* Repository Info */
  ButtonElement repositoryInfoBtn = query('#cmis-repository-info');
  repositoryInfoBtn.onClick.listen(doRepositoryInfo);
  
  ButtonElement checkedOutDocsBtn = query('#cmis-repository-checkedoutdocs');
  checkedOutDocsBtn.onClick.listen(doCheckedOutDocs);
  
  ButtonElement repositoryInfoBtnClear = query('#cmis-repository-info-clear');
  repositoryInfoBtnClear.onClick.listen(doRepositoryInfoClear);
  
  /* Root Folder */
  ButtonElement rootInfoBtn = query('#cmis-root-info');
  rootInfoBtn.onClick.listen(doRootInfo);
  
  query('#cmis-root-info-folder').onClick.listen(onRootFilterSelect);
  query('#cmis-root-info-document').onClick.listen(onRootFilterSelect);
  query('#cmis-root-info-both').onClick.listen(onRootFilterSelect);
  
  ButtonElement rootInfoBtnClear = query('#cmis-root-info-clear');
  rootInfoBtnClear.onClick.listen(doRootInfoClear);
   
  /* Type information */
  ButtonElement typeInfoDescendantsBtn = query('#cmis-type-info-descendants');
  typeInfoDescendantsBtn.onClick.listen(doTypeInfoDescendants);
  
  ButtonElement typeInfoChildrenBtn = query('#cmis-type-info-children');
  typeInfoChildrenBtn.onClick.listen(doTypeInfoChildren);
  
  ButtonElement typeInfoDefinitionBtn = query('#cmis-type-info-definition');
  typeInfoDefinitionBtn.onClick.listen(doTypeInfoDefinition);
  
  ButtonElement typeInfoBtnClear = query('#cmis-type-info-clear');
  typeInfoBtnClear.onClick.listen(doTypeInfoClear);
  
  /* Document Information */
  ButtonElement docInfoBtn = query('#cmis-docinfo-get');
  docInfoBtn.onClick.listen(doDocInfo);
  
  ButtonElement docDeleteBtn = query('#cmis-doccreate-delete');
  docDeleteBtn.onClick.listen(doDocDelete);
  
  ButtonElement docInfoBtnClear = query('#cmis-docinfo-clear');
  docInfoBtnClear.onClick.listen(doDocInfoClear);
}

