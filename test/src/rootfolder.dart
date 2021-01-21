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

InputElement? cmisRootInfoId = querySelector('#cmis-rootinfo-id') as InputElement?;
DivElement? rootInfoAlertSection = querySelector('#cmis-alertsection-rootinfo') as DivElement?;
DivElement? rootInfoListSection = querySelector('#cmis-rootinfo-list') as DivElement?;
String? rootFilterSelection = 'both';

void doRootInfoClear(Event e) {
  rootInfoAlertSection!.children.clear();
  rootInfoListSection!.children.clear();
}

void onRootFilterSelect(Event e) {
  final dynamic target = e.target;
  rootFilterSelection = target.value;
}

void outputRootInfo(dynamic response) {
  final uList = UListElement();

  if (response.jsonCmisResponse.isNotEmpty) {
    if (response.jsonCmisResponse.objects.isNotEmpty) {
      final List<dynamic>? objects = response.jsonCmisResponse.objects;
      final int numItems = response.jsonCmisResponse.numItems;

      if (numItems > 0) {
        for (final dynamic object in objects!) {
          final dynamic properties = object.object.properties;

          /* Check for the type filter */
          var outputInfo = false;

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
            final name = LIElement();
            name.innerHtml = 'Name: ${properties['cmis:name'].value}';
            uList.children.add(name);
            final objectId = LIElement();
            objectId.innerHtml =
                'Object Id: ${properties['cmis:objectId'].value}';
            uList.children.add(objectId);
            final objectTypeId = LIElement();
            objectTypeId.innerHtml =
                'Object Type Id: ${properties['cmis:objectTypeId'].value}';
            uList.children.add(objectTypeId);
            if (properties['cmis:parentId'] != null) {
              final parentId = LIElement();
              parentId.innerHtml =
                  'Parent Id: ${properties['cmis:parentId'].value}';
              uList.children.add(parentId);
            }
            if (properties['cmis:path'] != null) {
              final path = LIElement();
              path.innerHtml = 'Path: ${properties['cmis:path'].value}';
              uList.children.add(path);
            }
            final spacer = LIElement();
            spacer.innerHtml = '  ....... ';
            uList.children.add(spacer);
          }
        }
      } else {
        final noChildren = LIElement();
        noChildren.innerHtml = 'There are no objects in the root folder';
        uList.children.add(noChildren);
      }
    } else {
      final noChildren = LIElement();
      noChildren.innerHtml = 'There are no objects in the root folder';
      uList.children.add(noChildren);
    }
  } else {
    final noChildren = LIElement();
    noChildren.innerHtml = 'There are no objects in the root folder';
    uList.children.add(noChildren);
  }

  rootInfoListSection!.children.add(uList);
}

void doRootInfo(Event e) {
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
      addErrorAlert(rootInfoAlertSection!, message);
    } else {
      outputRootInfo(cmisResponse);
    }
  }

  cmisSession!.resultCompletion = completer;
  cmisSession!.getRootFolderContents();
}
