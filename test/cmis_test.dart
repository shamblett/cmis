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
  cmisRepositoryId.value = "";
  cmisSession.repositoryId = null;
  
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

/* Connect */
InputElement cmisUrl =  query('#cmis-url'); 
InputElement cmisServiceUrl =  query('#cmis-service-url'); 
InputElement cmisUser =  query('#cmis-user');
InputElement cmisPassword = query('#cmis-password'); 
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
    addSuccessAlert(connectAlertSection,
                    "Cmis Session successfully created");
    
  } catch(e) {
    
    addErrorAlert(connectAlertSection,
                  e); 
  }
  
}

/* Type information */
InputElement cmisType =  query('#cmis-type-id'); 
DivElement typeAlertSection = query('#cmis-alertsection-type');
DivElement typeListSection = query('#cmis-type-list');
void outputTypeList(jsonobject.JsonObject response) {
  
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
void doTypeInfo(Event e) {
  
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
      
        outputTypeList(cmisResponse);
      
    }
    
  }
  
  clearAlertSection(typeAlertSection);
  cmisSession.resultCompletion = completer;
  cmisSession.depth = 1;
  if ( cmisType.value.isEmpty ) {
    
    cmisSession.getTypeDescendants(null);
    
  } else {
    
    cmisSession.getTypeDescendants(cmisType.value);
  }
  
}

/* Document Information */
InputElement cmisDocInfo =  query('#cmis-docinfo-id'); 
DivElement docInfoAlertSection = query('#cmis-alertsection-docinfo');
DivElement docInfoListSection = query('#cmis-docInfo-list');
void outputDocInfoList(jsonobject.JsonObject response){
  
  
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
    
    addErrorAlert(typeAlertSection,
                  "You must supply a document Id");;
    
    
  } else {
    
      cmisSession.getDocument(cmisDocInfo.value);
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
  }
  
  /* Get our working element set and add event handlers */
  
  /* Connect */
  ButtonElement connectBtn = query('#cmis-connect-btn');
  connectBtn.onClick.listen(doConnect);
 
  /* Repository Info */
  ButtonElement repositoryInfoBtn = query('#cmis-repository-info');
  repositoryInfoBtn.onClick.listen(doRepositoryInfo);
  
  ButtonElement repositoryInfoBtnClear = query('#cmis-repository-info-clear');
  repositoryInfoBtnClear.onClick.listen(doRepositoryInfoClear);
  
  /* Type information */
  ButtonElement typeInfoBtn = query('#cmis-type-info');
  typeInfoBtn.onClick.listen(doTypeInfo);
  
  ButtonElement typeInfoBtnClear = query('#cmis-type-info-clear');
  typeInfoBtnClear.onClick.listen(doTypeInfoClear);
  
  /* Document Information */
  ButtonElement docInfoBtn = query('#cmis-docinfo-get');
  docInfoBtn.onClick.listen(doDocInfo);
  
  ButtonElement docDeleteBtn = query('#cmis-docinfo-delete');
  docDeleteBtn.onClick.listen(doDocDelete);
}

