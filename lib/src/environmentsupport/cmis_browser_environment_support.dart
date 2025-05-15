/*
* Package : Cmis
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 24/07/2019
* Copyright :  S.Hamblett@OSCF
*
* Environmental support
*/

part of '../../cmis_browser_client.dart';

/// Browser environmental support
class CmisBrowserEnvironmentSupport extends CmisEnvironmentSupport {
  /// Encoded authentication string
  @override
  String encodedAuthString(String authStringToEncode) =>
      window.btoa(authStringToEncode);

  /// Form data
  @override
  dynamic formData() => FormData();

  /// Blob
  dynamic blob(JSArray<BlobPart> blobParts, BlobPropertyBag mimeType) =>
      Blob(blobParts, mimeType);

  /// File reader
  @override
  dynamic fileReader() => FileReader();

  /// File contents
  @override
  String? fileContents(String? filename) => null;

  /// File
  @override
  dynamic file() => File;

  /// Decode an encoded url string
  @override
  String decodeUrl(String url) => url;
}
