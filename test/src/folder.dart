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

InputElement cmisFolderInfo = querySelector('#cmis-folder-id');
DivElement folderInfoAlertSection = querySelector('#cmis-alertsection-folder');
DivElement folderInfoListSection = querySelector('#cmis-folder-list');
void doFolderInfoClear(Event e) {
  folderInfoListSection.children.clear();
  folderInfoAlertSection.children.clear();
}

void doFolderUpdateClear(Event e) {
  folderUpdateListSection.children.clear();
  folderUpdateAlertSection.children.clear();
}

void outputFolderInfoCommon(dynamic response) {
  final UListElement uList = new UListElement();

  if (response.jsonCmisResponse.isNotEmpty) {
    if (response.jsonCmisResponse.objects.isNotEmpty) {
      final List objects = response.jsonCmisResponse.objects;
      final int numItems = response.jsonCmisResponse.numItems;

      if (numItems > 0) {
        objects.forEach((dynamic object) {
          final dynamic properties = object.object.properties;

          final LIElement name = new LIElement();
          name.innerHtml = "Name: ${properties['cmis:name'].value}";
          uList.children.add(name);
          final LIElement objectId = new LIElement();
          objectId.innerHtml =
              "Object Id: ${properties['cmis:objectId'].value}";
          uList.children.add(objectId);
          final LIElement objectTypeId = new LIElement();
          objectTypeId.innerHtml =
              "Object Type Id: ${properties['cmis:objectTypeId'].value}";
          uList.children.add(objectTypeId);
          if (properties['cmis:parentId'] != null) {
            final LIElement parentId = new LIElement();
            parentId.innerHtml =
                "Parent Id: ${properties['cmis:parentId'].value}";
            uList.children.add(parentId);
          }
          if (properties['cmis:path'] != null) {
            final LIElement path = new LIElement();
            path.innerHtml = "Path: ${properties['cmis:path'].value}";
            uList.children.add(path);
          }
          final LIElement spacer = new LIElement();
          spacer.innerHtml = "  ....... ";
          uList.children.add(spacer);
        });
      } else {
        final LIElement noChildren = new LIElement();
        noChildren.innerHtml = "There are no objects in this folder";
        uList.children.add(noChildren);
      }
    } else {
      final LIElement noChildren = new LIElement();
      noChildren.innerHtml = "There are no objects in this folder";
      uList.children.add(noChildren);
    }
  } else {
    addErrorAlert(folderInfoAlertSection, "This is not a folder type object");
  }

  folderInfoListSection.children.add(uList);
}

/* Children */
void doFolderInfoChildren(Event e) {
  void completer() {
    final dynamic cmisResponse = cmisSession.completionResponse;

    if (cmisResponse.error) {
      final dynamic errorResponse = cmisResponse.jsonCmisResponse;
      final int errorCode = cmisResponse.errorCode;
      String error = null;
      String reason = null;
      if (errorCode == 0) {
        error = errorResponse.error;
        reason = errorResponse.reason;
      } else {
        error = errorResponse.message;
        reason = "CMIS Server Response";
      }

      final String message =
          "Error - $error, Reason - $reason, Code - $errorCode";
      addErrorAlert(folderInfoAlertSection, message);
    } else {
      outputFolderInfoCommon(cmisResponse);
    }
  }

  clearAlertSection(folderInfoAlertSection);
  cmisSession.resultCompletion = completer;
  if (cmisFolderInfo.value.isEmpty) {
    addErrorAlert(folderInfoAlertSection, "You must supply a valid folder Id");
  } else {
    cmisSession.getFolderChildren(cmisFolderInfo.value.trim());
  }
}

/* Descendants */
void outputFolderInfoDescendants(dynamic response) {
  final UListElement uList = new UListElement();

  if (response.jsonCmisResponse.isNotEmpty) {
    final List objects = response.jsonCmisResponse.toList();

    objects.forEach((dynamic object) {
      final dynamic properties = object.object.object.properties;

      final LIElement name = new LIElement();
      name.innerHtml = "Name: ${properties['cmis:name'].value}";
      uList.children.add(name);
      final LIElement objectId = new LIElement();
      objectId.innerHtml = "Object Id: ${properties['cmis:objectId'].value}";
      uList.children.add(objectId);
      final LIElement objectTypeId = new LIElement();
      objectTypeId.innerHtml =
          "Object Type Id: ${properties['cmis:objectTypeId'].value}";
      uList.children.add(objectTypeId);
      if (properties['cmis:parentId'] != null) {
        final LIElement parentId = new LIElement();
        parentId.innerHtml = "Parent Id: ${properties['cmis:parentId'].value}";
        uList.children.add(parentId);
      }
      if (properties['cmis:path'] != null) {
        final LIElement path = new LIElement();
        path.innerHtml = "Path: ${properties['cmis:path'].value}";
        uList.children.add(path);
      }
      final LIElement spacer = new LIElement();
      spacer.innerHtml = "  ....... ";
      uList.children.add(spacer);
    });
  } else {
    final LIElement noChildren = new LIElement();
    noChildren.innerHtml = "There are no objects in this folder";
    uList.children.add(noChildren);
  }

  folderInfoListSection.children.add(uList);
}

void doFolderInfoDescendants(Event e) {
  void completer() {
    final dynamic cmisResponse = cmisSession.completionResponse;

    if (cmisResponse.error) {
      final dynamic errorResponse = cmisResponse.jsonCmisResponse;
      final int errorCode = cmisResponse.errorCode;
      String error = null;
      String reason = null;
      if (errorCode == 0) {
        error = errorResponse.error;
        reason = errorResponse.reason;
      } else {
        error = errorResponse.message;
        reason = "CMIS Server Response";
      }

      final String message =
          "Error - $error, Reason - $reason, Code - $errorCode";
      addErrorAlert(folderInfoAlertSection, message);
    } else {
      outputFolderInfoDescendants(cmisResponse);
    }
  }

  clearAlertSection(folderInfoAlertSection);
  cmisSession.resultCompletion = completer;
  if (cmisFolderInfo.value.isEmpty) {
    addErrorAlert(folderInfoAlertSection, "You must supply a valid folder Id");
  } else {
    cmisSession.depth = 1;
    cmisSession.getFolderDescendants(cmisFolderInfo.value.trim());
  }
}

/* Parent */
void outputFolderInfoParent(dynamic response) {
  final UListElement uList = new UListElement();

  if (response.jsonCmisResponse.isNotEmpty) {
    final dynamic properties = response.jsonCmisResponse.properties;

    final LIElement name = new LIElement();
    name.innerHtml = "Name: ${properties['cmis:name'].value}";
    uList.children.add(name);
    final LIElement objectId = new LIElement();
    objectId.innerHtml = "Object Id: ${properties['cmis:objectId'].value}";
    uList.children.add(objectId);
    final LIElement objectTypeId = new LIElement();
    objectTypeId.innerHtml =
        "Object Type Id: ${properties['cmis:objectTypeId'].value}";
    uList.children.add(objectTypeId);
    if (properties['cmis:parentId'] != null) {
      final LIElement parentId = new LIElement();
      parentId.innerHtml = "Parent Id: ${properties['cmis:parentId'].value}";
      uList.children.add(parentId);
    }
    if (properties['cmis:path'] != null) {
      final LIElement path = new LIElement();
      path.innerHtml = "Path: ${properties['cmis:path'].value}";
      uList.children.add(path);
    }
    final LIElement spacer = new LIElement();
    spacer.innerHtml = "  ....... ";
    uList.children.add(spacer);
  } else {
    final LIElement noChildren = new LIElement();
    noChildren.innerHtml = "This folder has no parent";
    uList.children.add(noChildren);
  }

  folderInfoListSection.children.add(uList);
}

void doFolderInfoParent(Event e) {
  void completer() {
    final dynamic cmisResponse = cmisSession.completionResponse;

    if (cmisResponse.error) {
      final dynamic errorResponse = cmisResponse.jsonCmisResponse;
      final int errorCode = cmisResponse.errorCode;
      String error = null;
      String reason = null;
      if (errorCode == 0) {
        error = errorResponse.error;
        reason = errorResponse.reason;
      } else {
        error = errorResponse.message;
        reason = "CMIS Server Response";
      }

      final String message =
          "Error - $error, Reason - $reason, Code - $errorCode";
      addErrorAlert(folderInfoAlertSection, message);
    } else {
      outputFolderInfoParent(cmisResponse);
    }
  }

  clearAlertSection(folderInfoAlertSection);
  cmisSession.resultCompletion = completer;
  if (cmisFolderInfo.value.isEmpty) {
    addErrorAlert(folderInfoAlertSection, "You must supply a valid folder Id");
  } else {
    cmisSession.getFolderParent(cmisFolderInfo.value.trim());
  }
}

/* Folder Tree */
void doFolderInfoTree(Event e) {
  void completer() {
    final dynamic cmisResponse = cmisSession.completionResponse;

    if (cmisResponse.error) {
      final dynamic errorResponse = cmisResponse.jsonCmisResponse;
      final int errorCode = cmisResponse.errorCode;
      String error = null;
      String reason = null;
      if (errorCode == 0) {
        error = errorResponse.error;
        reason = errorResponse.reason;
      } else {
        error = errorResponse.message;
        reason = "CMIS Server Response";
      }

      final String message =
          "Error - $error, Reason - $reason, Code - $errorCode";
      addErrorAlert(folderInfoAlertSection, message);
    } else {
      //TODO can't test this on Alfresco
      outputFolderInfoCommon(cmisResponse);
    }
  }

  clearAlertSection(folderInfoAlertSection);
  cmisSession.resultCompletion = completer;
  if (cmisFolderInfo.value.isEmpty) {
    addErrorAlert(folderInfoAlertSection, "You must supply a valid folder Id");
  } else {
    cmisSession.getFolderTree(cmisFolderInfo.value.trim());
  }
}

/* Checked Out */
void outputFolderInfoCheckedOut(dynamic response) {
  final UListElement uList = new UListElement();

  if (response.jsonCmisResponse.isNotEmpty) {
    final List objects = response.jsonCmisResponse.toList();
    if ((objects.isNotEmpty) && (objects[0] != false)) {
      objects.forEach((dynamic object) {
        final dynamic properties = object.object.object.properties;

        final LIElement name = new LIElement();
        name.innerHtml = "Name: ${properties['cmis:name'].value}";
        uList.children.add(name);
        final LIElement objectId = new LIElement();
        objectId.innerHtml = "Object Id: ${properties['cmis:objectId'].value}";
        uList.children.add(objectId);
        final LIElement objectTypeId = new LIElement();
        objectTypeId.innerHtml =
            "Object Type Id: ${properties['cmis:objectTypeId'].value}";
        uList.children.add(objectTypeId);
        if (properties['cmis:parentId'] != null) {
          final LIElement parentId = new LIElement();
          parentId.innerHtml =
              "Parent Id: ${properties['cmis:parentId'].value}";
          uList.children.add(parentId);
        }
        if (properties['cmis:path'] != null) {
          final LIElement path = new LIElement();
          path.innerHtml = "Path: ${properties['cmis:path'].value}";
          uList.children.add(path);
        }
        final LIElement spacer = new LIElement();
        spacer.innerHtml = "  ....... ";
        uList.children.add(spacer);
      });
    } else {
      final LIElement noChildren = new LIElement();
      noChildren.innerHtml = "There are no checked out docs in this folder";
      uList.children.add(noChildren);
    }
  } else {
    final LIElement noChildren = new LIElement();
    noChildren.innerHtml = "There are no checked out docs in this folder";
    uList.children.add(noChildren);
  }

  folderInfoListSection.children.add(uList);
}

void doFolderInfoCheckedOut(Event e) {
  void completer() {
    final dynamic cmisResponse = cmisSession.completionResponse;

    if (cmisResponse.error) {
      final dynamic errorResponse = cmisResponse.jsonCmisResponse;
      final int errorCode = cmisResponse.errorCode;
      String error = null;
      String reason = null;
      if (errorCode == 0) {
        error = errorResponse.error;
        reason = errorResponse.reason;
      } else {
        error = errorResponse.message;
        reason = "CMIS Server Response";
      }

      final String message =
          "Error - $error, Reason - $reason, Code - $errorCode";
      addErrorAlert(folderInfoAlertSection, message);
    } else {
      outputFolderInfoCheckedOut(cmisResponse);
    }
  }

  clearAlertSection(folderInfoAlertSection);
  cmisSession.resultCompletion = completer;
  if (cmisFolderInfo.value.isEmpty) {
    addErrorAlert(folderInfoAlertSection, "You must supply a valid folder Id");
  } else {
    cmisSession.getFolderCheckedOutDocs(cmisFolderInfo.value.trim());
  }
}

/* Create */
InputElement cmisFolderUpdate = querySelector('#cmis-folder-update-name');
InputElement cmisFolderParent = querySelector('#cmis-folder-update-parent');
DivElement folderUpdateAlertSection =
    querySelector('#cmis-alertsection-folder-update');
DivElement folderUpdateListSection = querySelector('#cmis-folder-update-list');
void outputFolderCreate(dynamic response) {
  final String message =
      "Success! the folder ${cmisFolderUpdate.value} has been created";
  addSuccessAlert(folderUpdateAlertSection, message);
  final UListElement uList = new UListElement();

  if (response.jsonCmisResponse.isNotEmpty) {
    final dynamic properties = response.jsonCmisResponse.properties;

    final LIElement name = new LIElement();
    name.innerHtml = "Name: ${properties['cmis:name'].value}";
    uList.children.add(name);
    final LIElement objectId = new LIElement();
    objectId.innerHtml = "Object Id: ${properties['cmis:objectId'].value}";
    uList.children.add(objectId);
    final LIElement objectTypeId = new LIElement();
    objectTypeId.innerHtml =
        "Object Type Id: ${properties['cmis:objectTypeId'].value}";
    uList.children.add(objectTypeId);
    if (properties['cmis:parentId'] != null) {
      final LIElement parentId = new LIElement();
      parentId.innerHtml = "Parent Id: ${properties['cmis:parentId'].value}";
      uList.children.add(parentId);
    }
    if (properties['cmis:path'] != null) {
      final LIElement path = new LIElement();
      path.innerHtml = "Path: ${properties['cmis:path'].value}";
      uList.children.add(path);
    }
    final LIElement spacer = new LIElement();
    spacer.innerHtml = "  ....... ";
    uList.children.add(spacer);
  } else {
    final LIElement noChildren = new LIElement();
    noChildren.innerHtml = "Oops no valid response from folder create";
    uList.children.add(noChildren);
  }

  folderUpdateListSection.children.add(uList);
}

void doFolderCreate(Event e) {
  void completer() {
    final dynamic cmisResponse = cmisSession.completionResponse;

    if (cmisResponse.error) {
      final dynamic errorResponse = cmisResponse.jsonCmisResponse;
      final int errorCode = cmisResponse.errorCode;
      String error = null;
      String reason = null;
      if (errorCode == 0) {
        error = errorResponse.error;
        reason = errorResponse.reason;
      } else {
        error = errorResponse.message;
        reason = "CMIS Server Response";
      }

      final String message =
          "Error - $error, Reason - $reason, Code - $errorCode";
      addErrorAlert(folderUpdateAlertSection, message);
    } else {
      outputFolderCreate(cmisResponse);
    }
  }

  clearAlertSection(folderUpdateAlertSection);
  cmisSession.resultCompletion = completer;
  if (cmisFolderUpdate.value.isEmpty) {
    addErrorAlert(
        folderUpdateAlertSection, "You must supply a valid folder name");
  } else {
    String parentPath = null;
    if (cmisFolderParent.value.isNotEmpty)
      parentPath = cmisFolderParent.value.trim();
    cmisSession.createFolder(cmisFolderUpdate.value.trim(),
        parentPath: parentPath);
  }
}

/* Delete */
void outputFolderDelete(dynamic response) {
  /* Valid response indicates success, there is no other data returned */

  final String message =
      "Success! the folder ${cmisFolderUpdate.value} has been deleted";
  addSuccessAlert(folderUpdateAlertSection, message);
}

void doFolderDelete(Event e) {
  void completer() {
    final dynamic cmisResponse = cmisSession.completionResponse;

    if (cmisResponse.error) {
      final dynamic errorResponse = cmisResponse.jsonCmisResponse;
      final int errorCode = cmisResponse.errorCode;
      String error = null;
      String reason = null;
      if (errorCode == 0) {
        error = errorResponse.error;
        reason = errorResponse.reason;
      } else {
        error = errorResponse.message;
        reason = "CMIS Server Response";
      }

      final String message =
          "Error - $error, Reason - $reason, Code - $errorCode";
      addErrorAlert(folderUpdateAlertSection, message);
    } else {
      outputFolderDelete(cmisResponse);
    }
  }

  clearAlertSection(folderUpdateAlertSection);
  cmisSession.resultCompletion = completer;
  if (cmisFolderUpdate.value.isEmpty) {
    addErrorAlert(
        folderUpdateAlertSection, "You must supply a valid Object Id");
  } else {
    cmisSession.deleteFolder(cmisFolderUpdate.value.trim());
  }
}
