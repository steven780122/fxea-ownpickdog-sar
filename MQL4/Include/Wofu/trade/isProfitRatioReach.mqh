#include <Wofu\\trade\\getOrdersTotalProfitRatio.mqh>
#include <Wofu\\common\\logger.mqh>

//fRatio <0  : 判斷現在虧損比例是否已經高於fRatio 
//fRatio >=0 : 判斷現在盈利比例是否已經高於fRatio
bool isProfitRatioReach
(
   string fSymbol,
   MIXED_ORDER_TYPE fOdType,
   int fMagicNumber,
   double fRatio,

)
{
   double RatioNow=getOrdersTotalProfitRatio(fSymbol,fOdType,fMagicNumber);
   //logger(LOG_INFO,"Target Ratio="+fRatio+"Now="+RatioNow);
   if( fRatio < 0 && RatioNow<0 && MathAbs(RatioNow)>=MathAbs(fRatio) ){logger(LOG_INFO,"Target Ratio="+DoubleToString(fRatio*100,4)+",Now="+DoubleToString(RatioNow*100,4));return(true);}
   if( fRatio > 0 && RatioNow>0 && MathAbs(RatioNow)>=MathAbs(fRatio) ){logger(LOG_INFO,"Target Ratio="+DoubleToString(fRatio*100,4)+",Now="+DoubleToString(RatioNow*100,4));return(true);}
   return(false);
}