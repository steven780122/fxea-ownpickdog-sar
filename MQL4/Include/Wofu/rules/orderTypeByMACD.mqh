/*
double  iMACD(
   string       symbol,           // symbol -->fSymbol
   int          timeframe,        // timeframe -->fTf
   int          fast_ema_period,  // Fast EMA period -->fPeriodF
   int          slow_ema_period,  // Slow EMA period -->fPeriodS
   int          signal_period,    // Signal line period -->fPeriodL
   int          applied_price,    // applied price --> fPrice
   int          mode,             // line index -->  (0-MODE_MAIN 灰柱, 1-MODE_SIGNAL 紅線).
   int          shift             // shift
   );

由最靠近的K棒(fKFr)開始往前找到前K根(fKTo) ,0:當根,1:前1根

fEntryType==0
   BUY :MAIN>=0,
   SELL:MAIN<0
fEntryType==1
   BUY :MAIN由下往上穿過0軸,
   SELL:MAIN由上往下穿過0軸

*/
#include <Wofu\\enums\\MarketOrderType.mqh>
#include <Wofu\\enums\\EntryWay.mqh>
#include <Wofu\\Common\\getOppMaketOrderType.mqh>
#include <Wofu\\Common\\logger.mqh>

MARKET_ORDER_TYPE orderTypeByMACD
(
   //--[ 內建指標參數 ]----------------------
   string fSymbol,
   ENUM_TIMEFRAMES fTf,
   int fPeriodF,
   int fPeriodS,
   int fPeriodL,
   ENUM_APPLIED_PRICE fPrice,
   //--[ 自有參數-常用 ]----------------------
   int fEntryType,            //採用模式
   ENUM_ENTRY_WAY fEntryWay,  //進場模式-進入方向(SELL單與BUY相反) //未使用
   int fKFr,                  //採用K棒數-起
   int fKTo,                  //採用K棒數-迄
   bool fPreK,                //與前K的值比對 //未使用
   bool fOdOpp,               //結果反向
   bool fLogger,              //是否寫出紀錄
   //--[ 自有參數-特殊 ]----------------------
)
{
   
   MARKET_ORDER_TYPE fOdType=-1;
   double FLine0=0,FLine1=0; 
   int    SymDigits=(int)SymbolInfoInteger(fSymbol,SYMBOL_DIGITS);
   //double SLine0,,SLine1;
   if( fEntryType==0 )fKTo=fKFr;

   for(int i=fKFr;i<=fKTo;i++)
   {
      #ifdef __MQL4__
         FLine0=iMACD(fSymbol,fTf,fPeriodF,fPeriodS,fPeriodL,fPrice,MODE_MAIN,i);   //快線
         FLine1=iMACD(fSymbol,fTf,fPeriodF,fPeriodS,fPeriodL,fPrice,MODE_MAIN,i+1); //快線
         //SLine0=iMACD(fSymbol,fTf,fPeriodF,fPeriodS,fPeriodL,fPrice,MODE_SIGNAL,i);   //慢線
         //SLine1=iMACD(fSymbol,fTf,fPeriodF,fPeriodS,fPeriodL,fPrice,MODE_SIGNAL,i+1); //慢線
      #endif 
      
      #ifdef __MQL5__
         FLine0=iMACDMQL4(fSymbol,fTf,fPeriodF,fPeriodS,fPeriodL,fPrice,MODE_MAIN,i);   //快線
         FLine1=iMACDMQL4(fSymbol,fTf,fPeriodF,fPeriodS,fPeriodL,fPrice,MODE_MAIN,i+1); //快線
         //SLine0=iMACDMQL4(fSymbol,fTf,fPeriodF,fPeriodS,fPeriodL,fPrice,MODE_SIGNAL,i);   //慢線
         //SLine1=iMACDMQL4(fSymbol,fTf,fPeriodF,fPeriodS,fPeriodL,fPrice,MODE_SIGNAL,i+1); //慢線
      #endif  
      
      if( fEntryType==0 )
      {
              if(FLine0>0 )fOdType=OD_BUY;  
         else if(FLine0<0 )fOdType=OD_SELL; 
         else fOdType=OD_NA;
      }
      else
      if( fEntryType==1 )
      {
              if(FLine0>0 && FLine1<=0 )fOdType=OD_BUY;  
         else if(FLine0<0 && FLine1>=0 )fOdType=OD_SELL; 
         else fOdType=OD_NA;
      }
      else
         return(OD_ERROR);
      
      //Logger(LOG_DEBUG,__FUNCTION__+": KD ("+(string)i+") OdType="+(string)fOdType+",FLine0="+DoubleToStr(FLine0,Digits)+",SLine0="+DoubleToStr(SLine0,Digits));
      if( fOdType==OD_BUY || fOdType==OD_SELL ) break;
   }

   if(fLogger)logger(LOG_INFO,__FUNCTION__+": 判斷結果="+EnumToString(fOdType)+",柱狀[0]="+DoubleToStr(FLine0,SymDigits)+",柱狀[1]="+DoubleToStr(FLine1,SymDigits));
   if( fOdOpp && fOdType>=0 )return(getOppMaketOrderType(fOdType));
   return(fOdType);
}


/*
E哥您好，

關於MACD作為濾網或是進出場的判別方式，因個人不懂程式語言，故以主觀的判斷方法提供給您參考。
判別方式一：

以柱體在0軸上方時判定為多方；在0軸下方時判定為空方。

判別方式二：

柱體在0軸下方時，若柱體較前一根向0軸內縮時，則判定多方。

反之當柱體在0軸上方時，若柱體較前一根向0軸內縮時，則判定為空方。

判別方式三：

MACD線在柱體外緣的上方時，判定為空方。

反之MACD現在柱體外緣的下方時，判定為多方。

如圖1號位置：可解釋

1.主線在柱體外緣的上方，判定空方

2.柱體在0軸以下，判定空方

圖中2號位置則可解釋：

1.主線在柱體外緣的下方，判定多方

2.柱體由0軸下，慢慢往0軸內縮，判定多方

3.柱體翻越至0軸上方，判定多方

以上為個人在MACD的使用，後續就辛苦E哥了，感謝您
*/