//+------------------------------------------------------------------+
//| 訊息定義                                                         |
//+------------------------------------------------------------------+
   //------- [ FNO1 開始 ] ------------------
   const string MSG_DLL_NOT_ALLOW = "EA無法正常運作，原因:未開啟 允許導入動態連接庫(DLL)";
   const string MSG_LIB_NOT_ALLOW = "EA無法正常運作，原因:未開啟 允許導入外部EA交易";
   const string MSG_TRADE_NOT_ALLOW = "EA無法正常運作，原因:未開啟 允許實時自動交易";
   const string MSG_ACCOUNT_TRADE_EXPERT_NOT_ALLOWED = "EA無法正常運作，原因:券商禁止本帳戶使用EA交易";
   const string MSG_EXPERT_NOT_ENABLE = "EA啟動按鈕 未開啟，EA停止執行";
   const string MSG_INTERNET_NOT_OPEN = "EA無法運作，原因:本機網路異常";
   //------- [ FNO1 結束 ] ------------------
   const string MSG_AUTHFAIL_BTN_REAUTH = "重新認證";
   const string MSG_AUTHFAIL_GETERROR = "取得認證錯誤原因失敗";
   const string MSG_AUTHFAIL_AUTH_EXPIRE = "會員已到期";
   const string MSG_AUTHFAIL_AUTH_FAILBYSERVER = "主機認證失敗";
   const string MSG_AUTHFAIL_REAUTH = "取得認證失敗，請重新認證";
   const string MSG_AUTHFAIL_PROCERROR = "認證過程錯誤";
   
   const string MSG_IS_NOT_CONNECTED = "與券商斷線";
   const string MSG_IS_NOT_LOGIN = "MT4未登入成功！";
   const string MSG_TIMELIMIT = "使用期限";
   const string MSG_AUTH_Y = "智能授權成功";
   const string MSG_AUTH_N = "智能授權失敗";
   const string MSG_AUTH_PROC_START = "授權中... ";
   const string MSG_AUTH_PROC_ERROR_LENGTH = "認證資料錯誤！嘗試重新連線...";
   const string MSG_AUTH_PROC_ERROR_CONNECT = "連接主機失敗！嘗試重新連線...";
   const string MSG_AUTH_PROC_ERROR_LOCAL = "本機連線異常！嘗試重新連線...";
   //------- [ FNO1.A 結束 ] ------------------
   
   //------- [ 私有 開始 ] ------------------   
   const string MSG_ORDER_ENTRY_RESULT="策略檢查結果:";
   const string MSG_ERROR_SYMBOL_VOLUME_MIN="券商規定,手數必須≧ " ;
   const string MSG_ERROR_STOPLEVEL_TP="券商規定,停利距離必須≧ "; 
   const string MSG_ERROR_STOPLEVEL_SL="券商規定,停損距離必須≧ ";
   const string MSG_ENTRYMODE_TITLE="-[進場模式]----";
   //------- [ 私有 結束 ] ------------------  
   
   
   
   


   #define DEFAULT_MSG_IS_NOT_CONNECTED "與券商斷線" 
   #ifndef MSG_IS_NOT_CONNECTED
      #define MSG_IS_NOT_CONNECTED DEFAULT_MSG_IS_NOT_CONNECTED
   #endif 
   
   #define DEFAULT_MSG_IS_NOT_LOGIN "MT4未登入成功！" 
   #ifndef MSG_IS_NOT_LOGIN
      #define MSG_IS_NOT_LOGIN DEFAULT_MSG_IS_NOT_LOGIN
   #endif 
   
   
   const string MSG_MSG_PANEL_HELP="點擊 取得幫助(Help)";
   const string MSG_EA_TICK_STOP="智能程式(EA)暫停執行";
   const string MSG_EA_TICK_STOP_TIME_LIMIT="程式暫停執行";
   const string MSG_EA_TICK_STOP_REASON="暫停原因：%{TICK_STOP_REASON}";