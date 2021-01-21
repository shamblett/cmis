/*
* Package : Cmis
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 24/07/2019
* Copyright :  S.Hamblett@OSCF
*
* Environmental support
*/

part of cmis_browser_client;

/// Browser environmental support
class CmisBrowserEnvironmentSupport extends CmisEnvironmentSupport {
  /// Encoded authentication string
  @override
  String encodedAuthString(String authStringToEncode) =>
      html.window.btoa(authStringToEncode);

  /// Form data
  @override
  dynamic formData() => html.FormData();

  /// Blob
  @override
  dynamic blob(List<String?> blobParts, String? mimeType) =>
      html.Blob(blobParts, mimeType);

  /// File reader
  @override
  dynamic fileReader() => html.FileReader();

  /// File contents
  @override
  String? fileContents(String? filename) => null;

  /// File
  @override
  dynamic file() => html.File;

  /// Decode an encoded url string
  @override
  String decodeUrl(String url) => url;
}
