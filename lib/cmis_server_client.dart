/*
 * Package : WiltServerClient
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 04/06/2013
 * Copyright :  S.Hamblett@OSCF
 * 
 * An instance of Wilt specialised for use in the server.
 */

library cmis_server_client;

import 'package:cmis/cmis.dart';
import 'package:http/http.dart' as http;
import 'package:json_object_lite/json_object_lite.dart' as jsonobject;

part 'src/httpadapters/cmis_server_http_adapter.dart';
part 'src/environmentsupport/cmis_server_environment_support.dart';

/// The Cmis server client
class CmisServerClient extends Cmis {
  /// Default constructor
  CmisServerClient() : super(serverHttpAdapter, serverEnvironmentSupport);

  /// Browser HTTP adapter
  static CmisServerHttpAdapter serverHttpAdapter = CmisServerHttpAdapter();

  /// Browser environment support
  static CmisServerEnvironmentSupport serverEnvironmentSupport =
      CmisServerEnvironmentSupport();
}
