#include <Wofu\\common\\logTradeError.mqh>
#include <Wofu\\trade\\getOrdersCnt.mqh>
#include <Wofu\\trade\\getLotsDigital.mqh>
#include <Wofu\\trade\\getPriceDigitals.mqh>
#include <Wofu\\enums\\TradeWay.mqh>

/*
int  OrderSend(
   string   symbol,              // symbol
   int      cmd,                 // operation
   double   volume,              // volume
   double   price,               // price
   int      slippage,            // slippage
   double   stoploss,            // stop loss
   double   takeprofit,          // take profit
   string   comment=NULL,        // comment
   int      magic=0,             // magic number
   datetime expiration=0,        // pending order expiration
   color    arrow_color=clrNONE  // color
   );
*/

int sendOrder
(
   ENUM_TRADE_WAY fTradeWay,     //進場方向
   string fSymbol, 
   ENUM_ORDER_TYPE fOdType, 
   double fOrderLots, 
   int fMagicNumber, 
   string fComment, 
   int fSlPage , 
   double fOpenPrice=0, 
   double fTakeProfitPrice = 0, 
   double fStopLossPrice = 0
) export
{
   int fTicketNo = -1;
   int fSymbolDigitals=getPriceDigitals(fSymbol);
   int fLotsDigital=getLotsDigital(_Symbol);
   
   color fColorBuy =clrBlue;
   color fColorSell=clrRed;
   
   if( fOrderLots <= 0){return(-1);}
   #ifdef SEND_ORDER_COLOR_BUY
      fColorBuy =SEND_ORDER_COLOR_BUY;
   #endif
   #ifdef SEND_ORDER_COLOR_SELL
      fColorSell =SEND_ORDER_COLOR_SELL;
   #endif
   
   color arrowColor = (fOdType == ORDER_TYPE_BUY || fOdType == ORDER_TYPE_BUY_STOP || fOdType == ORDER_TYPE_BUY_LIMIT )? fColorBuy : fColorSell;
   
   RefreshRates();     
   if( fOpenPrice==0 && fOdType==ORDER_TYPE_BUY )fOpenPrice=SymbolInfoDouble(fSymbol, SYMBOL_ASK);
   else
   if( fOpenPrice==0 && fOdType==ORDER_TYPE_SELL)fOpenPrice=SymbolInfoDouble(fSymbol, SYMBOL_BID);
   
   
   if( fOpenPrice<=0 )return(fTicketNo);
   
   if( ( ( fOdType==ORDER_TYPE_BUY || fOdType==ORDER_TYPE_BUY_STOP || fOdType==ORDER_TYPE_BUY_LIMIT )  && ( fTradeWay==TRADE_WAY_ONLY_LONG_AND_SHORT || fTradeWay==TRADE_WAY_ONLY_LONG   ) ) ||
       ( ( fOdType==ORDER_TYPE_SELL|| fOdType==ORDER_TYPE_SELL_STOP|| fOdType==ORDER_TYPE_SELL_LIMIT)  && ( fTradeWay==TRADE_WAY_ONLY_LONG_AND_SHORT || fTradeWay==TRADE_WAY_ONLY_SHORT  ) ) )
   { fTicketNo = OrderSend(fSymbol, fOdType, NormalizeDouble(fOrderLots,fLotsDigital), NormalizeDouble(fOpenPrice,fSymbolDigitals), fSlPage, NormalizeDouble(fStopLossPrice,fSymbolDigitals), NormalizeDouble(fTakeProfitPrice,fSymbolDigitals), fComment, fMagicNumber, 0, arrowColor); }   

   if(fTicketNo > 0) 
      logger(LOG_INFO,__FUNCTION__+": Ticket="+(string)fTicketNo+",Type="+EnumToString(fOdType)+",Lots="+(string)fOrderLots+",Price="+(string)fOpenPrice+",TP="+(string)fTakeProfitPrice+",SL="+(string)fStopLossPrice+",Way="+EnumToString(fTradeWay));
   else
      logTradeError(__FUNCTION__,fTicketNo,GetLastError(),"Type="+EnumToString(fOdType)+",Lots="+(string)fOrderLots+",Price="+(string)fOpenPrice+",TP="+(string)fTakeProfitPrice+",SL="+(string)fStopLossPrice+",Way="+EnumToString(fTradeWay));
   
   return fTicketNo;
}