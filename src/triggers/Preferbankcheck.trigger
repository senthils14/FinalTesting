/*
Author :  Paramasivan A
Description : This trigger is for making an account as prferred account.
              It will also uncheck the existing preferred account when creating or updating a new preferred bank account on a finance account.
*/
trigger Preferbankcheck on Payment_Source__c (before insert,before update,after update, after delete) {
   
    // Before Insert Blog - To make sure the firstly created bank accounts will be the preferred bank account for the customers
    if(Trigger.isInsert && Trigger.isBefore)
    {
    Set<Id> finAccIds = new Set<Id>();
    Set<Id> finAccPreferredIds = new Set<Id>();
    List<Payment_Source__c> paymentSourceList = new List<Payment_Source__c>();
    Map<Id, integer > bankAccountMap = new Map <Id, integer>();
        for(Payment_Source__c currPayment:Trigger.new)
        {  
        
            finAccIds.add(currPayment.Finance_Account_Number__c);
            if(currPayment.Preferred_Payment_Source__c)
            {
                    finAccPreferredIds.add(currPayment.Finance_Account_Number__c);
            }
        }
        for( AggregateResult currResult  : [SELECT Finance_Account_Number__c , COUNT(Id) FROM Payment_Source__c where Finance_Account_Number__c In :finAccIds GROUP BY Finance_Account_Number__c ])
        {
            bankAccountMap.put((Id)currResult.get('Finance_Account_Number__c'), integer.valueof(currResult.get('expr0')));
        }
        for(Payment_Source__c currPaymentRecord : Trigger.new)
        {
            if(bankAccountMap.get(currPaymentRecord.Finance_Account_Number__c) == 0)
            {
                currPaymentRecord.Preferred_Payment_Source__c = true;
            }
        }
        if(finAccPreferredIds.size() > 0)
        {   
                for(Payment_Source__c pso:[select id,Preferred_Payment_Source__c from Payment_Source__c where Preferred_Payment_Source__c=true and Finance_Account_Number__c in:finAccPreferredIds]){
                pso.Preferred_Payment_Source__c = false;
                paymentSourceList.add(pso);
                }
                try{
                    update paymentSourceList;
                }
                catch(Exception ex){
                system.debug(ex.getMessage());
                }
        }
        
    }
    // Before update blog - used to update all the bank accounts as not a preferred when the customer changes a specific bank accounts as preferred bank account
    if(Trigger.isUpdate && Trigger.isBefore)
    {
    Set<Id> finAccIds = new Set<Id>();
    Set<Id> bankAccountId = new Set<Id>();
    List<Payment_Source__c> paymentSourceList = new List<Payment_Source__c>();
    for(Payment_Source__c currPaymentRecord : Trigger.new)
    {
    Payment_Source__c oldPaymentRecord = Trigger.oldMap.get(currPaymentRecord.id);
        if(currPaymentRecord.Preferred_Payment_Source__c == true && currPaymentRecord.Preferred_Payment_Source__c != oldPaymentRecord.Preferred_Payment_Source__c)
        {
                finAccIds.add(currPaymentRecord.Finance_Account_Number__c);
        }   
    }
    for(Payment_Source__c pso:[select id,Preferred_Payment_Source__c from Payment_Source__c where Preferred_Payment_Source__c=true and Finance_Account_Number__c in:finAccIds]){
        pso.Preferred_Payment_Source__c = false;
        paymentSourceList.add(pso);
    }
    try{
        update paymentSourceList;
    }
    catch(Exception ex){
    system.debug(ex.getMessage());
    }
        
    } 
    
    // IF PREFERED BANK ACCOUNT STATUS IS DELETED THEN MARK LATEST CREATED BANK ACCOUNT AS PREFERRED
    
    Set<Id> finAccIds = new Set<Id>();
    List<Payment_Source__c> paymentSourceList = new List<Payment_Source__c>();
    String currBankAccId = NULL ;
    
      if( Trigger.isAfter &&  Trigger.isUpdate ) { 
        
        for(Payment_Source__c currBankAccRecord : Trigger.new) {
            
            Payment_Source__c oldBankAccRecord = Trigger.oldMap.get(currBankAccRecord.id);
                
                if( currBankAccRecord.Status__c == 'Deleted' && currBankAccRecord.Status__c != oldBankAccRecord.Status__c && 
                        currBankAccRecord.Preferred_Payment_Source__c ) {
                
                    // GET THE FINANCE ACCOUNT ID 
                    finAccIds.add(currBankAccRecord.Finance_Account_Number__c);
                    // GET THE CURRENT BANK ACCOUNT RECORD ID
                    currBankAccId  = currBankAccRecord.Id ;
                }  
         }
      }   
         
      
      //WHEN BANK ACCOUNT RECORD IS DELETED
        if  ( Trigger.isAfter && Trigger.isDelete ) {
            for(Payment_Source__c currBankAccRecord : Trigger.Old) {
                if ( currBankAccRecord.Preferred_Payment_Source__c ) {
                    // GET THE FINANCE ACCOUNT ID 
                    finAccIds.add(currBankAccRecord.Finance_Account_Number__c);
                    // GET THE CURRENT BANK ACCOUNT RECORD ID
                    currBankAccId  = currBankAccRecord.Id ;
                }
            }
        }
         
        if ( !finAccIds.isEmpty() ){  
            // QUERY THE RELATED FINANCE ACCOUNT AND NEXT LATEST BANK ACCOUNT RECORD 
            List<Finance_Account__c> financeAccountList = [ SELECT id, (SELECT id,Status__c FROM Bank_Accounts__r 
                                                                            WHERE Id != :currBankAccId AND Status__c = 'Active' ORDER BY createdDate DESC Limit 1) 
                                                                    FROM Finance_Account__c WHERE id in:finAccIds ];
            
            SYSTEM.DEBUG(' bank account ==> ' + financeAccountList[0].Bank_Accounts__r );
            // ITERATE THE OTHER BANK ACCOUNT TO THE SAME FINANCE ACCOUNT AND MARK IT AS PREFFERED
            for(Finance_Account__c finAcc : financeAccountList ) {
        
                for(Payment_Source__c bankAcc : finAcc.Bank_Accounts__r) {
                    Payment_Source__c paymentSourceIns = new Payment_Source__c();
                    paymentSourceIns.id = bankAcc.id ;
                    paymentSourceIns.Preferred_Payment_Source__c = true;
                    paymentSourceList.add(paymentSourceIns);
                }
            }
    
            
            // UPDATE THE BANK ACCOUNT RECORD
            if(paymentSourceList.size() > 0) {
        
                try{
                    update paymentSourceList;
                } catch(Exception ex){
                    system.debug(ex.getMessage());
                }
            }
        }
        
    
}