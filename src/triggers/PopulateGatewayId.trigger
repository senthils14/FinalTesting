trigger PopulateGatewayId on ChargentOrders__ChargentOrder__c (before insert, before update) {
//TO POPULATE THE GATEWAY RECORD 
    
    if (Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert) ) {
    
        List<ChargentBase__Gateway__c> gateWay = New List<ChargentBase__Gateway__c>();
            gateWay = [SELECT id 
                        FROM ChargentBase__Gateway__c 
                        WHERE Name = : System.label.GatewayName  AND ChargentBase__Active__c = true limit 1]; 
        
        for (ChargentOrders__ChargentOrder__c a : Trigger.new){
            if ( !gateWay.isEmpty() ) {                 
                a.ChargentOrders__Gateway__c  = gateWay[0].Id ;
            }
        }                
    }
}