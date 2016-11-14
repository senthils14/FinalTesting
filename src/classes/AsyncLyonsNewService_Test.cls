/*
Test Class for AsyncLyonsNewService	

*/
@isTest
public class AsyncLyonsNewService_Test{
    
    private static testMethod void testAsyncLyons()
    {
    Test.setMock(WebServiceMock.class , new LyonsNewServiceMock());
        
    AsyncLyonsNewService.FindASCompanyIDResponse_elementFuture Inst1 = new AsyncLyonsNewService.FindASCompanyIDResponse_elementFuture();
    Integer i1=Inst1.getValue();
    
    AsyncLyonsNewService.GetCompanyIDResponse_elementFuture Inst2 = new AsyncLyonsNewService.GetCompanyIDResponse_elementFuture();
    Integer i2=Inst2.getValue();
    
    AsyncLyonsNewService.LogonResponse_elementFuture Inst3 = new AsyncLyonsNewService.LogonResponse_elementFuture();
    String str1=Inst3.getValue();
    
    AsyncLyonsNewService.ValidateABAResponse_elementFuture Inst4 = new AsyncLyonsNewService.ValidateABAResponse_elementFuture();
    Boolean b1=Inst4.getValue();
    
    AsyncLyonsNewService.GetBanksWithWireXML_W3CResponse_elementFuture Inst5 = new AsyncLyonsNewService.GetBanksWithWireXML_W3CResponse_elementFuture();
    String str2=Inst5.getValue();
    
    AsyncLyonsNewService.RequiredLogonResponse_elementFuture Inst6= new AsyncLyonsNewService.RequiredLogonResponse_elementFuture();
    Boolean b2=Inst6.getValue();
    
    AsyncLyonsNewService.GetBanksXML_W3CResponse_elementFuture Inst7 = new AsyncLyonsNewService.GetBanksXML_W3CResponse_elementFuture();
    String str3=Inst7.getValue();
    
    AsyncLyonsNewService.VerifyWireResponse_elementFuture Inst8 = new AsyncLyonsNewService.VerifyWireResponse_elementFuture();
    Boolean b3=Inst8.getValue();
    
    AsyncLyonsNewService.FindCompanyIDResponse_elementFuture Inst9 = new AsyncLyonsNewService.FindCompanyIDResponse_elementFuture();
    Integer i3=Inst9.getValue();
    
    AsyncLyonsNewService.VerifyABAResponse_elementFuture Inst10 = new AsyncLyonsNewService.VerifyABAResponse_elementFuture();
    Boolean b4=Inst10.getValue();
    
    AsyncLyonsNewService.GetBanksXMLResponse_elementFuture Inst11 = new AsyncLyonsNewService.GetBanksXMLResponse_elementFuture();
    String str4=Inst11.getValue();
    
    AsyncLyonsNewService.LogoffResponse_elementFuture Inst12 = new AsyncLyonsNewService.LogoffResponse_elementFuture();
    Inst12.getValue();
    
    AsyncLyonsNewService.GetBanksPrimarySortXMLResponse_elementFuture Inst13 = new AsyncLyonsNewService.GetBanksPrimarySortXMLResponse_elementFuture();
    String str5=Inst13.getValue();
    
    AsyncLyonsNewService.GetBanksWithWireXMLResponse_elementFuture Inst14 = new AsyncLyonsNewService.GetBanksWithWireXMLResponse_elementFuture();
    String str6=Inst14.getValue();
    
    AsyncLyonsNewService.AsyncABAServiceSoap Inst15 = new AsyncLyonsNewService.AsyncABAServiceSoap();
    System.Continuation cont;
    
    AsyncLyonsNewService.FindASCompanyIDResponse_elementFuture obj1 = Inst15.beginFindASCompanyID(cont,'serialNumber','payeeCode');
    AsyncLyonsNewService.GetCompanyIDResponse_elementFuture obj2 = Inst15.beginGetCompanyID(cont,'token');
    AsyncLyonsNewService.LogonResponse_elementFuture obj3 = Inst15.beginLogon(cont,1003,'Username','pwd');
    AsyncLyonsNewService.ValidateABAResponse_elementFuture obj4 = Inst15.beginValidateABA(cont,'token','aba');
    AsyncLyonsNewService.GetBanksWithWireXML_W3CResponse_elementFuture obj5 = Inst15.beginGetBanksWithWireXML_W3C(cont,'token','aba');
    AsyncLyonsNewService.RequiredLogonResponse_elementFuture obj6 = Inst15.beginRequiredLogon(cont,'token');
    AsyncLyonsNewService.GetBanksXML_W3CResponse_elementFuture obj7 = Inst15.beginGetBanksXML_W3C(cont,'token','aba');
    AsyncLyonsNewService.VerifyWireResponse_elementFuture obj8 = Inst15.beginVerifyWire(cont,'token','aba');
    AsyncLyonsNewService.FindCompanyIDResponse_elementFuture obj9 = Inst15.beginFindCompanyID(cont,'Wcard');
    AsyncLyonsNewService.VerifyABAResponse_elementFuture obj10 = Inst15.beginVerifyABA(cont,'token','aba');
    AsyncLyonsNewService.GetBanksXMLResponse_elementFuture obj11 = Inst15.beginGetBanksXML(cont,'token','aba');
    AsyncLyonsNewService.LogoffResponse_elementFuture obj12 = Inst15.beginLogoff(cont,'token');
    AsyncLyonsNewService.GetBanksPrimarySortXMLResponse_elementFuture obj13 = Inst15.beginGetBanksPrimarySortXML(cont,'token','aba');
    AsyncLyonsNewService.GetBanksWithWireXMLResponse_elementFuture obj14 = Inst15.beginGetBanksWithWireXML(cont,'token','aba');
    
    }
	
    }