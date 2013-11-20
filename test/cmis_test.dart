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

library cmistest;

import 'dart:async';
import 'dart:html';
import 'dart:math';
import 'package:json_object/json_object.dart' as jsonobject;

import '../lib/cmis.dart';
import 'cmis_test_config.dart';

part 'src/common.dart';
part 'src/connect.dart';
part 'src/repository.dart';
part 'src/rootfolder.dart';
part 'src/typeinfo.dart';
part 'src/document.dart';
part 'src/folder.dart';
part 'src/query.dart';

main() {
  
  /* Initialise the page from the config file */
  if ( configInUse ) {
    
    cmisRepositoryId.value = configRepositoryId;
    cmisUrl.value = configUrl;
    cmisServiceUrl.value = serviceUrl;
    cmisUser.value = configUser;
    cmisPassword.value = configPassword;      
    cmisProxy.checked = configProxy;
  
  }
  
  /* Get our working element set and add event handlers */
  
  /* Connect */
  ButtonElement connectBtn = querySelector('#cmis-connect-btn');
  connectBtn.onClick.listen(doConnect);
 
  /* Repository Info */
  ButtonElement repositoryInfoBtn = querySelector('#cmis-repository-info');
  repositoryInfoBtn.onClick.listen(doRepositoryInfo);
  
  ButtonElement checkedOutDocsBtn = querySelector('#cmis-repository-checkedoutdocs');
  checkedOutDocsBtn.onClick.listen(doCheckedOutDocs);
  
  ButtonElement repositoryInfoBtnClear = querySelector('#cmis-repository-info-clear');
  repositoryInfoBtnClear.onClick.listen(doRepositoryInfoClear);
  
  /* Root Folder */
  ButtonElement rootInfoBtn = querySelector('#cmis-root-info');
  rootInfoBtn.onClick.listen(doRootInfo);
  
  querySelector('#cmis-root-info-folder').onClick.listen(onRootFilterSelect);
  querySelector('#cmis-root-info-document').onClick.listen(onRootFilterSelect);
  querySelector('#cmis-root-info-both').onClick.listen(onRootFilterSelect);
  
  ButtonElement rootInfoBtnClear = querySelector('#cmis-root-info-clear');
  rootInfoBtnClear.onClick.listen(doRootInfoClear);
   
  /* Type information */
  ButtonElement typeInfoDescendantsBtn = querySelector('#cmis-type-info-descendants');
  typeInfoDescendantsBtn.onClick.listen(doTypeInfoDescendants);
  
  ButtonElement typeInfoChildrenBtn = querySelector('#cmis-type-info-children');
  typeInfoChildrenBtn.onClick.listen(doTypeInfoChildren);
  
  ButtonElement typeInfoDefinitionBtn = querySelector('#cmis-type-info-definition');
  typeInfoDefinitionBtn.onClick.listen(doTypeInfoDefinition);
  
  ButtonElement typeInfoBtnClear = querySelector('#cmis-type-info-clear');
  typeInfoBtnClear.onClick.listen(doTypeInfoClear);
  
  /* Document Information */
  ButtonElement docInfoBtn = querySelector('#cmis-docinfo-get');
  docInfoBtn.onClick.listen(doDocInfo);
  
  ButtonElement docInfoBtnClear = querySelector('#cmis-docinfo-clear');
  docInfoBtnClear.onClick.listen(doDocInfoClear);
  
  /* Document Update */
  ButtonElement documentCreateBtn = querySelector('#cmis-document-update-create');
  documentCreateBtn.onClick.listen(doDocumentCreate);
  
  ButtonElement documentDeleteBtn = querySelector('#cmis-document-update-delete');
  documentDeleteBtn.onClick.listen(doDocumentDelete);
  
  ButtonElement documentUpdateBtnClear = querySelector('#cmis-document-update-clear');
  documentUpdateBtnClear.onClick.listen(doDocumentUpdateClear);
  
  /* Folder Information */
  ButtonElement folderInfoChildrenBtn = querySelector('#cmis-folder-get-children');
  folderInfoChildrenBtn.onClick.listen(doFolderInfoChildren);
  
  ButtonElement folderInfoDescendantsBtn = querySelector('#cmis-folder-get-descendants');
  folderInfoDescendantsBtn.onClick.listen(doFolderInfoDescendants);
  
  ButtonElement folderInfoParentBtn = querySelector('#cmis-folder-get-parent');
  folderInfoParentBtn.onClick.listen(doFolderInfoParent);
  
  ButtonElement folderInfoTreeBtn = querySelector('#cmis-folder-get-tree');
  folderInfoTreeBtn.onClick.listen(doFolderInfoTree);
  
  ButtonElement folderInfoCheckedOutBtn = querySelector('#cmis-folder-get-checkedout');
  folderInfoCheckedOutBtn.onClick.listen(doFolderInfoCheckedOut);
  
  ButtonElement folderInfoBtnClear = querySelector('#cmis-folder-clear');
  folderInfoBtnClear.onClick.listen(doFolderInfoClear);
  
  /* Folder Update  */
  ButtonElement folderCreateBtn = querySelector('#cmis-folder-update-create');
  folderCreateBtn.onClick.listen(doFolderCreate);
  
  ButtonElement folderDeleteBtn = querySelector('#cmis-folder-update-delete');
  folderDeleteBtn.onClick.listen(doFolderDelete);
  
  ButtonElement folderUpdateBtnClear = querySelector('#cmis-folder-update-clear');
  folderUpdateBtnClear.onClick.listen(doFolderUpdateClear);
  
  /* Query */
  ButtonElement queryBtn = querySelector('#cmis-query-query');
  queryBtn.onClick.listen(doQuery);
  
  ButtonElement queryBtnClear = querySelector('#cmis-query-clear');
  queryBtnClear.onClick.listen(doQueryClear);
  
}

