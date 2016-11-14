trigger PaymentEmailNotificationTrigger on ChargentOrders__ChargentOrder__c (after insert, after update) {

    if(!TaskHelper.istriggerExecuted()||Test.isRunningTest()){
    //if(!TaskHelper.istriggerExecuted()){  
        // Stop sending Text for the Suppress Finance Account (Fl_Suppress_All_Notifications__c )
        // Condition Starts
        Set<id> finId = new Set<id>();

        for (ChargentOrders__ChargentOrder__c co: Trigger.new){
            finId.add(co.Finance_Account_Number__c);
        }
    
        Map<id,Finance_Account__c> finSuppress = new Map<id,Finance_Account__c>([select id,Fl_Suppress_All_Notifications__c from Finance_Account__c where id in: finId]);
        // Suppress Condition ends
        
        // Bypass the Email Service through Custom Label - this trigger will affect, while loading the data from integration profile/users
        String profilesString = label.IntegrationBypassProfileId;
        Set<string> profileList = new Set<string>(profilesString.trim().split(','));
        if(!profileList.contains(UserInfo.getProfileId())) {
        
            for(ChargentOrders__ChargentOrder__c payment : Trigger.new)
            {
                if(Trigger.isInsert && (!finSuppress.get(payment.Finance_Account_Number__c).Fl_Suppress_All_Notifications__c || finSuppress.get(payment.Finance_Account_Number__c).Fl_Suppress_All_Notifications__c ==null))
                    PaymentEmailNotificationController.sendPymtEmailConfirmation(payment, 'Creation');
                else if(Trigger.isUpdate && payment.Payment_Display_Status__c == 'Pending' && (!finSuppress.get(payment.Finance_Account_Number__c).Fl_Suppress_All_Notifications__c || finSuppress.get(payment.Finance_Account_Number__c).Fl_Suppress_All_Notifications__c ==null))
                    PaymentEmailNotificationController.sendPymtEmailConfirmation(payment, 'Modification');
                else if(Trigger.isUpdate && payment.Payment_Display_Status__c == 'Cancelled' && (!finSuppress.get(payment.Finance_Account_Number__c).Fl_Suppress_All_Notifications__c || finSuppress.get(payment.Finance_Account_Number__c).Fl_Suppress_All_Notifications__c ==null))
                    PaymentEmailNotificationController.sendPymtEmailConfirmation(payment, 'Cancellation');
                else if(Trigger.isUpdate && payment.Payment_Display_Status__c == 'Suspended' && (!finSuppress.get(payment.Finance_Account_Number__c).Fl_Suppress_All_Notifications__c || finSuppress.get(payment.Finance_Account_Number__c).Fl_Suppress_All_Notifications__c ==null))
                    PaymentEmailNotificationController.sendPymtEmailConfirmation(payment, 'Suspension');    
            }
        }
        TaskHelper.setTriggerAsExecuted();

    }    
}