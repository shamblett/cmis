/*
 * Package : CmisBrowserClient
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 23/07/2019
 * Copyright :  S.Hamblett
 * 
 * An instance of Cmis specialised for use in the browser
 */

library;

import 'dart:async';
import 'dart:html' as html;
import 'package:json_object_lite/json_object_lite.dart' as jsonobject;
import 'cmis.dart';

part 'src/httpadapters/cmis_browser_http_adapter.dart';
part 'src/environmentsupport/cmis_browser_environment_support.dart';

/// The Cmis browser client
class CmisBrowserClient extends Cmis {
  /// Browser HTTP adapter
  static final CmisBrowserHttpAdapter browserHttpAdapter =
      CmisBrowserHttpAdapter();

  /// Browser environment support
  static final CmisBrowserEnvironmentSupport browserEnvironmentSupport =
      CmisBrowserEnvironmentSupport();

  /// Default constructor
  CmisBrowserClient() : super(browserHttpAdapter, browserEnvironmentSupport);
}
