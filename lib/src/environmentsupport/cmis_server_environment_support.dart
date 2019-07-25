/*
* Package : Cmis
* Author : S. Hamblett <steve.hamblett@linux.com>
* Date   : 24/07/2019
* Copyright :  S.Hamblett@OSCF
*
* Environmental support
*/

part of cmis_server_client;

/// Server environmental support
class CmisServerEnvironmentSupport extends CmisEnvironmentSupport {
  /// Encoded authentication string
  @override
  String encodedAuthString(String authStringToEncode) =>
      const Base64Encoder().convert(authStringToEncode.codeUnits);

  /// Form data
  @override
  dynamic formData() => null;

  /// Blob
  @override
  dynamic blob(List<String> blobParts, String mimeType) => null;

  /// File reader
  @override
  dynamic fileReader() => null;

  /// File contents
  @override
  String fileContents(String filename) => File(filename).readAsStringSync();

  /// File
  @override
  dynamic file() => null;
}
