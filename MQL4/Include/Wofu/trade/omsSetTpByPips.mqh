#include <Wofu\\common\\getOdMultiplier.mqh>
#include <Wofu\\common\\logTradeError.mqh>
void omsSetTpByPips(int fTicket,int fTpPips=-1) 
{
   if( fTpPips<0 || fTicket<0 )return;
  
   double SymPoint=SymbolInfoDouble(OrderSymbol(),SYMBOL_POINT);
   int    SymDigits=(int)SymbolInfoInteger(OrderSymbol(),SYMBOL_DIGITS);
   double TpPriceNew=0,TpPriceOld=0;

   if(fTpPips==0)
      { TpPriceNew=0; }
   else
      { TpPriceNew=OrderOpenPrice()+getOdMultiplier(OrderType())*fTpPips*SymPoint; }   // Steven:透過getOdMultiplier就可以直接知道要設的方向了!!!
      
   TpPriceNew=NormalizeDouble(TpPriceNew,SymDigits);
   TpPriceOld=NormalizeDouble(OrderTakeProfit(),SymDigits);
   //跟訂單的TP價位不同才做更改
   if( TpPriceNew!= TpPriceOld )
   {
     int setCnt=1;
     while( setCnt<=3 && !OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),TpPriceNew,0, clrYellow ) )
     {
         if(setCnt==1)logTradeError(__FUNCTION__,fTicket,GetLastError(),"OrderModify SL Error! TpPriceOld="+DoubleToString(TpPriceOld,SymDigits)+"TpPriceNew="+DoubleToString(TpPriceNew,SymDigits));
         setCnt++;
     } //EOF while
   }//EOF if(TpPrice!=NormalizeDouble(OrderTakeProfit(),SymDigits))
}
            
/*

bool  OrderModify(
   int        ticket,      // ticket
   double     price,       // price
   double     stoploss,    // stop loss
   double     takeprofit,  // take profit
   datetime   expiration,  // expiration
   color      arrow_color  // color
   );


if( TpPrice>0 && OrderProfit()>0 && 
   ( ( OrderType()==ORDER_TYPE_BUY  && NormalizeDouble(SymbolInfoDouble(OrderSymbol(), SYMBOL_BID),SymDigits)>=TpPrice ) ||
     ( OrderType()==ORDER_TYPE_SELL && NormalizeDouble(SymbolInfoDouble(OrderSymbol(), SYMBOL_ASK),SymDigits)<=TpPrice )   ))
   { 
      if ( !OrderClose(OrderTicket(),OrderLots(),OrderClosePrice(),SlPage,CLR_NONE) ) 
          logger(LOG_WARN,"OrderTicket()="+IntegerToString(OrderTicket())+",CloseAllOrder ErrorCode="+IntegerToString(GetLastError()));
   }

*/