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
