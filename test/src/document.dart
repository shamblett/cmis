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

part of cmistest;

/* Information */
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
      
      if ( response.jsonCmisResponse.containsKey('rawText') ) {
      
        String rawText = response.jsonCmisResponse.rawText;
        PreElement theText = new PreElement();
        theText.innerHtml = rawText;
        docInfoListSection.children.add(theText);
        
      } else {
        
        addErrorAlert(docInfoAlertSection,
        "This is not a document type object");
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
      addErrorAlert(docInfoAlertSection,
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

/* Update */
InputElement cmisDocumentUpdate =  query('#cmis-document-update-name');
InputElement cmisDocumentFolderPath = query('#cmis-document-update-folderPath');
InputElement cmisDocumentContentFileName =  query('#cmis-document-update-fileName');
DivElement documentUpdateAlertSection = query('#cmis-alertsection-document-update');
DivElement documentUpdateListSection = query('#cmis-document-update-list');

void doDocumentUpdateClear(Event e) {
  
  documentUpdateListSection.children.clear();
  documentUpdateAlertSection.children.clear();
  
}

/* Create */
void outputDocumentCreate(jsonobject.JsonObject response) {
  
  String message = "Success! the document ${cmisDocumentUpdate.value} has been created";
  addSuccessAlert(documentUpdateAlertSection,
      message);
  UListElement uList = new UListElement();
  
  if ( response.jsonCmisResponse.isNotEmpty ) {
    
    jsonobject.JsonObject properties = response.jsonCmisResponse.properties;
    
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
    
 } else {
    
    LIElement noChildren = new LIElement();
    noChildren.innerHtml = "Oops no valid response from document create";
    uList.children.add(noChildren);
 }
  
  documentUpdateListSection.children.add(uList);
  
}

void doDocumentCreate(Event e) {
  
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
      addErrorAlert(documentUpdateAlertSection,
                    message);
      
    } else {
      
        outputDocumentCreate(cmisResponse);
      
    }
    
  }
  
  clearAlertSection(documentUpdateAlertSection);
  cmisSession.resultCompletion = completer;
  if ( cmisDocumentUpdate.value.isEmpty ) {
    
    addErrorAlert(documentUpdateAlertSection,
                  "You must supply a valid document name");
    
    
  } else {
    
      String folderPath = null;
      String content = null;
      if ( cmisDocumentFolderPath.value.isNotEmpty) folderPath = cmisDocumentFolderPath.value.trim();
      if ( cmisDocumentContentFileName.value.isNotEmpty ) content = cmisDocumentContentFileName.value;
      cmisSession.createDocument(cmisDocumentUpdate.value.trim(),
                               folderPath: folderPath,
                               content: content);
  }
  
}
/* Delete */
InputElement cmisDocumentDelete =  query('#cmis-document-update-deleteId');
void outputDocumentDelete(jsonobject.JsonObject response) {
  
  /* Valid response indicates success, there is no other data returned */ 
  String message = "Success! the document ${cmisDocumentDelete.value} has been deleted";
  addSuccessAlert(documentUpdateAlertSection,
      message);
  
}

void doDocumentDelete(Event e) {
  
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
      addErrorAlert(documentUpdateAlertSection,
                    message);
      
    } else {
      
        outputDocumentDelete(cmisResponse);
      
    }
    
  }
  
  clearAlertSection(documentUpdateAlertSection);
  cmisSession.resultCompletion = completer;
  if ( cmisDocumentDelete.value.isEmpty ) {
    
    addErrorAlert(documentUpdateAlertSection,
                  "You must supply a valid Object Id");
    
    
  } else {
    
      cmisSession.deleteDocument(cmisDocumentDelete.value.trim());
  }
  
}
