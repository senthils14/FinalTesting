trigger ReversalEmailNotificationTrigger on Chargent_Queues__Batch_Queue_Item__c (after update) {
Map<Id,Chargent_Queues__Batch_Queue_Item__c> batchQueueItemMap = new Map<Id,Chargent_Queues__Batch_Queue_Item__c>();

List<Id> PaymentsTobeUpdated = New  List<Id>  () ;

    for(Chargent_Queues__Batch_Queue_Item__c payment : Trigger.new)
    {
        Chargent_Queues__Batch_Queue_Item__c oldRecord = Trigger.oldMap.get(payment.id);
           
            if(Trigger.isUpdate && payment.Payment_Status__c == 'R')
            {
                //PaymentEmailNotificationController.sendReversalEmailNotification(payment);
            }
                     
            // Added : Mariappan to update the chargent order display status 
            if(payment.Payment_Status__c != oldRecord.Payment_Status__c)
            {
                    batchQueueItemMap.put(payment.Chargent_Queues__Chargent_Order__c,payment);
            }
            
       
       // UPDATE NEXTWITHDRAWL DATE FOR EASY PAYMENTS
       if ( oldRecord.Chargent_Queues__Status__c <> 'Pending' &&  payment.Chargent_Queues__Status__c == 'Pending' ) {
           PaymentsTobeUpdated.add(payment.Chargent_Queues__Chargent_Order__c);
       }  
    }
    if(batchQueueItemMap.keySet().size() > 0)
    {
        BatchQueueItemTriggerHandler.updatePaymentStatus(batchQueueItemMap);
    }
    
    if(!PaymentsTobeUpdated.isEmpty() ) {
        BatchQueueItemTriggerHandler.UpdatePaymentNextWithDrawal(PaymentsTobeUpdated);
    }
    
}