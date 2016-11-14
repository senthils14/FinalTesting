trigger PreferencesUpdateNotification on Communication_Preferences__c (before insert,before update,after update) {
    
    list<Id> financeMap = new list<Id>(); 
    Map<Id,String> financeActType = new Map<Id,String>();
    
    //Update unsubscibe all for communication preferences
    if (Trigger.isBefore) {
        for(Communication_Preferences__c cp:trigger.new){            
         if( ( (cp.Payment_Reminders_via_Email__c )
               || (cp.Payment_Reminders_via_Text__c)          
               || (cp.Payment_Confirmations_via_Email__c)
               || (cp.Payment_Confirmations_via_Text__c)
               || (cp.EasyPay_Communications_via_Email__c)
               || (cp.EasyPay_Communications_via_Text__c) )
               && (cp.Unsubscribe_from_all__c)         
            )
            {       
              cp.Unsubscribe_from_all__c=false;
            }
                    
            //Commented below code, Keep the cp.Is_Comm_Pref_Set__c = True to receive CP Update Notification for Unsubscribe_from_all__c   
            //  if ( cp.Unsubscribe_from_all__c) {
            //      cp.Is_Comm_Pref_Set__c = False ;
            //  }
          }
            
    }
    
    //Bypass the CASS CALLOUT through Custom Label - this trigger will affect, while loading the data from integration profile/users
        String profilesString = label.IntegrationBypassProfileId;
        Set<string> profileList = new Set<string>(profilesString.trim().split(','));
        if(!profileList.contains(UserInfo.getProfileId())) {
    
        // Stop sending Text for the Suppress Finance Account (Fl_Suppress_All_Notifications__c )
        // Condition Starts
        Set<id> finId = new Set<id>();

        for (Communication_Preferences__c cp: Trigger.new){
            finId.add(cp.Finance_Account_Number__c);
        }
        
        Map<id,Finance_Account__c> finSuppress = new Map<id,Finance_Account__c>([select id,Fl_Suppress_All_Notifications__c from Finance_Account__c where id in: finId]);
        // Suppress Condition ends
        
            if(Trigger.isAfter && Trigger.isUpdate)
            {    
                for(Communication_Preferences__c cp:trigger.new)
                    financeMap.add(cp.Finance_Account_Number__c);
                
                for(Finance_Account__c f:[Select id,Honda_Brand__c ,Finance_Account_Number__c,(Select id,Text_Number__c, Payment_Reminders_via_Text__c, Payment_Confirmations_via_Text__c, EasyPay_Communications_via_Text__c from Communication_Preferences__r) from Finance_Account__c where Id IN:financeMap])
                    financeActType.put(f.id,f.Honda_Brand__c+'::'+f.Finance_Account_Number__c);
                
                for(Communication_Preferences__c cp:trigger.new){
                    Communication_Preferences__c oldCp = Trigger.oldMap.get(cp.Id);
                    //Trigger will be fired 
                    if(!finSuppress.get(cp.Finance_Account_Number__c).Fl_Suppress_All_Notifications__c || finSuppress.get(cp.Finance_Account_Number__c).Fl_Suppress_All_Notifications__c==null) { // Check the Finance Account is not Suppress
                        if((cp.Payment_Reminders_via_Text__c||cp.Payment_Confirmations_via_Text__c || cp.EasyPay_Communications_via_Text__c || cp.Unsubscribe_from_all__c) && cp.Text_Number__c!=null){
                                NotificationTextMsgs__c msgTemplate = null;
                                String isHonda, finAccNum;        
                                if(financeActType.containsKey(cp.Finance_Account_Number__c)){    
                                    isHonda = financeActType.get(cp.Finance_Account_Number__c).split('::')[0];
                                    finAccNum = financeActType.get(cp.Finance_Account_Number__c).split('::')[1];
                                }
                                if(!oldCp.Is_Comm_Pref_Set__c && cp.Is_Comm_Pref_Set__c)
                                {
                                    if(isHonda  !='AFS' ){
                                        msgTemplate = NotificationTextMsgs__c.getValues('WelcomToNotificationHonda');
                                    }else{
                                        msgTemplate = NotificationTextMsgs__c.getValues('WelcomToNotificationAcura');
                                    }
                                }
                                else if((!cp.Unsubscribe_from_all__c) && (cp.Text_Number__c != oldCp.Text_Number__c || cp.Payment_Reminders_via_Text__c != oldCp.Payment_Reminders_via_Text__c || cp.Days_Prior_Reminder__c != oldCp.Days_Prior_Reminder__c || cp.Payment_Confirmations_via_Text__c != oldCp.Payment_Confirmations_via_Text__c || cp.EasyPay_Communications_via_Text__c != oldCp.EasyPay_Communications_via_Text__c)){
                                    if(isHonda  !='AFS' ){
                                        msgTemplate = NotificationTextMsgs__c.getValues('UpdatedCommPrefHonda');
                                    }else{
                                        msgTemplate = NotificationTextMsgs__c.getValues('UpdatedCommPrefAcura');
                                    }
                                 }else if(cp.Unsubscribe_from_all__c){
                                        if(isHonda  !='AFS' ){
                                            msgTemplate = NotificationTextMsgs__c.getValues('OptOutNotificationHonda');
                                        }else{
                                            msgTemplate = NotificationTextMsgs__c.getValues('OptOutNotificationAcura');
                                        }
                                 }
                                if(msgTemplate != null && cp.Text_Number__c!=null){
                                    finAccNum  = finAccNum.substring(finAccNum.length()-4 );
                                    String template = msgTemplate.MsgTemplate__c;
                                    template = template.replaceAll('<Last 4 of Fin Acct Nmbr>',finAccNum );
                                    list<string> mobileNumbers = new list<string>();
                                    String mobilenum = cp.Text_Number__c;
                                    if(mobilenum!=null){
                                        mobileNum = mobileNum.replaceAll('\\(','').replaceAll('\\)','').replaceAll(' ','').replaceAll('-','');
                                        string countryCode = (mobileNum.substring(0,1)=='1')?'':'1';
                                        mobileNum = countryCode+mobileNum;
                                        
                                    }
                                    mobileNumbers.add(mobileNum);
                                    //Sajila: Adding condition check to avoid the ExactTargetService call from Test class
                                    if(!Test.isRunningTest())
                                    {
                                       //Start : Omkar added for the defect 114000 to avaoid recursive execustion of exacttarget service
                                        if(RecursiveRunClass.canIRun() != false)
                                        {
                                            // To avoid future handler after bounce back is updated
                                            if(!TaskHelper.istriggerExecutedSMS())
                                            ExactTargetService.sendSMS(mobileNumbers,true, true, template,cp.id);
                                       }    
                                    }   
                                        Task task = new Task();
                                        task.WhatId = cp.Id;
                                        task.Subject = 'SMS: COMMUNICATION PREFERENCES UPDATED';
                                        //task.WhoId = 
                                        task.ActivityDate = Date.today();
                                  //    task.Description = 'SMS: COMMUNICATION PREFERENCES UPDATED';  
                                        task.Description = template;  // Added by Senthil to include the SMS content in Description Field
                                        task.Priority = 'Normal';
                                        task.Status = 'completed';
                                        /*
                                        Event event = new Event();
                                        event.WhatId = cp.Id;
                                        event.Subject = 'SMS Sent - Event';
                                        event.ActivityDate = Date.today();
                                        event.ActivityDateTime = Datetime.now();
                                        event.EndDateTime = Datetime.now();
                                        */
                                        insert task;
                                        
                            }
                        }
                                
                    }
                       
                }
            }
      }
}