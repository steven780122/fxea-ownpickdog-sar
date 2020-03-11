//+------------------------------------------------------------------+
//|                                               CourseTestLab2.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//--- input parameters
input int      iTakeProfitDiff = 100;
input int      iStopLossDiff = 300;
input double      dlots = 1;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
    
    //---printf("" )
    double valueSar = iSAR(NULL,0,0.02,0.2,1);    //--- 取得該SAR值，其為最後一個1是前一根，其他參數用f1
    bool bIsGoldCross = FALSE;
    bool bIsDeathCross = FALSE;
    
    double dAskPrice = Ask; 
    double dBidPrice = Bid;
    //double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL); 
    
    
    bIsGoldCross = (iStochastic(NULL,0,5,3,3,MODE_SMA,0,MODE_MAIN,1) > iStochastic(NULL,0,5,3,3,MODE_SMA,0,MODE_SIGNAL,1)) && 
    (iStochastic(NULL,0,5,3,3,MODE_SMA,0,MODE_MAIN,2) < iStochastic(NULL,0,5,3,3,MODE_SMA,0,MODE_SIGNAL,2));
    
    bIsDeathCross = (iStochastic(NULL,0,5,3,3,MODE_SMA,0,MODE_MAIN,1) < iStochastic(NULL,0,5,3,3,MODE_SMA,0,MODE_SIGNAL,1)) && 
    (iStochastic(NULL,0,5,3,3,MODE_SMA,0,MODE_MAIN,2) > iStochastic(NULL,0,5,3,3,MODE_SMA,0,MODE_SIGNAL,2));
    
    if((valueSar >= Close[1]) && bIsDeathCross)    //---SAR大於前一根收盤價 & 死亡交叉:  下sell單       // Close[1] 表示前一根的收
    {
      double stoploss=NormalizeDouble(Ask + iStopLossDiff*Point , Digits); 
      double takeprofit=NormalizeDouble(Ask - iTakeProfitDiff*Point, Digits); 
    
      
      for(int i=OrdersTotal()-1;i>=0;i--)
      {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol() == Symbol() && OrderType()==OP_BUY)
         {
            if(!OrderClose(OrderTicket(),OrderLots(), Bid, 3,Red))    // 問Vol orderClose   // OrderClose改Bid
            {
               Sleep(100);
            }
         }     
      
      }
      
      //OrderClose
      //OrderTicket
      
      int ticket=OrderSend(Symbol(), OP_SELL, dlots, dBidPrice, 3, stoploss, takeprofit,"My order",16384,0,clrGreen); 
      if(ticket<0) 
        { 
         Print("OrderSend Sell failed with error #",GetLastError()); 
        } 
      else
      { 
         Print("OrderSend Sell placed successfully");
      }
         
    }
    
    else if((valueSar < Close[1]) && bIsGoldCross)   //---SAR小於前一根收盤價 & 黃金交叉:  下buy單
    {
      double stoploss=NormalizeDouble(Bid - iStopLossDiff*Point , Digits); 
      double takeprofit=NormalizeDouble(Bid + iTakeProfitDiff*Point, Digits); 
    
      for(int i=OrdersTotal()-1;i>=0;i--)
      {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol() == Symbol() && OrderType()==OP_SELL)
         {
            if(!OrderClose(OrderTicket(),OrderLots(), Ask, 3, Red))    // 問Vol orderClose   // orderClosePrice改Ask
            {
               Sleep(100);
            }
         }     
      
      }
    
      int ticket=OrderSend(Symbol(), OP_BUY, dlots, dAskPrice, 3, stoploss, takeprofit,"My order",16384,0,clrGreen); 
      if(ticket<0) 
        { 
         Print("OrderSend Buy failed with error #",GetLastError()); 
        } 
      else
      { 
         Print("OrderSend Buy placed successfully");
      }
        
    }else
    {
        
    }
   
  }
//+------------------------------------------------------------------+
