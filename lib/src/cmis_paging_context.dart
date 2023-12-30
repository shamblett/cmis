/*
 * Packge : Cmis
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 01/07/2013
 * Copyright :  S.Hamblett@OSCF
 *
 * 
 * A CMIS Paging Context class
 */

part of '../cmis.dart';

/// CMIS paging
class CmisPagingContext {
  /// Construct this with a skip count, total items and an operational context
  CmisPagingContext(this.skipCount, this._totalItems, this._opCtx);

  /// Unknown
  static const double cmisUnknown = -1;

  /// Skip count
  int skipCount;

  final int _totalItems;
  final CmisOperationContext _opCtx;

  /// Get total item count
  int get totalItems => _totalItems == 0 ? 4294967295 : _totalItems;

  /// Get the current page
  num get currentPage => ((skipCount / _opCtx.maxItems) + 1).floor();

  /// Get the total page count
  int getTotalPages() {
    double totalPages;

    if ((_opCtx.maxItems == 0)) {
      totalPages = cmisUnknown;
    } else {
      totalPages =
          ((_totalItems - (_totalItems % _opCtx.maxItems)) / _opCtx.maxItems) +
              1;
    }

    return totalPages.round();
  }

  /// Set the page to the previous page
  void setPreviousPage() {
    skipCount = skipCount - _opCtx.maxItems;
    if (skipCount < 0) {
      skipCount = 0;
    }
  }

  /// Set the page to the next page
  void setNextPage() {
    skipCount = skipCount + _opCtx.maxItems;
    if (skipCount >= _totalItems) {
      skipCount = _totalItems - _opCtx.maxItems;
    }
  }

  /// Set the first page
  int firstPage() => skipCount = 0;

  /// Set the last page
  void lastPage() {
    final totalPages = getTotalPages() - 1;
    skipCount = totalPages * _opCtx.maxItems;
  }
}
