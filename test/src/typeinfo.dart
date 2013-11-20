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

InputElement cmisType =  querySelector('#cmis-type-id'); 
DivElement typeAlertSection = querySelector('#cmis-alertsection-type');
DivElement typeListSection = querySelector('#cmis-type-list');
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
    noDefinition.innerHtml = "There is no definition for this type";
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

