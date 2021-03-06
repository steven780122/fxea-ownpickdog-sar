#include <Wofu\\trade\\selectOpOrderByTicketNo.mqh>
#include <Wofu\\trade\\omsSetSlByPrice.mqh>
#include <Wofu\\rules\\getPriceByZigZag.mqh>
#include <Wofu\\common\\getOdMultiplier.mqh>
#include <Wofu\\common\\logTradeError.mqh>
//#include <Wofu\\trade\\omsSetSlByZigZag.mqh>
void setSlByZigZag
(

   //--[ 內建指標參數 ]----------------------
   //string fSymbol,
   ENUM_TIMEFRAMES fTf,
   int fDepth,
   int fDeviation,
   int fBackStep,
   //--[ 自有參數-常用 ]----------------------
   //ENTRY_TYPE_ZIGZAG fEntryType,
   int fKFr,
   int fKTo,
   //bool fLogger,              //是否寫出紀錄
   //--[ 自有參數-特殊 ]----------------------
   int fCntStart,       //第幾個開始算，通常第1個因為未確定則不使用，需要設置成2
   int fSlGapPips,
      
   int fTicket,
   bool fKeepCloser=false,
   bool fSelectBeforeSet=true
)export
{
   logger(LOG_INFO,"SlPriceNew---");
   if(fSelectBeforeSet)
      if( fTicket<0 || !selectOpOrderByTicketNo(fTicket))return;

   ENTRY_TYPE_ZIGZAG fEtZigzag;
   if(OrderType()==ORDER_TYPE_BUY)fEtZigzag=ET_ZIGZAG_FIND_LOW;
   else
   if(OrderType()==ORDER_TYPE_SELL)fEtZigzag=ET_ZIGZAG_FIND_HIGH;
   else
      return;
   
   double SymPoint=SymbolInfoDouble(OrderSymbol(),SYMBOL_POINT);
   int    SymDigits=(int)SymbolInfoInteger(OrderSymbol(),SYMBOL_DIGITS);
   double SlPriceNew=getPriceByZigZag(OrderSymbol(),fTf,fDepth,fDeviation,fBackStep,fEtZigzag,fKFr,fKTo,false,fCntStart);
   if( SlPriceNew<=0)return;
   
   if( fSlGapPips!=0 )
      SlPriceNew=SlPriceNew-getOdMultiplier(OrderType())*fSlGapPips*SymPoint;

   omsSetSlByPrice(fTicket,SlPriceNew,fKeepCloser);
   
}


 //setSlByZigZag(fTf,fDepth,fDeviation,fBackStep,fKFr,fKTo,fCntStart,fTicket, fSlGapPips,fKeepCloser,fSelectBeforeSet)