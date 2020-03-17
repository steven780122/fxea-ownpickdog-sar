//+------------------------------------------------------------------+
//|                                                        刪除預掛單.mq4 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, 英雄哥外匯贏家 Hero Forex."
#property link      "http://www.HeroFx.biz"
#property version   "1.00"
#property description "==[ 刪除預掛單 ]=="
#property strict
#include <stderror.mqh>
#include <stdlib.mqh>
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
      for(int i=OrdersTotal()-1;i>=0;i--)
       if( OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol() == Symbol() && (OrderType()==OP_BUYSTOP||OrderType()==OP_BUYLIMIT||OrderType()==OP_SELLSTOP||OrderType()==OP_SELLLIMIT) )
        if ( !OrderDelete(OrderTicket()) ){int LastErrorCode=GetLastError();Alert(IntegerToString(OrderTicket())+(string)LastErrorCode+ErrorDescription(LastErrorCode));}
 
   
  }
//+------------------------------------------------------------------+
