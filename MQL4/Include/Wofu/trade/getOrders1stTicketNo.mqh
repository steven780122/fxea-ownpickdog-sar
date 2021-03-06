//#include <Wofu\\trade\\getOrders1stTicketNo.mqh>
//返回訂單中第一張開倉單號，沒有找到則返回-1
#include <Wofu\\trade\\omsIsMyOrder.mqh>
int getOrders1stTicketNo(string fSymbol,ENUM_MIXED_ORDER_TYPE fOdType,int fMagicNumber) export
 {
  int fLtNo=-1;
  datetime fOrderOpenTime=StringToTime("2999.12.31");
  for(int i=0;i<OrdersTotal();i++)
   { if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && omsIsMyOrder(fSymbol,fOdType,fMagicNumber) && OrderOpenTime() < fOrderOpenTime) 
      { 
       fOrderOpenTime=OrderOpenTime(); 
       fLtNo=OrderTicket();
      }
   } //EOF for 
   return(fLtNo);
 }
