/*
#include <Wofu\\rules\\orderTypeByRSI.mqh>
#include <Wofu\\userparms\\sample\\orderTypeByRSI.mqh>

double  iRSI(
   string       symbol,           // symbol
   int          timeframe,        // timeframe
   int          period,           // period
   int          applied_price,    // applied price
   int          shift             // shift
   );
RSI在0~100之間震盪

由最靠近的K棒(fKFr)開始往前找到前K根(fKTo) ,0:當根,1:前1根

fEntryType==0 濾網模式
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

fEntryType==1 進場模式
   當fEntryWay==往上進BUY(0)
      BUY :由下而上穿過 自訂BUY 基準值
      SELL:由上而下穿過 自訂SELL基準值
   當fEntryWay==往下進BUY(1)
      BUY :由上而下穿過 自訂BUY 基準值
      SELL:由下而上穿過 自訂SELL基準值



fEntryType==2 區間模式
   區間1：BB~BE
   區間2：SB~SE
   
   無方向區間
   a. RSI>BE 
   b. RSI>SE
   c. RSI在SE~BE
   
   現在在區間1或區間2內
   BUY ：從下面進入該區間
   SELL：從上面進入該區間
   
   fEntryWay不影響結果

*/
 
#include <Wofu\\enums\\MarketOrderType.mqh>
#include <Wofu\\enums\\EntryWay.mqh>
#include <Wofu\\Common\\getOppMaketOrderType.mqh>
#include <Wofu\\Common\\getOppOrderType.mqh>
#include <Wofu\\Common\\logger.mqh>
#include <Wofu\\rules\\rulesParmCommon.mqh>


struct rulesParmRsi
{
//--[ 內建指標參數 ]----------------------
   string symbol;
   ENUM_TIMEFRAMES tf;
   int period;
   ENUM_APPLIED_PRICE price;
//--[ 自有參數-特殊 ]----------------------
   double rangeBB;            //BUY 基準值 下限
   double rangeBE;            //BUY 基準值 上限(rpc.entryType=0才會用到)
   double rangeSB;            //SELL基準值 上限
   double rangeSE;            //SELL基準值 下限(rpc.entryType=0才會用到)

};

int orderTypeByRSI
(
   rulesParmRsi&    rps,
   rulesParmCommon& rpc
)
{
   int fOdType=-1;
   double FLine0=0,FLine1=0;
   int    SymDigits=(int)SymbolInfoInteger(rps.symbol,SYMBOL_DIGITS);
   //濾網模式
   if( rpc.entryType==0 )rpc.kBarTo=rpc.kBarFr;

   for(int i=rpc.kBarFr;i<=rpc.kBarTo;i++)
   {
      #ifdef __MQL4__
         FLine0 = iRSI(rps.symbol,rps.tf,rps.period,rps.price,i  );
         FLine1 = iRSI(rps.symbol,rps.tf,rps.period,rps.price,i+1);
      #endif 
      #ifdef __MQL5__
         FLine0 = iRSIMQL4(rps.symbol,rps.tf,rps.period,rps.price,i  );
         FLine1 = iRSIMQL4(rps.symbol,rps.tf,rps.period,rps.price,i+1);
      #endif 
      double FLinePre=0;
      int cntPre=1;


      if( rpc.entryType==0 )  
      {
      
            if ( FLine0 > MathMax(rps.rangeBB,rps.rangeSB) && FLine0 <= rps.rangeBE  )fOdType=ORDER_TYPE_BUY;
            else
            if ( FLine0 < MathMin(rps.rangeBB,rps.rangeSB) && FLine0 >= rps.rangeSE  )fOdType=ORDER_TYPE_SELL;
            else
            if ( FLine0 <= MathMax(rps.rangeBB,rps.rangeSB) && FLine0 >= MathMin(rps.rangeBB,rps.rangeSB) )
            {   
               //處理落在rps.rangeB~rps.rangeS中間
               if ( rps.rangeBB >= rps.rangeSB )
                  fOdType=-1; //落在rps.rangeB~rps.rangeS中間則無方向
               else
               {
                  while(1)
                  {
                     #ifdef __MQL4__
                        FLinePre =     iRSI(rps.symbol,rps.tf,rps.period,rps.price,i+cntPre);
                     #endif 
                     #ifdef __MQL5__
                        FLinePre = iRSIMQL4(rps.symbol,rps.tf,rps.period,rps.price,i+cntPre);
                     #endif 
   
                     if( FLinePre < rps.rangeBB )fOdType=ORDER_TYPE_BUY;  
                     else
                     if( FLinePre > rps.rangeSB )fOdType=ORDER_TYPE_SELL;
                     
                     if( fOdType > 0 )break;
                     cntPre++;    
                  } 
               
               }
            }
            else
               fOdType=-1;
            //與前K比較處理
            if( rpc.comparePreK )
            {
               if( fOdType==OD_BUY  && FLine0 <= FLine1 )fOdType=-1;
               if( fOdType==OD_SELL && FLine0 >= FLine1 )fOdType=-1;
            }
      }
      else 
      if( rpc.entryType==1 )  
      {
         if (rpc.entryWay==ENTRY_BUY_CROSSUP) //往上進BUY
         {
            if ( FLine0 > rps.rangeBB && FLine1<= rps.rangeBB )fOdType=ORDER_TYPE_BUY;  
            else
            if ( FLine0 < rps.rangeSB && FLine1>= rps.rangeSB )fOdType=ORDER_TYPE_SELL;
         }
         else
         if (rpc.entryWay==ENTRY_BUY_CROSSDOWN) //往下進BUY
         {
            if ( FLine0 < rps.rangeBB && FLine1>= rps.rangeBB )fOdType=ORDER_TYPE_BUY;  
            else
            if ( FLine0 > rps.rangeSB && FLine1<= rps.rangeSB )fOdType=ORDER_TYPE_SELL;
         }
      }
      else
      if( rpc.entryType==2 )  
      {
         //分成2區
         double RangeUB=-1,RangeLB=-1;
         
         if( FLine0 > rps.rangeBE ||  FLine0 < rps.rangeSE )fOdType=-1;
         if( FLine0 < rps.rangeBB &&  FLine0 > rps.rangeSB )fOdType=-1;
         
         if( rps.rangeBB==rps.rangeSB && FLine0==rps.rangeBB )
            { RangeLB=rps.rangeBB; RangeUB=rps.rangeBB; }         
         else         
         if( FLine0 >= rps.rangeBB && FLine0 <= rps.rangeBE )
            { RangeLB=rps.rangeBB; RangeUB=rps.rangeBE; }
         else
         if( FLine0 <= rps.rangeSB && FLine0 >= rps.rangeSE )
            { RangeLB=rps.rangeSE; RangeUB=rps.rangeSB; }
         
         if( RangeUB>0 && RangeLB > 0 )
         {
            while(1)
            {
               #ifdef __MQL4__
                  FLinePre =     iRSI(rps.symbol,rps.tf,rps.period,rps.price,i+cntPre);
               #endif 
               #ifdef __MQL5__
                  FLinePre = iRSIMQL4(rps.symbol,rps.tf,rps.period,rps.price,i+cntPre);
               #endif 
   
               if( FLinePre < RangeLB )fOdType=ORDER_TYPE_BUY;  
               else
               if( FLinePre > RangeUB )fOdType=ORDER_TYPE_SELL;
               
               if( fOdType==OD_BUY || fOdType==ORDER_TYPE_SELL )break;
               cntPre++;    
            } 
         }
         //與前K比較處理
         if( rpc.comparePreK )
         {
            if( fOdType==OD_BUY  && FLine0 <= FLine1 )fOdType=-1;
            if( fOdType==OD_SELL && FLine0 >= FLine1 )fOdType=-1;
         }
         if(rpc.doLogger)
               logger(LOG_INFO,__FUNCTION__+": OdType="+( (fOdType>=0)?EnumToString((ENUM_ORDER_TYPE)fOdType):(string)fOdType )+",Line0="+DoubleToStr(FLine0,SymDigits)+",LinePre="+DoubleToStr(FLinePre,SymDigits)+"Range="+DoubleToStr(RangeLB,SymDigits)+"~"+DoubleToStr(RangeUB,SymDigits));
         
      }
      else
         return(-999);
      
      if( fOdType==ORDER_TYPE_BUY || fOdType==ORDER_TYPE_SELL ) break;
   } //EOF for
   
   if(rpc.doLogger && rpc.entryType!=2)
         logger(LOG_INFO,__FUNCTION__+": OdType="+( (fOdType>=0)?EnumToString((ENUM_ORDER_TYPE)fOdType):(string)fOdType )+",FLine0="+DoubleToStr(FLine0,SymDigits)+",FLine1="+DoubleToStr(FLine1,SymDigits));
   if( rpc.resultOpp && fOdType>=0 )return(getOppOrderType((ENUM_ORDER_TYPE)fOdType));
   return(fOdType);
    
}

ENUM_MARKET_ORDER_TYPE orderTypeByRSI
(
   //--[ 內建指標參數 ]----------------------
   string fSymbol,
   ENUM_TIMEFRAMES fTf,
   int fPeriod,
   ENUM_APPLIED_PRICE fPrice,
   //--[ 自有參數-常用 ]----------------------
   int fEntryType,            //採用模式
   ENUM_ENTRY_WAY fEntryWay,  //進場模式-進入方向(SELL單與BUY相反)
   int fKFr,                  //採用K棒數-起
   int fKTo,                  //採用K棒數-迄
   bool fPreK,                //與前K的值比對
   bool fOdOpp,               //結果反向
   bool fLogger,              //是否寫出紀錄
   //--[ 自有參數-特殊 ]----------------------
   double fBaseBB,            //BUY 基準值 下限
   double fBaseBE,            //BUY 基準值 上限(fEntryType=0才會用到)
   double fBaseSB,            //SELL基準值 上限
   double fBaseSE             //SELL基準值 下限(fEntryType=0才會用到)
)
{
   ENUM_MARKET_ORDER_TYPE fOdType=OD_NA;
   double FLine0=0,FLine1=0;
   int    SymDigits=(int)SymbolInfoInteger(fSymbol,SYMBOL_DIGITS);
   //濾網模式
   if( fEntryType==0 )fKTo=fKFr;

   for(int i=fKFr;i<=fKTo;i++)
   {
      #ifdef __MQL4__
         FLine0 = iRSI(fSymbol,fTf,fPeriod,fPrice,i);
         FLine1 = iRSI(fSymbol,fTf,fPeriod,fPrice,i+1);
      #endif 
      #ifdef __MQL5__
         FLine0 = iRSIMQL4(fSymbol,fTf,fPeriod,fPrice,i);
         FLine1 = iRSIMQL4(fSymbol,fTf,fPeriod,fPrice,i+1);
      #endif 
      double FLinePre=0;
      int cntPre=1;


      if( fEntryType==0 )  
      {
      
            if ( FLine0 > MathMax(fBaseBB,fBaseSB) && FLine0 <= fBaseBE )fOdType=OD_BUY;
            else
            if ( FLine0 < MathMin(fBaseBB,fBaseSB) && FLine0 >= fBaseSE  )fOdType=OD_SELL;
            else
            if ( FLine0 <= MathMax(fBaseBB,fBaseSB) && FLine0 >= MathMin(fBaseBB,fBaseSB) )
            {   
               //處理落在fBaseB~fBaseS中間
               if ( fBaseBB >= fBaseSB )
                  fOdType=OD_NA; //落在fBaseB~fBaseS中間則無方向
               else
               {
                  while(1)
                  {
                     #ifdef __MQL4__
                        FLinePre =     iRSI(fSymbol,fTf,fPeriod,fPrice,i+cntPre);
                     #endif 
                     #ifdef __MQL5__
                        FLinePre = iRSIMQL4(fSymbol,fTf,fPeriod,fPrice,i+cntPre);
                     #endif 
   
                     if( FLinePre < fBaseBB )fOdType=OD_BUY;  
                     else
                     if( FLinePre > fBaseSB )fOdType=OD_SELL;
                     
                     if( fOdType > 0 )break;
                     cntPre++;    
                  } 
               
               }
            }
            else
               fOdType=OD_NA;
            //與前K比較處理
            if( fPreK )
            {
               if( fOdType==OD_BUY  && FLine0 <= FLine1 )fOdType=OD_NA;
               if( fOdType==OD_SELL && FLine0 >= FLine1 )fOdType=OD_NA;
            }
      }
      else 
      if( fEntryType==1 )  
      {
         if (fEntryWay==ENTRY_BUY_CROSSUP) //往上進BUY
         {
            if ( FLine0 > fBaseBB && FLine1<= fBaseBB )fOdType=OD_BUY;  
            else
            if ( FLine0 < fBaseSB && FLine1>= fBaseSB )fOdType=OD_SELL;
         }
         else
         if (fEntryWay==ENTRY_BUY_CROSSDOWN) //往下進BUY
         {
            if ( FLine0 < fBaseBB && FLine1>= fBaseBB )fOdType=OD_BUY;  
            else
            if ( FLine0 > fBaseSB && FLine1<= fBaseSB )fOdType=OD_SELL;
         }
      }
      else
      if( fEntryType==2 )  
      {
         //分成2區
         double RangeUB=-1,RangeLB=-1;
         
         if( FLine0 > fBaseBE ||  FLine0 < fBaseSE )fOdType=OD_NA;
         if( FLine0 < fBaseBB &&  FLine0 > fBaseSB )fOdType=OD_NA;
         
         if( fBaseBB==fBaseSB && FLine0==fBaseBB )
            { RangeLB=fBaseBB; RangeUB=fBaseBB; }         
         else         
         if( FLine0 >= fBaseBB && FLine0 <= fBaseBE )
            { RangeLB=fBaseBB; RangeUB=fBaseBE; }
         else
         if( FLine0 <= fBaseSB && FLine0 >= fBaseSE )
            { RangeLB=fBaseSE; RangeUB=fBaseSB; }
         
         if( RangeUB>0 && RangeLB > 0 )
         {
            while(1)
            {
               #ifdef __MQL4__
                  FLinePre =     iRSI(fSymbol,fTf,fPeriod,fPrice,i+cntPre);
               #endif 
               #ifdef __MQL5__
                  FLinePre = iRSIMQL4(fSymbol,fTf,fPeriod,fPrice,i+cntPre);
               #endif 
   
               if( FLinePre < RangeLB )fOdType=OD_BUY;  
               else
               if( FLinePre > RangeUB )fOdType=OD_SELL;
               
               if( fOdType==OD_BUY || fOdType==OD_SELL )break;
               cntPre++;    
            } 
         }
         //與前K比較處理
         if( fPreK )
         {
            if( fOdType==OD_BUY  && FLine0 <= FLine1 )fOdType=OD_NA;
            if( fOdType==OD_SELL && FLine0 >= FLine1 )fOdType=OD_NA;
         }
         if(fLogger)
               logger(LOG_INFO,__FUNCTION__+": OdType="+EnumToString(fOdType)+",Line0="+DoubleToStr(FLine0,SymDigits)+",LinePre="+DoubleToStr(FLinePre,SymDigits)+"Range="+DoubleToStr(RangeLB,SymDigits)+"~"+DoubleToStr(RangeUB,SymDigits));
         
      }
      else
         return(OD_ERROR);
      
      if( fOdType==OD_BUY || fOdType==OD_SELL ) break;
   } //EOF for
   
   if(fLogger && fEntryType!=2)
         logger(LOG_INFO,__FUNCTION__+": OdType="+EnumToString(fOdType)+",FLine0="+DoubleToStr(FLine0,SymDigits)+",FLine1="+DoubleToStr(FLine1,SymDigits));
      
   if( fOdOpp && fOdType>=0 )return(getOppMaketOrderType(fOdType));
   return(fOdType);
    
}
