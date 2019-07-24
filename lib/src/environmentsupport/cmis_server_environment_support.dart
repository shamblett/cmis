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
  String encodedAuthString(String authStringToEncode) => null;
  //html.window.btoa(authStringToEncode);

  /// Form data
  @override
  dynamic formData() => null; //html.FormData();

  /// Blob
  @override
  dynamic blob(List<String> blobParts, String mimeType) => null;
  //html.Blob(blobParts, mimeType);

  /// File reader
  @override
  dynamic fileReader() => null; //html.FileReader();

  /// File
  @override
  dynamic file() => null; //html.File;
}
