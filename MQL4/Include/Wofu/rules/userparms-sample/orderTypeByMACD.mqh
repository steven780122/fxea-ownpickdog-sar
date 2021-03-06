input string SepLineTMACDM = "---------";         //---< MACD穿零軸 >---
input ENUM_ENTRY_TYPE MacdEntryType=1;              //採用模式
input ENUM_TIMEFRAMES MacdTf=PERIOD_CURRENT;        //時區
input int MacdPeriodF=12;                           //快速EMA
input int MacdPeriodS=26;                           //慢速EMA
input int MacdPeriodL=9;                            //MACD SMA
input ENUM_APPLIED_PRICE MacdAppPrice=PRICE_CLOSE;  //應用於(價額)

ENUM_ENTRY_WAY  MacdEntryWay=ENTRY_WAY_NOT_DEFINE;  //進場模式-進入方向(SELL單與BUY相反)
int MacdKFr=1;                                      //進場模式-採用K棒數(起)
input int MacdKTo=1;                                //進場模式-採用K棒數(在多少根K內發生都算)
bool MacdPreK=false;                                //濾網模式-與前K的XXX比對
input  bool  MacdOdOpp=false;                       //結果反向 