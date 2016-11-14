/*
Author      :  Sajila Kadayaprath
Description :  Test class for BankAccountTrigger, BankAccEmailNotificationTrigger and Preferbankcheck
Modified On :  9th Sep 2016
*/
@isTest
public class BankAccountTrigger_Test{
    private static TestMethod void testBankAccount(){
    
    //Set up Finance Account Data
    Finance_Account__c finacc = new Finance_Account__c();
    finacc.Finance_Account_Number__c='2541';
    finacc.Honda_Brand__c='HFS';
    insert finacc;
    
    //Set up Account Data
    Account a=new Account();
    a.Name='Test';
    insert a;
    
    Communication_Preferences__c cPref=new Communication_Preferences__c();
    cPref.Finance_Account_Number__c=finacc.Id;
    cPref.Customer__c=a.Id;
    cPref.Payment_Confirmations_via_Email__c=true;
    cPref.Payment_Reminders_via_Text__c=true;
    cPref.Text_Number__c='9992223334';
    insert cPref;
    
    Payment_Source__c paysourcerecord = new Payment_Source__c();
    paysourcerecord.Bank_Name__c='TestCitiBank';
    paysourcerecord.Payment_Source_Nickname__c='TestABC';
    paysourcerecord.Bank_Account_Type__c='TestSaving';
    paysourcerecord.Preferred_Payment_Source__c=true;
    paysourcerecord.Bank_Account_Number__c='Test1234567';
    paysourcerecord.Finance_Account_Number__c = finacc.Id;
    paysourcerecord.Status__c='Active';
    
    NotificationTextMsgs__c msgTemplate=new NotificationTextMsgs__c();
    msgTemplate.Name='AddedBankAccountHonda';
    msgTemplate.MsgTemplate__c='testtemplate';
    insert msgTemplate;
    
    NotificationTextMsgs__c msgTemplate1=new NotificationTextMsgs__c();
    msgTemplate1.Name='AddedBankAccountAcura';
    msgTemplate1.MsgTemplate__c='testtemplate';
    insert msgTemplate1;
    
    NotificationTextMsgs__c msgTemplate2=new NotificationTextMsgs__c();
    msgTemplate2.Name='DeletedBankAccountHonda';
    msgTemplate2.MsgTemplate__c='testtemplate';
    insert msgTemplate2;
    
    NotificationTextMsgs__c msgTemplate3=new NotificationTextMsgs__c();
    msgTemplate3.Name='DeletedBankAccountAcura';
    msgTemplate3.MsgTemplate__c='testtemplate';
    insert msgTemplate3;
    
    Test.startTest();
    insert paysourcerecord;
    
    paysourcerecord.Status__c='Deleted';
    update paysourcerecord; 
    
    delete paysourcerecord;    
    
    Test.stopTest();
    
    }
     private static TestMethod void testBankAccount2(){
    
    Finance_Account__c finacc = new Finance_Account__c();
    finacc.Finance_Account_Number__c='2541';
    finacc.Honda_Brand__c='AFS';
    insert finacc;
    
    Account a=new Account();
    a.Name='Test';
    insert a;
    
    Communication_Preferences__c cPref=new Communication_Preferences__c();
    cPref.Finance_Account_Number__c=finacc.Id;
    cPref.Customer__c=a.Id;
    cPref.Payment_Confirmations_via_Email__c=true;
    cPref.Payment_Reminders_via_Text__c=true;
    cPref.Text_Number__c='9992223334';
    insert cPref;
    
    Payment_Source__c paysourcerecord = new Payment_Source__c();
    paysourcerecord.Bank_Name__c='TestCitiBank';
    paysourcerecord.Payment_Source_Nickname__c='TestABC';
    paysourcerecord.Bank_Account_Type__c='TestSaving';
    paysourcerecord.Preferred_Payment_Source__c=true;
    paysourcerecord.Bank_Account_Number__c='Test1234567';
    paysourcerecord.Finance_Account_Number__c = finacc.Id;
    paysourcerecord.Status__c='Active';
    
    NotificationTextMsgs__c msgTemplate=new NotificationTextMsgs__c();
    msgTemplate.Name='AddedBankAccountHonda';
    msgTemplate.MsgTemplate__c='testtemplate';
    insert msgTemplate;
    
    NotificationTextMsgs__c msgTemplate1=new NotificationTextMsgs__c();
    msgTemplate1.Name='AddedBankAccountAcura';
    msgTemplate1.MsgTemplate__c='testtemplate';
    insert msgTemplate1;
    
    NotificationTextMsgs__c msgTemplate2=new NotificationTextMsgs__c();
    msgTemplate2.Name='DeletedBankAccountHonda';
    msgTemplate2.MsgTemplate__c='testtemplate';
    insert msgTemplate2;
    
    NotificationTextMsgs__c msgTemplate3=new NotificationTextMsgs__c();
    msgTemplate3.Name='DeletedBankAccountAcura';
    msgTemplate3.MsgTemplate__c='testtemplate';
    insert msgTemplate3;
    
    Test.startTest();
    insert paysourcerecord;
    
    paysourcerecord.Status__c='Deleted';
    update paysourcerecord; 
    
    delete paysourcerecord;   
    
    Test.stopTest();
    
    }
}