
//刪除預掛單 
#include <Wofu\\trade\\omsIsMyOrder.mqh>
#include <Wofu\\common\\errorDescriptions.mqh>
  
void deleteAllPendingOrders(string fSymbol,MIXED_ORDER_TYPE fOdType,int fMagicNumber) export
 {
      int LastErrorCode;
      ResetLastError();
      for(int i=OrdersTotal()-1;i>=0;i--)
       if( OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && omsIsMyOrder(fSymbol,fOdType,fMagicNumber)  )
        if ( !OrderDelete(OrderTicket()) )
         {LastErrorCode=GetLastError();Alert(IntegerToString(OrderTicket())+(string)LastErrorCode+ErrorDescription(LastErrorCode));}
 }


#ifdef OLD_ALIAS
   void DeleteAllOrder(int fMagicNumber) export
   {  deleteAllPendingOrders(_Symbol,98,fMagicNumber); }
#endif 