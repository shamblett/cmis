/*
 * Packge : Cmis
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 01/07/2013
 * Copyright :  S.Hamblett@OSCF
 *
 * This exception is thrown when Cmis has an internal error, such as an invalid
 * parameter being passed to a function.
 */

part of '../cmis.dart';

/// CMIS client exceptions
class CmisException implements Exception {
  final String _message;

  /// Default
  CmisException([this._message = 'No Message Supplied']);

  @override
  String toString() => 'CmisException: message = $_message';
}
