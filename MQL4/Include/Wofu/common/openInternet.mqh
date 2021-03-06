#include <Wofu\\common\\importWininet.mqh>

//回傳值 如果<=0 則是未通.>0才能使用網路
#define DEFAULT_MSG_INTERNET_NOT_OPEN "Internet can NOT connect"
#ifndef MSG_INTERNET_NOT_OPEN
   #define MSG_INTERNET_NOT_OPEN DEFAULT_MSG_INTERNET_NOT_OPEN
#endif

int openInternet(int RetryCnt=3,bool fAlert=true)
{
   int InternetOP=0;
   for(int is=1;is<=RetryCnt;is++)
   {
      InternetOP=InternetOpenW(INTERNET_AGENT, 0 , "0", "0", 0);
      if( InternetOP<=0 )
      { 
         if(fAlert)Alert(MSG_INTERNET_NOT_OPEN);
         Sleep(500*is);
      }
      else
         break;   
   }
   return(InternetOP);
}