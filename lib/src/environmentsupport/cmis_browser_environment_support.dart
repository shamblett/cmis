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
  String encodedAuthString(String authStringToEncode) => null;

  /// Form data
  @override
  dynamic formData() => null;

  /// Blob
  @override
  dynamic blob(List<String> blobParts, String mimeType) => null;

  /// File reader
  @override
  dynamic fileReader() => null;

  /// File
  @override
  dynamic file() => null;
}
