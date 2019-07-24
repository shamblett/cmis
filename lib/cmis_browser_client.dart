/*
 * Package : CmisBrowserClient
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 23/07/2019
 * Copyright :  S.Hamblett
 * 
 * An instance of Cmis specialised for use in the browser
 */

library cmis_browser_client;

import 'dart:html' as html;
import 'package:cmis/cmis.dart';
import 'package:json_object_lite/json_object_lite.dart' as jsonobject;

part 'src/httpadapters/cmis_browser_http_adapter.dart';

/// The Cmis browser client
class CmisBrowserClient extends Cmis {
  /// Default constructor
  CmisBrowserClient() : super(browserHttpAdapter);

  /// Browser HTTP adapter
  static CmisBrowserHttpAdapter browserHttpAdapter = CmisBrowserHttpAdapter();
}
