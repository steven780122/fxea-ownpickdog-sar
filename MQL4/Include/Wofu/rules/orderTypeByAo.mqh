/*
#include <Wofu\\rules\\orderTypeByMA.mqh>
#include <Wofu\\userparms\\sample\\orderTypeByMA.mqh>

double  iAO(
   string       symbol,     // symbol
   int          timeframe,  // timeframe
   int          shift       // shift
   );


由最靠近的K棒(fKFr)開始往前找到前K根(fKTo) ,0:當根,1:前1根

fEntryType==0 (濾網)
   穿越0軸
   BUY :0軸以上
   SELL:0軸以下
   
   fEntryWay不影響結果

fEntryType==1 (精準穿越)
   BUY :由下往上 穿越0軸
   SELL:由上往下 穿越0軸
   fEntryWay不影響結果

fEntryType==10 (濾網)
   紅綠轉換
   BUY :0軸以上
   SELL:0軸以下
   
   fEntryWay不影響結果

fEntryType==11 (精準穿越)
   BUY :由下往上 穿越0軸
   SELL:由上往下 穿越0軸
   fEntryWay不影響結果

*/
 
#include <Wofu\\enums\\EntryWay.mqh>
#include <Wofu\\Common\\getOppOrderType.mqh>
#include <Wofu\\Common\\logger.mqh>
#include <Wofu\\rules\\rulesParmCommon.mqh>
struct rulesParmAo
{
   string             symbol;       
   ENUM_TIMEFRAMES    timeframe;    
};

int orderTypeByAo
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
     double ao0   = iAO(rps.symbol,rps.timeframe,i);
     double ao1   = iAO(rps.symbol,rps.timeframe,i+1);
     double ao2   = iAO(rps.symbol,rps.timeframe,i+2);
   #endif 
   #ifdef __MQL5__
     double ao0   = iAOMQL4(rps.symbol,rps.timeframe,i);
     double ao1   = iAOMQL4(rps.symbol,rps.timeframe,i+1);
     double ao1   = iAOMQL4(rps.symbol,rps.timeframe,i+2);
   #endif 

      if( rpc.entryType==0 )  
      {
              if( ao0>0 )resultOrderType=ORDER_TYPE_BUY;  
         else if( ao0<0 )resultOrderType=ORDER_TYPE_SELL; 
         else resultOrderType=-1;      

      }
      else 
      if( rpc.entryType==1 )  
      {
              if( ao0>0 && ac1<=0 )resultOrderType=ORDER_TYPE_BUY;  
         else if( ao0<0 && ac1>=0 )resultOrderType=ORDER_TYPE_SELL; 
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
