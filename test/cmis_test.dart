/*
 * Packge : Cmis
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 05/07/2013
 * Copyright :  S.Hamblett@OSCF
 *
 * The Cmis class provides core functionality for interacting with CMIS servers from
 * the browser.
 * 
 * This isn the CMIS client interactive test suite
 * 
 */

import 'dart:async';
import 'dart:json' as json;
import 'dart:html';

import '../lib/cmis.dart';
import 'package:json_object/json_object.dart' as jsonobject;

main() {
  
  /* Initialise */
  Cmis cmisClient = null;
  
  /* Get our working element set and add event handlers */
  ButtonElement connectBtn = query('#cmis-connect-btn');
  connectBtn.onClick.listen(doConnect);
  
}

/* Event handlers */

/* Connect */
void doConnect(Event e){
  
  
}