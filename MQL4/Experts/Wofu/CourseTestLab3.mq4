//+------------------------------------------------------------------+
//|                                               CourseTestLab3.mq4 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   printf(SymbolsTotal(TRUE));
   
   for(int i = 0; i < SymbolsTotal(TRUE);i++)
   {
      string sSymbol = SymbolName(i, TRUE);
      printf("貨幣兌 %i %s", i,sSymbol);
      //---
      int iSwapType = MarketInfo(sSymbol,MODE_SWAPTYPE);

      switch(iSwapType) 
      { 
         case 0: 
            Print("In points"); 
            break; 
         case 1: 
            Print("In the symbol base currency"); 
            break; 
         case 2: 
            Print("By interest"); 
            break; 
         case 3: 
            Print("in the margin currency"); 
            break; 
         default: 
            Print("in the margin currency"); 
            break; 
      } 
      
      //---
      
      Print("Swap of the buy order=",MarketInfo(sSymbol,MODE_SWAPLONG)); 
      //---
      
      Print("Swap of the sell order=",MarketInfo(sSymbol,MODE_SWAPSHORT)); 
      
      //---
      int iSwap3Days=SymbolInfoInteger(sSymbol,SYMBOL_SWAP_ROLLOVER3DAYS);
      string sSwap3DaysValue = sSymbol + "3日庫存費於星期";
      switch(iSwap3Days) 
      { 
         case 0: 
            sSwap3DaysValue += "日";
            Print(sSwap3DaysValue); 
            break; 
         case 1: 
            sSwap3DaysValue += "一";
            Print(sSwap3DaysValue); 
            break; 
         case 2: 
            sSwap3DaysValue += "二";
            Print(sSwap3DaysValue); 
            break; 
         case 3: 
            sSwap3DaysValue += "三";
            Print(sSwap3DaysValue); 
            break; 
         case 4: 
            sSwap3DaysValue += "四";
            Print(sSwap3DaysValue); 
            break; 
            
         case 5: 
            sSwap3DaysValue += "五";
            Print(sSwap3DaysValue); 
            break; 
            
         case 6: 
            sSwap3DaysValue += "六";
            Print(sSwap3DaysValue); 
            break; 

         default: 
            Print("error"); 
            break; 
      }
      
      Print("點差 ",  SymbolInfoInteger(sSymbol,SYMBOL_SPREAD));
      
//---
   
      
      
      
      
   }
   
   
   
   
   
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
  
      
//---
   
  }
//+------------------------------------------------------------------+
