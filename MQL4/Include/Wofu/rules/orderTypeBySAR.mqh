/*
#include <Wofu\\rules\\orderTypeBySAR.mqh>
#include <Wofu\\userparms\\sample\\orderTypeBySAR.mqh>

double  iSAR(
   string       symbol,            // symbol
   int          timeframe,         // timeframe
   double       step,              // price increment step - acceleration factor
   double       maximum,           // maximum value of step
   int          shift              // shift
   );

由最靠近的K棒(fKFr)開始往前找到前K根(fKTo) ,0:當根,1:前1根
fEntryType==0
   BUY :SAR<收盤價
   SELL:SAR>收盤價
fEntryType==1 
   BUY :SAR由上往下穿過收盤價(SAR[0]<KC[0] && SAR[0]>=KC[0]
   SELL:SAR由下往上穿過收盤價(SAR[0]>KC[0] && SAR[0]<=KC[0]
   
*/

#include <Wofu\\enums\\MarketOrderType.mqh>
#include <Wofu\\enums\\EntryWay.mqh>
#include <Wofu\\Common\\getOppMaketOrderType.mqh>
#include <Wofu\\Common\\getOppOrderType.mqh>

#include <Wofu\\Common\\logger.mqh>
#include <Wofu\\rules\\rulesParmCommon.mqh>

struct rulesParmSar
{
   //--[ 內建指標參數 ]----------------------
   string symbol; 
   ENUM_TIMEFRAMES tf;
   double sarStep;
   double sarMax;
};
int orderTypeBySAR
( 
   rulesParmSar&    rpp,
   rulesParmCommon& rps
)
{

   int fOdType=-1;
   double FLine0=-1,KC0=-1,FLine1=-1,KC1=-1;
   int    SymDigits=(int)SymbolInfoInteger(rpp.symbol,SYMBOL_DIGITS);

   for(int i=rps.kBarFr;i<=rps.kBarTo;i++)
   {
      #ifdef __MQL4__
         //SAR
         FLine0=iSAR(rpp.symbol,rpp.tf,rpp.sarStep,rpp.sarMax,i);
         FLine1=iSAR(rpp.symbol,rpp.tf,rpp.sarStep,rpp.sarMax,i+1); //K快線
         //收盤價
         KC0=iClose(rpp.symbol,rpp.tf,i);
         KC1=iClose(rpp.symbol,rpp.tf,i+1);
      #endif 
      
      #ifdef __MQL5__
         //SAR
         FLine0=iSARMQ4(rpp.symbol,rpp.tf,rpp.sarStep,rpp.sarMax,i);
         FLine1=iSARMQ4(rpp.symbol,rpp.tf,rpp.sarStep,rpp.sarMax,i+1); //K快線
         //收盤價
         KC0=iCloseMQ4(rpp.symbol,rpp.tf,i);
         KC1=iCloseMQ4(rpp.symbol,rpp.tf,i+1);
      #endif   
   
      if( rps.entryType==0 )  
      {
              if( FLine0<=KC0 )fOdType=ORDER_TYPE_BUY;  
         else if( FLine0> KC0 )fOdType=ORDER_TYPE_SELL; 
         else fOdType=-1;           
      }
      else 
      if( rps.entryType==1 )  
      {
              if( FLine0<KC0 && FLine1>=KC1 )fOdType=ORDER_TYPE_BUY;  
         else if( FLine0>KC0 && FLine1<=KC1 )fOdType=ORDER_TYPE_SELL; 
         else fOdType=-1;         
      }
      else
         return(OD_ERROR);
         
      if( fOdType==ORDER_TYPE_BUY || fOdType==ORDER_TYPE_SELL ) break;
   }
   
   if( rps.doLogger )logger(LOG_INFO,__FUNCTION__+": 判斷結果="+( (fOdType>=0)?EnumToString((ENUM_ORDER_TYPE)fOdType):(string)fOdType )+",SAR指標="+DoubleToStr(FLine0,SymDigits)+(DoubleToStr(FLine0,SymDigits)>DoubleToStr(KC0,SymDigits)?">":"<")+"收盤="+DoubleToStr(KC0,SymDigits));
   if( rps.resultOpp && fOdType>=0 )return(getOppOrderType((ENUM_ORDER_TYPE)fOdType));
   return(fOdType);
}



ENUM_MARKET_ORDER_TYPE orderTypeBySAR
( 
   //--[ 內建指標參數 ]----------------------
   string fSymbol, 
   ENUM_TIMEFRAMES fTf, 
   double fSarStep, 
   double fSarMax, 
   //--[ 自有參數-常用 ]----------------------
   int fEntryType,            //採用模式
   //ENUM_ENTRY_WAY fEntryWay,  //進場模式-進入方向(SELL單與BUY相反)
   int fKFr,                  //採用K棒數-起
   int fKTo,                  //採用K棒數-迄
   bool fPreK,                //與前K的值比對 //未使用
   bool fOdOpp,               //結果反向
   bool fLogger               //是否寫出紀錄
)
{

   ENUM_MARKET_ORDER_TYPE fOdType=OD_NA;
   double FLine0=-1,KC0=-1,FLine1=-1,KC1=-1;
   int    SymDigits=(int)SymbolInfoInteger(fSymbol,SYMBOL_DIGITS);

   for(int i=fKFr;i<=fKTo;i++)
   {
      #ifdef __MQL4__
         //SAR
         FLine0=iSAR(fSymbol,fTf,fSarStep,fSarMax,i);
         FLine1=iSAR(fSymbol,fTf,fSarStep,fSarMax,i+1); //K快線
         //收盤價
         KC0=iClose(fSymbol,fTf,i);
         KC1=iClose(fSymbol,fTf,i+1);
      #endif 
      
      #ifdef __MQL5__
         //SAR
         FLine0=iSARMQ4(fSymbol,fTf,fSarStep,fSarMax,i);
         FLine1=iSARMQ4(fSymbol,fTf,fSarStep,fSarMax,i+1); //K快線
         //收盤價
         KC0=iCloseMQ4(fSymbol,fTf,i);
         KC1=iCloseMQ4(fSymbol,fTf,i+1);
      #endif   
   
      if( fEntryType==0 )  
      {
              if( FLine0<=KC0 )fOdType=OD_BUY;  
         else if( FLine0> KC0 )fOdType=OD_SELL; 
         else fOdType=OD_NA;           
      }
      else 
      if( fEntryType==1 )  
      {
              if( FLine0<KC0 && FLine1>=KC1 )fOdType=OD_BUY;  
         else if( FLine0>KC0 && FLine1<=KC1 )fOdType=OD_SELL; 
         else fOdType=OD_NA;         
      }
      else
         return(OD_ERROR);
         
      if( fOdType==OD_BUY || fOdType==OD_SELL ) break;
   }
   
   if(fLogger)logger(LOG_INFO,__FUNCTION__+": 判斷結果="+EnumToString(fOdType)+",SAR指標="+DoubleToStr(FLine0,SymDigits)+",收盤="+DoubleToStr(KC0,SymDigits));
   if( fOdOpp && fOdType>=0 )return(getOppMaketOrderType(fOdType));
   return(fOdType);
}






/*
   #ifdef __MQL5__
      double IndArray[];
      ArraySetAsSeries(IndArray,true);
      if(CopyClose(fSymbol,fTf, fShift, 1, IndArray)<0)return(-1);
      KC0=IndArray[0];   
   
      int handle=iSAR(fSymbol,fTf,fSarStep,fSarMax);
      if(handle==INVALID_HANDLE)return(-1);
      ArrayResize(IndArray,0);
      if(CopyBuffer(handle,0,fShift,1,IndArray)<0)return(-1);
      SAR0 = IndArray[0];
   
   #endif 
*/   
   
   
