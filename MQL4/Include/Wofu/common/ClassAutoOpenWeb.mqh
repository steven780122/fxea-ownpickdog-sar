#include <Wofu\\common\\openWebBroswer.mqh>
#include <Wofu\\common\\getInfoFromServer.mqh>
#include <Wofu\\common\\getInfoUrl.mqh>
#include <Wofu\\common\\logger.mqh>


class ClassAutoOpenWeb
  {
   //----
   public:
      //void setNew( string text,string url);
      ClassAutoOpenWeb(string fsysCode,string feaCode);
      void openByTimer();
   private:
      void setParm(string stringParm);

   protected: 
      string   sysCode;
      string   eaCode;
      string   aryParm[];
      int      openIndex;
      string   infoString;
      datetime getInfoTime;
      int      getinfoWaitSecs;
      datetime autoOpenTime;
      int      autoOpenWaitSecs;
   //---- 
  };
  
ClassAutoOpenWeb::ClassAutoOpenWeb(string fsysCode,string feaCode)
{
   getinfoWaitSecs =3600; //60分鐘抓一次 資料
   autoOpenWaitSecs=3600; //1個小時之後再開始彈出
   autoOpenTime=TimeCurrent();
   sysCode=fsysCode;
   eaCode=feaCode;
}

void ClassAutoOpenWeb::setParm(string stringParm)
{
   ArrayFree(aryParm);
   StringSplit(stringParm,',',aryParm);
   //if(MathMod(ArraySize(aryParm),3)==1)ArrayResize(aryParm,ArraySize(aryParm)+1);
   openIndex=1;
}

void ClassAutoOpenWeb::openByTimer()
{
  

      //每個多久重新讀取
      if(getInfoTime+getinfoWaitSecs<TimeCurrent())
      {
         infoString=getInfoFromServer(getInfoUrl(sysCode,eaCode,"getAutoOpenInfo"));
         logger(LOG_DEBUG,"Info[A] (*´▽`*)"+infoString);
         getInfoTime=TimeCurrent();
         
      }
      if(infoString!="ERROR")setParm(infoString);
      else{return;};

      //每隔多久彈出一次
      if(autoOpenTime+autoOpenWaitSecs>TimeCurrent())return;
      
      if(ArraySize(aryParm)<2)return;
      autoOpenWaitSecs=(int)StringToInteger(aryParm[0]);
      if(autoOpenWaitSecs==0)return;
      openWebBroswer(aryParm[openIndex]);
      autoOpenTime=TimeCurrent();
      openIndex++;
      if(openIndex>=ArraySize(aryParm))openIndex=1;
}