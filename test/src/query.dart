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

TextAreaElement queryStatement = querySelector('#cmis-query-statement');
DivElement queryAlertSection = querySelector('#cmis-alertsection-query');
DivElement queryListSection = querySelector('#cmis-query-list-section');
void doQueryClear(Event e) {
  queryListSection.children.clear();
  queryAlertSection.children.clear();
}

void outputQueryList(dynamic response) {
  final PreElement preElement = PreElement();
  final UListElement uList = UListElement();

  if (response.jsonCmisResponse.isNotEmpty) {
    final List<dynamic> results = response.jsonCmisResponse.results;
    if (results.isNotEmpty) {
      preElement.innerHtml = results.toString();
      queryListSection.children.add(preElement);
    } else {
      final LIElement noChildren = LIElement();
      noChildren.innerHtml = 'The query has returned no items';
      uList.children.add(noChildren);
      queryListSection.children.add(uList);
    }
  } else {
    final LIElement noChildren = LIElement();
    noChildren.innerHtml = 'There query has returned no items';
    uList.children.add(noChildren);
    queryListSection.children.add(uList);
  }
}

void doQuery(Event e) {
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
      addErrorAlert(queryAlertSection, message);
    } else {
      outputQueryList(cmisResponse);
    }
  }

  clearAlertSection(queryAlertSection);
  cmisSession.resultCompletion = completer;
  if (queryStatement.value.isEmpty) {
    addErrorAlert(queryAlertSection, 'You must supply a query!');
  } else {
    cmisSession.query(queryStatement.value.trim());
  }
}
