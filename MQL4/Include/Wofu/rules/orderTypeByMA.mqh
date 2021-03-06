/*
#include <Wofu\\rules\\orderTypeByMA.mqh>
#include <Wofu\\userparms\\sample\\orderTypeByMA.mqh>

double  iMA(
   string       symbol,           // symbol
   int          timeframe,        // timeframe
   int          ma_period,        // MA averaging period
   int          ma_shift,         // MA shift
   int          ma_method,        // averaging method ENUM_MA_METHOD
   int          applied_price,    // applied price ENUM_APPLIED_PRICE
   int          shift             // shift
   );

由最靠近的K棒(fKFr)開始往前找到前K根(fKTo) ,0:當根,1:前1根

fEntryType==0
   當 自訂BUY基準值 > 自訂SELL基準值
      BUY :RSI> 自訂BUY基準值 
      SELL:RSI< 自訂SELL基準值
      落在自訂BUY基準值~自訂SELL基準值則無方向

   當 自訂BUY基準值 <= 自訂SELL基準值
      BUY :RSI> 自訂SELL基準值 或 
      SELL:RSI< 自訂BUY基準值 或
      落在 自訂BUY基準值~自訂SELL基準值則
      找到是從哪一邊進入 區間(自訂BUY基準值~自訂SELL基準值)
         BUY :由下而上穿過 自訂BUY 基準值
         SELL:由上而下穿過 自訂SELL基準值
   fEntryWay不影響結果

fEntryType==1
   當fEntryWay==往上進BUY(0)
      BUY :由下而上穿過 自訂BUY 基準值
      SELL:由上而下穿過 自訂SELL基準值
   當fEntryWay==往下進BUY(1)
      BUY :由上而下穿過 自訂BUY 基準值
      SELL:由下而上穿過 自訂SELL基準值

*/
 
#include <Wofu\\enums\\MarketOrderType.mqh>
#include <Wofu\\enums\\EntryWay.mqh>
#include <Wofu\\Common\\getOppMaketOrderType.mqh>
#include <Wofu\\Common\\getOppOrderType.mqh>
#include <Wofu\\Common\\logger.mqh>
#include <Wofu\\rules\\rulesParmCommon.mqh>
struct rulesParmMa
{
   string symbol;
   ENUM_TIMEFRAMES tf;
   int maPeriodF;
   int maPeriodS;
   int maShiftF;
   int maShiftS;
   ENUM_MA_METHOD maMethod;
   ENUM_APPLIED_PRICE appPrice;
};

int orderTypeByMA
(
   rulesParmMa&    rps,
   rulesParmCommon& rpc
)
{
   int resultOrderType=-1;
   double FLine0=0,FLine1=0,SLine0=0,SLine1=0;
   int    SymDigits=(int)SymbolInfoInteger(rps.symbol,SYMBOL_DIGITS);
   //濾網模式
   if( rpc.entryType==0 )rpc.kBarTo=rpc.kBarFr;

   
   for(int i=rpc.kBarFr;i<=rpc.kBarTo;i++)
   {
      #ifdef __MQL4__
         FLine0=iMA(rps.symbol,rps.tf,rps.maPeriodF,rps.maShiftF,rps.maMethod,rps.appPrice,i);   //快線
         FLine1=iMA(rps.symbol,rps.tf,rps.maPeriodF,rps.maShiftF,rps.maMethod,rps.appPrice,i+1); //快線

         SLine0=iMA(rps.symbol,rps.tf,rps.maPeriodS,rps.maShiftS,rps.maMethod,rps.appPrice,i);   //慢線
         SLine1=iMA(rps.symbol,rps.tf,rps.maPeriodS,rps.maShiftS,rps.maMethod,rps.appPrice,i+1); //慢線
      #endif 
      #ifdef __MQL5__
         FLine0=iMAMQL4(rps.symbol,rps.tf,rps.maPeriodF,rps.maShiftF,rps.maMethod,rps.appPrice,i);   //快線
         FLine1=iMAMQL4(rps.symbol,rps.tf,rps.maPeriodF,rps.maShiftF,rps.maMethod,rps.appPrice,i+1); //快線

         SLine0=iMAMQL4(rps.symbol,rps.tf,rps.maPeriodS,rps.maShiftS,rps.maMethod,rps.appPrice,i);   //慢線
         SLine1=iMAMQL4(rps.symbol,rps.tf,rps.maPeriodS,rps.maShiftS,rps.maMethod,rps.appPrice,i+1); //慢線
      #endif 

      if( rpc.entryType==0 )  
      {
              if(FLine0 > SLine0 )resultOrderType=ORDER_TYPE_BUY;  //黃金交叉
         else if(FLine0 < SLine0 )resultOrderType=ORDER_TYPE_SELL; //死亡交叉
         else resultOrderType=-1;      

      }
      else 
      if( rpc.entryType==1 )  
      {
              if(FLine1 <= SLine1 && FLine0 > SLine0 )resultOrderType=ORDER_TYPE_BUY;  //黃金交叉
         else if(FLine1 >= SLine1 && FLine0 < SLine0 )resultOrderType=ORDER_TYPE_SELL; //死亡交叉
         else resultOrderType=-1;
      }
      else
         return(-999);
      
      if( resultOrderType==ORDER_TYPE_BUY || resultOrderType==ORDER_TYPE_SELL ) break;
   } //EOF for
   

   if( rpc.doLogger )logger(LOG_INFO,__FUNCTION__+": 判斷結果="+( (resultOrderType>=0)?EnumToString((ENUM_ORDER_TYPE)resultOrderType):(string)resultOrderType )+",快線="+DoubleToStr(FLine0,SymDigits)+",慢線="+DoubleToStr(SLine0,SymDigits));
   if( rpc.resultOpp && resultOrderType>=0 )return(getOppOrderType((ENUM_ORDER_TYPE)resultOrderType));
   return(resultOrderType);
    
}

ENUM_MARKET_ORDER_TYPE orderTypeByMA
(
   //--[ 內建指標參數 ]----------------------
   string fSymbol,
   ENUM_TIMEFRAMES fTf,
   int fMaPeriodF,
   int fMaPeriodS,
   int fMaShiftF,
   int fMaShiftS,
   ENUM_MA_METHOD fMaMethod,
   ENUM_APPLIED_PRICE fPrice,
   //--[ 自有指標參數 ]----------------------
   int fEntryType,            //採用模式
   ENUM_ENTRY_WAY fEntryWay,  //進場模式-進入方向(SELL單與BUY相反)
   int fKFr,                  //採用K棒數-起
   int fKTo,                  //採用K棒數-迄
   bool fPreK,                //與前K的值比對
   bool fOdOpp,               //結果反向
   bool fLogger               //是否寫出紀錄
   //--[ 自有參數-特殊 ]----------------------
)
{
   ENUM_MARKET_ORDER_TYPE resultOrderType=OD_NA;
   double FLine0=0,FLine1=0,SLine0=0,SLine1=0;
   int    SymDigits=(int)SymbolInfoInteger(fSymbol,SYMBOL_DIGITS);
   //濾網模式
   if( fEntryType==0 )fKTo=fKFr;

   
   for(int i=fKFr;i<=fKTo;i++)
   {
      #ifdef __MQL4__
         FLine0=iMA(fSymbol,fTf,fMaPeriodF,fMaShiftF,fMaMethod,fPrice,i);   //快線
         FLine1=iMA(fSymbol,fTf,fMaPeriodF,fMaShiftF,fMaMethod,fPrice,i+1); //快線

         SLine0=iMA(fSymbol,fTf,fMaPeriodS,fMaShiftS,fMaMethod,fPrice,i);   //慢線
         SLine1=iMA(fSymbol,fTf,fMaPeriodS,fMaShiftS,fMaMethod,fPrice,i+1); //慢線
      #endif 
      #ifdef __MQL5__
         FLine0=iMAMQL4(fSymbol,fTf,fMaPeriodF,fMaShiftF,fMaMethod,fPrice,i);   //快線
         FLine1=iMAMQL4(fSymbol,fTf,fMaPeriodF,fMaShiftF,fMaMethod,fPrice,i+1); //快線

         SLine0=iMAMQL4(fSymbol,fTf,fMaPeriodS,fMaShiftS,fMaMethod,fPrice,i);   //慢線
         SLine1=iMAMQL4(fSymbol,fTf,fMaPeriodS,fMaShiftS,fMaMethod,fPrice,i+1); //慢線
      #endif 

      if( fEntryType==0 )  
      {
              if(FLine0 > SLine0 )resultOrderType=OD_BUY;  //黃金交叉
         else if(FLine0 < SLine0 )resultOrderType=OD_SELL; //死亡交叉
         else resultOrderType=OD_NA;      

      }
      else 
      if( fEntryType==1 )  
      {
              if(FLine1 <= SLine1 && FLine0 > SLine0 )resultOrderType=OD_BUY;  //黃金交叉
         else if(FLine1 >= SLine1 && FLine0 < SLine0 )resultOrderType=OD_SELL; //死亡交叉
         else resultOrderType=OD_NA;
      }
      else
         return(OD_ERROR);
      
      if( resultOrderType==OD_BUY || resultOrderType==OD_SELL ) break;
   } //EOF for
   

   if(fLogger)logger(LOG_INFO,__FUNCTION__+": 判斷結果="+EnumToString(resultOrderType)+",快線="+DoubleToStr(FLine0,SymDigits)+",慢線="+DoubleToStr(SLine0,SymDigits));
   if( fOdOpp && resultOrderType>=0 )return(getOppMaketOrderType(resultOrderType));
   return(resultOrderType);
    
}




/*
      #ifdef __MQL5__
         double IndArray[];
         ArraySetAsSeries(IndArray,true);
         int handle;
             
         handle=iMA(fSymbol,fTf,fMaPeriodF,fMaShiftF,fMaMethod,fPrice);
         if(handle==INVALID_HANDLE)return(-1);
         ArrayResize(IndArray,0);
         if(CopyBuffer(handle,0,i,2,IndArray)<0)return(-1);
         FLine0 = IndArray[0];
         FLine1 = IndArray[1];
      
         handle=iMA(fSymbol,fTf,fMaPeriodS,fMaShiftS,fMaMethod,fPrice);
         if(handle==INVALID_HANDLE)return(-1);
         ArrayResize(IndArray,0);
         if(CopyBuffer(handle,0,i,2,IndArray)<0)return(-1);
         SLine0 = IndArray[0];
         SLine1 = IndArray[1];

         
      #endif   
*/