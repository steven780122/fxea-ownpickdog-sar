//網路
#define INTERNET_FLAG_PRAGMA_NOCACHE    0x00000100 // Forces the request to be resolved by the origin server, even if a cached copy exists on the proxy.
#define INTERNET_FLAG_NO_CACHE_WRITE    0x04000000 // Does not add the returned entity to the cache. 
#define INTERNET_FLAG_RELOAD            0x80000000 // Forces a download of the requested file, object, or directory listing from the origin server, not from the cache.
#define INTERNET_FLAG_KEEP_CONNECTION   0x00400000  // keep connection
#define INTERNET_AGENT "Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; Q312461)"

#import "wininet.dll"
   int InternetOpenW(string sAgent,int lAccessType,string sProxyName="",string sProxyBypass="",int lFlags=0 );
   int InternetOpenUrlW(int hInternetSession,string sUrl,string sHeaders="",int lHeadersLength=0,int lFlags=0,int lContext=0);
   int InternetReadFile(int hFile,uchar &sBuffer[],int lNumBytesToRead,int& lNumberOfBytesRead[]);
   int InternetCloseHandle(int hInet);
   int InternetConnectW(int, string, int, string, string, int, int, int); 
   int HttpOpenRequestW(int, string, string, int, string, int, string, int); 
   bool HttpSendRequestW(int, string, int, string, int);   
#import


