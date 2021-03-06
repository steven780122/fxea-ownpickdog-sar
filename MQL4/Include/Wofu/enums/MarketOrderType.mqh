/*
ORDER_TYPE_BUY       0 Buy operation
ORDER_TYPE_SELL      1 Sell operation
ORDER_TYPE_BUY_LIMIT  2 Buy limit pending order
ORDER_TYPE_SELL_LIMIT 3 Sell limit pending order
ORDER_TYPE_BUY_STOP   4 Buy stop pending order
ORDER_TYPE_SELL_STOP  5 Sell stop pending order
*/

enum ENUM_MARKET_ORDER_TYPE
{ 
   OD_BUY=ORDER_TYPE_BUY,
   OD_SELL=ORDER_TYPE_SELL,
   /*
   OD_BUY_STOP=ORDER_TYPE_BUY_STOP,
   OD_SELL_STOP=ORDER_TYPE_SELL_STOP,
   OD_BUY_LIMIT=ORDER_TYPE_BUY_LIMIT,
   OD_SELL_LIMIT=ORDER_TYPE_SELL_LIMIT,
   */
   OD_NA=-1,          //不明
   OD_ERROR=-999, //錯誤
};

//取得反向時 可以使用 getOppMaketOrderType