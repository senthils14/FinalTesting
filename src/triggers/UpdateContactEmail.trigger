trigger UpdateContactEmail on Communication_Preferences__c(before update) {

    UpdateContactEmailTriggerHandler.onBeforeActions(Trigger.new);
}