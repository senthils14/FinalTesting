/*
 
 Author     :Paramasivan Arunachalam
 Description :This class purpose is to support the bankaccount landing page.
              It contains all the logic to handle the business rule around the bankaccount landing page.
              It will display all the bankaccounts related to the provided finance account number    
*/

public  class BankAcctLandingController{
public list<Payment_Source__c> paymentSource{get;set;}
public String finnumber;
public string bankaccnickname{get;set;}
public string bankaccid{get;set;}
public string bankacciddelete{get;set;}
public boolean displayPopup{get;set;}
public boolean displayPopUpDelete{get;set;}
public boolean accountoverview{get;set;}
public boolean displayPopUpUnDelete{get;set;}  
public Payment_Source__c deletepopuppaymentsource{get;set;}
public list<Finance_Account__c> Financeacclist{get;set;}
public boolean rename{get;set;}
public string selected{get;set;}
public boolean disablenewbutton{get;set;}
public boolean csat{get;set;}
public boolean Honda{get;set;}
public String buttonStyle{get;set;}
public String buttonStyle3{get;set;}
public Boolean mobile {get;set;}

public BankAcctLandingController(){ 
mobile = false;
    Honda = true;
    csat = false;
    selected = '';
    bankaccnickname = '';
    bankaccid = '';
    accountoverview = false;
    bankacciddelete = '';
    disablenewbutton=false;
    rename = false;
    displayPopup = false;
    displayPopUpDelete = false;
    displayPopUpUnDelete = false;
    finnumber = '';
    buttonStyle='primary-btn btn-1';
    buttonStyle3='primary-btn btn-3';
    //buttonStyle='inactive-btn';
    Financeacclist = new list<Finance_Account__c>();
    paymentSource = new list<Payment_Source__c>(); 
    finnumber = Apexpages.currentPage().getParameters().get('finnumber');
    
    //  For IE9
    Apexpages.currentPage().getHeaders().put('p3p', 'CP="HONDA"');
    
     
        
        if(Apexpages.currentPage().getParameters().get('isReadOnly')!=null && Apexpages.currentPage().getParameters().get('isReadOnly')!='' && Apexpages.currentPage().getParameters().get('isReadOnly')=='true'){
           csat = true;
           buttonStyle3='primary-btn btn-3 inactive-btn';
        }
        
        if(finnumber != '' && finnumber != null){
                list<Finance_Account__c> financelist =[select id,Honda_Brand__c from Finance_Account__c where Finance_Account_Number__c=:finnumber];
                if(financelist.size()>0){
                if(financelist[0].Honda_Brand__c == 'AFS'){
                 Honda = false;
                }
                else{
                 Honda = true;
                }
                }
                fetchpaymentsource();
    
        }
     
}

Public PageReference init(){
    
    System.debug(' *** Init *** ==>' );
    
    if ( Apexpages.currentPage().getParameters().get('finnumber') <> NULL ) {
        if ( !UserSecurity.ValidateFinNumber(Apexpages.currentPage().getParameters().get('finnumber')) ) {
        
             pagereference p = new pagereference('/apex/UserSecurityNotAuthorized');
              p.setRedirect(true);
            return p;
        }
    }
    
    return null;
}

public void fetchpaymentsource(){

        paymentSource = new list<Payment_Source__c>();
        /*Changes made for defect # 113209 */
        //paymentSource = [select id,Bank_Name__c,Payment_Source_Nickname__c,Bank_Account_Type__c,Preferred_Payment_Source__c,Last_4__c,Bank_Account_Number__c,Finance_Account_Number__c,Creation_Date__c from Payment_Source__c where Finance_Account_Number__r.Finance_Account_Number__c=:finnumber and Status__c = 'Active' ORDER BY Id DESC]; 
       paymentSource = [select id,Bank_Name__c,Payment_Source_Nickname__c,Bank_Account_Type__c,Preferred_Payment_Source__c,Last_4__c,Bank_Account_Number__c,Finance_Account_Number__c,Creation_Date__c from Payment_Source__c where Finance_Account_Number__r.Finance_Account_Number__c=:finnumber and Status__c = 'Active' ORDER BY createddate DESC]; 
       
        if(paymentSource.size()>=4 ){
        disablenewbutton=true;
        //buttonStyle='inactive-btn';
        buttonStyle='primary-btn btn-1 inactive-btn';    
        }
        else{
        buttonStyle='primary-btn btn-1';
        disablenewbutton=false;
        }
}

public void Save(){
    string bankaccid = '';
    bankaccid = apexpages.currentpage().getparameters().get('param3');
    string bankname = '';
    bankname = apexpages.currentpage().getparameters().get('param1');
    string banknickname = '';
    banknickname = apexpages.currentpage().getparameters().get('param2');
    string banktype = '';
    banktype = apexpages.currentpage().getparameters().get('param4');
    Payment_Source__c psource;
    //system.debug('@@@@@@'+bankname+bankaccid+banknickname);  
    psource = new Payment_Source__c(id = bankaccid);
    //Added by Omkar for 114149 defect below null check condition                   
    if(String.isNotBlank(bankname)){
        psource.Bank_Name__c = bankname;
    }   
    if(banknickname!=''){
    psource.Payment_Source_Nickname__c = banknickname;
    }
    else{
    psource.Payment_Source_Nickname__c = bankname+'-'+banktype;
    }
        
    try{
    //system.debug('@@@@@@'+psource);  
    Update psource;


    }
    catch(DMLException ex){
      error(ex);
    }
    selected = '';
    fetchpaymentsource();
    
}
public pagereference error(DMLException ex){
    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getdmlMessage(0));
    ApexPages.addMessage(myMsg );

    return null;
}

public void Cancel(){    
    selected ='';
    displayPopUpUndelete = false;
    fetchpaymentsource();
  //  rename = false;
  //  accountoverview();
  /*  pagereference p = new pagereference(System.Label.System_CL0023+finnumber+'&isReadOnly='+csat);
    p.setRedirect(true);
    return p; */
}

public Pagereference Canceldeletefn(){    
    pagereference p = new pagereference(System.Label.System_CL0023+finnumber+'&isReadOnly='+csat);
    p.setRedirect(true);
    return p;
}


public void CancelaccOverivew(){    
    rename = false;
    accountoverview();
  /*  pagereference p = new pagereference(System.Label.System_CL0023+finnumber+'&isReadOnly='+csat);
    p.setRedirect(true);
    return p; */
}

public void accountoverview(){
    if(rename==true){
    accountoverview = true;
    }
    if(rename==false){
    accountoverview = false;
    }
   // return null;
}

public void Rename(){
    selected = '';
    selected = apexpages.currentpage().getparameters().get('bankaccid');
    //system.debug('@@@@@@'+selected);
    rename = true;
   // return null;
}

public void closePopup() {        
    displayPopup = false;  
    displayPopUpUnDelete=false;
    displayPopUpDelete=false;  
} 


public void showPopup() {  
    deletepopuppaymentsource = new Payment_Source__c();
    bankacciddelete = apexpages.currentpage().getparameters().get('bankaccid'); 
    deletepopuppaymentsource = [ select id,Bank_Name__c,Payment_Source_Nickname__c,Bank_Account_Number__c,Last_4__c from Payment_Source__c where id=:bankacciddelete];  
    list<ChargentOrders__ChargentOrder__c> chagentlist = [select id from ChargentOrders__ChargentOrder__c where Payment_Source_Nickname__c=:bankacciddelete and  Payment_Display_Status__c in('Pending','Processing')];
    if(chagentlist.size()>0){
    displayPopUpUnDelete=true;
    displayPopUpDelete=false;
    }
    else{
     
    displayPopUpUnDelete=false;
    displayPopUpDelete=true;
    }   
}

public pagereference Delete1(){
 
    List<Payment_Source__c> pymtsource = [select id,Preferred_Payment_Source__c,status__c from Payment_Source__c where Finance_Account_Number__r.Finance_Account_Number__c =:finnumber];
    List<Payment_Source__c> pymtsourceToUpdate = new List<Payment_Source__c>();
    Integer i = 0;
    Integer j = 0;
    for(Payment_Source__c p:pymtsource){
        if(p.Id == bankacciddelete){
            p.status__c = 'Deleted';
            pymtsourceToUpdate.add(p);
        }
        if(i==j && p.Id != bankacciddelete && p.status__c =='Active'){
        //    p.Preferred_Payment_Source__c= true;
            pymtsourceToUpdate.add(p);
        } else {
            j++;
        }        
        i++;
    }
    
    try{
        update pymtsourceToUpdate;
    }
    catch(DMLException ex){
     ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getdmlMessage(0));
     ApexPages.addMessage(myMsg );

     return null;
    }
    closePopup();
    fetchpaymentsource();
    return null;
}

public pagereference Delete2(){
 
    closePopup();
    fetchpaymentsource();
    return null;
}

public pagereference newbankaccount(){
    pagereference p = new pagereference(System.Label.System_CL0019+finnumber+'&isReadOnly='+csat);
    return p;
}

public pagereference Updatepreferredbank(){
    string bankid = '';
    bankid = apexpages.currentpage().getparameters().get('bankid');
    if(bankid!=null){
    Payment_Source__c psource = new Payment_Source__c(id=bankid);
    psource.Preferred_Payment_Source__c = true;
    try{
    Update psource;
    fetchpaymentsource();
    }
    catch(DMLException ex){
     ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,ex.getdmlMessage(0));
     ApexPages.addMessage(myMsg );

     return null;
    }
    }
    return null;
}

public pagereference redirectToHFS()
    {
        ApexPages.pageReference pageref;
        pageref = Page.BankAccounts;
        
        if(mobile==false)
        {
            System.debug('$$$ In redirectToHFS(): ');
            //mobile = false;
            System.debug('$$$ In mobile ELSE Block : ' + mobile);
            if(Honda == true)
            pageref = new pageReference('https://staging.redesign.hondafinancialservices.com/MyAccount/');
            else
            pageref = new pageReference('https://staging.redesign.acurafinancialservices.com/MyAccount');

            pageref.setRedirect(true);
        }
        return pageref;
    }
    
    public void checkDevice()
    {
        System.debug('$$$ Before  User-Agent: ');
        Map<String, String> headerlist = ApexPages.currentPage().getHeaders();
        if(headerList.get('User-Agent').contains('Android') || 
            headerList.get('User-Agent').contains('BlackBerry') ||
            headerList.get('User-Agent').contains('IEMobile') || 
            headerList.get('User-Agent').contains('iPad') ||
            headerList.get('User-Agent').contains('iPhone') || 
            headerList.get('User-Agent').contains('iPod'))
        {
            mobile = true;
            System.debug('$$$ In mobile true block: ' + mobile);
        }
        else
        {
            mobile = false;
            System.debug('$$$ In mobile else block Mobile false: ' + mobile);
        }
    }
    
    public void doNothingMethod()
    {
    }



}