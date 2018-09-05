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

/* Initialise */
Cmis cmisClient = new Cmis();
CmisSession cmisSession = null;

/* Alert Handling */
void clearAlertSection(DivElement section) {
  section.children.clear();
}

void addErrorAlert(DivElement section, String alertText) {
  DivElement alert = new DivElement();
  alert.classes.add("alert alert-error");
  alert.text = alertText;
  clearAlertSection(section);
  section.children.add(alert);
}

void addInfoAlert(DivElement section, String alertText) {
  DivElement alert = new DivElement();
  alert.classes.add("alert alert-info");
  alert.text = alertText;
  clearAlertSection(section);
  section.children.add(alert);
}

void addSuccessAlert(DivElement section, String alertText) {
  DivElement alert = new DivElement();
  alert.classes.add("alert alert-success");
  alert.text = alertText;
  clearAlertSection(section);
  section.children.add(alert);
}
