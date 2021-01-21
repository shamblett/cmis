/*
 * Packge : Cmis
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 01/07/2013
 * Copyright :  S.Hamblett@OSCF
 *
 * 
 * A CMIS Operational context class for the CMIS session
 */

part of cmis;

/// CMIS operation context
class CmisOperationContext {
  String propertyFilter = '*';
  int maxItems = 25;
  int skipCount = 0;
  bool includeAcls = false;
  bool includeAllowableActions = false;
  bool includePolicies = false;
  String includeRelationships = 'none';
  String renditionFilter = 'cmis:none';
  bool includePathSegment = false;
  String? orderBy;
  bool includePropertyDefinitions = true;
  bool searchAllVersions = true;
  bool succint = false;
}
