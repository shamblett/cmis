/*
 * Packge : Cmis
 * Author : S. Hamblett <steve.hamblett@linux.com>
 * Date   : 01/07/2013
 * Copyright :  S.Hamblett@OSCF
 *
 * 
 * A CMIS Paging Context class
 */

part of cmis;

class CmisPagingContext {
  
  static const double CMIS_UNKNOWN = -1.0;
  
  int _skipCount =  null;
  int _totalItems = null;
  CmisOperationContext _opCtx = null;
  
  /**
   * Construct this with a skipcount, total items and an operational context
   */
  CmisPagingContext(this._skipCount, 
                    this._totalItems, 
                    this._opCtx);
  
  /**
   * Get total item count
   */
  int get totalItems => _totalItems == 0 ? 4294967295 : _totalItems;
  
  /**
   * Get the current page
   */
  num get currentPage => ( (_skipCount / _opCtx.maxItems) + 1 ).floor();
  
  /**
   * Get the total page count
   */
  int getTotalPages() {
    
   double totalPages = null;
    
    if ( (_totalItems == null ) || 
        ( _opCtx.maxItems == null ) || 
        ( _opCtx.maxItems == 0 )
        ) {
          totalPages = CMIS_UNKNOWN;
          
    } else {
      
      totalPages = ( ( _totalItems - ( _totalItems % _opCtx.maxItems) ) / _opCtx.maxItems ) + 1;
      
    }
    
    return totalPages.round();
    
  }
  
  /**
   * Set the page to the previous page
   */
  void setPreviousPage() {
    
    _skipCount = _skipCount - _opCtx.maxItems;
    if (_skipCount < 0)
      _skipCount = 0;
    
  }
  
  /**
   * Set the page to the next page
   */
  void setNextPage() {
    
    _skipCount = _skipCount + _opCtx.maxItems;
    if ( _skipCount >= _totalItems)
      _skipCount = _totalItems - _opCtx.maxItems;
    
   }
  
  /**
   * Set the first page
   */
  int firstPage() => _skipCount = 0;
  
  /**
   * Set the last page
   */
  void lastPage() {
    
    if (_totalItems != null) {
     
      int totalPages = getTotalPages() - 1;
      _skipCount = totalPages * _opCtx.maxItems;
      
    }
    
  }

}