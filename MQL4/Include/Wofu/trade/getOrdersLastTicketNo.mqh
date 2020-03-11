//#include <Wofu\\trade\\getOrdersLastTicketNo.mqh>
//返回訂單中最後一張開倉單號，沒有找到則返回-1
#include <Wofu\\trade\\omsIsMyOrder.mqh>
int getOrdersLastTicketNo
(
   string fSymbol,
   ENUM_MIXED_ORDER_TYPE fOdType,
   int fMagicNumber,
   datetime fOrderOpenTimeMin =D'2000.01.01 00:00:00',
   datetime fOrderOpenTimeMax =D'2999.12.31 23:59:59'  
) export
 {
  int fLtNo=-1;
  datetime fOrderOpenTime=StringToTime("2000.1.1");
  for(int i=0;i<OrdersTotal();i++)
   { if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && 
         omsIsMyOrder(fSymbol,fOdType,fMagicNumber) && 
         OrderOpenTime() > fOrderOpenTime &&
         OrderOpenTime() >= fOrderOpenTimeMin &&
         OrderOpenTime() <= fOrderOpenTimeMax 
        ) 
      { 
       fOrderOpenTime=OrderOpenTime(); 
       fLtNo=OrderTicket();
      }
   } //EOF for 
   return(fLtNo);
 }


void getOrdersLastTicketNo
(
   string fSymbol,
   int fMagicNumber,
   int& lastOrderTicketNo,
   int& lastOrderBuyTicketNo,
   int& lastOrderSellTicketNo
) export
 {
   lastOrderTicketNo=-1;
   lastOrderBuyTicketNo=-1;
   lastOrderSellTicketNo=-1;
   
  datetime fOrderOpenTime=StringToTime("2000.1.1");
  for(int i=0;i<OrdersTotal();i++)
   { if(  OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && 
          OrderSymbol()==fSymbol &&
          OrderMagicNumber()==fMagicNumber &&
          ( OrderType()==ORDER_TYPE_BUY ||  OrderType()==ORDER_TYPE_SELL ) &&
          OrderOpenTime() > fOrderOpenTime 
        ) 
         { 
          fOrderOpenTime=OrderOpenTime(); 
          lastOrderTicketNo=OrderTicket();
          if(OrderType()==ORDER_TYPE_BUY)lastOrderBuyTicketNo=OrderTicket();
          else
          if(OrderType()==ORDER_TYPE_SELL)lastOrderSellTicketNo=OrderTicket();
         }
   } //EOF for 
 }

