/*
 * Packge : Cmis
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 05/07/2013
 * Copyright :  S.Hamblett@OSCF
 *
 * The Cmis class provides core functionality for interacting with
 * CMIS servers from the browser.
 * 
 * This is the CMIS client interactive test suite
 * 
 */
bool configInUse = true;
String configUrlBrowser = 'http://localhost:5000/http://cmis.alfresco.com/cmisbrowser';
// Hosted service 'https://cors.bridged.cc/http://cmis.alfresco.com/cmisbrowser';

String configUrlServer = 'http://cmis.alfresco.com/cmisbrowser';
String serviceUrl = ''; //Optional
String configUser = 'admin';
String configPassword = 'admin';
String configRepositoryId = ''; // Optional
bool configProxy = false;
