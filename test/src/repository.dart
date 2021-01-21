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

dynamic cmisRepositoryId = querySelector('#cmis-repository-id');
String? repoId;
DivElement? repositoryAlertSection =
    querySelector('#cmis-alertsection-repository') as DivElement?;
DivElement? repositoryDetailsSection = querySelector('#cmis-repository-details') as DivElement?;
void outputRepositoryInfo(dynamic response) {
  final dynamic repositoryInfo = response.jsonCmisResponse;

  repositoryDetailsSection!.children.clear();
  final uList = UListElement();
  final repoDescription = LIElement();
  repoDescription.innerHtml =
      'Repository Description : ${repositoryInfo.repositoryDescription}';
  uList.children.add(repoDescription);
  final vendorName = LIElement();
  vendorName.innerHtml = 'Vendor Name :  ${repositoryInfo.vendorName}';
  uList.children.add(vendorName);
  final productName = LIElement();
  productName.innerHtml = 'Product Name : ${repositoryInfo.productName}';
  uList.children.add(productName);
  final productVersion = LIElement();
  productVersion.innerHtml =
      'Product Version : ${repositoryInfo.productVersion}';
  uList.children.add(productVersion);
  final rootFolderId = LIElement();
  rootFolderId.innerHtml = 'Root Folder Id : ${repositoryInfo.rootFolderId}';
  uList.children.add(rootFolderId);
  cmisSession!.rootFolderId = repositoryInfo.rootFolderId;
  final rootFolderUrl = LIElement();
  rootFolderUrl.innerHtml = 'Root Folder URL : ${repositoryInfo.rootFolderUrl}';
  uList.children.add(rootFolderUrl);
  final repositoryUrl = LIElement();
  repositoryUrl.innerHtml = 'Repository URL : ${repositoryInfo.repositoryUrl}';
  uList.children.add(repositoryUrl);

  repositoryDetailsSection!.children.add(uList);
}

DivElement? repositoryListSection = querySelector('#cmis-repository-list') as DivElement?;
void outputRepositoryList(dynamic response) {
  void onRepoSelect(Event e) {
    final dynamic radioElement = e.target;
    cmisRepositoryId.value = radioElement.value;
  }

  final dynamic repositoryInfo = response.jsonCmisResponse;

  repositoryListSection!.children.clear();
  var id = 0;
  repositoryInfo.forEach((dynamic key, Map<dynamic, dynamic> value) {
    final div = DivElement();
    div.classes.add('radio');

    final repoLabel = LabelElement();
    repoLabel.htmlFor = 'cmis-repoId-$id';
    repoLabel.text = '${value['repositoryId']} -- ${value['repositoryName']}';

    final repoEntry = RadioButtonInputElement();
    repoEntry.value = '${value['repositoryId']}';
    repoEntry.name = 'repoId';
    repoEntry.id = 'cmis-repoId-$id';
    repoEntry.title = '${value['repositoryId']} ${value['repositoryName']}';
    repoEntry.onClick.listen(onRepoSelect);
    repoLabel.children.add(repoEntry);

    div.children.add(repoLabel);
    repositoryListSection!.children.add(div);
    id++;
  });
}

void doRepositoryInfoClear(Event e) {
  repositoryAlertSection!.children.clear();
  repositoryDetailsSection!.children.clear();
}

void doRepositoryInfo(Event e) {
  void completer() {
    final dynamic cmisResponse = cmisSession!.completionResponse;

    if (cmisResponse.error) {
      final dynamic errorResponse = cmisResponse.jsonCmisResponse;
      final int? errorCode = cmisResponse.errorCode;
      String? error;
      String? reason;
      if (errorCode == 0) {
        error = errorResponse.error;
        reason = errorResponse.reason;
      } else {
        error = errorResponse.message;
        reason = 'CMIS Server Response';
      }

      final message = 'Error - $error, Reason - $reason, Code - $errorCode';
      addErrorAlert(repositoryAlertSection!, message);
    } else {
      if (cmisSession!.repositoryId != null) {
        outputRepositoryInfo(cmisResponse);
      } else {
        outputRepositoryList(cmisResponse);
      }
    }
  }

  clearAlertSection(repositoryAlertSection!);
  cmisSession!.resultCompletion = completer;
  if (cmisRepositoryId.value.isEmpty) {
    cmisSession!.getRepositories();
  } else {
    cmisSession!.repositoryId = cmisRepositoryId.value;
    cmisSession!.getRepositoryInfo();
  }
}

void outputCheckedOutDocs(dynamic response) {
  final uList = UListElement();

  if (response.jsonCmisResponse.isNotEmpty) {
    /* Get the first 4 children */
    if (response.jsonCmisResponse.objects.isNotEmpty) {
      final dynamic properties =
          response.jsonCmisResponse.objects[0].properties;

      final displayName = LIElement();
      displayName.innerHtml =
          'Display Name: ${properties['cmis:contentStreamFileName'].displayName}';
      uList.children.add(displayName);
      final id = LIElement();
      id.innerHtml = 'Id: ${properties['cmis:contentStreamFileName'].id}';
      uList.children.add(id);
      final docValue = LIElement();
      docValue.innerHtml =
          'Value: ${properties['cmis:contentStreamFileName'].value}';
      uList.children.add(docValue);
    } else {
      final noChildren = LIElement();
      noChildren.innerHtml = 'There are no checked out documents';
      uList.children.add(noChildren);
    }
  } else {
    final noChildren = LIElement();
    noChildren.innerHtml = 'There are no checked out documents';
    uList.children.add(noChildren);
  }

  repositoryDetailsSection!.children.add(uList);
}

void doCheckedOutDocs(Event e) {
  void completer() {
    final dynamic cmisResponse = cmisSession!.completionResponse;

    if (cmisResponse.error) {
      final dynamic errorResponse = cmisResponse.jsonCmisResponse;
      final int? errorCode = cmisResponse.errorCode;
      String? error;
      String? reason;
      if (errorCode == 0) {
        error = errorResponse.error;
        reason = errorResponse.reason;
      } else {
        error = errorResponse.message;
        reason = 'CMIS Server Response';
      }

      final message = 'Error - $error, Reason - $reason, Code - $errorCode';
      addErrorAlert(typeAlertSection!, message);
    } else {
      outputCheckedOutDocs(cmisResponse);
    }
  }

  cmisSession!.resultCompletion = completer;
  cmisSession!.getCheckedOutDocs();
}
