/*
#include <Wofu\\rules\\TrendTypeByADX.mqh>
#include <Wofu\\userparms\\sample\\TrendTypeByADX.UserParm.mqh>

double  iADX(
   string       symbol,        // symbol -->fSymbol
   int          timeframe,     // timeframe -->fTf
   int          period,        // averaging period -->fPeriod
   int          applied_price, // applied price
   int          mode,          // line index -->(0 - MODE_MAIN, 1 - MODE_PLUSDI, 2 - MODE_MINUSDI).
   int          shift          // shift
   );


由最靠近的K棒(fKFr)開始往前找到前K根(fKTo) ,0:當根,1:前1根


   趨勢盤:當ADX>趨勢分界
   盤整盤:當ADX<盤整分界
   其他則是趨勢不明
   


//未寫
http://www.infinmarkets.com/zh_TW/ntx-indicators/adx
ADX是否在DI+,DI-同邊(fMustSide)判斷關閉時
ADX是否在DI+,DI-同邊(fMustSide)判斷開啟時
    
 
 */

#include <Wofu\\enums\\MarketTrendType.mqh>
MARKET_TREND_TYPE trendTypeByADX
(
   //--[ 內建指標參數 ]----------------------
   string fSymbol,
   ENUM_TIMEFRAMES fTf,
   int fPeriod, 
   ENUM_APPLIED_PRICE fPrice,
   //--[ 自有指標參數 ]----------------------
   double fPowerOnBase,  //以上趨勢分界
   double fPowerOffBase, //以下盤整分界
   int  fEntryType,
   int  fKFr=1,
   int  fKTo=1,
)
{
   MARKET_TREND_TYPE fOdType=MARKET_NA;
   double Main0;
   //double Main0,PlusDi0,MinusDi0;
   //double Main1,PlusDi1,MinusDi1;
   
   //for(int i=fKTo;i>=fKFr;i--)
   for(int i=fKFr;i<=fKTo;i++)
   {
      #ifdef __MQL4__
         Main0   = iADX(fSymbol,fTf,fPeriod,fPrice,MODE_MAIN   ,i);
         //PlusDi0 = iADX(fSymbol,fTf,fPeriod,fPrice,MODE_PLUSDI ,i);
         //MinusDi0= iADX(fSymbol,fTf,fPeriod,fPrice,MODE_MINUSDI,i);
         
         //Main1   = iADX(fSymbol,fTf,fPeriod,fPrice,MODE_MAIN   ,i+1);
         //PlusDi1 = iADX(fSymbol,fTf,fPeriod,fPrice,MODE_PLUSDI ,i+1);
         //MinusDi1= iADX(fSymbol,fTf,fPeriod,fPrice,MODE_MINUSDI,i+1);
      #endif 
      #ifdef __MQL5__
         Main0   = iADXMQL4(fSymbol,fTf,fPeriod,fPrice,MODE_MAIN   ,i);
         //PlusDi0 = iADXMQL4(fSymbol,fTf,fPeriod,fPrice,MODE_PLUSDI ,i);
         //MinusDi0= iADXMQL4(fSymbol,fTf,fPeriod,fPrice,MODE_MINUSDI,i);
         
         //Main1   = iADXMQL4(fSymbol,fTf,fPeriod,fPrice,MODE_MAIN   ,i+1);
         //PlusDi1 = iADXMQL4(fSymbol,fTf,fPeriod,fPrice,MODE_PLUSDI ,i+1);
         //MinusDi1= iADXMQL4(fSymbol,fTf,fPeriod,fPrice,MODE_MINUSDI,i+1);
      #endif 

      if ( fEntryType == 0 )
      {
         if ( Main0 > fPowerOnBase )
            fOdType=MARKET_TREND;
         else
         if ( Main0 < fPowerOffBase )
            fOdType=MARKET_CORRECTION;
         else
            fOdType=MARKET_NA;
       }
       else
         return(MARKET_ERROR);
         
       if( fOdType==MARKET_TREND || fOdType==MARKET_CORRECTION ) break;
   } //EOF for
   #ifdef EA_51AREA
      Logger(LOG_DEBUG,__FUNCTION__+": OdType="+(string)fOdType+",Main0="+DoubleToStr(Main0,Digits));
   #endif
   
   return(fOdType);
    
}

