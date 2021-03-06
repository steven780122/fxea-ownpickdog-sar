#include <Wofu\\trade\\getLotsDigital.mqh>
const  string EA_CODE  =EA_NAME_E+"V"+StringSubstr(IntegerToString((int)(StringToDouble(VERSION)*10)),0,2);
const  string TERM_PATH=TerminalInfoString(TERMINAL_PATH);
const  int    LOTS_DIGITAL=getLotsDigital(_Symbol);
struct MqlTradeReq 
  { 
   ulong                         magic;            // Expert Advisor ID (magic number) 
   ulong                         order;            // Order ticket 
   string                        symbol;           // Trade symbol 
   double                        volume;           // Requested volume for a deal in lots 
   double                        price;            // Price 
   double                        sl;               // Stop Loss level of the order 
   double                        tp;               // Take Profit level of the order 
   ulong                         deviation;        // Maximal possible deviation from the requested price 
   ENUM_ORDER_TYPE               type;             // Order type 
   datetime                      expiration;       // Order expiration time (for the orders of ORDER_TIME_SPECIFIED type) 
   string                        comment;          // Order comment 
   ulong                         position;         // Position ticket 
   ulong                         position_by;      // The ticket of an opposite position 
  };