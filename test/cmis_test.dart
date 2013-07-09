/*
 * Packge : Cmis
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 05/07/2013
 * Copyright :  S.Hamblett@OSCF
 *
 * The Cmis class provides core functionality for interacting with CMIS servers from
 * the browser.
 * 
 * This isn the CMIS client interactive test suite
 * 
 */

import 'dart:async';
import 'dart:json' as json;
import 'dart:html';

import '../lib/cmis.dart';
import 'package:json_object/json_object.dart' as jsonobject;

/* Initialise */
Cmis cmisClient = null;
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
DivElement repositoryListSection = query('#cmis-repository-list');
void outputRepositoryInfo(jsonobject.JsonObject response){
  
  jsonobject.JsonObject repositoryInfo = response.jsonCmisResponse;
  
  repositoryListSection.children.clear();
  UListElement uList = new UListElement();
  LIElement repoName = new LIElement();
  repoName.innerHtml = "Repository Name : ${repositoryInfo.repositoryName}";
  uList.children.add(repoName);
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
  repositoryListSection.children.add(uList);
   
}
void outputRepositoryList(jsonobject.JsonObject response){
  
  
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
InputElement cmisUser =  query('#cmis-user');
InputElement cmisPassword = query('#cmis-password'); 
DivElement connectAlertSection = query('#cmis-alertsection-connect');
void doConnect(Event e){
  
  String url = cmisUrl.value;
  /* Must have a url */
  if ( url.isEmpty ) {
    
    addErrorAlert(connectAlertSection,
                  "You must specify a URL");
    return;
    
  }
  String userName = cmisUser.value;
  String password = cmisPassword.value;
  if ( !cmisRepositoryId.value.isEmpty ) {
    
    repoId = cmisRepositoryId.value;
    
  }
  
  cmisClient = new Cmis();
  try {
  
    cmisSession = cmisClient.getCmisSession(url,
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

/* Main here */
main() {
  
  /* Initialise the page */
  clearAlertSection(connectAlertSection);
  clearAlertSection(repositoryAlertSection);
  
  /* Get our working element set and add event handlers */
  
  /* Connect */
  ButtonElement connectBtn = query('#cmis-connect-btn');
  connectBtn.onClick.listen(doConnect);
 
  /* Repository Info */
  ButtonElement repositoryInfoBtn = query('#cmis-repository-info');
  repositoryInfoBtn.onClick.listen(doRepositoryInfo);
}

