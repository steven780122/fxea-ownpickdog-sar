//fKSt從哪根開始高點,0當根->即時,1前一根:開盤在判斷就可以
//找到高點後 在望前fKFr~fKT找低點：找到高點的K棒算0，0~1就是找當根與前跟誰低
void setSlByKBarTrailingStop(int fTicket,int fStPips,int fSpPips,ENUM_TIMEFRAMES fTf,int fKSt,int fKFr,int fKTo,bool fMoveBHL)
{
   //if(fStPips<0)return;
   //fKSt=1 
   if(!OrderSelect(fTicket,SELECT_BY_TICKET,MODE_TRADES))logger(LOG_WARN,"OrderSelect ERROR OrderTicket="+(string)fTicket+" ErrorCode="+(string)GetLastError()+ErrorDescription(GetLastError()));
   if(fSpPips<=0 || fKSt>0 )fSpPips=1; //當根才會需要有這個條件避免頻繁改動
   double DiffPrice=0;  //與現價差 
   double SlPrice=0; //要設定的停損價格
   int    OpShiftBar=iBarShift(_Symbol,fTf,OrderOpenTime(),true); //離開倉K的距離
   double SymPoint=SymbolInfoDouble(OrderSymbol(),SYMBOL_POINT);
   int    SymDigits=(int)SymbolInfoInteger(OrderSymbol(),SYMBOL_DIGITS);
   //printf("開艙單OpShiftBar="+OpShiftBar);  
   int    KShiftBar=0;
   
   if( OrderType()==ORDER_TYPE_BUY  )
   {
   
         DiffPrice=NormalizeDouble(SymbolInfoDouble(OrderSymbol(), SYMBOL_BID)-OrderOpenPrice(),SymDigits);
         if( DiffPrice>=fStPips*SymPoint || fStPips==0 )
         {
            //OpShiftBar==0開倉當根，找當根與前1根。其她找到最高價K棒
            //KShiftBar找到的高點是哪根K , 從現在到開倉前2根
            KShiftBar=(OpShiftBar>0)?iHighest(OrderSymbol(),fTf,MODE_HIGH,OpShiftBar+1-fKSt+2,fKSt):1; //從當根開始找到高點K棒
            //printf("iHighest KShiftBar="+KShiftBar);  
            //找到高價跟與前N根誰的低
            SlPrice=NormalizeDouble(GetLowestPrice(OrderSymbol(),fTf,fKFr+KShiftBar,fKTo+KShiftBar),SymDigits);
            if( OrderStopLoss()==0 || SlPrice>NormalizeDouble(OrderStopLoss()+(fSpPips*SymPoint),SymDigits) )
            {
               if(OrderModify(OrderTicket(),OrderOpenPrice(),SlPrice,OrderTakeProfit(),0,clrGreen))
                  logger(LOG_INFO,(string)OrderTicket()+" OrderModify by K Trailing Stop,SlPrice="+(string)SlPrice);
               else
                  logger(LOG_WARN,__FUNCTION__+" OrderModify OrderTicket="+(string)OrderTicket()+" ErrorCode="+(string)GetLastError()+ErrorDescription(GetLastError())+",SlPrice="+(string)SlPrice);
            }
         }
   }
   else 
   if( OrderType()==ORDER_TYPE_SELL )
   {

         DiffPrice=NormalizeDouble(OrderOpenPrice()-SymbolInfoDouble(OrderSymbol(), SYMBOL_ASK),SymDigits);
         if( DiffPrice>=fStPips*SymPoint || fStPips==0 )
         {
            KShiftBar=(OpShiftBar>0)?iLowest(OrderSymbol(),fTf,MODE_LOW,OpShiftBar+1-fKSt+2,fKSt):1; //從當根開始找到高點K棒
            //printf("iLowest KShiftBar="+KShiftBar);  
            SlPrice=NormalizeDouble(GetHighestPrice(OrderSymbol(),fTf,fKFr+KShiftBar,fKTo+KShiftBar),SymDigits); 
            if( OrderStopLoss()==0 || SlPrice<NormalizeDouble(OrderStopLoss()-(fSpPips*SymPoint),SymDigits) )
            {
               if(OrderModify(OrderTicket(),OrderOpenPrice(),SlPrice,OrderTakeProfit(),0,clrGreen))
                  logger(LOG_INFO,(string)OrderTicket()+" OrderModify by K Trailing Stop,SlPrice="+(string)SlPrice);
               else
                  logger(LOG_WARN,__FUNCTION__+" OrderModify OrderTicket="+(string)OrderTicket()+" ErrorCode="+(string)GetLastError()+ErrorDescription(GetLastError())+",SlPrice="+(string)SlPrice);
            }
         }
   }
}
