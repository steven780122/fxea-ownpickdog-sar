#include <Wofu\\enums\\EntryWay.mqh>
struct rulesParmCommon
{
   //--[ 自有參數-常用 ]----------------------
   int entryType;              //採用模式
   ENUM_ENTRY_WAY entryWay;    //進場模式-進入方向(SELL單與BUY相反)
   int  kBarFr;                //採用K棒數-起
   int  kBarTo;                //採用K棒數-迄
   bool comparePreK;           //與前K的值比對
   bool resultOpp;             //結果反向
   bool doLogger;              //是否寫出紀錄
};
