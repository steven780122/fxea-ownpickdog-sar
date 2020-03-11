input string SepLineTZZ  = "---------";            //---< Zigzag預掛單 >---
input ENUM_TIMEFRAMES    ZZTf=PERIOD_CURRENT;      //時區
input int                ZZDepth=12;               //Depth
//設置高低點是相對與過去多少個k棒
input int                ZZDeviation=5;            //Deviation
//重新計算高低點時與前一高低點的相對點差
input int                ZZBackStep=3;             //BackStep
//設置回退計算的k棒個數
int ZZStart=0;
int ZZCnt=500;
input bool ZZOdOpp=false;                          //結果反向
