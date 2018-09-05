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

InputElement cmisRootInfoId = querySelector('#cmis-rootinfo-id');
DivElement rootInfoAlertSection = querySelector('#cmis-alertsection-rootinfo');
DivElement rootInfoListSection = querySelector('#cmis-rootinfo-list');
String rootFilterSelection = 'both';

void doRootInfoClear(Event e) {
  rootInfoAlertSection.children.clear();
  rootInfoListSection.children.clear();
}

void onRootFilterSelect(Event e) {
  dynamic target = e.target;
  rootFilterSelection = target.value;
}

void outputRootInfo(dynamic response) {
  UListElement uList = new UListElement();

  if (response.jsonCmisResponse.isNotEmpty) {
    if (response.jsonCmisResponse.objects.isNotEmpty) {
      List objects = response.jsonCmisResponse.objects;
      int numItems = response.jsonCmisResponse.numItems;

      if (numItems > 0) {
        objects.forEach((dynamic object) {
          dynamic properties = object.object.properties;

          /* Check for the type filter */
          bool outputInfo = false;

          if (rootFilterSelection == 'both') {
            outputInfo = true;
          } else if ((rootFilterSelection == 'document') &&
              (properties['cmis:objectTypeId'].value == 'cmis:document')) {
            outputInfo = true;
          } else if ((rootFilterSelection == 'folder') &&
              (properties['cmis:objectTypeId'].value == 'cmis:folder')) {
            outputInfo = true;
          }

          if (outputInfo) {
            LIElement name = new LIElement();
            name.innerHtml = "Name: ${properties['cmis:name'].value}";
            uList.children.add(name);
            LIElement objectId = new LIElement();
            objectId.innerHtml =
                "Object Id: ${properties['cmis:objectId'].value}";
            uList.children.add(objectId);
            LIElement objectTypeId = new LIElement();
            objectTypeId.innerHtml =
                "Object Type Id: ${properties['cmis:objectTypeId'].value}";
            uList.children.add(objectTypeId);
            if (properties['cmis:parentId'] != null) {
              LIElement parentId = new LIElement();
              parentId.innerHtml =
                  "Parent Id: ${properties['cmis:parentId'].value}";
              uList.children.add(parentId);
            }
            if (properties['cmis:path'] != null) {
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
    dynamic cmisResponse = cmisSession.completionResponse;

    if (cmisResponse.error) {
      dynamic errorResponse = cmisResponse.jsonCmisResponse;
      int errorCode = cmisResponse.errorCode;
      String error = null;
      String reason = null;
      if (errorCode == 0) {
        error = errorResponse.error;
        reason = errorResponse.reason;
      } else {
        error = errorResponse.message;
        reason = "CMIS Server Response";
      }

      String message = "Error - $error, Reason - $reason, Code - $errorCode";
      addErrorAlert(rootInfoAlertSection, message);
    } else {
      outputRootInfo(cmisResponse);
    }
  }

  cmisSession.resultCompletion = completer;
  cmisSession.getRootFolderContents();
}
