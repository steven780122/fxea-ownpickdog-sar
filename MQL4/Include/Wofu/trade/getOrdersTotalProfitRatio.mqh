//依照訂單類型回傳目前在倉獲利總額
#include <Wofu\\trade\\getOrdersTotalProfit.mqh>
#include <Wofu\\enums\\AccountMoneyType.mqh>
double getOrdersTotalProfitRatio
(
   string fSymbol,
   MIXED_ORDER_TYPE fOdType,
   int fMagicNumber,
   ENUM_ACCOUNT_MONEY_TYPE mode=ACCOUNT_MONEY_TYPE_BALANCE,  //0=AccountBalance,1=AccountEquity
) export
{
   if( mode==ACCOUNT_MONEY_TYPE_EQUILTY )
      return(getOrdersTotalProfit(fSymbol,fOdType,fMagicNumber)/AccountEquity());
   
   return(getOrdersTotalProfit(fSymbol,fOdType,fMagicNumber)/AccountBalance());
}
