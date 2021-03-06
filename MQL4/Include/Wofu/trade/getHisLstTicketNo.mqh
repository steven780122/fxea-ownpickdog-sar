//#include <Wofu\\trade\\getHisLstTicketNo.mqh>
//返回歷史單中最後一張單號，沒有找到則返回-1
#include <Wofu\\trade\\omsIsMyOrder.mqh>
int getHisLstTicketNo(string fSymbol,MIXED_ORDER_TYPE fOdType,int fMagicNumber) export
 {
  int fLtNo=-1;
  datetime fOrderCloseTime=StrToTime("2000.1.1");
  for(int i=0;i<OrdersHistoryTotal();i++)
   { if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY) && omsIsMyOrder(fSymbol,fOdType,fMagicNumber) && OrderCloseTime() > fOrderCloseTime) 
      { 
       fOrderCloseTime=OrderCloseTime(); 
       fLtNo=OrderTicket();
      }
   } //EOF for 
   return(fLtNo);
 }
