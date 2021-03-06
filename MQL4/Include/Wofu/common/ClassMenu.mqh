#include <Wofu\\common\\getInfoUrl.mqh>
#include <Wofu\\common\\openWebBroswer.mqh>
#include <Wofu\\draw\\deleteAllObjects.mqh>
#include <Wofu\\draw\\writeImage.mqh>

#define IMG_MENU_1 "Files\\Wofu\\menu1.bmp"
#define IMG_MENU_2 "Files\\Wofu\\menu2.bmp"
#define IMG_MENU_3 "Files\\Wofu\\menu3.bmp"
#define IMG_MENU_4 "Files\\Wofu\\menu4.bmp"

#resource "\\Files\\Wofu\\menu1.bmp"
#resource "\\Files\\Wofu\\menu2.bmp"
#resource "\\Files\\Wofu\\menu3.bmp"
#resource "\\Files\\Wofu\\menu4.bmp"

class ClassMenu
  {
   //----
   public:
      void setLocation( int fmsgPanelX,int fmsgPanelY,int fmsgPanelW=0,int fmsgPanelH=0  );
      void show(bool enable);
      void click(string fsparam);
      ClassMenu(string fsysCode,string feaCode,string fobjId);      
   private:
   protected: 
      string sysCode;
      string eaCode;
      string objId;
      int    objPanelX;
      int    objPanelY;
      int    objPanelW;
      int    objPanelH;
   //---- 
  };
ClassMenu::ClassMenu(string fsysCode,string feaCode,string fobjId)
{
   objId=fobjId;
   sysCode=fsysCode;
   eaCode=feaCode;
};
  
void ClassMenu::show(bool enable)
{
   if(enable)
   {
       writeImage(objId+"1","::"+IMG_MENU_1, 95,75,clrSnow,CORNER_RIGHT_UPPER,false);
       writeImage(objId+"2","::"+IMG_MENU_2, 65,75,clrSnow,CORNER_RIGHT_UPPER,false);
       writeImage(objId+"3","::"+IMG_MENU_3, 35,75,clrSnow,CORNER_RIGHT_UPPER,false);
       writeImage(objId+"4","::"+IMG_MENU_4,  5,75,clrSnow,CORNER_RIGHT_UPPER,false);
   }
   else
      if(ObjectFind(objId+"1")>=0)deleteAllObjects(DELETE_OBJECT_BY_PREFIX,objId);
}


void ClassMenu::click(string fsparam)
{
   if(fsparam==objId+"1")
      openWebBroswer(getInfoUrl(SYS_CODE,EA_CODE,"menuDocs"));        //使用說明
   else if(fsparam==objId+"2")
      openWebBroswer(getInfoUrl(SYS_CODE,EA_CODE,"menuResearch"));    //研究報告
   else if(fsparam==objId+"3")
      openWebBroswer(getInfoUrl(SYS_CODE,EA_CODE,"menuLearn"));       //線上學習
   else if(fsparam==objId+"4")
      openWebBroswer(getInfoUrl(SYS_CODE,EA_CODE,"menuMyWofu"));      //我的沃富

}