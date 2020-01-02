/*
 * Package : Cmis
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 01/07/2013
 * Copyright :  S.Hamblett@OSCF
 *
 * The Cmis class provides core functionality for interacting with CMIS servers from
 * the browser.
 * 
 * The class library itself is based on the cmislib.js library from the Apache Chemistry project.
 * 
 * Reference:https://svn.apache.org/repos/asf/chemistry/playground/chemistry-opencmis-javascript-client/
 * 
 * It is a factory class for the creation of Cmis sessions, if a repository is supplied
 * that does not already have a session a new one is created otherwise the existing
 * Cmis session is used.
 * 
 * If no repository id is supplied a new Cmis session is always created.
 * 
 * NOTE: As Dart passes all objects by reference a CMIS session created in this class with
 * a repository id and one retrieved later with the same repository id will be the same object.
 * Manipulation of this by two clients will have undesirable side effects for both. If a user 
 * wants multiple instances of a repository that are independant then don't supply a repository
 * id in the getCmisSession method, or use different instantiations of this class.
 * 
 * This class is primarily aimed at a single client usage where repositories can be easily
 * 'hot' swapped between rather than shared.  
 */

part of cmis;

// ignore_for_file: omit_local_variable_types
// ignore_for_file: unnecessary_final
// ignore_for_file: cascade_invocations
// ignore_for_file: avoid_print
// ignore_for_file: lines_longer_than_80_chars

/// The CMIS client
class Cmis {
  /// Default constructor
  Cmis(this.httpAdapter, this.environmentSupport);

  /// HTTP Adapter
  CmisHttpAdapter httpAdapter;

  /// Environment support
  CmisEnvironmentSupport environmentSupport;

  /// Cmis session map
  final Map<String, CmisSession> _sessionMap = <String, CmisSession>{};

  ///  Return either a new CmisSession or one from the cache if we have one
  CmisSession getCmisSession(String urlPrefix,
      [String serviceUrlPrefix,
      String userName,
      String password,
      String repId]) {
    /// Check for an existing session
    if (_sessionMap.containsKey(repId)) {
      return _sessionMap[repId];
    }

    // Generate a new one
    final CmisSession newSession = CmisSession(
        urlPrefix, httpAdapter, environmentSupport, serviceUrlPrefix, repId);

    // Login if asked
    if ((userName != null) && (password != null)) {
      newSession.login(userName, password);
    }

    // Add to the map
    if (repId != null) {
      _sessionMap[repId] = newSession;
    }

    // Return the new session
    return newSession;
  }

  ///  Session existence
  bool sessionExists(String repId) => _sessionMap.containsKey(repId);

  ///  Session removal
  bool removeSession(String repId) {
    if (sessionExists(repId)) {
      _sessionMap.remove(repId);
      return true;
    }

    return false;
  }
}
