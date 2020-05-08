/*
 * Package : cmis
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 05/09/2018
 * Copyright :  S.Hamblett@OSCF
 */

library cmisexample;

import 'dart:async';
import 'package:json_object_lite/json_object_lite.dart';
import 'package:cmis/cmis_server_client.dart';
import 'package:cmis/cmis.dart';

CmisSession cmisSession;

// Cmis get repositories function wrapped in a future wrapper
Future<JsonObjectLite<dynamic>> getRepositories() async {
  final completer = Completer<JsonObjectLite<dynamic>>();

  void localcompleter() {
    final dynamic cmisResponse = cmisSession.completionResponse;
    final dynamic repo = cmisResponse.jsonCmisResponse.toList()[0];
    final String repositoryId = repo.toList()[0];
    cmisSession.repositoryId = repositoryId;
    completer.complete(repo);
  }

  cmisSession.resultCompletion = localcompleter;
  cmisSession.getRepositories();
  return completer.future;
}

Future<void> main() async {
  /// Examples of usage can be found in the test suite
  /// Currently this client uses a completion callback mechanism,
  /// this can easily be converted into a future based interface
  /// by wrapping the client calls, see below.

  // Initialise
  final cmisClient = CmisServerClient();
  const cmisRepositoryId = '';
  const cmisUrl = 'http://cmis.alfresco.com/cmisbrowser';
  const cmisUser = 'admin';
  const cmisPassword = 'admin';
  const serviceUrl = '';

  try {
    cmisSession = cmisClient.getCmisSession(
        cmisUrl, serviceUrl, cmisUser, cmisPassword, cmisRepositoryId);
  } on Exception catch (e) {
    print(e);
  }

  // Get the repositories, future based
  await getRepositories();
  // or ... JsonObjectLite<dynamic> info = await getRepositories();
  print('Repository id is : ${cmisSession.repositoryId}');
}
