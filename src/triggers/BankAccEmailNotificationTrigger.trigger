trigger BankAccEmailNotificationTrigger on Payment_Source__c (after insert, after update) {
    
    //Bypass the Email Service through Custom Label - this trigger will affect, while loading the data from integration profile/users
        String profilesString = label.IntegrationBypassProfileId;
        Set<string> profileList = new Set<string>(profilesString.trim().split(','));
        if(!profileList.contains(UserInfo.getProfileId())) {   
    
        // Stop sending Text for the Suppress Finance Account (Fl_Suppress_All_Notifications__c )
        // Condition Starts
        Set<id> finId = new Set<id>();

        for (Payment_Source__c src: Trigger.new){
            finId.add(src.Finance_Account_Number__c);
        }
        
        Map<id,Finance_Account__c> finSuppress = new Map<id,Finance_Account__c>([select id,Fl_Suppress_All_Notifications__c from Finance_Account__c where id in: finId]);
        // Suppress Condition ends
        
        for(Payment_Source__c src: Trigger.new)
        {
            if(Trigger.isInsert && (!finSuppress.get(src.Finance_Account_Number__c).Fl_Suppress_All_Notifications__c || finSuppress.get(src.Finance_Account_Number__c).Fl_Suppress_All_Notifications__c ==null))
                PaymentEmailNotificationController.sendBankAccEmailConfirmation(src, 'Addition');
            else if(Trigger.isUpdate && src.Status__c == 'Deleted' && (!finSuppress.get(src.Finance_Account_Number__c).Fl_Suppress_All_Notifications__c || finSuppress.get(src.Finance_Account_Number__c).Fl_Suppress_All_Notifications__c ==null))
                PaymentEmailNotificationController.sendBankAccEmailConfirmation(src, 'Deletion');
        }
    }   
}