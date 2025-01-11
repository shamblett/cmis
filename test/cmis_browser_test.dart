/*
 * Package : Cmis
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 25/07/2019
 * Copyright :  S.Hamblett
 *
 * The Cmis class provides core functionality for interacting with CMIS servers from
 * the browser.
 * 
 * This is the CMIS client test suite
 * 
 */

@TestOn('browser')
library;

import 'package:json_object_lite/json_object_lite.dart' as jsonobject;
import 'package:cmis/cmis_browser_client.dart';
import 'package:cmis/cmis.dart';
import 'package:test/test.dart';
import 'cmis_test_config.dart';

int main() {
  // Initialise
  final cmisClient = CmisBrowserClient();
  CmisSession? cmisSession;
  String? cmisRepositoryId;
  String? cmisUrl;
  String? cmisUser;
  String? cmisPassword;

  // Initialise the page from the config file
  if (configInUse) {
    cmisRepositoryId = configRepositoryId;
    cmisUrl = configUrlBrowser;
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
      cmisResponse = cmisSession!.completionResponse;
      final jsonobject.JsonObjectLite<dynamic> repo =
          cmisResponse.jsonCmisResponse.toList()[0];
      final String? repositoryId = repo.toList()[0];
      final String? repositoryName = repo.toList()[1];
      final String? repositoryDescription = repo.toList()[2];
      print(
          'Repository : Id - $repositoryId, : name - $repositoryName, : description - $repositoryDescription');
      cmisSession!.repositoryId = repositoryId;
    }

    cmisSession!.resultCompletion = expectAsync0(completer, count: 1);
    print('Getting repositories');
    cmisSession!.getRepositories();
  });

  test('Root folder', () {
    dynamic cmisResponse;
    void completer() {
      cmisResponse = cmisSession!.completionResponse;
      expect(cmisResponse, isA<jsonobject.JsonObjectLite>());
      expect(cmisResponse.error, isTrue);
    }

    cmisSession!.resultCompletion = expectAsync0(completer, count: 1);
    print('Getting root folder contents');
    cmisSession!.getRootFolderContents();
  }, skip: true);

  test('Repository info', () {
    dynamic cmisResponse;
    void completer() {
      cmisResponse = cmisSession!.completionResponse;
      expect(cmisResponse, isA<jsonobject.JsonObjectLite>());
      expect(cmisResponse.error, isFalse);
    }

    cmisSession!.resultCompletion = expectAsync0(completer, count: 1);
    print('Getting repository info');
    cmisSession!.getRepositoryInfo();
  });

  test('Checked out docs', () {
    dynamic cmisResponse;
    void completer() {
      cmisResponse = cmisSession!.completionResponse;
      expect(cmisResponse, isA<jsonobject.JsonObjectLite>());
      expect(cmisResponse.error, isFalse);
    }

    cmisSession!.resultCompletion = expectAsync0(completer, count: 1);
    print('Getting checked out docs');
    cmisSession!.getCheckedOutDocs();
  });

  test('Root folder contents', () {
    dynamic cmisResponse;
    void completer() {
      cmisResponse = cmisSession!.completionResponse;
      expect(cmisResponse, isA<jsonobject.JsonObjectLite>());
      expect(cmisResponse.error, isTrue);
    }

    cmisSession!.resultCompletion = expectAsync0(completer, count: 1);
    print('Getting root folder contents');
    cmisSession!.getRootFolderContents();
  }, skip: true);

  test('Type descendants', () {
    dynamic cmisResponse;
    void completer() {
      cmisResponse = cmisSession!.completionResponse;
      expect(cmisResponse, isA<jsonobject.JsonObjectLite>());
      expect(cmisResponse.error, isFalse);
    }

    cmisSession!.resultCompletion = expectAsync0(completer, count: 1);
    print('Getting type descendants');
    cmisSession!.depth = 1;
    cmisSession!.getTypeDescendants();
  });

  test('Type children', () {
    dynamic cmisResponse;
    void completer() {
      cmisResponse = cmisSession!.completionResponse;
      expect(cmisResponse, isA<jsonobject.JsonObjectLite>());
      expect(cmisResponse.error, isFalse);
    }

    cmisSession!.resultCompletion = expectAsync0(completer, count: 1);
    print('Getting type children');
    cmisSession!.depth = 1;
    cmisSession!.getTypeChildren();
  });

  test('Type definition', () {
    dynamic cmisResponse;
    void completer() {
      cmisResponse = cmisSession!.completionResponse;
      expect(cmisResponse, isA<jsonobject.JsonObjectLite>());
      expect(cmisResponse.error, isTrue);
    }

    cmisSession!.resultCompletion = expectAsync0(completer, count: 1);
    print('Getting type definition');
    cmisSession!.depth = 1;
    cmisSession!.getTypeDefinition('cmis:folder');
  }, skip: true);

  test('Query ', () {
    dynamic cmisResponse;
    void completer() {
      cmisResponse = cmisSession!.completionResponse;
      expect(cmisResponse, isA<jsonobject.JsonObjectLite>());
      expect(cmisResponse.error, isTrue);
    }

    cmisSession!.resultCompletion = expectAsync0(completer, count: 1);
    print('Running CMIS query');
    cmisSession!.depth = 1;
    cmisSession!.query('SELECT * FROM cmis:document');
  }, skip: true);

  return 0;
}
