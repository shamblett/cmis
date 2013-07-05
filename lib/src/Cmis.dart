
/*
 * Packge : Cmis
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 01/07/2013
 * Copyright :  S.Hamblett@OSCF
 *
 * The Cmis class provides core functionality for interacting with CMIS servers from
 * the browser.
 * 
 * The class itself is based on the cmislib.js library from the Apache Chemistry project.
 * 
 * It is a factory class for the creation of Cmis sessions, if a repository is supplied
 * that does not already have a session a new one is created otherwise th existing
 * Cmis session is used.
 * 
 * If no repository id is supplied a new Cmis session is always created
 */

part of cmis;

class Cmis {
  
  /* Cmis session map */
  Map _sessionMap = new Map<String,CmisSession>();
  
}