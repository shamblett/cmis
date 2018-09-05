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

dynamic cmisRepositoryId = querySelector('#cmis-repository-id');
String repoId = null;
DivElement repositoryAlertSection =
    querySelector('#cmis-alertsection-repository');
DivElement repositoryDetailsSection = querySelector('#cmis-repository-details');
void outputRepositoryInfo(dynamic response) {
  final dynamic repositoryInfo = response.jsonCmisResponse;

  repositoryDetailsSection.children.clear();
  final UListElement uList = new UListElement();
  final LIElement repoDescription = new LIElement();
  repoDescription.innerHtml =
      "Repository Description : ${repositoryInfo.repositoryDescription}";
  uList.children.add(repoDescription);
  final LIElement vendorName = new LIElement();
  vendorName.innerHtml = "Vendor Name :  ${repositoryInfo.vendorName}";
  uList.children.add(vendorName);
  final LIElement productName = new LIElement();
  productName.innerHtml = "Product Name : ${repositoryInfo.productName}";
  uList.children.add(productName);
  final LIElement productVersion = new LIElement();
  productVersion.innerHtml =
      "Product Version : ${repositoryInfo.productVersion}";
  uList.children.add(productVersion);
  final LIElement rootFolderId = new LIElement();
  rootFolderId.innerHtml = "Root Folder Id : ${repositoryInfo.rootFolderId}";
  uList.children.add(rootFolderId);
  cmisSession.rootFolderId = repositoryInfo.rootFolderId;
  final LIElement rootFolderUrl = new LIElement();
  rootFolderUrl.innerHtml = "Root Folder URL : ${repositoryInfo.rootFolderUrl}";
  uList.children.add(rootFolderUrl);
  final LIElement repositoryUrl = new LIElement();
  repositoryUrl.innerHtml = "Repository URL : ${repositoryInfo.repositoryUrl}";
  uList.children.add(repositoryUrl);

  repositoryDetailsSection.children.add(uList);
}

DivElement repositoryListSection = querySelector('#cmis-repository-list');
void outputRepositoryList(dynamic response) {
  void onRepoSelect(Event e) {
    final dynamic radioElement = e.target;
    cmisRepositoryId.value = radioElement.value;
  }

  final dynamic repositoryInfo = response.jsonCmisResponse;

  repositoryListSection.children.clear();
  int id = 0;
  repositoryInfo.forEach((var key, Map value) {
    final DivElement div = new DivElement();
    div.classes.add("radio");

    final LabelElement repoLabel = new LabelElement();
    repoLabel.htmlFor = "cmis-repoId-$id";
    repoLabel.text = "${value['repositoryId']} -- ${value['repositoryName']}";

    final RadioButtonInputElement repoEntry = new RadioButtonInputElement();
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
      addErrorAlert(repositoryAlertSection, message);
    } else {
      if (cmisSession.repositoryId != null) {
        outputRepositoryInfo(cmisResponse);
      } else {
        outputRepositoryList(cmisResponse);
      }
    }
  }

  clearAlertSection(repositoryAlertSection);
  cmisSession.resultCompletion = completer;
  if (cmisRepositoryId.value.isEmpty) {
    cmisSession.getRepositories();
  } else {
    cmisSession.repositoryId = cmisRepositoryId.value;
    cmisSession.getRepositoryInfo();
  }
}

void outputCheckedOutDocs(dynamic response) {
  final UListElement uList = new UListElement();

  if (response.jsonCmisResponse.isNotEmpty) {
    /* Get the first 4 children */
    if (response.jsonCmisResponse.objects.isNotEmpty) {
      final dynamic properties =
          response.jsonCmisResponse.objects[0].properties;

      final LIElement displayName = new LIElement();
      displayName.innerHtml =
          "Display Name: ${properties['cmis:contentStreamFileName'].displayName}";
      uList.children.add(displayName);
      final LIElement id = new LIElement();
      id.innerHtml = "Id: ${properties['cmis:contentStreamFileName'].id}";
      uList.children.add(id);
      final LIElement docValue = new LIElement();
      docValue.innerHtml =
          "Value: ${properties['cmis:contentStreamFileName'].value}";
      uList.children.add(docValue);
    } else {
      final LIElement noChildren = new LIElement();
      noChildren.innerHtml = "There are no checked out documents";
      uList.children.add(noChildren);
    }
  } else {
    final LIElement noChildren = new LIElement();
    noChildren.innerHtml = "There are no checked out documents";
    uList.children.add(noChildren);
  }

  repositoryDetailsSection.children.add(uList);
}

void doCheckedOutDocs(Event e) {
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
      addErrorAlert(typeAlertSection, message);
    } else {
      outputCheckedOutDocs(cmisResponse);
    }
  }

  cmisSession.resultCompletion = completer;
  cmisSession.getCheckedOutDocs();
}
