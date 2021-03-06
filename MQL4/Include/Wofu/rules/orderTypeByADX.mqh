/*
#include <Wofu\\rules\\orderTypeByADX.mqh>
#include <Wofu\\userparms\\sample\\orderTypeByADX.mqh>

double  iADX(
   string       symbol,        // symbol -->fSymbol
   int          timeframe,     // timeframe -->fTf
   int          period,        // averaging period -->fPeriod
   int          applied_price, // applied price
   int          mode,          // line index -->(0 - MODE_MAIN, 1 - MODE_PLUSDI, 2 - MODE_MINUSDI).
   int          shift          // shift
   );

由最靠近的K棒(fKFr)開始往前找到前K根(fKTo) ,0:當根,1:前1根


fEntryType==0
   BUY :DI+>=DI-
   SELL:DI+< DI-

fEntryType==1
   BUY :DI+由下往上穿過DI-
   SELL:DI+由上往下穿過DI-

*/
#include <Wofu\\Common\\logger.mqh>
#include <Wofu\\enums\\MarketOrderType.mqh>
#include <Wofu\\Common\\getOppMaketOrderType.mqh>

MARKET_ORDER_TYPE orderTypeByADX
 (
   //--[ 內建指標參數 ]----------------------
   string fSymbol,
   ENUM_TIMEFRAMES fTf,
   int fPeriod, 
   ENUM_APPLIED_PRICE fPrice,
   //--[ 自有參數-常用 ]----------------------
   int fEntryType,            //採用模式
   int fKFr,                  //採用K棒數-起
   int fKTo,                  //採用K棒數-迄
   bool fOdOpp,               //結果反向
   bool fLogger,              //是否寫出紀錄
   //--[ 自有參數-特殊 ]----------------------
)
{
   MARKET_ORDER_TYPE fOdType=OD_NA;
   int    SymDigits=(int)SymbolInfoInteger(fSymbol,SYMBOL_DIGITS);
   double Main0=0,PlusDi0=0,MinusDi0=0;
   double Main1=0,PlusDi1=0,MinusDi1=0;
   //濾網模式
   if( fEntryType==0 )fKTo=fKFr;

   
   for(int i=fKFr;i<=fKTo;i++)
   {
      #ifdef __MQL4__
         Main0   = iADX(fSymbol,fTf,fPeriod,fPrice,MODE_MAIN   ,i);
         PlusDi0 = iADX(fSymbol,fTf,fPeriod,fPrice,MODE_PLUSDI ,i);
         MinusDi0= iADX(fSymbol,fTf,fPeriod,fPrice,MODE_MINUSDI,i);
         
         Main1   = iADX(fSymbol,fTf,fPeriod,fPrice,MODE_MAIN   ,i+1);
         PlusDi1 = iADX(fSymbol,fTf,fPeriod,fPrice,MODE_PLUSDI ,i+1);
         MinusDi1= iADX(fSymbol,fTf,fPeriod,fPrice,MODE_MINUSDI,i+1);
      #endif 
      #ifdef __MQL5__
         Main0   = iADXMQL4(fSymbol,fTf,fPeriod,fPrice,MODE_MAIN   ,i);
         PlusDi0 = iADXMQL4(fSymbol,fTf,fPeriod,fPrice,MODE_PLUSDI ,i);
         MinusDi0= iADXMQL4(fSymbol,fTf,fPeriod,fPrice,MODE_MINUSDI,i);
         
         Main1   = iADXMQL4(fSymbol,fTf,fPeriod,fPrice,MODE_MAIN   ,i+1);
         PlusDi1 = iADXMQL4(fSymbol,fTf,fPeriod,fPrice,MODE_PLUSDI ,i+1);
         MinusDi1= iADXMQL4(fSymbol,fTf,fPeriod,fPrice,MODE_MINUSDI,i+1);
      #endif 

      if( fEntryType==0 )  //濾網模式
      {
         if ( PlusDi0 > MinusDi0 )fOdType=OD_BUY;
         else
         if ( PlusDi0 < MinusDi0 )fOdType=OD_SELL;
      }
      else 
      if( fEntryType==1 )  //進場模式
      {
         if ( PlusDi0 > MinusDi0 && PlusDi1<= MinusDi1 )fOdType=OD_BUY;  
         else
         if ( PlusDi0 < MinusDi0 && PlusDi1>= MinusDi1 )fOdType=OD_SELL;
      }
      else
         return(OD_ERROR);
      
      if( fOdType==OD_BUY || fOdType==OD_SELL ) break;
   } //EOF for
   
   if(fLogger)logger(LOG_INFO,__FUNCTION__+": OdType="+EnumToString(fOdType)+",PlusDi0="+DoubleToStr(PlusDi0,SymDigits)+",MinusDi0="+DoubleToStr(MinusDi0,SymDigits));
   if( fOdOpp && fOdType>=0 )return(getOppMaketOrderType(fOdType));
   return(fOdType);
   if( fOdOpp && fOdType>=0 )return(getOppMaketOrderType(fOdType));
   return(fOdType);
    
}

