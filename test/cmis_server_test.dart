/*
 * Package : Cmis
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 25/07/2019
 * Copyright :  S.Hamblett
 *
 * The Cmis class provides core functionality for interacting with CMIS servers from
 * the server.
 * 
 * This is the CMIS client test suite
 * 
 */

@TestOn('vm')

library cmisservertest;

import 'package:json_object_lite/json_object_lite.dart' as jsonobject;
import 'package:cmis/cmis_server_client.dart';
import 'package:cmis/cmis.dart';
import 'package:test/test.dart';
import 'cmis_test_config.dart';

// ignore_for_file: omit_local_variable_types
// ignore_for_file: unnecessary_final
// ignore_for_file: lines_longer_than_80_chars
// ignore_for_file: avoid_annotating_with_dynamic
// ignore_for_file: cascade_invocations
// ignore_for_file: avoid_print

int main() {
  // Initialise
  final CmisServerClient cmisClient = CmisServerClient();
  CmisSession cmisSession;
  String cmisRepositoryId;
  String cmisUrl;
  String cmisUser;
  String cmisPassword;

  // Initialise the page from the config file
  if (configInUse) {
    cmisRepositoryId = configRepositoryId;
    cmisUrl = configUrlServer;
    cmisUser = configUser;
    cmisPassword = configPassword;
  }

  test('Connect', () async {
    try {
      cmisSession = cmisClient.getCmisSession(
          cmisUrl, serviceUrl, cmisUser, cmisPassword, cmisRepositoryId);
    } on Exception catch (e) {
      print(e);
    }
  });

  test('Repositories', () {
    dynamic cmisResponse;
    void completer() {
      cmisResponse = cmisSession.completionResponse;
      print(cmisResponse);
      final jsonobject.JsonObjectLite<dynamic> repo =
          cmisResponse.jsonCmisResponse.toList()[0];
      final String repositoryId = repo.toList()[0];
      final String repositoryName = repo.toList()[1];
      final String repositoryDescription = repo.toList()[2];
      print(
          'Repository : Id - $repositoryId, : name - $repositoryName, : description - $repositoryDescription');
      cmisSession.repositoryId = repositoryId;
    }

    cmisSession.resultCompletion = expectAsync0(completer, count: 1);
    print('Getting repositories');
    cmisSession.getRepositories();
  });

  test('Root folder', () {
    dynamic cmisResponse;
    void completer() {
      cmisResponse = cmisSession.completionResponse;
      print(cmisResponse);
    }

    cmisSession.resultCompletion = expectAsync0(completer, count: 1);
    print('Getting root folder contents');
    cmisSession.getRootFolderContents();
  });

  test('Repository info', () {
    dynamic cmisResponse;
    void completer() {
      cmisResponse = cmisSession.completionResponse;
      print(cmisResponse);
    }

    cmisSession.resultCompletion = expectAsync0(completer, count: 1);
    print('Getting repository info');
    cmisSession.getRepositoryInfo();
  });

  test('Checked out docs', () {
    dynamic cmisResponse;
    void completer() {
      cmisResponse = cmisSession.completionResponse;
      print(cmisResponse);
    }

    cmisSession.resultCompletion = expectAsync0(completer, count: 1);
    print('Getting checked out docs');
    cmisSession.getCheckedOutDocs();
  });

  test('Root folder contents', () {
    dynamic cmisResponse;
    void completer() {
      cmisResponse = cmisSession.completionResponse;
      print(cmisResponse);
    }

    cmisSession.resultCompletion = expectAsync0(completer, count: 1);
    print('Getting root folder contents');
    cmisSession.getRootFolderContents();
  });

  test('Type descendants', () {
    dynamic cmisResponse;
    void completer() {
      cmisResponse = cmisSession.completionResponse;
      print(cmisResponse.jsonCmisResponse);
    }

    cmisSession.resultCompletion = expectAsync0(completer, count: 1);
    print('Getting type descendants');
    cmisSession.depth = 1;
    cmisSession.getTypeDescendants();
  });

  test('Type children', () {
    dynamic cmisResponse;
    void completer() {
      cmisResponse = cmisSession.completionResponse;
      print(cmisResponse.jsonCmisResponse);
    }

    cmisSession.resultCompletion = expectAsync0(completer, count: 1);
    print('Getting type children');
    cmisSession.depth = 1;
    cmisSession.getTypeChildren();
  });

  test('Type definition', () {
    dynamic cmisResponse;
    void completer() {
      cmisResponse = cmisSession.completionResponse;
      print(cmisResponse.jsonCmisResponse);
    }

    cmisSession.resultCompletion = expectAsync0(completer, count: 1);
    print('Getting type definition');
    cmisSession.depth = 1;
    cmisSession.getTypeDefinition('cmis:folder');
  });

  return 0;
}
