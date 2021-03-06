//+------------------------------------------------------------------+
//| 影像檔案                                                         |
//+------------------------------------------------------------------+
   #define BTN_CLOSE  "Files\\wofu\\close10.bmp"                           // 畫UI 用
   #resource "\\"+BTN_CLOSE                                                 // 把圖帶入 (bmp)，用resource compile後會打包就不用另給圖檔
//+------------------------------------------------------------------+
//| 載入函式庫                                                       |
//+------------------------------------------------------------------+
//----- [ 通用參數 ] -------
   #include <Wofu\\Parms.mqh>
//----- [ 畫面彈出訊息 ] -------
   #include <Wofu\\common\\ClassMsgPanel.mqh>
//----- [ 自動開啟網頁 ] -------
   #include <Wofu\\common\\ClassAutoOpenWeb.mqh>
//----- [ 廣告訊息 ] -------
   #include <Wofu\\common\\ClassShowBanner.mqh>
//----- [ 文字訊息 ] -------
   #include <Wofu\\common\\ClassShowInfo.mqh>
//----- [ Tick動作檢查與暫停原因 ] -------
   #include <Wofu\\common\\ClassTickStop.mqh>                                // EA暫停時會用到，像是關EA秀UI
//----- [ 右上選單 ] -------
   #include <Wofu\\common\\ClassMenu.mqh>                                     // 類似右上角的小UI可以連
//----- [ 在倉、歷史單統計 ] -------   
   #include <Wofu\\common\\ClassOrdersTradesInfo.mqh>                         // 超重要必看!!!  常用
//+------------------------------------------------------------------+
//| 全域參數設定                                                     |
//+------------------------------------------------------------------+
   int    g_lotsDigital=2;      //下單手數 小數位數，在INIT通過SetLotsDigital()由券商取得
   int    g_slipPage=5;         //允許滑價點數，無須重新詢價
   
   bool   g_isAuth=false;       //是否通過認證
   bool   g_isNewBar=false;     //是否產生新BAR
   bool   g_isTickWork=true;    //TICK是否作業  
   
//----- [ Tick動作檢查與暫停原因 ] -------
   string g_tickStop="_TICK_STOP";
   ClassTickStop g_tick_stop(SYS_CODE,EA_CODE,EA_NAME_E+g_tickStop); 
//----- [ 文字訊息 ] -------
   string g_infoNews="_INFO_NEWS";
   ClassShowInfo g_info_news(SYS_CODE,EA_CODE,EA_NAME_E+g_infoNews);
//----- [ 廣告訊息 ] -------   
   string g_bannerAD="_BANNER_AD";
   ClassShowBanner g_banner_ad(SYS_CODE,EA_CODE,EA_NAME_E+g_bannerAD); 
//----- [ 自動開啟網頁 ] -------
   ClassAutoOpenWeb g_auto_web(SYS_CODE,EA_CODE); 
//----- [ 畫面彈出訊息 ] -------
   string g_msgPanel="_MSG_PANEL";
   ClassMsgPanel g_msg_panel(SYS_CODE,EA_CODE,EA_NAME_E+g_msgPanel);
//----- [ 右上選單 ] -------
   string g_menu="_MENU";
   ClassMenu g_menu_right_upper(SYS_CODE,EA_CODE,EA_NAME_E+g_menu);
//----- [ 在倉、歷史單統計 ] -------   
   ClassOrdersTradesInfo g_orders_trades_info;
//----- [ 所需要進出場的資訊 ] -------   
   struct ReferenceTickInfo                                                      // 目前沒用到
   {
      bool entryBuy;
      bool entrySell;
      int orderTypeZigZag;
      int orderTypeMa;
      double ZzSlPriceBuy;
      double ZzSlPriceSell;
   };
   ReferenceTickInfo g_rti;
//+------------------------------------------------------------------+
//| 使用者參數設定                                                   |
//+------------------------------------------------------------------+
input string u_Remarks = EA_NAME_C+" Ver"+VERSION ;  //畫面註解
input int    orderMagicNumber = 8888;                //程式編號
input string orderCommentPrefix="";                  //下單註解
      int    orderSlPage = 5;                        //允許滑點點數
      
#ifdef AUTH_ENABLE
input string sepLineAuth = "＝＝＝＝";               //＝[ 認證 ]＝＝＝＝＝＝＝
input string u_sn="12345678ABcdEfG";                 //認證序號
input string u_email="myemail@mail.com";             //認證E-MAIL
input string u_mobile="";                            //認證手機號碼
#endif

input string sepLineEntry = "＝＝＝＝";              //＝[ 進場 ]＝＝＝＝＝＝＝
input string u_opWkNo="0123456";                     //進場時間-星期幾?0123456(0:周日)
input string u_opFrTo ="00:00-23:59";                //進場時間

string SepLineOp = "＝＝＝＝";                       //＝[ 進場控制 ]＝＝＝＝＝＝＝
#include <Wofu\\enums\\LotsMode.mqh>
input ENUM_LOTS_MODE u_LotsMode=0;                   //進場手數
//input double u_SlAmt=0.00;                           //輸入止損金額換算手數
input double u_Lots=0.00;                            //固定手數
input bool   u_CloseByOrder=true;                    //進單前先平反向單

//+------------------------------------------------------------------+
//| 風險控制-偵測                                                    |
//+------------------------------------------------------------------+
input string SepLineTp     = "＝＝＝＝＝＝＝＝＝＝＝";      //＝[ 風險控制偵測 ]＝＝＝＝＝＝＝
input int    u_TpPips=0;                                    //　　固定停利點數(Pips)
input int    u_SlPips=0;                                    //　　固定停損點數(Pips)
input string SepLineTpCheck = 
    "說明：如設定多個,先達到的會先執行，關閉EA則停止偵測";  //　< 停利偵測條件 >
input double        u_TpAmt=0;                              //　　金額(0關閉)
input double        u_TpBalanceRatio=0;                     //　　餘額比例(0關閉)
      double        u_TpEquityRatio=0;                      //　　淨值比例(0關閉)
input string SepLineSlCheck = 
    "說明：如設定多個,先達到的會先執行，關閉EA則停止偵測";  //　< 停損偵測條件 >
input double        u_SlAmt=0;                              //　　金額停損(0關閉)
input double        u_SlBalanceRatio=0;                     //　　餘額比例(0關閉)
      double        u_SlEquityRatio=0;                      //　　淨值比例(0關閉)