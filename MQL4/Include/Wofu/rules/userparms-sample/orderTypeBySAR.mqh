input string SepLineTSar = "---------";            //---< SAR >---
input ENUM_ENTRY_TYPE u_SarEntryType=1;              //採用模式
input ENUM_TIMEFRAMES u_SarTf=PERIOD_CURRENT;        //時區
input double u_SarStep=0.02;                         //步長
input double u_SarMax=0.2;                           //最大
input bool u_SarOdOpp=false;                         //結果反向
ENUM_ENTRY_WAY  u_SarEntryWay=ENTRY_WAY_NOT_DEFINE;  //進場模式-進入方向(SELL單與BUY相反)
 int u_SarKFr=1;                                     //進場模式-採用K棒數(起)
input int u_SarKTo=1;                                //進場模式-採用K棒數(在多少根K內發生都算)
bool u_SarPreK=false;                                //濾網模式-與前K的XXX比對
input bool  u_SarOdOpp=false;                       

