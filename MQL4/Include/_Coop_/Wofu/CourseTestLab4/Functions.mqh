#include <Wofu\\common\\getInfoUrl.mqh>
#include <Wofu\\common\\isTime.mqh>
//#include <Wofu\\common\\getOppOrderType.mqh>
#include <Wofu\\draw\\chartPreSet.mqh>
#include <Wofu\\draw\\deleteAllObjects.mqh>
#include <Wofu\\draw\\createLabelText.mqh>
#include <Wofu\\draw\\createButton.mqh>

#include <Wofu\\trade\\sendOrder.mqh>
#include <Wofu\\trade\\closeAllOrders.mqh>
#include <Wofu\\trade\\setTpByPips.mqh>
#include <Wofu\\trade\\setSlByPips.mqh>


#include <Wofu\\trade\\setSlByPrice.mqh>   // my
#include <Wofu\\trade\\setTpByPrice.mqh>   // my


#include <Wofu\\common\\getLotsBySlPips.mqh>
//#include <Wofu\\rules\\getPriceByZigZag.mqh>



/* ================================================================= */
/* ================================================================= */
/* ================================================================= */

//+------------------------------------------------------------------+
//| Tick管理                                                         |
//+------------------------------------------------------------------+
bool isTickWork()
{
   if(!IsTradeAllowed()||!IsExpertEnabled())
      {        
         //第一次發生的時候做紀錄
         string msgMustRule="Expert Enabled Button="+(string)IsExpertEnabled()+
               ",Allow Live Trading="+(string)IsTradeAllowed()+
               ",Allow DLLs imports="+(string)IsDllsAllowed()+
               ",Allow import of external experts="+(string)IsLibrariesAllowed();
         if(g_isTickWork)logger(LOG_INFO,"Setting is NOT correct!"+msgMustRule);
         return(false); 
      }
      
   if(!g_isAuth)
      {
         if(g_isTickWork)logger(LOG_INFO,"Auth is NOT Corrrect!!"); 
         return(false); //畫面由Timer控制
      }
   
   if(g_tick_stop.isGvStop())
      {
         if(g_isTickWork)logger(LOG_INFO,"EA Tick Stop Time!!"+TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS)+","+TimeToStr((datetime)GlobalVariableGet(EA_NAME_E+g_tickStop+"_E"),TIME_DATE|TIME_SECONDS)); 
         return(false); //畫面由Timer控制
      
      }

   if(!g_isTickWork)logger(LOG_INFO,"Ea Tick Go ");
   return(true);

}
//+------------------------------------------------------------------+
//| Tick資料蒐集(放置同一個TICK不會改變的資訊，供全部程式使用)       |
//+------------------------------------------------------------------+
void genReferenceTickInfo()
{
   g_orders_trades_info.getInfo(_Symbol,orderMagicNumber);    //---   收集場上的單
   
   if(g_isNewBar && g_orders_trades_info.countOpen==0 ){    
      double valueSar = iSAR(NULL,0,0.02,0.2,1);    //--- 取得該SAR值，其為最後一個1是前一根，其他參數用f1
      if(valueSar >= Close[1])    //---大於前一根收盤價:  下sell單       // Close[1] 表示前一根的收
      {
         g_rti.entryBuy = FALSE;
         g_rti.entrySell = TRUE;
      }
      else
      {
         g_rti.entryBuy = TRUE;
         g_rti.entrySell = FALSE;
      } 
   }
   
   
}
//+------------------------------------------------------------------+
//| 風險管理-在倉處理                                                |
//+------------------------------------------------------------------+
bool riskManager()
{
   g_orders_trades_info.getInfo(_Symbol,orderMagicNumber);
   
//----- [ 進場先平反向單 ] -------
   if(u_CloseByOrder){
      if( g_orders_trades_info.countOpen>0 ){
         if(g_rti.entryBuy){
            closeAllOrders(_Symbol,(ENUM_MIXED_ORDER_TYPE)ORDER_TYPE_SELL,orderMagicNumber,orderSlPage);
            g_orders_trades_info.getInfo(_Symbol,orderMagicNumber);
         }
         if(g_rti.entrySell){
            closeAllOrders(_Symbol,(ENUM_MIXED_ORDER_TYPE)ORDER_TYPE_BUY ,orderMagicNumber,orderSlPage);
            g_orders_trades_info.getInfo(_Symbol,orderMagicNumber);
         }
      }
   }
//----- [ 停利偵測 ] -------
   if( g_orders_trades_info.profitAll>0 ){
      if( (u_TpAmt>0          && g_orders_trades_info.profitAll >= u_TpAmt ) ||
          (u_TpBalanceRatio>0 && g_orders_trades_info.profitAll >= AccountBalance()*u_TpBalanceRatio/100 ) ||
          (u_TpEquityRatio>0  && g_orders_trades_info.profitAll >= AccountEquity()*u_TpEquityRatio/100   )   ){ 
            closeAllOrders(_Symbol,MIXED_ODTYPE_BUY_SELL,orderMagicNumber,orderSlPage);
            g_orders_trades_info.getInfo(_Symbol,orderMagicNumber); 
        }
   }
//----- [ 停損偵測 ] -------
   else
   if( g_orders_trades_info.profitAll<0 )
   {
      if( (u_SlAmt>0          && MathAbs(g_orders_trades_info.profitAll) >= u_SlAmt ) ||
          (u_SlBalanceRatio>0 && MathAbs(g_orders_trades_info.profitAll) >= AccountBalance()*u_SlBalanceRatio/100 ) ||
          (u_SlEquityRatio>0  && MathAbs(g_orders_trades_info.profitAll) >= AccountEquity()*u_SlEquityRatio/100   ) ){ 
            closeAllOrders(_Symbol,MIXED_ODTYPE_BUY_SELL,orderMagicNumber,orderSlPage);
            g_orders_trades_info.getInfo(_Symbol,orderMagicNumber); 
        }
   }
//----- [ 依照每張訂單設定SL,TP ] -------
   // int SelectTicketNo=-1;
   // if( OrdersTotal()>0 && ( u_TpPips>0 || u_SlPips>0 )  ){
   //      for(int i=0;i<OrdersTotal();i++){ 
   //          if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && isMyOrder(_Symbol,MIXED_ODTYPE_BUY_SELL,orderMagicNumber) ){
   //             SelectTicketNo=OrderTicket();
   //             //----- [ 設定停利/損點 ] -------
   //             if( u_TpPips>0 )setTpByPips(SelectTicketNo,u_TpPips,false);               
   //             if( u_SlPips>0 )setSlByPips(SelectTicketNo,u_SlPips,false,false);
   //          }
   //       } 
   //  }
   //---  [Steven ]
   if(bIsBreakEven)
   {
      setSLByBreakEven();
   }

   // 依時區判斷追蹤止損判斷  ?? 但回測超怪啊...   先保留
   // if(isNewBar(Symbol(),PERIOD_CURRENT,true))
   // {

   // }
   switch(e_TRAIL_TYPE) 
   { 
      case E_TRAIL_BY_PIPS: 
         trailByPips();
         break; 
      case E_TRAIL_BY_MA:
         trailByMA(); 
      case E_TRAIL_BY_PSAR: 
         trailByPSAR();
         break; 
      case E_TRAIL_BY_ZIGZAG: 
         trailByZigZag();
         break; 
      default: 
         Print("NOT A, B or C"); 
         break; 
   } 
  
   
   return(true);
}


//--- Steven: 追蹤止損 by 點數, 尚未寫by newBar
void trailByPips()
{
   int SelectTicketNo=-1;
   if( OrdersTotal()>0 && ui_profitPipsBfTrlSl>0 ){
        for(int i=0;i<OrdersTotal();i++){ 
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && isMyOrder(_Symbol,MIXED_ODTYPE_BUY_SELL,orderMagicNumber) ){
               if(OrderType()==OP_BUY)
               {
                  SelectTicketNo=OrderTicket();
                  double stoploss=NormalizeDouble(Bid - ui_pipsSl*Point , Digits); // 新的止損價
                  if(OrderStopLoss() > 0)    // 先前已設定過止損，需判斷距離設定的點數才調整
                  {
                     if(ui_pipsStartModify > 0)    // 有輸入超過幾點調整一次
                     {
                        double dNewBuyStoplossChkPoint=Bid - NormalizeDouble(ui_pipsStartModify*Point , Digits); 
                        if(OrderStopLoss() < dNewBuyStoplossChkPoint && stoploss > OrderStopLoss())        // 若場上的buy單SL 價低於新的可調整追蹤止損價位, 且新的止損價高於舊的
                        {                               
                              setSlByPrice(SelectTicketNo,stoploss,false);                            
                        }
                     }
                  }
                  else           // 還未設定過止損，啟動設定的追蹤止損點位
                  {
                     double dStartTrailSlPrice = NormalizeDouble(OrderOpenPrice() + ui_profitPipsBfTrlSl*Point, Digits); 
                     if(Bid > dStartTrailSlPrice)  
                     {
                        setSlByPrice(SelectTicketNo,stoploss,false);
                     }                      
                  }
               }
               else    // 該場上單為Sell
               {
                  SelectTicketNo=OrderTicket();
                  double stoploss=NormalizeDouble(Ask + ui_pipsSl*Point , Digits);    // 新的止損價
                  if(OrderStopLoss() > 0)    // 先前已設定過止損，需判斷距離設定的點數才調整
                  {
                     if(ui_pipsStartModify > 0)    // 有輸入超過幾點調整一次
                     {
                        double dNewSellStoplossChkPoint=Ask + NormalizeDouble(ui_pipsStartModify*Point , Digits); 
                        if(OrderStopLoss() > dNewSellStoplossChkPoint && stoploss < OrderStopLoss())        // 若場上的buy單SL 價低於新的可調整追蹤止損價位
                        {                                 
                              setSlByPrice(SelectTicketNo,stoploss,false);                            
                        }
                     }
                  }
                  else           // 還未設定過止損，啟動設定的追蹤止損點位
                  {
                     double dStartTrailSlPrice = NormalizeDouble(OrderOpenPrice() - ui_profitPipsBfTrlSl*Point, Digits);              
                     if(Ask < dStartTrailSlPrice)
                     {
                        setSlByPrice(SelectTicketNo,stoploss,false);
                     }            
                  }
               }
                   
            }
         } 
    }
}


//--- Steven: 追蹤止損 by MA
void trailByMA()
{
   int SelectTicketNo=-1;
   if( OrdersTotal()>0 && ui_profitPipsBfTrlSl>0){
        for(int i=0;i<OrdersTotal();i++){ 
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && isMyOrder(_Symbol,MIXED_ODTYPE_BUY_SELL,orderMagicNumber) ){
               double dMaCurrent=iMA(NULL,0,uiMAperiod,0,e_MA_METHOD,PRICE_CLOSE,0);
               double stoploss=NormalizeDouble(dMaCurrent, Digits);   // 新的止損價
               // MaPrevious=iMA(NULL,0,uiMAperiod,0,MODE_EMA,PRICE_CLOSE,1);
               if(OrderType()==OP_BUY)
               {
                  SelectTicketNo=OrderTicket();
                  if(OrderStopLoss() > 0)             // 已設定過止損
                  {
                     if(dMaCurrent > OrderStopLoss() && stoploss > OrderStopLoss())  // buy單若當下的MA比原先設的止損高，則設定新止損為MA，且新的止損價高於舊的
                     {
                        setSlByPrice(SelectTicketNo,stoploss,false);  
                     }
                  }
                  else                                 // 未設定過追蹤止損
                  {
                     double dStartTrailSlPrice = NormalizeDouble(OrderOpenPrice() + ui_profitPipsBfTrlSl*Point, Digits);    // 啟動追蹤止損價位
                     if(Bid > dStartTrailSlPrice)           // 達到開啟追蹤止損價位
                     {
                        setSlByPrice(SelectTicketNo,stoploss,false);  
                     }     
                  }

               }
               else     // sell 單
               {
                  SelectTicketNo=OrderTicket();
                  if(OrderStopLoss() > 0)             // 已設定過止損
                  {
                     if(dMaCurrent < OrderStopLoss() && stoploss < OrderStopLoss())  // buy單若當下的MA比原先設的止損高，則設定新止損為MA
                     {
                        setSlByPrice(SelectTicketNo,stoploss,false);  
                     }
                  }
                  else
                  {
                     double dStartTrailSlPrice = NormalizeDouble(OrderOpenPrice() - ui_profitPipsBfTrlSl*Point, Digits); 
                     if(Ask < dStartTrailSlPrice)
                     {
                        setSlByPrice(SelectTicketNo,stoploss,false);  
                     }           
                  }
               }
            }
         } 
    }
}


//--- Steven: 追蹤止損 by PSAR
void trailByPSAR()
{
   int SelectTicketNo=-1;
   if( OrdersTotal()>0 && ui_profitPipsBfTrlSl>0){
        for(int i=0;i<OrdersTotal();i++){ 
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && isMyOrder(_Symbol,MIXED_ODTYPE_BUY_SELL,orderMagicNumber) ){
               double dValueSar = iSAR(NULL,0,0.02,0.2,0);   
               double stoploss=NormalizeDouble(dValueSar, Digits); 
               if(OrderType()==OP_BUY)
               {
                  SelectTicketNo=OrderTicket();
                  if(OrderStopLoss() > 0)             // 已設定過止損
                  {
                     if(dValueSar > OrderStopLoss() && stoploss > OrderStopLoss())  // buy單若當下的MA比原先設的止損高，則設定新止損為MA
                     {
                        setSlByPrice(SelectTicketNo,stoploss,false);  
                     }
                  }
                  else
                  {
                     double dStartTrailSlPrice = NormalizeDouble(OrderOpenPrice() + ui_profitPipsBfTrlSl*Point, Digits);    // 啟動追蹤止損價位
                     if(Bid > dStartTrailSlPrice)           // 達到開啟追蹤止損價位
                     {
                        setSlByPrice(SelectTicketNo,stoploss,false);  
                     }
                     
                  }

               }
               else     // sell 單
               {
                  SelectTicketNo=OrderTicket();
                  if(OrderStopLoss() > 0)             // 已設定過止損
                  {
                     if(dValueSar < OrderStopLoss() && stoploss < OrderStopLoss())  // buy單若當下的MA比原先設的止損高，則設定新止損為MA
                     {
                        setSlByPrice(SelectTicketNo,stoploss,false);  
                     }
                  }
                  else
                  {
                     double dStartTrailSlPrice = NormalizeDouble(OrderOpenPrice() - ui_profitPipsBfTrlSl*Point, Digits); 
                     if(Ask < dStartTrailSlPrice)
                     {
                        setSlByPrice(SelectTicketNo,stoploss,false);  
                     }
                  }
               }
            }
         } 
    }

}


void trailByZigZag()                // 目前問題: 最高點沒出來..   不確定Buy單最低點更低要不要設，反之亦然
{
   int SelectTicketNo=-1;
   if( OrdersTotal()>0){

        for(int i=0;i<OrdersTotal();i++){ 
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && isMyOrder(_Symbol,MIXED_ODTYPE_BUY_SELL,orderMagicNumber) ){
               SelectTicketNo=OrderTicket();
               int fDepth=12;     // Depth
               int fDeviation=5;  // Deviation
               int fBackStep=3;   // Backstep

               double ZigZagH=iCustom(OrderSymbol(),0,"ZigZag",fDepth,fDeviation,fBackStep,1,1);
               double ZigZagL=iCustom(OrderSymbol(),0,"ZigZag",fDepth,fDeviation,fBackStep,2,1);

               if(OrderType()==OP_BUY)                // buy單
               {
                  if(OrderStopLoss() > 0)            
                  {
                     if(OrderStopLoss() >= OrderOpenPrice())   // 設過損益兩平
                     {
                        if(ZigZagL > OrderStopLoss())       // 需判斷低點高於開倉價
                        {
                           setSlByPrice(SelectTicketNo, ZigZagL, false);
                        }
                     } 
                     else
                     {
                        setSlByPrice(SelectTicketNo, ZigZagL, false);
                     }
                  }
                  else             // 沒設過止損直接設
                  {
                     if(ZigZagL > 0)
                     {
                        setSlByPrice(SelectTicketNo, ZigZagL, false);
                     }
                  }

                  if(ZigZagH > 0 && ZigZagH > ZigZagL && ZigZagL > 0)                  // 設停利
                     {
                        setTpByPrice(SelectTicketNo, ZigZagH, false);
                     }
               }
               else           // sell 單
               {
                  if(OrderStopLoss() > 0)                   // 設過止損
                  {
                     if(OrderStopLoss() <= OrderOpenPrice())   // 設過損益兩平
                     {
                        if(ZigZagH < OrderStopLoss() && ZigZagH > 0)       // 需判斷高點低於開倉價，且存在最高點值
                        {
                           setSlByPrice(SelectTicketNo, ZigZagH, false);
                        }
                     } 
                     else
                     {
                        if(ZigZagH > 0)
                        {
                           setSlByPrice(SelectTicketNo, ZigZagH, false);
                        }    
                     }
                  }
                  else             // 沒設過止損直接設
                  {
                     if(ZigZagH > 0)
                     {
                        setSlByPrice(SelectTicketNo, ZigZagH, false);
                     }
                  }

                  if(ZigZagL > 0 && ZigZagH > ZigZagL)                  // 設停利
                     {
                        setTpByPrice(SelectTicketNo, ZigZagL, false);
                     }
               }
            }
         } 
    }

}



void setSLByBreakEven()
{
   int SelectTicketNo=-1;
   if( OrdersTotal()>0 && ui_profitPipsBeforeBreakEven>0){
        for(int i=0;i<OrdersTotal();i++){ 
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && isMyOrder(_Symbol,MIXED_ODTYPE_BUY_SELL,orderMagicNumber) ){
               SelectTicketNo=OrderTicket();
               //----- [ 設定停利/損點 ] -------
               if(OrderType()==OP_BUY)                // buy單
               {
                  double dStartBreakEvenSlPrice = NormalizeDouble(OrderOpenPrice() + ui_profitPipsBeforeBreakEven*Point, Digits); // 達到啟動損益兩平的價位
                  if(OrderStopLoss() > 0)    // 已設過追蹤止損，要判斷新的止損價位(開倉價)比原先的更高才設
                  {
                     if(Bid > dStartBreakEvenSlPrice && OrderOpenPrice() > OrderStopLoss())
                     {
                        setSlByPrice(SelectTicketNo, OrderOpenPrice(),false);  
                     }

                  }
                  else     // 未設過追蹤止損，直接設損益兩平
                  {
                     if(Bid > dStartBreakEvenSlPrice)
                     {
                        setSlByPrice(SelectTicketNo, OrderOpenPrice(),false);  
                     }
                  }

               }
               else                                   // sell單
               {
                  double dStartBreakEvenSlPrice = NormalizeDouble(OrderOpenPrice() - ui_profitPipsBeforeBreakEven*Point, Digits); 
                  if(OrderStopLoss() > 0)    // 已設過追蹤止損，要判斷新的止損價位(開倉價)比原先的更低才設
                  {
                     if(Ask < dStartBreakEvenSlPrice && OrderOpenPrice() < OrderStopLoss())
                     {
                        setSlByPrice(SelectTicketNo, OrderOpenPrice(),false);  
                     }
                  }
                  else                       // 未設過止損，直接損益兩平
                  {
                     if(Ask < dStartBreakEvenSlPrice)
                     {
                        setSlByPrice(SelectTicketNo, OrderOpenPrice(),false);  
                     }
                  }    
               }        
            }
         } 
    }
}


//+------------------------------------------------------------------+
//| 進場管理-進場處理                                                |
//+------------------------------------------------------------------+
bool tradeManager()
{
//----- [ 圖表K棒進場 ] -------
   if(g_isNewBar)
   {
      logger(LOG_INFO,"新K棒產生");
   //----- [ 進場時間 ] -------
      if( isTime(u_opWkNo,u_opFrTo,30,0) )
      {
         logger(LOG_INFO,"下單時間內，偵測下單");
         g_orders_trades_info.getInfo(_Symbol,orderMagicNumber);
         if( g_orders_trades_info.countOpen==0 )
         {
            if(g_rti.entryBuy)
            {
               sendOrder(TRADE_WAY_ONLY_LONG_AND_SHORT,_Symbol,ORDER_TYPE_BUY ,getOrderLots(ORDER_TYPE_BUY ),orderMagicNumber,EA_NAME_E+orderCommentPrefix+"B",orderSlPage,Ask,0,0);
            }
            if(g_rti.entrySell)
            {
               sendOrder(TRADE_WAY_ONLY_LONG_AND_SHORT,_Symbol,ORDER_TYPE_SELL,getOrderLots(ORDER_TYPE_SELL),orderMagicNumber,EA_NAME_E+orderCommentPrefix+"S",orderSlPage,Bid,0,0);
            }
         }
      }
   }
   return(true);
}

double getOrderLots(ENUM_ORDER_TYPE orderType)
{
   
   if(u_LotsMode==LOTS_MODE_FIX)return(u_Lots);
   else
   if(u_LotsMode==LOTS_MODE_SLAMT)
            return(getLotsBySlPips(_Symbol,u_SlPips,u_SlAmt));   
   return(0);

}

//+------------------------------------------------------------------+
//| 畫面繪製OnTick                                                   |
//+------------------------------------------------------------------+
void drawOnTick()
{

}
//+------------------------------------------------------------------+
//| 畫面繪製OnTimer                                                  |
//+------------------------------------------------------------------+
void drawOnTimer()
{

}

//+------------------------------------------------------------------+
//| 畫面繪製OnTimer                                                  |
//+------------------------------------------------------------------+
void drawOnInit()
{
//----- [ 通用畫面繪製 ] -------
    chartPreSet();
//----- [ 人工暫停按鈕 ] -------     
    createButton(0,EA_NAME_E+"TickStopBtn",0,8,8,8,8,CORNER_RIGHT_LOWER,"■",EA_FONT,8); 
//----- [ EA註解 EaRemarks ] -------     
    createLabelTextRU(EA_NAME_E+"Remarks",10*StringLen(u_Remarks)+125+10,0,10*StringLen(u_Remarks)+10,20,u_Remarks,10);
//----- [ 顯示選單 ] -------
    g_menu_right_upper.show(true);     
}
/* ================================================================= */
/* ================================================================= */
/* ================================================================= */

string getUserParm()
{
   string userParm="";
#ifdef AUTH_ENABLE
   userParm+="UserSN="+u_sn+";;";
   userParm+="UserEmail="+u_email+";;";
   userParm+="UserMobile="+u_mobile+";;";
#endif
   return(userParm);
}

void userParmCheck()
{
   g_lotsDigital=getLotsDigital(_Symbol);
/*
//--- 提示參數設定錯誤  
   if(B_TpPips<MarketInfo(Symbol(),MODE_STOPLEVEL))Alert("BUY "+MSG_ERROR_STOPLEVEL+"("+DoubleToString(MarketInfo(Symbol(),MODE_STOPLEVEL),0)+")");
   if(S_TpPips<MarketInfo(Symbol(),MODE_STOPLEVEL))Alert("SELL"+MSG_ERROR_STOPLEVEL+"("+DoubleToString(MarketInfo(Symbol(),MODE_STOPLEVEL),0)+")");
   if(B_Lots  <MarketInfo(Symbol(),MODE_MINLOT))Alert("BUY "+MSG_ERROR_MODE_MINLOT+"("+DoubleToString(MarketInfo(Symbol(),MODE_MINLOT),2)+")");
   if(S_Lots  <MarketInfo(Symbol(),MODE_MINLOT))Alert("SELL"+MSG_ERROR_MODE_MINLOT+"("+DoubleToString(MarketInfo(Symbol(),MODE_MINLOT),2)+")");
   */
   
}




void showMsgPanelExpertNotEnable()
{
      g_msg_panel.setLabel(MSG_EA_TICK_STOP,MSG_EXPERT_NOT_ENABLE,getInfoUrl(SYS_CODE,EA_CODE,"Help-ExpertNotEnable"),clrPink);
      g_msg_panel.showPanel(true);   
}