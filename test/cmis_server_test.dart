/*
 * Package : Cmis
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 25/07/2019
 * Copyright :  S.Hamblett
 *
 * The Cmis class provides core functionality for interacting with CMIS servers from
 * the server.
 * 
 * This is the CMIS client test suite
 * 
 */

@TestOn('vm')

library cmisservertest;

import 'dart:async';

import 'package:cmis/cmis_server_client.dart';
import 'package:cmis/cmis.dart';
import 'package:test/test.dart';
import 'cmis_test_config.dart';

int main() {
  // Initialise
  final CmisServerClient cmisClient = CmisServerClient();
  CmisSession cmisSession;
  String cmisRepositoryId;
  String cmisUrl;
  String cmisServiceUrl;
  String cmisUser;
  String cmisPassword;
  bool cmisProxy;

  test('1', () async {
    // Initialise the page from the config file
    if (configInUse) {
      cmisRepositoryId = configRepositoryId;
      cmisUrl = configUrlServer;
      cmisServiceUrl = serviceUrl;
      cmisUser = configUser;
      cmisPassword = configPassword;
      cmisProxy = configProxy;
    }

    // Connect
    try {
      cmisSession = cmisClient.getCmisSession(
          cmisUrl, serviceUrl, cmisUser, cmisPassword, cmisRepositoryId);
    } on Exception catch (e) {
      print(e);
    }

    void completer() {
      final dynamic cmisResponse = cmisSession.completionResponse;
        print(cmisResponse);
    }

    cmisSession.resultCompletion = expectAsync0(completer, count:1);

    // Repository info
    if (cmisRepositoryId.isEmpty) {
      cmisSession.getRepositories();
    } else {
      cmisSession.repositoryId = cmisRepositoryId;
      cmisSession.getRepositoryInfo();
    }

    await Future<void>.delayed(Duration(seconds: 2));

    // Root folder contents
    cmisSession.getRootFolderContents();

    // Repository Info
//    final ButtonElement repositoryInfoBtn =
//        querySelector('#cmis-repository-info');
//    repositoryInfoBtn.onClick.listen(doRepositoryInfo);
//
//    final ButtonElement checkedOutDocsBtn =
//        querySelector('#cmis-repository-checkedoutdocs');
//    checkedOutDocsBtn.onClick.listen(doCheckedOutDocs);
//
//    final ButtonElement repositoryInfoBtnClear =
//        querySelector('#cmis-repository-info-clear');
//    repositoryInfoBtnClear.onClick.listen(doRepositoryInfoClear);
//
//    // Root Folder
//    final ButtonElement rootInfoBtn = querySelector('#cmis-root-info');
//    rootInfoBtn.onClick.listen(doRootInfo);
//
//    querySelector('#cmis-root-info-folder').onClick.listen(onRootFilterSelect);
//    querySelector('#cmis-root-info-document')
//        .onClick
//        .listen(onRootFilterSelect);
//    querySelector('#cmis-root-info-both').onClick.listen(onRootFilterSelect);
//
//    final ButtonElement rootInfoBtnClear =
//        querySelector('#cmis-root-info-clear');
//    rootInfoBtnClear.onClick.listen(doRootInfoClear);
//
//    // Type information
//    final ButtonElement typeInfoDescendantsBtn =
//        querySelector('#cmis-type-info-descendants');
//    typeInfoDescendantsBtn.onClick.listen(doTypeInfoDescendants);
//
//    final ButtonElement typeInfoChildrenBtn =
//        querySelector('#cmis-type-info-children');
//    typeInfoChildrenBtn.onClick.listen(doTypeInfoChildren);
//
//    final ButtonElement typeInfoDefinitionBtn =
//        querySelector('#cmis-type-info-definition');
//    typeInfoDefinitionBtn.onClick.listen(doTypeInfoDefinition);
//
//    final ButtonElement typeInfoBtnClear =
//        querySelector('#cmis-type-info-clear');
//    typeInfoBtnClear.onClick.listen(doTypeInfoClear);
//
//    // Document Information
//    final ButtonElement docInfoBtn = querySelector('#cmis-docinfo-get');
//    docInfoBtn.onClick.listen(doDocInfo);
//
//    final ButtonElement docInfoBtnClear = querySelector('#cmis-docinfo-clear');
//    docInfoBtnClear.onClick.listen(doDocInfoClear);
//
//    // Document Update
//    final ButtonElement documentCreateBtn =
//        querySelector('#cmis-document-update-create');
//    documentCreateBtn.onClick.listen(doDocumentCreate);
//
//    final ButtonElement documentDeleteBtn =
//        querySelector('#cmis-document-update-delete');
//    documentDeleteBtn.onClick.listen(doDocumentDelete);
//
//    final ButtonElement documentUpdateBtnClear =
//        querySelector('#cmis-document-update-clear');
//    documentUpdateBtnClear.onClick.listen(doDocumentUpdateClear);
//
//    // Folder Information
//    final ButtonElement folderInfoChildrenBtn =
//        querySelector('#cmis-folder-get-children');
//    folderInfoChildrenBtn.onClick.listen(doFolderInfoChildren);
//
//    final ButtonElement folderInfoDescendantsBtn =
//        querySelector('#cmis-folder-get-descendants');
//    folderInfoDescendantsBtn.onClick.listen(doFolderInfoDescendants);
//
//    final ButtonElement folderInfoParentBtn =
//        querySelector('#cmis-folder-get-parent');
//    folderInfoParentBtn.onClick.listen(doFolderInfoParent);
//
//    final ButtonElement folderInfoTreeBtn =
//        querySelector('#cmis-folder-get-tree');
//    folderInfoTreeBtn.onClick.listen(doFolderInfoTree);
//
//    final ButtonElement folderInfoCheckedOutBtn =
//        querySelector('#cmis-folder-get-checkedout');
//    folderInfoCheckedOutBtn.onClick.listen(doFolderInfoCheckedOut);
//
//    final ButtonElement folderInfoBtnClear =
//        querySelector('#cmis-folder-clear');
//    folderInfoBtnClear.onClick.listen(doFolderInfoClear);
//
//    // Folder Update
//    final ButtonElement folderCreateBtn =
//        querySelector('#cmis-folder-update-create');
//    folderCreateBtn.onClick.listen(doFolderCreate);
//
//    final ButtonElement folderDeleteBtn =
//        querySelector('#cmis-folder-update-delete');
//    folderDeleteBtn.onClick.listen(doFolderDelete);
//
//    final ButtonElement folderUpdateBtnClear =
//        querySelector('#cmis-folder-update-clear');
//    folderUpdateBtnClear.onClick.listen(doFolderUpdateClear);
//
//    // Query
//    final ButtonElement queryBtn = querySelector('#cmis-query-query');
//    queryBtn.onClick.listen(doQuery);
//
//    final ButtonElement queryBtnClear = querySelector('#cmis-query-clear');
//    queryBtnClear.onClick.listen(doQueryClear);
  });

  return 0;
}
