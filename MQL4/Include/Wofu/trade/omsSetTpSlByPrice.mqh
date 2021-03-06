#include <Wofu\\common\\logTradeError.mqh>

//fKeepCloser=
void omsSetTpSlByPrice
(
   int fTicket,
   double fTpPrice,        //-1 不更動
   double fSlPrice,        //-1 不更動
   int fSetCount=3,        //設定的次數(設定失敗時會重試)
   int fSleepMSeconds=30,  //重試間隔時間(微秒)
   color fColor=clrNONE    //標示顏色
)
{
   if( fTicket<0 )return;

   int    SymDigits=(int)SymbolInfoInteger(OrderSymbol(),SYMBOL_DIGITS);
   
   double TpPriceNew=NormalizeDouble(fTpPrice,SymDigits);
   double TpPriceOld=NormalizeDouble(OrderTakeProfit(),SymDigits);
   double SlPriceNew=NormalizeDouble(fSlPrice,SymDigits);
   double SlPriceOld=NormalizeDouble(OrderStopLoss(),SymDigits);
   if( fTpPrice==-1 )TpPriceNew=TpPriceOld;
   if( fSlPrice==-1 )SlPriceNew=SlPriceOld;
   
   if(TpPriceOld!=TpPriceNew || SlPriceOld!=SlPriceNew)
   {
      int setCnt=1;
      while( setCnt<=fSetCount && !OrderModify(OrderTicket(),OrderOpenPrice(),SlPriceNew,TpPriceNew,0, fColor ) )
      {
         if(setCnt==1)logTradeError(__FUNCTION__,fTicket,GetLastError(),"OrderModify TP Error");
         Sleep(fSleepMSeconds);
         setCnt++;
      } //EOF while     
   }
}