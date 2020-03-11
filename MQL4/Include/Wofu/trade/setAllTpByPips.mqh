
//刪除預掛單 
#include <Wofu\\trade\\omsIsMyOrder.mqh>
#include <Wofu\\trade\\setTpByPips.mqh>

void setAllTpByPips(string fSymbol,int fOdType,int fMagicNumber,int fTpPips=-1) export
{
   if( OrdersTotal()>0 )
      for(int i=0;i<OrdersTotal();i++)
         if( OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && omsIsMyOrder(fSymbol,fOdType,fMagicNumber) ) 
            setTpByPips(OrderTicket(),fTpPips,false);
}

