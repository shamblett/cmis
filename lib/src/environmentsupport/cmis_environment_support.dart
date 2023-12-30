/*
* Package : Cmis
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 24/07/2019
* Copyright :  S.Hamblett@OSCF
*
* Environmental support
*/

part of '../../cmis.dart';

/// Environmental support
abstract class CmisEnvironmentSupport {
  /// Encoded authentication string
  String encodedAuthString(String authStringToEncode);

  /// Form data
  dynamic formData();

  /// Blob
  dynamic blob(List<String?> blobParts, String? mimeType);

  /// File reader
  dynamic fileReader();

  /// File contents
  String? fileContents(String? filename);

  /// File
  dynamic file();

  /// Decode an encoded url string
  String decodeUrl(String url);
}
