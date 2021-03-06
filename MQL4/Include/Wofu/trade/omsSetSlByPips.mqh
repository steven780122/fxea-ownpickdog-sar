#include <Wofu\\common\\getOdMultiplier.mqh>
#include <Wofu\\trade\\omsSetSlByPrice.mqh>

//fKeepCloser=true,只會越拉越近
void omsSetSlByPips(int fTicket,int fSlPips=-1,bool fKeepCloser=false,int fSetCount=3,int fSleepMSeconds=30,color fColor=clrNONE)
{
   if( fSlPips<0 || fTicket<0 )return;

   double SymPoint=SymbolInfoDouble(OrderSymbol(),SYMBOL_POINT);
   double SlPriceNew=0;

   if(fSlPips==0)
      { SlPriceNew=0; } /*注意：如果KEEPCLOSE=TRUE,就不會更動了 */
   else
      { SlPriceNew=OrderOpenPrice()-getOdMultiplier(OrderType())*fSlPips*SymPoint; }
      
   omsSetSlByPrice(fTicket,SlPriceNew,fKeepCloser,fSetCount,fSleepMSeconds,fColor);
}
