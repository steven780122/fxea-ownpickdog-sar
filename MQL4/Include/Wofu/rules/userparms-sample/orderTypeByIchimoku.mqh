#include <EagerFx\\Transformers\\enums\\EntryType.mqh>
input string SepLineTIc = "---------";        //---< Ichimoku >---
input ENUM_ENTRY_TYPE IcEntryType=1;          //採用模式
input ENUM_TIMEFRAMES IcTf=PERIOD_CURRENT;    //時區
input int IcTS=9;                             //Tenkan-Sen週期 (轉換線)
input int IcKS=26;                            //Kijun-Sen週期  (基準線)
input int IcSSB=52;                           //Senkou Span B週期 (先行帶B)

input ENUM_ENTRY_WAY_CHT IcEntryWay=0;        //(雲帶)進場模式-進入方向(SELL單與BUY相反)
      int                IcKFr=1;             //進場模式-判斷K棒數(起)
input int                IcKTo=3;             //進場模式-採用K棒數(在多少根K內發生都算)
bool IcPreK=false;                            //濾網模式-與前K的XXX比對
input bool IcOdOpp=false;                     //結果反向 

input int    IcOdOCDifPips=-1;                //前K開盤跳空超過距離(Pips)不下單(-1關閉)
input bool IcTouchClose=true;                 //使用雲帶進場下單後，回碰雲帶出場
