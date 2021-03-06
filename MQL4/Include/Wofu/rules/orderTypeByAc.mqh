/*
#include <Wofu\\rules\\orderTypeByMA.mqh>
#include <Wofu\\userparms\\sample\\orderTypeByMA.mqh>

double  iAC(
   string       symbol,     // symbol
   int          timeframe,  // timeframe
   int          shift       // shift
   );

由最靠近的K棒(fKFr)開始往前找到前K根(fKTo) ,0:當根,1:前1根

fEntryType==0
   藍色顎線(jaw)
   紅色齒線(teeth)
   綠色唇線(lip)

   BUY :綠>紅>藍 
   SELL:綠<紅<藍
   
   fEntryWay不影響結果

fEntryType==1
   未使用

*/
 
#include <Wofu\\enums\\EntryWay.mqh>
#include <Wofu\\Common\\getOppOrderType.mqh>
#include <Wofu\\Common\\logger.mqh>
#include <Wofu\\rules\\rulesParmCommon.mqh>
struct rulesParmAc
{
   string             symbol;       
   ENUM_TIMEFRAMES    timeframe;    
};

int orderTypeByAc
(
   rulesParmAlg&    rps,
   rulesParmCommon& rpc
)
{
   int resultOrderType=-1;
   int    SymDigits=(int)SymbolInfoInteger(rps.symbol,SYMBOL_DIGITS);
   //濾網模式
   if( rpc.entryType==0 )rpc.kBarTo=rpc.kBarFr;

   
   for(int i=rpc.kBarFr;i<=rpc.kBarTo;i++)
   {
   #ifdef __MQL4__
     double ac0   = iAC(rps.symbol,rps.timeframe,i);
     double ac1   = iAC(rps.symbol,rps.timeframe,i+1);
   #endif 
   #ifdef __MQL5__
     double ac0   = iACMQL4(rps.symbol,rps.timeframe,i);
     double ac1   = iACMQL4(rps.symbol,rps.timeframe,i+1);
   #endif 

      if( rpc.entryType==0 )  
      {
              if( lips0>teeth0 && teeth0>jaw0 )resultOrderType=ORDER_TYPE_BUY;  //綠>紅>藍
         else if( lips0<teeth0 && teeth0<jaw0 )resultOrderType=ORDER_TYPE_SELL; //綠<紅<藍
         else resultOrderType=-1;      

      }
      else 
      if( rpc.entryType==1 )  
      {
              if( lips0>teeth0 && teeth0>jaw0 )resultOrderType=ORDER_TYPE_BUY;  //綠>紅>藍
         else if( lips0<teeth0 && teeth0<jaw0 )resultOrderType=ORDER_TYPE_SELL; //綠<紅<藍
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
