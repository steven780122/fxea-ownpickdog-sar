#include <Wofu\\common\\DefaultDefines.mqh>
#include <Wofu\\trade\\sendOrder.mqh>
#include <Wofu\\trade\\getTradePriceNow.mqh>
#include <Wofu\\common\\getOdMultiplier.mqh>
#include <Wofu\\common\\getOppOrderType.mqh>
#include <Wofu\\enums\\TradeWay.mqh>
#include <Wofu\\common\\getOrderType1Char.mqh>
#include <Wofu\\trade\\getOrdersCnt.mqh>
/*
向券商傳送預掛單


*/

double sendPendingOrders
(
   string fSymbol,            //貨幣兌
   ENUM_ORDER_TYPE fOdType,   //下單類型
   double& fOrderLots[],      //下單手數
   int fMagicNumber,          //程式編號
   string fComment,           //下單註解
   int fSlPage , 
   int& fOrdersGap[], 
   double fOpenPrice=0,       //0:BUY用ASK,SELL用BID,-1:BUY用BID,SELL用ASK,-2:取ASK+BID/2
   int  fOrderCnts=1,
   int fTpPips = 0, 
   int fSlPips = 0,
  
) export
{
   ENUM_TRADE_WAY fTradeWay;
   int StopLevel=(int)SymbolInfoInteger(fSymbol, SYMBOL_TRADE_STOPS_LEVEL);
   int GapArySize=ArraySize(fOrdersGap);
   int LotArySize=ArraySize(fOrderLots);
   int AryIdx=0;
   int GapPips;
   double fOdLots=0;   
   double fOdOpPrice=0,OdTpPrice=0,OdSlPrice=0;
   int fOrdersCnt=0;
   if( fOdType==ORDER_TYPE_BUY_STOP || fOdType==ORDER_TYPE_BUY_LIMIT)
     fOrdersCnt=getOrdersCnt(fSymbol,MIXED_ODTYPE_BUY_ALL,fMagicNumber);
   else
     fOrdersCnt=getOrdersCnt(fSymbol,MIXED_ODTYPE_SELL_ALL,fMagicNumber);
      
   double SymPoint=SymbolInfoDouble(fSymbol,SYMBOL_POINT);
   int    SymDigits=(int)SymbolInfoInteger(fSymbol,SYMBOL_DIGITS);

   if( LotArySize==0 )return(fOpenPrice);
   if( GapArySize==0 )fOrdersGap[0]=StopLevel;
   if( fOpenPrice>0 )
      fOdOpPrice=fOpenPrice;
   else if( fOpenPrice==0 )
      fOdOpPrice=getTradePriceNow(fSymbol,fOdType); //BUY:ASK,SELL:BID
   else if( fOpenPrice==-1 )
      fOdOpPrice=getTradePriceNow(fSymbol,getOppOrderType(fOdType)); //BUY:BID,SELL:ASK
   else if( fOpenPrice==-2 )
      fOdOpPrice=( SymbolInfoDouble(fSymbol, SYMBOL_ASK)+SymbolInfoDouble(fSymbol, SYMBOL_BID) )/2; //BUY:BID,SELL:ASK
   //設定返回值
   fOpenPrice=fOdOpPrice;
   
   for( int OdOpCnt=1;OdOpCnt<=fOrderCnts;OdOpCnt++ )
   {

      AryIdx=OdOpCnt-1;
      if(AryIdx>=GapArySize){GapPips=fOrdersGap[GapArySize-1];}
      else                  {GapPips=fOrdersGap[AryIdx];}
      if( fOdType==ORDER_TYPE_BUY_LIMIT || fOdType==ORDER_TYPE_SELL_LIMIT )GapPips=-1*GapPips;
      
      if(AryIdx>=LotArySize){fOdLots=fOrderLots[LotArySize-1];}
      else                  {fOdLots=fOrderLots[AryIdx];}
         
         
      fOdOpPrice=fOdOpPrice+getOdMultiplier(fOdType)*GapPips*SymPoint;
      
         
      if( fTpPips!=0 )
         OdTpPrice=fOdOpPrice+getOdMultiplier(fOdType)*SymPoint*fTpPips;
      else
         OdTpPrice=0;
         
      if( fSlPips!=0 )
         OdSlPrice=fOdOpPrice-getOdMultiplier(fOdType)*SymPoint*fSlPips;
      else
         OdSlPrice=0;

      if( GlobalVariableCheck(EA_NAME_E+"TRADE_WAY") )
         fTradeWay=(ENUM_TRADE_WAY)(int)GlobalVariableGet(EA_NAME_E+"TRADE_WAY");
      else
         fTradeWay=TRADE_WAY_ONLY_LONG_AND_SHORT;
         
      sendOrder(fTradeWay,fSymbol,(ENUM_ORDER_TYPE)fOdType ,fOdLots,fMagicNumber,EA_NAME_E+"_"+fSymbol+fComment+"_"+getOrderType1Char((ENUM_ORDER_TYPE)fOdType)+(string)(fOrdersCnt+OdOpCnt),fSlPage,fOdOpPrice,OdTpPrice,OdSlPrice);
   }
   
   return(NormalizeDouble(fOpenPrice,SymDigits));
}


