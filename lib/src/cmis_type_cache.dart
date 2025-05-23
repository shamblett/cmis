/*
 * Packge : Cmis
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 01/07/2013
 * Copyright :  S.Hamblett@OSCF
 *
 * 
 * A CMIS Type Cache class for the CMIS session
 */

part of '../cmis.dart';

/// CMIS type cache
class CmisTypeCache {
  // A map from a type id to to a CMIS type definition
  final Map<String?, jsonobject.JsonObjectLite<dynamic>> _types =
      <String?, jsonobject.JsonObjectLite<dynamic>>{};

  // A map from a type id to a time stamp when it was last used
  final Map<String?, DateTime> _lastAccessed = <String?, DateTime>{};

  // The number of types to be cached */
  final int _maxSize = 10;

  /// Get the size of the cache
  int get size => _types.length;

  /// Reset the type id maps
  void reset() {
    _types.clear();
    _lastAccessed.clear();
  }

  /// Check if we have a type cached
  bool isTypeInCache(String key) => _types.containsKey(key);

  /// Get a type for a supplied type id
  jsonobject.JsonObjectLite<dynamic>? getType(String typeId) {
    if (_types.containsKey(typeId)) {
      return _types[typeId];
    }

    return null;
  }

  /// Remove the oldest element from the type maps.
  void removeOldestElement() {
    var oldest = DateTime.now();
    String? oldestKey;

    // Find the oldest entry
    _lastAccessed.forEach((dynamic key, dynamic value) {
      if (value.isBefore(oldest)) {
        oldest = value;
        oldestKey = key;
      }

      // Remove the oldest key
      _types.remove(oldestKey);
      _lastAccessed.remove(oldestKey);
    });
  }

  /// Remove oldest elements from the type maps
  void removeOldestElements() {
    while (_types.length >= _maxSize) {
      removeOldestElement();
    }
  }

  /// Add a type to the cache
  void addType(dynamic typeDef) {
    try {
      // TODO SJH fix this
      final tt = typeDef;
      final tmp = tt as jsonobject.JsonObjectLite;
      if (tmp.keys.contains('id')) {
        removeOldestElements();
        _types[typeDef.id] = typeDef;
        _lastAccessed[typeDef.id] = DateTime.now();
      }
    } on Exception {
      // Do nothing
    }
  }
}
