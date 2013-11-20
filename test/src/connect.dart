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

InputElement cmisUrl =  querySelector('#cmis-url'); 
InputElement cmisServiceUrl =  querySelector('#cmis-service-url'); 
InputElement cmisUser =  querySelector('#cmis-user');
InputElement cmisPassword = querySelector('#cmis-password'); 
InputElement cmisProxy = querySelector('#cmis-proxy'); 
DivElement connectAlertSection = querySelector('#cmis-alertsection-connect');
void doConnect(Event e){
  
  repoId = null;
  
  /* Must have a url */
  String url = cmisUrl.value;
  if ( url.isEmpty ) {
    
    addErrorAlert(connectAlertSection,
                  "You must specify a URL");
    return;
    
  }
  String serviceUrl = cmisServiceUrl.value;
  if ( serviceUrl.isEmpty) serviceUrl = null;
  String userName = cmisUser.value;
  if ( userName.isEmpty) userName = null;
  String password = cmisPassword.value;
  if ( password.isEmpty) password = null;
  if ( !cmisRepositoryId.value.isEmpty ) {
    
    repoId = cmisRepositoryId.value;
    
  }
  
  
  try {
  
    cmisSession = cmisClient.getCmisSession(url,
                                            serviceUrl,
                                            userName,
                                            password,
                                            repoId);
    
    if ( cmisProxy.value == 'yes' ) cmisSession.proxy = true;
    
    addSuccessAlert(connectAlertSection,
                    "Cmis Session successfully created");
    
  } catch(e) {
    
    addErrorAlert(connectAlertSection,
                  e); 
  }
  
}

