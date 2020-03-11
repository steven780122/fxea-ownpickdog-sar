#include <Wofu\\trade\\selectOpOrderByTicketNo.mqh>
#include <Wofu\\trade\\omsSetTpByPips.mqh>
void setTpByPips(int fTicket,int fTpPips=-1,bool fSelectBeforeSet=true) 
{
   if(fSelectBeforeSet)
      if( fTicket<0 || !selectOpOrderByTicketNo(fTicket))return;
      
   omsSetTpByPips(fTicket,fTpPips);
}
