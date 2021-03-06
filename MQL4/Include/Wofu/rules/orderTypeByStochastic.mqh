/*
#include <Wofu\\rules\\orderTypeByStochastic.mqh>
#include <Wofu\\userparms\\sample\\orderTypeByStochastic.mqh>
orderTypeByStochastic(CPair,KdTf,KdPeriodK,KdPeriodD,KdSlowing,KdMethod,KdAppPrice,KdKFr,KdKTo,KdOdOpp);


double  iStochastic(
   string       symbol,           // symbol -->rps.symbol
   int          rps.timeframe,        // rps.timeframe -->rps.timeframe
   int          Kperiod,          // K line period -->rps.periodF
   int          Dperiod,          // D line period -->rps.periodS
   int          rps.slowing,          // rps.slowing -->rps.slowing
   int          method,           // averaging method    -->rps.maMethod
   int          price_field,      // price (Low/High or Close/Close)   -->rps.stoPrice 0 - Low/High or 1 - Close/Close.
   int          mode,             // line index -->MODE_MAIN:K 快線,MODE_SIGNAL:D 慢線
   int          shift             // shift
   );


由最靠近的K棒(fKFr)開始往前找到前K根(fKTo) ,0:當根,1:前1根
KD指標 
rpc.entryType==0
   BUY :K>D 且 K值在rps.boundH~rps.boundL之間
   SELL:K<D 且 K值在rps.boundH~rps.boundL之間
   
rpc.entryType==1
   BUY :黃金交叉(K[1]<=D[1] && K[0]>D[0]) 且 K值在rps.boundH~rps.boundL之間
   SELL:死亡交叉(K[1]>=D[1] && K[0]<D[0]) 且 K值在rps.boundH~rps.boundL之間



*/



#include <Wofu\\enums\\EntryWay.mqh>
#include <Wofu\\Common\\getOppOrderType.mqh>
#include <Wofu\\Common\\logger.mqh>
#include <Wofu\\rules\\rulesParmCommon.mqh>
struct rulesParmStochastic
{
   string             symbol;    
   ENUM_TIMEFRAMES    timeframe;
   int                periodF;
   int                periodS;
   int                slowing;
   ENUM_MA_METHOD     maMethod;
   ENUM_STO_PRICE     stoPrice;
   bool               compareKD;
   double             boundL;
   double             boundH;
   
};

int orderTypeByStochastic
(
   rulesParmStochastic&    rps,
   rulesParmCommon&        rpc
)
{
   int resultOrderType=-1;
   double valueK0=0,valueK1=0,valueD0=0,valueD1=0;
   int    SymDigits=(int)SymbolInfoInteger(rps.symbol,SYMBOL_DIGITS);
   //濾網模式
   if( rpc.entryType==0 )rpc.kBarTo=rpc.kBarFr;

   
   for(int i=rpc.kBarFr;i<=rpc.kBarTo;i++)
   {
      #ifdef __MQL4__
         //K
         valueK0=iStochastic(rps.symbol,rps.timeframe,rps.periodF,rps.periodS,rps.slowing,rps.maMethod,rps.stoPrice,MODE_MAIN,i);   //K快線
         valueK1=iStochastic(rps.symbol,rps.timeframe,rps.periodF,rps.periodS,rps.slowing,rps.maMethod,rps.stoPrice,MODE_MAIN,i+1); //K快線
         //D
         valueD0=iStochastic(rps.symbol,rps.timeframe,rps.periodF,rps.periodS,rps.slowing,rps.maMethod,rps.stoPrice,MODE_SIGNAL,i);   //D慢線
         valueD1=iStochastic(rps.symbol,rps.timeframe,rps.periodF,rps.periodS,rps.slowing,rps.maMethod,rps.stoPrice,MODE_SIGNAL,i+1); //D慢線
      #endif 
      
      #ifdef __MQL5__
         //K
         valueK0=iStochasticMQL4(rps.symbol,rps.timeframe,rps.periodF,rps.periodS,rps.slowing,rps.maMethod,rps.stoPrice,MODE_MAIN,i);   //K快線
         valueK1=iStochasticMQL4(rps.symbol,rps.timeframe,rps.periodF,rps.periodS,rps.slowing,rps.maMethod,rps.stoPrice,MODE_MAIN,i+1); //K快線
         //D
         valueD0=iStochasticMQL4(rps.symbol,rps.timeframe,rps.periodF,rps.periodS,rps.slowing,rps.maMethod,rps.stoPrice,MODE_SIGNAL,i);   //D慢線
         valueD1=iStochasticMQL4(rps.symbol,rps.timeframe,rps.periodF,rps.periodS,rps.slowing,rps.maMethod,rps.stoPrice,MODE_SIGNAL,i+1); //D慢線
      #endif   
   

      if( rpc.entryType==0 )  
      {
              if( (!rps.compareKD || valueK0>valueD0 ) && valueK0 >= rps.boundL && valueK0 <= rps.boundH )resultOrderType=ORDER_TYPE_BUY;  
         else if( (!rps.compareKD || valueK0<valueD0 ) && valueK0 >= rps.boundL && valueK0 <= rps.boundH )resultOrderType=ORDER_TYPE_SELL; 
         else resultOrderType=-1;           
      }
      else 
      if( rpc.entryType==1 )  
      {
              if( valueK0>valueD0 && valueK1<=valueD1 && valueK0 >= rps.boundL && valueK0 <= rps.boundH )resultOrderType=ORDER_TYPE_BUY;  
         else if( valueK0<valueD0 && valueK1>=valueD1 && valueK0 >= rps.boundL && valueK0 <= rps.boundH )resultOrderType=ORDER_TYPE_SELL; 
         else resultOrderType=-1;         
      }
      else
         return(-999);
      
      if( resultOrderType==ORDER_TYPE_BUY || resultOrderType==ORDER_TYPE_SELL ) break;
   } //EOF for
   

   if( rpc.doLogger )logger(LOG_INFO,__FUNCTION__+": 判斷結果="+( (resultOrderType>=0)?EnumToString((ENUM_ORDER_TYPE)resultOrderType):(string)resultOrderType )+",快線="+DoubleToStr(valueK0,SymDigits)+",慢線="+DoubleToStr(valueD0,SymDigits));
   if( rpc.resultOpp && resultOrderType>=0 )return(getOppOrderType((ENUM_ORDER_TYPE)resultOrderType));
   return(resultOrderType);
    
}
