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

TextAreaElement queryStatement =  query('#cmis-query-statement'); 
DivElement queryAlertSection = query('#cmis-alertsection-query');
DivElement queryListSection = query('#cmis-query-list-section');
void doQueryClear(Event e) {
  
  queryListSection.children.clear();
  queryAlertSection.children.clear();
  
}


void outputQueryList(jsonobject.JsonObject response) {
  
  UListElement uList = new UListElement();
  
  if ( response.jsonCmisResponse.isNotEmpty ) {
      
      List objects = response.jsonCmisResponse.objects;
      if ( (objects.isNotEmpty) && ( objects[0] != false) ) {
            
        objects.forEach((jsonobject.JsonObject object){
        
          jsonobject.JsonObject properties = object.object.properties;
            
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
          
          });
      
      } else {
        
        LIElement noChildren = new LIElement();
        noChildren.innerHtml = "The query has returned no items";
        uList.children.add(noChildren);
      }
        
  } else {
    
    LIElement noChildren = new LIElement();
    noChildren.innerHtml = "There query has returned no items";
    uList.children.add(noChildren);
  }
  
  queryListSection.children.add(uList);
  
}
void doQuery(Event e) {
  
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
      addErrorAlert(queryAlertSection,
                    message);
      
    } else {
      
      outputQueryList(cmisResponse);
      
    }
    
  }
  
  clearAlertSection(queryAlertSection);
  cmisSession.resultCompletion = completer;
  if ( queryStatement.value.isEmpty ) {
    
    addErrorAlert(queryAlertSection,
                  'You must supply a query!');
    
  } else {
    
    cmisSession.query(queryStatement.value.trim());
  }
  
}