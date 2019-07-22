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

InputElement cmisType = querySelector('#cmis-type-id');
DivElement typeAlertSection = querySelector('#cmis-alertsection-type');
DivElement typeListSection = querySelector('#cmis-type-list');
void outputTypeListDescendants(dynamic response) {
  final UListElement uList = UListElement();

  if (response.jsonCmisResponse.isNotEmpty) {
    /* Get a random type if no type id specified */
    int childIndex = 0;
    int typeIndex = 0;
    if (cmisType.value.isEmpty) {
      final int length = response.jsonCmisResponse.length;
      final Random randomizer = Random();
      childIndex = randomizer.nextInt(length);
    }
    // Check for a 'children' property, if none announce this and go.
    // We can't cater for all possibilities in this relatively simple test
    // harness
    try {
      final dynamic test = response.jsonCmisResponse[childIndex].children;
      print(test);
    } on Exception {
      final LIElement noDescendants = LIElement();
      noDescendants.innerHtml = 'No "children" property, try again';
      uList.children.add(noDescendants);
      typeListSection.children.add(uList);
      return;
    }
    if (response.jsonCmisResponse[childIndex].children.isNotEmpty) {
      if (response.jsonCmisResponse[childIndex].children.length > 0) {
        if (cmisType.value.isEmpty) {
          final int length =
              response.jsonCmisResponse[childIndex].children.length;
          final Random randomizer = Random();
          typeIndex = randomizer.nextInt(length);
        }
        final dynamic children =
            response.jsonCmisResponse[childIndex].children[typeIndex];

        final dynamic typeInfo = children.type;
        final LIElement localName = LIElement();
        localName.innerHtml = 'Local Name: ${typeInfo.localName}';
        uList.children.add(localName);
        final LIElement description = LIElement();
        description.innerHtml = 'Description: ${typeInfo.description}';
        uList.children.add(description);
        final LIElement id = LIElement();
        id.innerHtml = 'Type Id: ${typeInfo.id}';
        uList.children.add(id);
        final LIElement parentId = LIElement();
        parentId.innerHtml = 'Parent Id: ${typeInfo.parentId}';
        uList.children.add(parentId);
        final LIElement spacer = LIElement();
        spacer.innerHtml = '  ....... ';
        uList.children.add(spacer);
      } else {
        final LIElement noDescendants = LIElement();
        noDescendants.innerHtml =
            'The children record id empty in this repository';
        uList.children.add(noDescendants);
      }
    } else {
      final LIElement noDescendants = LIElement();
      noDescendants.innerHtml =
          'There are no type children records in this repository';
      uList.children.add(noDescendants);
    }
  } else {
    final LIElement noDescendants = LIElement();
    if (cmisType.value.isEmpty) {
      noDescendants.innerHtml =
          'There are no more type descendants in this repository';
    } else {
      noDescendants.innerHtml =
          'There are no more type descendants for this type';
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
      addErrorAlert(typeAlertSection, message);
    } else {
      outputTypeListDescendants(cmisResponse);
    }
  }

  clearAlertSection(typeAlertSection);
  cmisSession.resultCompletion = completer;
  cmisSession.depth = 1;
  if (cmisType.value.isEmpty) {
    cmisSession.getTypeDescendants(null);
  } else {
    cmisSession.getTypeDescendants(cmisType.value.trim());
  }
}

void outputTypeListChildren(dynamic response) {
  final UListElement uList = UListElement();

  if (response.jsonCmisResponse.isNotEmpty) {
    /* Get the first 4 children */
    if (response.jsonCmisResponse.types.isNotEmpty) {
      final int length = response.jsonCmisResponse.types.length;
      if (length > 0) {
        final List<dynamic> types = response.jsonCmisResponse.types;
        int children = length;
        if (children > 4) {
          children = 4;
        }
        for (int i = 0; i <= children - 1; i++) {
          final LIElement localName = LIElement();
          localName.innerHtml = 'Local Name: ${types[i].localName}';
          uList.children.add(localName);
          final LIElement description = LIElement();
          description.innerHtml = 'Description: ${types[i].description}';
          uList.children.add(description);
          final LIElement id = LIElement();
          id.innerHtml = 'Type Id: ${types[i].id}';
          uList.children.add(id);
          final LIElement spacer = LIElement();
          spacer.innerHtml = '  ....... ';
          uList.children.add(spacer);
        }
      } else {
        final LIElement noChildren = LIElement();
        noChildren.innerHtml =
            'The children types are empty in this repository';
        uList.children.add(noChildren);
      }
    } else {
      final LIElement noChildren = LIElement();
      noChildren.innerHtml = 'There are no children types';
      uList.children.add(noChildren);
    }
  } else {
    final LIElement noChildren = LIElement();
    if (cmisType.value.isEmpty) {
      noChildren.innerHtml =
          'There are no more children types in this repository';
    } else {
      noChildren.innerHtml = 'There are no more children types for this type';
    }
    uList.children.add(noChildren);
  }

  typeListSection.children.add(uList);
}

void doTypeInfoChildren(Event e) {
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
      addErrorAlert(typeAlertSection, message);
    } else {
      outputTypeListChildren(cmisResponse);
    }
  }

  clearAlertSection(typeAlertSection);
  cmisSession.resultCompletion = completer;
  cmisSession.depth = 1;
  if (cmisType.value.isEmpty) {
    cmisSession.getTypeChildren(null);
  } else {
    cmisSession.getTypeChildren(cmisType.value.trim());
  }
}

void outputTypeListDefinition(dynamic response) {
  final UListElement uList = UListElement();

  if (response.jsonCmisResponse.isNotEmpty) {
    final LIElement localName = LIElement();
    localName.innerHtml = 'Local Name: ${response.jsonCmisResponse.localName}';
    uList.children.add(localName);
    final LIElement queryName = LIElement();
    queryName.innerHtml = 'Description: ${response.jsonCmisResponse.queryName}';
    uList.children.add(queryName);
  } else {
    final LIElement noDefinition = LIElement();
    noDefinition.innerHtml = 'There is no definition for this type';
    uList.children.add(noDefinition);
  }

  typeListSection.children.add(uList);
}

void doTypeInfoDefinition(Event e) {
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
      addErrorAlert(typeAlertSection, message);
    } else {
      outputTypeListDefinition(cmisResponse);
    }
  }

  clearAlertSection(typeAlertSection);
  if (cmisType.value.isEmpty) {
    const String message = 'You must supply a Type Id for this function';
    addErrorAlert(typeAlertSection, message);
    return;
  }
  cmisSession.resultCompletion = completer;
  cmisSession.depth = 1;
  cmisSession.getTypeDefinition(cmisType.value.trim());
}
