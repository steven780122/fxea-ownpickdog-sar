#include <Wofu\\common\\logTradeError.mqh>

//fKeepCloser=
void omsSetTpByPrice
(
   int fTicket,
   double fTpPrice,
   int fSetCount=3,        //設定的次數(設定失敗時會重試)
   int fSleepMSeconds=30,  //重試間隔時間(微秒)
   color fColor=clrNONE    //標示顏色
)
{
   if( fTpPrice<0 || fTicket<0 )return;

   int    SymDigits=(int)SymbolInfoInteger(OrderSymbol(),SYMBOL_DIGITS);
   double TpPriceNew=NormalizeDouble(fTpPrice,SymDigits);
   double TpPriceOld=NormalizeDouble(OrderTakeProfit(),SymDigits);
   if(TpPriceOld != TpPriceNew)
   {
      int setCnt=1;
      while( setCnt<=fSetCount && !OrderModify(OrderTicket(),OrderOpenPrice(),OrderStopLoss(),TpPriceNew,0, fColor ) )
      {
         if(setCnt==1)logTradeError(__FUNCTION__,fTicket,GetLastError(),"OrderModify TP Error");
         Sleep(fSleepMSeconds);
         setCnt++;
      } //EOF while     
   }
}