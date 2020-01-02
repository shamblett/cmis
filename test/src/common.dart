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

// Initialise
CmisBrowserClient cmisClient = CmisBrowserClient();
CmisSession cmisSession;

// Alert Handling
void clearAlertSection(DivElement section) {
  section.children.clear();
}

void addErrorAlert(DivElement section, String alertText) {
  final DivElement alert = DivElement();
  alert.classes.add('alert&nbspalert-error');
  alert.text = alertText;
  clearAlertSection(section);
  section.children.add(alert);
}

void addInfoAlert(DivElement section, String alertText) {
  final DivElement alert = DivElement();
  alert.classes.add('alert&nbspalert-info');
  alert.text = alertText;
  clearAlertSection(section);
  section.children.add(alert);
}

void addSuccessAlert(DivElement section, String alertText) {
  final DivElement alert = DivElement();
  alert.classes.add('alert&nbspalert-success');
  alert.text = alertText;
  clearAlertSection(section);
  section.children.add(alert);
}
