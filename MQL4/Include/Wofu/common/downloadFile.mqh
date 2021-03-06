#include <Wofu\\common\\openInternet.mqh>
#include <Wofu\\common\\writeFile1Line.mqh>
#define DOWNLOAD_FILE_MAXSIZE 20000000
void downloadFile
(
   string fileUrl,
   string fileName
)
{


   int    InternetOU=0,InternetRF=0,InternetRFRT[]={1};
   uchar  InternetRFBF[];
   //開啟網路連線
   int InternetOP=openInternet();
   if(InternetOP<=0)return;

   InternetOU = InternetOpenUrlW(InternetOP, fileUrl,"",0,INTERNET_FLAG_PRAGMA_NOCACHE,0);
   if(InternetOU<=0)return;
   ArrayResize(InternetRFBF,DOWNLOAD_FILE_MAXSIZE);
   InternetRF=InternetReadFile(InternetOU, InternetRFBF, DOWNLOAD_FILE_MAXSIZE , InternetRFRT);
   InternetCloseHandle(InternetOP);
   if(InternetRF<=0)return;
   ArrayResize(InternetRFBF,InternetRFRT[0]);
   writeFile1Line(fileName,InternetRFBF);
   InternetCloseHandle(InternetOP);
   return;



}

