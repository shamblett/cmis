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

part of cmisbrowsertest;

// ignore_for_file: omit_local_variable_types
// ignore_for_file: unnecessary_final
// ignore_for_file: lines_longer_than_80_chars
// ignore_for_file: avoid_annotating_with_dynamic
// ignore_for_file: cascade_invocations
// ignore_for_file: avoid_print

// Information
InputElement cmisDocInfo = querySelector('#cmis-docinfo-id');
DivElement docInfoAlertSection = querySelector('#cmis-alertsection-docinfo');
DivElement docInfoListSection = querySelector('#cmis-docinfo-list');
void doDocInfoClear(Event e) {
  docInfoListSection.children.clear();
  docInfoAlertSection.children.clear();
}

void outputDocInfoList(dynamic response) {
  if (response.jsonCmisResponse.isNotEmpty) {
    if (response.jsonCmisResponse.containsKey('rawText')) {
      final String rawText = response.jsonCmisResponse.rawText;
      final PreElement theText = PreElement();
      theText.innerHtml = rawText;
      docInfoListSection.children.add(theText);
      addErrorAlert(docInfoAlertSection, 'This is not a document type object');
    }
  } else {
    addErrorAlert(docInfoAlertSection, 'This is not a document type object');
  }
}

void doDocInfo(Event e) {
  void completer() {
    final dynamic cmisResponse = cmisSession.completionResponse;

    if (cmisResponse.error) {
      final dynamic errorResponse = cmisResponse.jsonCmisResponse;
      final int errorCode = cmisResponse.errorCode;
      String error;
      String reason;
      if (errorCode == 0) {
        error = errorResponse.error;
        reason = errorResponse.reason;
      } else {
        error = errorResponse.message;
        reason = 'CMIS Server Response';
      }

      final String message =
          'Error - $error, Reason - $reason, Code - $errorCode';
      addErrorAlert(docInfoAlertSection, message);
    } else {
      outputDocInfoList(cmisResponse);
    }
  }

  clearAlertSection(docInfoAlertSection);
  cmisSession.resultCompletion = completer;
  if (cmisDocInfo.value.isEmpty) {
    addErrorAlert(docInfoAlertSection, 'You must supply a valid document Id');
  } else {
    cmisSession.getDocument(cmisDocInfo.value.trim());
  }
}

/* Update */
InputElement cmisDocumentUpdate = querySelector('#cmis-document-update-name');
InputElement cmisDocumentFolderPath =
    querySelector('#cmis-document-update-folderPath');
FileUploadInputElement cmisDocumentContentFileName =
    querySelector('#cmis-document-update-fileName');
TextAreaElement cmisDocumentText = querySelector('#cmis-document-update-text');
DivElement documentUpdateAlertSection =
    querySelector('#cmis-alertsection-document-update');
DivElement documentUpdateListSection =
    querySelector('#cmis-document-update-list');

void doDocumentUpdateClear(Event e) {
  documentUpdateListSection.children.clear();
  documentUpdateAlertSection.children.clear();
}

/* Create */
void outputDocumentCreate(dynamic response) {
  final String message =
      'Success! the document ${cmisDocumentUpdate.value} has been created';
  addSuccessAlert(documentUpdateAlertSection, message);
  final UListElement uList = UListElement();

  if (response.jsonCmisResponse.isNotEmpty) {
    final dynamic properties = response.jsonCmisResponse.properties;

    final LIElement name = LIElement();
    name.innerHtml = 'Name: ${properties['cmis:name'].value}';
    uList.children.add(name);
    final LIElement objectId = LIElement();
    objectId.innerHtml = 'Object Id: ${properties['cmis:objectId'].value}';
    uList.children.add(objectId);
    final LIElement objectTypeId = LIElement();
    objectTypeId.innerHtml =
        'Object Type Id: ${properties['cmis:objectTypeId'].value}';
    uList.children.add(objectTypeId);
    if (properties['cmis:parentId'] != null) {
      final LIElement parentId = LIElement();
      parentId.innerHtml = 'Parent Id: ${properties['cmis:parentId'].value}';
      uList.children.add(parentId);
    }
    if (properties['cmis:path'] != null) {
      final LIElement path = LIElement();
      path.innerHtml = 'Path: ${properties['cmis:path'].value}';
      uList.children.add(path);
    }
    final LIElement spacer = LIElement();
    spacer.innerHtml = '  ....... ';
    uList.children.add(spacer);
  } else {
    final LIElement noChildren = LIElement();
    noChildren.innerHtml = 'Oops no valid response from document create';
    uList.children.add(noChildren);
  }

  documentUpdateListSection.children.add(uList);
}

void doDocumentCreate(Event e) {
  void completer() {
    final dynamic cmisResponse = cmisSession.completionResponse;

    if (cmisResponse.error) {
      final dynamic errorResponse = cmisResponse.jsonCmisResponse;
      final int errorCode = cmisResponse.errorCode;
      String error;
      String reason;
      if (errorCode == 0) {
        error = errorResponse.error;
        reason = errorResponse.reason;
      } else {
        error = errorResponse.message;
        reason = 'CMIS Server Response';
      }

      final String message =
          'Error - $error, Reason - $reason, Code - $errorCode';
      addErrorAlert(documentUpdateAlertSection, message);
    } else {
      outputDocumentCreate(cmisResponse);
    }
  }

  clearAlertSection(documentUpdateAlertSection);
  cmisSession.resultCompletion = completer;
  if (cmisDocumentUpdate.value.isEmpty) {
    addErrorAlert(
        documentUpdateAlertSection, 'You must supply a valid document name');
  } else {
    String folderPath;
    String fileName;
    String content;
    File inputFile;

    if (cmisDocumentFolderPath.value.isNotEmpty) {
      folderPath = cmisDocumentFolderPath.value.trim();
    }
    if (cmisDocumentText.value.isNotEmpty) {
      content = cmisDocumentText.value;
    } else {
      if (cmisDocumentContentFileName.value.isNotEmpty) {
        fileName = cmisDocumentContentFileName.value;
        inputFile = cmisDocumentContentFileName.files[0];
      } else {
        addErrorAlert(documentUpdateAlertSection,
            'You must supply either content or a file name');
      }
    }

    cmisSession.createDocument(cmisDocumentUpdate.value.trim(),
        folderPath: folderPath,
        content: content,
        fileName: fileName,
        file: inputFile);
  }
}

/* Delete */
InputElement cmisDocumentDelete =
    querySelector('#cmis-document-update-deleteId');
void outputDocumentDelete(dynamic response) {
  /* Valid response indicates success, there is no other data returned */
  final String message =
      'Success! the document ${cmisDocumentDelete.value} has been deleted';
  addSuccessAlert(documentUpdateAlertSection, message);
}

void doDocumentDelete(Event e) {
  void completer() {
    final dynamic cmisResponse = cmisSession.completionResponse;

    if (cmisResponse.error) {
      final dynamic errorResponse = cmisResponse.jsonCmisResponse;
      final int errorCode = cmisResponse.errorCode;
      String error;
      String reason;
      if (errorCode == 0) {
        error = errorResponse.error;
        reason = errorResponse.reason;
      } else {
        error = errorResponse.message;
        reason = 'CMIS Server Response';
      }

      final String message =
          'Error - $error, Reason - $reason, Code - $errorCode';
      addErrorAlert(documentUpdateAlertSection, message);
    } else {
      outputDocumentDelete(cmisResponse);
    }
  }

  clearAlertSection(documentUpdateAlertSection);
  cmisSession.resultCompletion = completer;
  if (cmisDocumentDelete.value.isEmpty) {
    addErrorAlert(
        documentUpdateAlertSection, 'You must supply a valid Object Id');
  } else {
    cmisSession.deleteDocument(cmisDocumentDelete.value.trim());
  }
}
