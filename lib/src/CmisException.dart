/*
 * Packge : Cmis
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 01/07/2013
 * Copyright :  S.Hamblett@OSCF
 *
 * This exception is thrown when Cmis has an internal error, such as an invalid
 * parameter being passed to a function.
 */

part of cmis;

class CmisException implements Exception {
  String _message = 'No Message Supplied';
  CmisException([this._message]);
  
  String toString() => "CmisException: message = ${_message}";
}

