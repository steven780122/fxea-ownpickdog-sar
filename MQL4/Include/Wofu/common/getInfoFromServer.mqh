#include <Wofu\\common\\openInternet.mqh>
#define GET_INFO_SERVER_MAXSIZE 20000
string getInfoFromServer
(
   string fileUrl
)
{


   int    InternetOU=0,InternetRF=0,InternetRFRT[]={1};
   uchar  InternetRFBF[];
   //開啟網路連線
   int InternetOP=openInternet();
   if(InternetOP<=0)return("ERROR");
   InternetOU = InternetOpenUrlW(InternetOP, fileUrl,"",0,INTERNET_FLAG_NO_CACHE_WRITE||INTERNET_FLAG_PRAGMA_NOCACHE||INTERNET_FLAG_RELOAD,0);
   if(InternetOU<=0)return("ERROR");
   ArrayResize(InternetRFBF,GET_INFO_SERVER_MAXSIZE);
   InternetRF=InternetReadFile(InternetOU, InternetRFBF, GET_INFO_SERVER_MAXSIZE , InternetRFRT);
   InternetCloseHandle(InternetOP);
   if(InternetRF<=0)return("ERROR");
   ArrayResize(InternetRFBF,InternetRFRT[0]);
   return(CharArrayToString(InternetRFBF,0,InternetRFRT[0],CP_UTF8));
   return("ERROR");
}

