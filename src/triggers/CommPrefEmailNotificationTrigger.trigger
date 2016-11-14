trigger CommPrefEmailNotificationTrigger on Communication_Preferences__c(after update) {

    //Bypass the CASS CALLOUT through Custom Label - this trigger will affect, while loading the data from integration profile/users
        String profilesString = label.IntegrationBypassProfileId;
        Set<string> profileList = new Set<string>(profilesString.trim().split(','));
        if(!profileList.contains(UserInfo.getProfileId())) {
    
        // Stop sending Emails for the Suppress Finance Account (Fl_Suppress_All_Notifications__c )
        // Condition Starts
        Set<id> finId = new Set<id>();

        for (Communication_Preferences__c cp: Trigger.new){
            finId.add(cp.Finance_Account_Number__c);
        }
        
        Map<id,Finance_Account__c> finSuppress = new Map<id,Finance_Account__c>([select id,Fl_Suppress_All_Notifications__c from Finance_Account__c where id in: finId]);
        // Suppress Condition ends
      
      for (Communication_Preferences__c cp: Trigger.new) {
        //Sajila - Added isUpdate and isInsert Criteria
        if (Trigger.isAfter && Trigger.isUpdate) {
          Communication_Preferences__c oldCp = Trigger.oldMap.get(cp.Id);
          //Trigger will be fired 

          system.debug('Current Email: ' + cp.Email_Address__c + ' Old email ' + oldCp.Email_Address__c);
          system.debug('Current Email: ' + cp.Text_Number__c + ' Old email ' + oldCp.Text_Number__c);
          system.debug('Current Email: ' + cp.Payment_Reminders_via_Email__c + ' Old email ' + oldCp.Payment_Reminders_via_Email__c);
          system.debug('Current Email: ' + cp.Payment_Reminders_via_Text__c + ' Old email ' + oldCp.Payment_Reminders_via_Text__c);
          system.debug('Current Email: ' + cp.Days_Prior_Reminder__c + ' Old email ' + oldCp.Days_Prior_Reminder__c);
          system.debug('Current Email: ' + cp.Days_Prior_Reminder__c + ' Old email ' + oldCp.Days_Prior_Reminder__c);
          system.debug('Current Email: ' + cp.Payment_Confirmations_via_Email__c + ' Old email ' + oldCp.Payment_Confirmations_via_Email__c);
          system.debug('Current Email: ' + cp.EasyPay_Communications_via_Email__c + ' Old email ' + oldCp.EasyPay_Communications_via_Email__c);
          system.debug('Current Email: ' + cp.EasyPay_Communications_via_Text__c + ' Old email ' + oldCp.EasyPay_Communications_via_Text__c);
          system.debug('Current Email: ' + cp.Paperless_Statements_Letters__c + ' Old email ' + oldCp.Paperless_Statements_Letters__c);
          system.debug('Current Comm Set: ' + cp.Is_Comm_Pref_Set__c + ' Old Comm Set ' + oldCp.Is_Comm_Pref_Set__c);

       if ((cp.Is_Comm_Pref_Set__c) && (cp.Email_Address__c != oldCp.Email_Address__c || cp.Text_Number__c != oldCp.Text_Number__c || cp.Payment_Reminders_via_Email__c != oldCp.Payment_Reminders_via_Email__c || cp.Payment_Reminders_via_Text__c != oldCp.Payment_Reminders_via_Text__c || cp.Days_Prior_Reminder__c != oldCp.Days_Prior_Reminder__c || cp.Payment_Confirmations_via_Email__c != oldCp.Payment_Confirmations_via_Email__c || cp.Payment_Confirmations_via_Text__c != oldCp.Payment_Confirmations_via_Text__c || cp.EasyPay_Communications_via_Email__c != oldCp.EasyPay_Communications_via_Email__c || cp.EasyPay_Communications_via_Text__c != oldCp.EasyPay_Communications_via_Text__c || cp.Paperless_Statements_Letters__c != oldCp.Paperless_Statements_Letters__c || cp.Unsubscribe_from_all__c != oldCp.Unsubscribe_from_all__c)) {
            System.debug(cp.Unsubscribe_from_all__c);
            if (Trigger.isUpdate && !cp.Unsubscribe_from_all__c && (!finSuppress.get(cp.Finance_Account_Number__c).Fl_Suppress_All_Notifications__c || finSuppress.get(cp.Finance_Account_Number__c).Fl_Suppress_All_Notifications__c ==null)) 
                    PaymentEmailNotificationController.sendCommPrefConfirmation(cp, 'Saved');
            else if (Trigger.isUpdate && cp.Unsubscribe_from_all__c && (!finSuppress.get(cp.Finance_Account_Number__c).Fl_Suppress_All_Notifications__c || finSuppress.get(cp.Finance_Account_Number__c).Fl_Suppress_All_Notifications__c ==null))
                    PaymentEmailNotificationController.sendCommPrefConfirmationforUnsubscribe(cp, 'Unsubscribe');
          }
        }
      }
    }  
}