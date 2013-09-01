/*
 * Packge : Cmis
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 01/07/2013
 * Copyright :  S.Hamblett@OSCF
 *
 * 
 * A CMIS Operation context class for the CMIS session
 */

part of cmis;

class CmisOperationContext {
  
  String propertyFilter = "*";
  int maxItems = 25;
  int skipCount = 0;
  bool includeAcls = false;
  bool includeAllowableActions = false;
  bool includePolicies = false;
  String includeRelationships = "none";
  String renditionFilter = null;
  bool includePathSegments = false;
  String orderBy = null;
  bool includePropertyDefinitions = true;
  bool searchAllVersions = true;
  bool succint = false;
  
}