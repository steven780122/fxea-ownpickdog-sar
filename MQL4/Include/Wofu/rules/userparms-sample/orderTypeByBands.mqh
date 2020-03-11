#include <FNO1\\enums\\EntryWay.mqh>
input string SepLineTBands = "---";               //---< 布林通道 >---
input ENUM_TIMEFRAMES BbTf=PERIOD_CURRENT;        //時區
input int BbPeriod=20;                            //週期
input double BbDeviation=2;                       //偏差
input int BbBandsShift=0;                         //位移
input ENUM_APPLIED_PRICE BbAppPrice=PRICE_CLOSE;  //採用價額
input ENUM_ENTRY_WAY BbEntryWay=ENTRY_BUY_CROSSUP;//採用進入方向(SELL單與BUY相反)
input int BbEntryType=1;                          //採用模式
input int BbKFr=1;                                //採用K棒數-起
input int BbKTo=1;                                //採用K棒數(進場模式在多少根K內發生都算)
input bool  BbOdOpp=false;                        //結果反向


