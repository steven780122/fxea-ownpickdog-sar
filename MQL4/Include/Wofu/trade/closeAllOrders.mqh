//關閉全部在倉訂單
#include <Wofu\\trade\\isMyOrder.mqh>
#include <Wofu\\common\\logTradeError.mqh>
#include <Wofu\\trade\\getOrdersCnt.mqh>
#include <Wofu\\enums\\MixedOrderType.mqh>
void closeAllOrders
(
   string fSymbol,
   ENUM_MIXED_ORDER_TYPE fOdType,
   int fMagicNumber,
   int fSlPage,
   bool fTpPipsEn=false,
   int fTpPips=0,
   bool fSlPipsEn=false,
   int fSlPips=0
) export
 {
   int TotalOrderCnt=0;
   int OdType=-100;
   int LastErrorCode=-1;
   
   while(true)
    {
      TotalOrderCnt = getOrdersCnt(fSymbol,fOdType,fMagicNumber);
      if (TotalOrderCnt < 1) break;

      for(int i=OrdersTotal()-1;i>=0;i--)
       if( OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && isMyOrder(fSymbol,fOdType,fMagicNumber) ) 
       {
         OdType=OrderType();
         if( OdType==ORDER_TYPE_BUY || OdType==ORDER_TYPE_SELL )
         {
            if( 
                ( !fTpPipsEn || ( OdType==OP_BUY &&    (Bid-OrderOpenPrice())/Point >= fTpPips ) || ( OdType==OP_SELL &&    (OrderOpenPrice()-Ask)/Point >= fTpPips ) ) &&
                ( !fSlPipsEn || ( OdType==OP_BUY && -1*(Bid-OrderOpenPrice())/Point >= fSlPips ) || ( OdType==OP_SELL && -1*(OrderOpenPrice()-Ask)/Point >= fSlPips ) )
              )
            {
               if ( !OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),fSlPage,CLR_NONE) ) 
                  logTradeError(__FUNCTION__,OrderTicket(),GetLastError(),"OrderClose Error");
            }
         }
         else
         if( OdType==ORDER_TYPE_BUY_STOP || OdType==ORDER_TYPE_SELL_STOP || OdType==ORDER_TYPE_BUY_LIMIT || OdType==ORDER_TYPE_SELL_LIMIT )
         {
            if ( !OrderDelete(OrderTicket()) )
               logTradeError(__FUNCTION__,OrderTicket(),GetLastError(),"OrderDelete Error");               
         }
       }
    }
 }