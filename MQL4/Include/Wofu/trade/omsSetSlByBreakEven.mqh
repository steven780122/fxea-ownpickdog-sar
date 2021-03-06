#include <Wofu\\common\\logTradeError.mqh>
//營利fBEStPips點後，將停損設定在進場價額+fBEAddPips小點，如果設定fBEStPips成-99則是1:1設置，停損300點則營利300點時把停損設置在進場價額
void omsSetSlByBreakEven
(
   int fTicket,
   int fBEStPips,    
   int fBEAddPips,
)
{
   //損益兩平 營利超過幾點 把停損價設定在進場價
   
   double SymPoint=SymbolInfoDouble(OrderSymbol(),SYMBOL_POINT);
   int    SymDigits=(int)SymbolInfoInteger(OrderSymbol(),SYMBOL_DIGITS);
   //1:1移動   
   if(fBEStPips==-99)fBEStPips=(int)(MathAbs(OrderOpenPrice()-OrderStopLoss())/SymPoint);
   if( fBEStPips<=0 && fBEAddPips<0 )return;

   if( OrderType()==ORDER_TYPE_BUY  && OrderStopLoss()!=OrderOpenPrice()+SymPoint*fBEAddPips && fBEStPips>0 && SymbolInfoDouble(OrderSymbol(), SYMBOL_BID)-OrderOpenPrice()>=SymPoint*fBEStPips )
   {
      if(!OrderModify(fTicket,OrderOpenPrice(),OrderOpenPrice()+SymPoint*fBEAddPips,OrderTakeProfit(),0,Green))
         logTradeError(__FUNCTION__,fTicket,GetLastError(),"Break Even Error");
   }
   else 
   if( OrderType()==ORDER_TYPE_SELL && OrderStopLoss()!=OrderOpenPrice()-SymPoint*fBEAddPips && fBEStPips>0 && OrderOpenPrice()-SymbolInfoDouble(OrderSymbol(), SYMBOL_ASK)>=SymPoint*fBEStPips )
   {
      if(!OrderModify(fTicket,OrderOpenPrice(),OrderOpenPrice()-SymPoint*fBEAddPips,OrderTakeProfit(),0,Red))
         logTradeError(__FUNCTION__,fTicket,GetLastError(),"Break Even Error");
   }
}