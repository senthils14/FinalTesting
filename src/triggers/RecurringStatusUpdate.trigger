trigger RecurringStatusUpdate on ChargentOrders__ChargentOrder__c (before insert,before update,after insert,after update) {

    // 114159 start - Prakash
    //Added String constants for QC #114159 
    final String NEW_PAYMENT = 'New';
    final String MODIFIED_PAYMENT = 'Modified';
    final String CANCELLED_PAYMENT = 'Cancelled';   
    // 114159 end- Prakash

    if ( TriggerRun.firstRun ) {
        set<id> financeid = new set<id>(); 
        list<ChargentOrders__ChargentOrder__c> chargentOrderlist = new list<ChargentOrders__ChargentOrder__c>();
        list<Finance_Account__c> finaccount =new list<Finance_Account__c>();
        
        String RecurringRecordTypeId = Schema.SObjectType.ChargentOrders__ChargentOrder__c.getRecordTypeInfosByName().get('Recurring Payment').getRecordTypeId();
        
        if (Trigger.isBefore && Trigger.isInsert) 
        {  
            for(ChargentOrders__ChargentOrder__c chargentOrderRecord:Trigger.new)
            {
                financeid.add(chargentOrderRecord.Finance_Account_Number__c);
            }
                
            
            for(ChargentOrders__ChargentOrder__c  pso:[select id,Payment_Display_Status__c,ChargentOrders__Payment_Status__c,Duplicate_Key_Tracker__c,Finance_Account_Number__r.Finance_Account_Number__c from ChargentOrders__ChargentOrder__c where Payment_Display_Status__c = 'Stopped' and Finance_Account_Number__c in:financeid and recordtype.developername = 'Recurring_Payment']){
                // Added by Mariappan for defect 112904 , above chargent status and our local status should be updated as per the latest PCD
                pso.ChargentOrders__Payment_Status__c = 'Complete';
                pso.Payment_Display_Status__c = 'Cancelled';
                //Below Line Change added by Jayashree for the defect 114165
                pso.Duplicate_Key_Tracker__c = pso.Finance_Account_Number__r.Finance_Account_Number__c + 'Recurring_Payment' + 'INACTIVE' + Datetime.now();
                chargentOrderlist.add(pso);
            }
            
                
            if(chargentOrderlist.size()>0){
            try{
               update chargentOrderlist;
            }
            catch(Exception ex){
                system.debug(ex.getMessage());
            }
            } 
            
        }
        
        
        
        //Bypass the CASS CALLOUT through Custom Label - this trigger will affect, while loading the data from integration profile/users
        String profilesString = label.IntegrationBypassProfileId;
        Set<string> profileList = new Set<string>(profilesString.trim().split(','));
        if(!profileList.contains(UserInfo.getProfileId())) {
        
        // CASS SYSTEM HTTP CALLOUT LOGIC 
         if ( !system.isBatch()  ) {
            if ( ( Trigger.isAfter && trigger.isInsert ) || ( Trigger.isBefore && trigger.isUpdate) ) {
            
                if (  Trigger.isAfter && trigger.isInsert ) {  
                    for(ChargentOrders__ChargentOrder__c a: Trigger.new) {  
                        if ( a.RecordTypeId != RecurringRecordTypeId ) {
                            CASSCallOut.MakeHttpCall( a.Id,NEW_PAYMENT); // 114159 - Prakash
                        }
                    }
        
                } else if ( Trigger.isBefore && trigger.isUpdate  ) {
                    
                    for ( ChargentOrders__ChargentOrder__c a : trigger.New ) {
                        
                        // OLD FIELD VALUES TO COMPARE, WHEN ANY FOLLOWING FIELDS ARE CHANGED TO MAKE THE CASS CALLOUT
                        ChargentOrders__ChargentOrder__c x = System.Trigger.oldMap.get(a.Id);
                             
                         // MAKE CASS CALLOUT WHEN THERE IS CHANGE IN FOLLOWING FIELDS && STATUS IS PENDING
                         if  ( a.RecordTypeId != RecurringRecordTypeId  && a.Payment_Display_Status__c == 'Pending'  && 
                              ( x.ChargentOrders__Payment_Start_Date__c != a.ChargentOrders__Payment_Start_Date__c ||
                                x.ChargentOrders__Charge_Amount__c      != a.ChargentOrders__Charge_Amount__c      ||
                                x.Payment_Source_Nickname__c            != a.Payment_Source_Nickname__c  ) ) {
                                   
                                CASSCallOut.MakeHttpCall( a.Id,MODIFIED_PAYMENT);  // 114159 - Prakash 
                                   
                          }  else if (  a.RecordTypeId != RecurringRecordTypeId && ( x.Payment_Display_Status__c <> 'Cancelled' && a.Payment_Display_Status__c == 'Cancelled' ) ) {
                              // MAKE CASS CALLOUT WHEN PAYMENT IS GETTING CANCELLED
                              CASSCallOut.MakeHttpCall( a.Id, CANCELLED_PAYMENT );  // 114159 - Prakash
                          }
                       TriggerRun.firstRun = False ;       
                    }
                    
                
                }
             }
            }
        }    
        
        
        
        
    
    
    
    }
    
    
    
}