#include <Wofu\\draw\\createRectLabel.mqh>
#include <Wofu\\draw\\writeLabel.mqh>
#include <Wofu\\common\\openWebBroswer.mqh>
#include <Wofu\\common\\downloadFile.mqh>
#include <Wofu\\common\\getInfoFromServer.mqh>
#include <Wofu\\common\\getInfoUrl.mqh>
#include <Wofu\\draw\\deleteAllObjects.mqh>
#include <Wofu\\draw\\writeImage.mqh>


class ClassShowBanner
  {
   //----
   public:
      //void setNew( string text,string url);
      ClassShowBanner(string fsysCode,string feaCode,string fobjId);
      void show(bool enable);
      void click();
      void clickClose();
   private:
      void setParm(string stringParm);
      void setUrl(string fimageUrl,string fImageFile,string fUrl);
      bool showBanner();
      void download(string fImageFile);
   protected: 
      string sysCode;
      string eaCode;
      string objId;
      int    objX;
      int    objY;
      int    objW;
      int    objH;
      string clickUrl;
      string imageFile;
      string imageUrl;
      string Parm;
      string aryParm[];
      int    showIndex;
      datetime getInfoTime;
      int      getinfoWaitSecs;
      string   infoString;
      datetime clickCloseTime;
      int      clickCloseSecs;
      
   //---- 
  };
  
ClassShowBanner::ClassShowBanner(string fsysCode,string feaCode,string fobjId)
{
   objId=fobjId;
   sysCode=fsysCode;
   eaCode=feaCode;
   objX=10;
   objY=5;
   objW=728;
   objH=90;
   getinfoWaitSecs=1800;
   clickCloseSecs=3600;
   showIndex=0;
   clickCloseTime=D'2000.01.01 00:00';
};


void ClassShowBanner::show(bool enable)
{
   
   if(enable && showBanner()){}
   else
      if(ObjectFind(objId)>=0)deleteAllObjects(DELETE_OBJECT_BY_PREFIX,objId);
}

void ClassShowBanner::click()
{
   if(clickUrl!="")openWebBroswer(clickUrl);
}


void ClassShowBanner::setParm(string stringParm)
{
   ArrayFree(aryParm);
   StringSplit(stringParm,',',aryParm);
   if(MathMod(ArraySize(aryParm),3)==1)ArrayResize(aryParm,ArraySize(aryParm)+1);
}

void ClassShowBanner::setUrl(string fimageUrl,string fImageFile,string fUrl)
{
   imageUrl=fimageUrl;
   imageFile=fImageFile;
   clickUrl=fUrl;
   
}

bool ClassShowBanner::showBanner()
{
   //點擊關閉
   if(clickCloseTime+clickCloseSecs>TimeCurrent())return(false);
   //每個多久重新讀取
   if(getInfoTime+getinfoWaitSecs<TimeCurrent())
   {
      infoString=getInfoFromServer(getInfoUrl(sysCode,eaCode,"getBannerInfo"));
      logger(LOG_DEBUG,"Info[B] (*´▽`*)"+infoString);
      getInfoTime=TimeCurrent();
   }
   
   
   
   if(infoString!="ERROR")setParm(infoString);
   else{return(false);};
   
   
   
   

   
   if(ArraySize(aryParm)<3)return(false);
   setUrl(aryParm[showIndex],aryParm[showIndex+1],aryParm[showIndex+2]);
   if(!FileIsExist(imageFile))downloadFile(imageUrl,imageFile);
   writeImage(objId,"\\Files\\"+imageFile,objX,objY,clrSnow,CORNER_LEFT_LOWER,false);
   writeImage(objId+"BtnClose","::"+BTN_CLOSE,objX+objW-10,objY+objH-10,clrSnow,CORNER_LEFT_LOWER,false);
   showIndex+=3;
   if(showIndex>=ArraySize(aryParm))showIndex=0;
   return(true);
}

void ClassShowBanner::clickClose()
{
   clickCloseTime=TimeCurrent();
   show(false);
}
