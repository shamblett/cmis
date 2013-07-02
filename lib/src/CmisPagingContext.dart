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
   * Get the curent page
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
  
  
}