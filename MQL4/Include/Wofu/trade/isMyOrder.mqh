/*
查詢訂單是否符合條件
*/
#include <Wofu\\trade\\selectOpOrderByTicketNo.mqh>
#include <Wofu\\trade\\omsIsMyOrder.mqh>
#include <Wofu\\enums\\MixedOrderType.mqh>
bool isMyOrder
(
   string fSymbol,               //貨幣兌("ALL":所有貨幣兌)
   ENUM_MIXED_ORDER_TYPE fOdType,     //訂單型態(MIXED_ORDER_TYPE*)
   int fMagicNumber              //程式編號(-1:所有程式編號)
)export
{
   if( OrderTicket()<=0 )return(false);
   return(omsIsMyOrder(fSymbol,fOdType,fMagicNumber));
}
