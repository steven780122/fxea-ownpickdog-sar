#include <Wofu\\common\\logTradeError.mqh>

//fKeepCloser=
void omsSetSlByPrice
(
   int fTicket,
   double fSlPrice,
   bool fKeepCloser=false, //true:只會越拉越近
   int fSetCount=3,        //設定的次數(設定失敗時會重試)
   int fSleepMSeconds=30,  //重試間隔時間(微秒)
   color fColor=clrNONE    //標示顏色
)
{
   if( fSlPrice<0 || fTicket<0 )return;

   int    SymDigits=(int)SymbolInfoInteger(OrderSymbol(),SYMBOL_DIGITS);
   double SlPriceNew=0,SlPriceOld=0;

   SlPriceNew=NormalizeDouble(fSlPrice,SymDigits);
   SlPriceOld=NormalizeDouble(OrderStopLoss(),SymDigits);
   
   if( ( !fKeepCloser && SlPriceNew!=SlPriceOld ) ||
       (  fKeepCloser && OrderType()==ORDER_TYPE_BUY  && ( SlPriceOld==0 || SlPriceNew>SlPriceOld ) ) ||
       (  fKeepCloser && OrderType()==ORDER_TYPE_SELL && ( SlPriceOld==0 || SlPriceNew<SlPriceOld ) )
     )
   {  
      int setCnt=1;
      while( setCnt<=fSetCount && !OrderModify(OrderTicket(),OrderOpenPrice(),SlPriceNew,OrderTakeProfit(),0, fColor ) )
      {
         if(setCnt==1)logTradeError(__FUNCTION__,fTicket,GetLastError(),"OrderModify SL Error");
         Sleep(fSleepMSeconds);
         setCnt++;
      } //EOF while     
  }
}