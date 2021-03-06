#include <Wofu\\enums\\CloseOrdersMode.mqh>
enum   ENUM_CLOSE_ORDERS_MODE_CHT  
{ 
   關閉定時平倉=CLOSE_ORDERS_MODE_DISABLE,
   單次平倉=CLOSE_ORDERS_MODE_ONETIME,
   每日平倉=CLOSE_ORDERS_MODE_DAILY,
   #ifdef ENABLE_CLOSE_ORDERS_MODE_WEEKLY
   每週平倉=CLOSE_ORDERS_MODE_WEEKLY,
   #endif
   #ifdef ENABLE_CLOSE_ORDERS_MODE_MONTHLY
   每月平倉=CLOSE_ORDERS_MODE_MONTHLY
   #endif
};
