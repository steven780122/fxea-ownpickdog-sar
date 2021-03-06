//+------------------------------------------------------------------+
//|                                          EagerFx.UT.ParmUser.mqh |
//|                                                 chchwa@gmail.com |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
input string LbTag = EA_NAME_C+" Ver"+VERSION ;  //畫面註解
input int    MagicNumber = 88882000;       //程式編號
input string OdCmPrefix="";                //下單註解
/*input */int    UserSlPage = 5;           //平倉允許滑點點數
input string SepLineAu = "＝＝＝＝";       //＝[ 認證 ]＝＝＝＝＝＝＝
input string UserEmail="myemail@mail.com"; //玩股網EMAIL
input string UserMobile="";                //認證手機號碼
/*input */string UserSN="12345678ABcdEfG"; //認證序號

input string SepLineOp = "■■■■■■■■■■■■■■■■■■■■";       //■■■■[ 進出控制 ]■■■■■■■■■■■■■■■■■■■■■■■■■
//bool   AutoOrder=true;                     //自動下單 
#include <FNO1\\enums\\TradeWayLang.mqh>
input ENUM_TRADE_WAY_CHT TradeWay=(ENUM_TRADE_WAY_CHT)TRADE_WAY_ONLY_LONG_AND_SHORT; //多空部位
input string OpWkNo="0123456";             //進場時間-星期幾?0123456(0:周日)
input string OpFrTo ="00:00-23:59";        //進場時間
input double OdLots=0;                     //下單固定手數
input double OdLotsAcc=0.0;                //下單比例手數 餘額1萬美元下多少手(0關閉)
//double OdLotsRatio=1.0;                    //虧損加碼比例

//Slippage = 30//允許最大滑點
input string   SepLineRt = "＝＝＝＝";       //＝[ 手數倍率調整 ]＝＝＝＝＝＝＝
input double   OpLotsRatio=0;                //調整倍率
input string   SepLineRtDesc1 = "符合以下任何一項，將手數調整為 調整倍率*下單手數";//--(說明)--

input bool   TimeLotsEnable=false;                 //＝[ 啟用時間調整 ]＝＝＝＝＝＝＝
input datetime OpRatioB=D'2017.01.01 00:00';       //時間調整-開始(本機)
input datetime OpRatioE=D'2017.01.01 00:00';       //時間調整-結束(本機)

#include <EagerFx\\Transformers\\userparms\\TrendTypeByADX.mqh>



input string SepLineOp1= "■■■■■■■■■■■■■■■■■■■■";       //■■■■[ 進出條件 ]■■■■■■■■■■■■■■■■■■■■■■■■■


enum ENUM_ENTRY_MODE 
{
不使用=0,
#ifdef TMODE_HA1
   HeikenAshi=TMODE_HA1,
#endif
#ifdef TMODE_RSI_DIFF1AND2
   RSI差異值=TMODE_RSI_DIFF1AND2,
#endif
#ifdef TMODE_RSI
   RSI=TMODE_RSI,
#endif
#ifdef TMODE_ICHIMOKU_CLOUD
   Ichimoku雲帶=TMODE_ICHIMOKU_CLOUD,
#endif
#ifdef TMODE_ICHIMOKU_TSKS
   Ichimoku快慢線=TMODE_ICHIMOKU_TSKS,
#endif
#ifdef TMODE_MA
   均線=TMODE_MA,
#endif
#ifdef TMODE_HA_MA
   均線與HA收盤=TMODE_HA_MA,
#endif
#ifdef TMODE_KBAR_MA
   均線與K棒收盤=TMODE_KBAR_MA,
#endif
#ifdef TMODE_PSAR
   PSAR=TMODE_PSAR,
#endif
#ifdef TMODE_HL
   過高破低=TMODE_HL,
#endif
#ifdef TMODE_KD
   KD黃金交叉=TMODE_KD,
#endif
#ifdef TMODE_MACD_MAIN
   MACD穿零軸=TMODE_MACD_MAIN,
#endif
#ifdef TMODE_WILLIAM
   威廉％Ｒ=TMODE_WILLIAM,
#endif

   //3X 預掛單
#ifdef TMODE_ZIGZAG1
   ZigZag預掛單1=TMODE_ZIGZAG1,
#endif
#ifdef TMODE_ZIGZAG
   ZigZag預掛單=TMODE_ZIGZAG,
#endif
#ifdef TMODE_ZZFIBO
   ZigZag黃金切割預掛單=TMODE_ZZFIBO,
#endif
};

enum ENUM_MUST_MODE {任一成立_但其他不可有反向訊號=0,必要條件=1,任一成立_不管其他=9,預掛單模式=10};
int    EntryModeArray[6];
int    EntryMustArray[6];
double EntryWieghtArray[6];
int    CloseModeArray[6];
int    CloseMustArray[6];
double CloseWieghtArray[6];
//必要條件 需要有其他任一條件同向
input ENUM_ENTRY_MODE EntryMode1=0;               //進場1
/*input */ENUM_MUST_MODE  EntryMust1=1;           //模式1
double EntryWeight1=1;                            //權重1

input ENUM_ENTRY_MODE EntryMode2=0;               //進場2
/*input */ENUM_MUST_MODE  EntryMust2=1;           //模式2
double EntryWeight2=1;                            //權重2

input ENUM_ENTRY_MODE EntryMode3=0;               //進場3
/*input */ENUM_MUST_MODE  EntryMust3=1;           //模式3
double EntryWeight3=1;                            //權重3

ENUM_ENTRY_MODE EntryMode4=0;    //進場4
ENUM_MUST_MODE  EntryMust4=1;    //模式4
double EntryWeight4=1;           //權重4

ENUM_ENTRY_MODE EntryMode5=0;    //進場5
ENUM_MUST_MODE  EntryMust5=1;    //模式5
double EntryWeight5=1;           //權重5

ENUM_ENTRY_MODE EntryMode6=0;    //進場6
ENUM_MUST_MODE  EntryMust6=1;    //模式6
double EntryWeight6=1;           //權重6

ENUM_ENTRY_MODE CloseMode1=0;    //出場1
ENUM_MUST_MODE  CloseMust1=1;    //模式1
double CloseWeight1=1;           //權重1

ENUM_ENTRY_MODE CloseMode2=0;    //出場2
ENUM_MUST_MODE  CloseMust2=1;    //模式2
double CloseWeight2=1;           //權重2

ENUM_ENTRY_MODE CloseMode3=0;    //出場3
ENUM_MUST_MODE  CloseMust3=1;    //模式3
double CloseWeight3=1;           //權重3

ENUM_ENTRY_MODE CloseMode4=0;    //出場4
ENUM_MUST_MODE  CloseMust4=1;    //模式4
double CloseWeight4=1;           //權重4

ENUM_ENTRY_MODE CloseMode5=0;    //出場5
ENUM_MUST_MODE  CloseMust5=1;    //模式5
double CloseWeight5=1;           //權重5

//系統使用 不可開放
ENUM_ENTRY_MODE CloseMode6=0;    //出場6
ENUM_MUST_MODE  CloseMust6=1;    //模式6
double CloseWeight6=1;           //權重6

input bool   OdRev=true;                   //市價單-與上次反向才進單
input int    StopGapPips=0;                //預掛單-外加掛單距離


input int    TpPips=0;                     //停利距離(Pips)
input int    SlPips=0;                     //停損距離(Pips)


input bool   TrSlEnable=false;             //＝[ 啟用追蹤止損 ]＝＝＝＝＝＝＝
input int    TrStPips=0;                   //追蹤止損：獲利達多少點數啟動
input int    TrSlPips=0;                   //追蹤止損：止損設置距離現價多少點數
input int    TrSpPips=0;                   //追蹤止損：每增加多少獲利點數移動一次


input bool   KTrSlEnable=false;             //＝[ 啟用K棒階梯止損 ]＝＝＝＝＝＝＝
input int    KTrStPips=0;                   //K棒階梯止損：獲利達多少點數啟動
int    KTrSpPips=0;                         //K棒階梯止損：每增加多少獲利點數移動一次(即時才有效)
int    KTrSlBarLowKFr=0;                    //K棒階梯止損：創新高往前幾根的低點-開始
int    KTrSlBarLowKTo=1;                    //K棒階梯止損：創新高往前幾根的低點-結束
bool   KTrMoveBHL=true;                     //K棒階梯止損：創新高才移動 
input ENUM_TIMEFRAMES KTrTf=PERIOD_CURRENT; //K棒階梯止損：判斷時區


input bool   PsarCloseEnable=false;                      //＝[ 啟用SAR出場 ]＝＝＝＝＝＝＝
input ENUM_TIMEFRAMES PsarCloseTf=PERIOD_CURRENT;        //SAR時區
input double PsarCloseStep=0.02;                         //SAR步長
input double PsarCloseMax=0.2;                           //SAR最大

input bool   RsiCloseEnable=false;                      //＝[ 啟用RSI出場 ]＝＝＝＝＝＝＝
input ENUM_TIMEFRAMES RsiCloseTf=PERIOD_CURRENT;        //RSI時區
input int                RsiClosePeriod=14;             //RSI週期設定
input ENUM_APPLIED_PRICE RsiCloseAp=PRICE_CLOSE;        //RSI價格
//input double RsiClose=10;                               //出場RSI值
input double RsiCloseUB=90;                             //BUY單出場RSI值
input double RsiCloseLB=10;                             //SELL單出場RSI值

   
   

input string SepLineTEC  = "■■■■■■■■■■■■■■■■■■■■■";         //■■■■[ 技術指標參數 ]■■■■■■■■■■■■■■■■■■■■■
#ifdef TMODE_HA1
   input string SepLineTHA  = "---------";        //---< HeikenAshi >---
   input ENUM_TIMEFRAMES    HaTf=PERIOD_CURRENT;  //時區
          int               HaKFr=1;              //HeikenAshi 判斷K棒數-起
   input int                HaKTo=1;              //HeikenAshi 判斷K棒數(在多少根K內變色都算)
   input bool               HaOdOpp=false;        //結果反向
   //輸入3：前HaKFr(0當根,1:前一根)~HaKTo根發生變色，且發生變色之後到HaKFr根(1:前一根)必須要一路同色
   
#endif 

#ifdef TMODE_RSI
   #include <EagerFx\\Transformers\\userparms\\orderTypeByRSI.mqh>
#endif 

#ifdef TMODE_RSI_DIFF1AND2   
   #include <EagerFx\\Transformers\\userparms\\orderTypeByRSI_DIFF1AND2.mqh>
#endif 

#ifdef TMODE_ICHIMOKU_PARM  
   #include <EagerFx\\Transformers\\userparms\\orderTypeByIchimoku.mqh>
#endif 


#ifdef TMODE_MA         
   #include <EagerFx\\Transformers\\userparms\\orderTypeByMA.mqh>

#endif 
   
#ifdef TMODE_HA_MA         
   input string SepLineTHAMA = "---------";           //---< 均線與HA收盤 >---
   input ENUM_TIMEFRAMES HaMaTf=PERIOD_CURRENT;       //時區
   input int HaMaPeriod=10;                           //MA時間週期
   input int HaMaShift=0;                             //MA平移
   input ENUM_MA_METHOD HaMaMethod=MODE_SMA;          //MA移動平均
   input ENUM_APPLIED_PRICE HaMaAppPrice=PRICE_CLOSE; //MA應用於(價額)
   input bool HaMaOdOpp=false;                        //結果反向
#endif 

#ifdef TMODE_KBAR_MA
   #include <EagerFx\\Transformers\\userparms\\orderTypeByKBAR_MA.mqh>
#endif 
      
#ifdef TMODE_PSAR
   input string SepLineTSAR = "---------";            //---< PSAR >---
   input ENUM_TIMEFRAMES SarTf=PERIOD_CURRENT;        //時區
   input double SarStep=0.02;                         //步長
   input double SarMax=0.2;                           //最大
   input bool SarOdOpp=false;                         //結果反向
#endif

#ifdef TMODE_HL   
   input string SepLineTHL  = "---------";            //---< 過高破低 >---
   input ENUM_TIMEFRAMES    HlTf=PERIOD_CURRENT;      //時區
   input int                HlKCnt=3;                 //判斷K棒數
   input bool HlOdOpp=false;                          //結果反向
#endif

#ifdef TMODE_KD         
   #include <EagerFx\\Transformers\\userparms\\orderTypeByStochastic.mqh>
#endif

#ifdef TMODE_MACD_MAIN         
   #include <EagerFx\\Transformers\\userparms\\orderTypeByMACD.mqh>
#endif

#ifdef TMODE_WILLIAM         
   #include <EagerFx\\Transformers\\userparms\\orderTypeByWPR.mqh>
#endif

#ifdef TMODE_ZIGZAG   
   #include <EagerFx\\Transformers\\userparms\\getPriceByZigZag.mqh>
   input bool   ZZOCO=false;                //預掛單-進場後刪除反向
#endif

#ifdef TMODE_ZZFIBO   
   #include <EagerFx\\Transformers\\userparms\\getPriceByZigZagFibo.mqh>

#endif

//input string SepLinePr  = "■■■■■■■■■■■■■■■■■■■■■";         //■■■■[ 畫面顯示 ]■■■■■■■■■■■■■■■■■■■■■■■■
bool MarketInfoEnable = false;                   //顯示報價資訊
bool TradingReportEnable = false;                //顯示交易統計

