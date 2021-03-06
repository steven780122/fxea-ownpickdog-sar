//取得在倉單數
#include <Wofu\\trade\\isMyOrder.mqh>
int getOrdersCnt(string fSymbol,ENUM_MIXED_ORDER_TYPE fOdType,int fMagicNumber) export
 {
  int fGetOpPosCnt=0; 
  for(int i=0;i<OrdersTotal();i++)
   { if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && isMyOrder(fSymbol,(ENUM_MIXED_ORDER_TYPE)fOdType,fMagicNumber) ) fGetOpPosCnt++; } 
  return(fGetOpPosCnt);
 }
/* 
int orderCntBuy=0, orderCntSell=0, orderCntBuyLimit=0, orderCntSellLimit=0,  orderCntBuyStop=0, orderCntSellStop=0;
getOrdersCnt(_Symbol,MagicNumber ,orderCntBuy , orderCntSell , orderCntBuyLimit , orderCntSellLimit , orderCntBuyStop , orderCntSellStop);
*/

/*
int getOrdersCnt
(
   string fSymbol,int fMagicNumber,
   int& orderCnt[],
) export
 {
     ArrayResize(orderCnt,0);
     ArrayResize(orderCnt,6);
     //for(int i=0;i<ArraySize(orderCnt);i++)
     //      orderCnt[i]=0;
     int cntAll=0;
     for(int i=0;i<OrdersTotal();i++)
     {
         if( OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && 
             omsIsMyOrder(fSymbol,MIXED_ODTYPE_ALL,fMagicNumber) )
         { 
            orderCnt[OrderType()]++;
            cntAll++;
         }
     }
     return(cntAll);
 }
*/
struct OrdersCnt
{

   int buy;
   int buystop;
   int buylimit;
   int sell;
   int sellstop;
   int selllimit;
};

int getOrdersCnt
(
   string fSymbol,int fMagicNumber,OrdersCnt& fOrdersCnt
) export
 {
   fOrdersCnt.buy=0;
   fOrdersCnt.buystop=0;
   fOrdersCnt.buylimit=0;
   fOrdersCnt.sell=0;
   fOrdersCnt.sellstop=0;
   fOrdersCnt.selllimit=0;
      
     for(int i=0;i<OrdersTotal();i++)
      if( OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && omsIsMyOrder(fSymbol,MIXED_ODTYPE_ALL,fMagicNumber) )
      { 
         switch(OrderType())
         {
            case ORDER_TYPE_BUY:
               fOrdersCnt.buy++;
               break;
            case ORDER_TYPE_SELL:
               fOrdersCnt.sell++;
               break;
            case ORDER_TYPE_BUY_STOP:
               fOrdersCnt.buystop++;
               break;
            case ORDER_TYPE_SELL_STOP:
               fOrdersCnt.sellstop++;
               break;
            case ORDER_TYPE_BUY_LIMIT:
               fOrdersCnt.buylimit++;
               break;
            case ORDER_TYPE_SELL_LIMIT:
               fOrdersCnt.selllimit++;
               break;               
            default:
               break;
         }      
      }
     return(fOrdersCnt.buy+fOrdersCnt.buystop+fOrdersCnt.buylimit+fOrdersCnt.sell+fOrdersCnt.sellstop+fOrdersCnt.selllimit);
 }
  
int getOrdersCnt
(
   string fSymbol,int fMagicNumber,
   int& outBuyCnts,int& outSellCnts,
   int& outBuyStopCnts,int& outSellStopCnts,
   int& outBuyLimitCnts,int& outSellLimitCnts
) export
 {
   outBuyCnts=0;
   outSellCnts=0;
   outBuyStopCnts=0;
   outSellStopCnts=0;
   outBuyLimitCnts=0;
   outSellLimitCnts=0;
      
     for(int i=0;i<OrdersTotal();i++)
      if( OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && omsIsMyOrder(fSymbol,MIXED_ODTYPE_ALL,fMagicNumber) )
      { 
         switch(OrderType())
         {
            case ORDER_TYPE_BUY:
               outBuyCnts++;
               break;
            case ORDER_TYPE_SELL:
               outSellCnts++;
               break;
            case ORDER_TYPE_BUY_STOP:
               outBuyStopCnts++;
               break;
            case ORDER_TYPE_SELL_STOP:
               outSellStopCnts++;
               break;
            case ORDER_TYPE_BUY_LIMIT:
               outBuyLimitCnts++;
               break;
            case ORDER_TYPE_SELL_LIMIT:
               outSellLimitCnts++;
               break;               
            default:
               break;
         }      
      }
     return(outBuyCnts+outSellCnts+outBuyStopCnts+outSellStopCnts+outBuyLimitCnts+outSellLimitCnts);
 }
 
/* 
 
 int getOrdersCnt
(
   string fSymbol,int fMagicNumber,
   int& outBuyCnts,int& outSellCnts,
   int& outBuyStopLimitCnts,int& outSellStopLimitCnts,
) export
 {
   outBuyCnts=0;
   outSellCnts=0;
   outBuyStopLimitCnts=0;
   outSellStopLimitCnts=0;
      
     for(int i=0;i<OrdersTotal();i++)
      if( OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && omsIsMyOrder(fSymbol,MIXED_ODTYPE_ALL,fMagicNumber) )
      { 
         switch(OrderType())
         {
            case ORDER_TYPE_BUY:
               outBuyCnts++;
               break;
            case ORDER_TYPE_SELL:
               outSellCnts++;
               break;
            case ORDER_TYPE_BUY_STOP:
               outBuyStopLimitCnts++;
               break;
            case ORDER_TYPE_SELL_STOP:
               outSellStopLimitCnts++;
               break;
            case ORDER_TYPE_BUY_LIMIT:
               outBuyStopLimitCnts++;
               break;
            case ORDER_TYPE_SELL_LIMIT:
               outSellStopLimitCnts++;
               break;               
            default:
               break;
         }      
      }
     return(outBuyCnts+outSellCnts+outBuyStopLimitCnts+outSellStopLimitCnts);
 }
 
 */