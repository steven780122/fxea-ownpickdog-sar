//#include <Wofu\\common\\isExistCurrencyPair.mqh>
#include <Wofu\\common\\logger.mqh>
//檢查貨幣兌是否存在
bool isExistCurrencyPair(string CPair) export
{
   string fSYMBOL_PATH="";
   SymbolInfoString(CPair,SYMBOL_PATH,fSYMBOL_PATH);
   #ifdef __MQL4__
      fSYMBOL_PATH=StringTrimRight(fSYMBOL_PATH);
   #endif
   #ifdef __MQL5__
      StringTrimRight(fSYMBOL_PATH);
   #endif 
   
   logger(LOG_ALL,"SYMBOL_PATH-->"+fSYMBOL_PATH+"<----");
   if (fSYMBOL_PATH!="")return(true);
   else return(false);
}