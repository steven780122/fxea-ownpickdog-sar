class ClassNewBar
  {
   //----
   public:
      ClassNewBar();
      bool isNewBar(string symbol,ENUM_TIMEFRAMES timeframe,bool firstreturn);

   protected: 
      datetime m_TOld;
   //---- 
  };
  
ClassNewBar::ClassNewBar()
{
   this.m_TOld=-1;
};

bool ClassNewBar::isNewBar(string symbol,ENUM_TIMEFRAMES timeframe,bool firstreturn)
  {
      //---- getting the time of the current bar appearing
      datetime TNew=datetime(SeriesInfoInteger(symbol,timeframe,SERIES_LASTBAR_DATE));
      if(this.m_TOld==-1 && !firstreturn)
      { 
         this.m_TOld=TNew;
         return(false);
      }
      
      if(TNew!=this.m_TOld && TNew) // checking for a new bar
        {
         this.m_TOld=TNew;
         return(true); // a new bar has appeared!
        }
      //----
      return(false); // there are no new bars yet!
  }

//---- class constructor    

