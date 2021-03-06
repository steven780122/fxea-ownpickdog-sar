/*
#include <Wofu\\rules\\orderTypeByKBAR_MA.mqh>
#include <Wofu\\userparms\\sample\\orderTypeByKBAR_MA.mqh>

double  iMA(
   string       symbol,           // symbol
   int          timeframe,        // timeframe
   int          ma_period,        // MA averaging period
   int          ma_shift,         // MA shift
   int          ma_method,        // averaging method
   int          applied_price,    // applied price
   int          shift             // shift
   );

由最靠近的K棒(fKFr)開始往前找到前K根(fKTo) ,0:當根,1:前1根

fEntryType==0 濾網模式
      BUY :漲根 且收盤在MA之上
      SELL:跌根 且收盤在MA之下

fEntryType==1 進場模式
      BUY :漲根 且收盤在MA之上
      SELL:跌根 且收盤在MA之下

*/
 
#include <Wofu\\enums\\MarketOrderType.mqh>
#include <Wofu\\enums\\EntryWay.mqh>
#include <Wofu\\Common\\getOppMaketOrderType.mqh>
#include <Wofu\\Common\\logger.mqh>

/*
int orderTypeByKBAR_MA(string fSymbol,ENUM_TIMEFRAMES fTf,int fMaPeriod,int fMaShift,ENUM_MA_METHOD fMaMethod,ENUM_APPLIED_PRICE fMaAppPrice, bool fOdOpp)
{


   
   //logger(LOG_DEBUG,__FUNCTION__+": KBar & MA OdType="+(string)fOdType+",KO1="+DoubleToStr(KO1,Digits)+",KC1="+DoubleToStr(KC1,Digits));
  
   if( fOdOpp && fOdType>=0 )return(GetRevOpType(fOdType));
   return(fOdType);
*/


ENUM_MARKET_ORDER_TYPE orderTypeByKBAR_MA
(
   //--[ 內建指標參數 ]----------------------
   string fSymbol,
   ENUM_TIMEFRAMES fTf,
   int fPeriod,
   int fMaShift,
   ENUM_MA_METHOD fMaMethod,
   ENUM_APPLIED_PRICE fAppPrice,
   //--[ 自有參數-常用 ]----------------------
   int fEntryType,            //採用模式
   //ENUM_ENTRY_WAY fEntryWay,  //進場模式-進入方向(SELL單與BUY相反)
   int fKFr,                  //採用K棒數-起
   int fKTo,                  //採用K棒數-迄
   bool fPreK,                //與前K的值比對 //未使用
   bool fOdOpp,               //結果反向
   bool fLogger,              //是否寫出紀錄
   //--[ 自有參數-特殊 ]----------------------
   bool fBarWay               //是否判斷漲根、跌根

)
{
   ENUM_MARKET_ORDER_TYPE fOdType=OD_NA;
   double KO0=0,KC1=0,KC0=0,MA0=0,MA1=0;
   int    SymDigits=(int)SymbolInfoInteger(fSymbol,SYMBOL_DIGITS);
   //濾網模式
   if( fEntryType==0 )fKTo=fKFr;

   
   for(int i=fKFr;i<=fKTo;i++)
   {
      KO0=iOpen(fSymbol,fTf,i);
      KC0=iClose(fSymbol,fTf,i);
      KC1=iClose(fSymbol,fTf,i+1);
      #ifdef __MQL4__
         MA0=iMA(fSymbol,fTf,fPeriod,fMaShift,fMaMethod,fAppPrice,i);
         MA1=iMA(fSymbol,fTf,fPeriod,fMaShift,fMaMethod,fAppPrice,i+1);
      #endif 
      #ifdef __MQL5__
         MA0=iMAMQL4(fSymbol,fTf,fPeriod,fMaShift,fMaMethod,fAppPrice,i);
         MA1=iMAMQL4(fSymbol,fTf,fPeriod,fMaShift,fMaMethod,fAppPrice,i+1);
      #endif 

      if( fEntryType==0 )  
      {

                 if( KC0>MA0 && (!fBarWay || KO0<KC0 ) )fOdType=OD_BUY;   
            else if( KC0<MA0 && (!fBarWay || KO0>KC0 ) )fOdType=OD_SELL;  
            else fOdType=OD_NA;

            //與前K比較處理
            /*
            if( fPreK )
            {
               if( fOdType==OD_BUY  && KC0 <= KC1 )fOdType=OD_NA;
               if( fOdType==OD_SELL && KC0 >= KC1 )fOdType=OD_NA;
            }
            */

      }
      else 
      if( fEntryType==1 )  
      {
                 if( KC0>MA0 && KC1<=MA1 && (!fBarWay || KO0<KC0 ) )fOdType=OD_BUY;   
            else if( KC0<MA0 && KC1>=MA1 && (!fBarWay || KO0>KC0 ) )fOdType=OD_SELL;  
            else fOdType=OD_NA;
      }
      else
         return(OD_ERROR);
      
      if( fOdType==OD_BUY || fOdType==OD_SELL ) break;
   } //EOF for
   
   if(fLogger)logger(LOG_INFO,__FUNCTION__+": 判斷結果="+EnumToString(fOdType)+",收盤="+DoubleToStr(KC0,SymDigits)+",均線="+DoubleToStr(MA0,SymDigits));
   if( fOdOpp && fOdType>=0 )return(getOppMaketOrderType(fOdType));
   return(fOdType);
    
}


/*

#ifdef __MQL5__
   double IndArray[];
   ArraySetAsSeries(IndArray,true);
   int handle;
   
   ArrayResize(IndArray,0);
   if(CopyOpen(fSymbol,fTf, 1, 1, IndArray)<0)return(-1);
   KO1=IndArray[0];
   
   ArrayResize(IndArray,0);
   if(CopyClose(fSymbol,fTf, 1, 1, IndArray)<0)return(-1);
   KC1=IndArray[0];   
   
   handle=iMA(fSymbol,fTf,fMaPeriod,fMaShift,fMaMethod,fAppPrice);
   if(handle==INVALID_HANDLE)return(-1);
   ArrayResize(IndArray,0);
   if(CopyBuffer(handle,0,1,1,IndArray)<0)return(-1);
   Ma = IndArray[0];

#endif 

*/