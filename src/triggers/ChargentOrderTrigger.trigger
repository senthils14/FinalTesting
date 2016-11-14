trigger ChargentOrderTrigger on ChargentOrders__ChargentOrder__c(after insert, after update, before insert, before update) {

    // To update the customer lookup reference in the chargent order
    // Aravind disabled Workflow: NextWithdrawalUpdatedDateUpdate for avoiding recurrsive triggers for Email & SMS. Defect id: 112924, 112974, 112975, 112961. Refer Handler codes

    if (Trigger.isUpdate && Trigger.isBefore) {

        for (ChargentOrders__ChargentOrder__c order: trigger.new) {
            ChargentOrders__ChargentOrder__c oldOrder = null;
            oldOrder = (ChargentOrders__ChargentOrder__c) System.Trigger.oldMap.get(order.Id);

            if (oldOrder != null && oldOrder.Next_Withdrawal_Date__c != order.Next_Withdrawal_Date__c) {
                order.Next_Withdrawal_Updated_Date__c = System.now();
            }

            //Defect id: 112548 - Aravind added it. Based on inputs given by Kamesh email dated 15 Nov 2015
            if (oldOrder != null && oldOrder.ChargentOrders__Charge_Amount__c != order.ChargentOrders__Charge_Amount__c) {
                order.Source_of_Modification_Date__c = System.now();
                order.Payment_Display_Status_Date__c = System.now();
                order.Charge_Amount_Date__c = System.now();
                order.Next_Withdrawal_Updated_Date__c = System.now();
            }


        }

        ChargentOrderTriggerHandler.onBeforeUpdate(Trigger.New);
    }



    if (Trigger.isInsert && Trigger.isBefore) {
        ChargentOrderTriggerHandler.onBeforeInsert(Trigger.New);
    } else {

        Map < Id, String > financeActType = new Map < Id, String > ();
        Map < Id, Communication_Preferences__c > orderMap = new Map < id, Communication_Preferences__c > ();
        Map < Id, List < Id >> financeMap = new Map < id, List < Id >> ();

        for (ChargentOrders__ChargentOrder__c cr: trigger.new) {
            system.debug(cr.Finance_Account_Number__c);
            if (financeMap.containsKey(cr.Finance_Account_Number__c)) {
                financeMap.get(cr.Finance_Account_Number__c).add(cr.id);
            } else {
                financeMap.put(cr.Finance_Account_Number__c, new List < Id > {
                    cr.id
                });
            }
        }
        for (Finance_Account__c f: [Select id, Honda_Brand__c, Finance_Account_Number__c, (Select id, Email_Address__c, Payment_Confirmations_via_Email__c, EasyPay_Communications_via_Email__c, Text_Number__c, Payment_Reminders_via_Text__c, Payment_Confirmations_via_Text__c, EasyPay_Communications_via_Text__c from Communication_Preferences__r) from Finance_Account__c where Id IN: financeMap.keySet()]) {
            system.debug('f.Communi' + financeMap.keySet());
            system.debug('f.Communication_Preferences__r' + f.Communication_Preferences__r);
            for (Communication_Preferences__c cr: f.Communication_Preferences__r) {
                orderMap.put(f.id, cr);

                financeActType.put(f.id, f.Honda_Brand__c + '::' + f.Finance_Account_Number__c);
            }
        }

        if (Trigger.isInsert && Trigger.isAfter) {

            ChargentOrderTriggerHandler.onAfterInsert(Trigger.New);
            WithdrawalDateHandler.onAfterInsert(Trigger.New);

            //Template List
            Map < String, Id > emailMap = new Map < String, Id > ();
            for (EmailTemplate e: [Select id, Name from EmailTemplate]) {
                emailMap.put(e.Name, e.Id);
            }


            //Template for Order
            Map < Id, Id > tempMap = new Map < Id, Id > ();
            Map < Id, Communication_Preferences__c > perferenceMap = new Map < Id, Communication_Preferences__c > ();
            for (ChargentOrders__ChargentOrder__c co: trigger.new) {

                Communication_Preferences__c cp;
                if (orderMap.containsKey(co.Finance_Account_Number__c)) {
                    cp = orderMap.get(co.Finance_Account_Number__c);
                    perferenceMap.put(co.id, cp);
                }

                //System.debug('#### '+emailMap.get('Demo_Template'));

                /*   if(co.Payment_Type__c == 'R' && cp.Payment_Confirmations_via_Email__c == true){
                tempMap.put(co.Id,emailMap.get('Demo_Template'));
                }
                
                else if(co.Payment_Type__c == 'R' && cp.EasyPay_Communications_via_Email__c == true){
                tempMap.put(co.Id,emailMap.get('Demo_Template'));
                }else if(co.Payment_Type__c == 'P' && cp.Payment_Confirmations_via_Email__c == true){
                tempMap.put(co.Id,emailMap.get('Demo_Template'));
                } */
            }


            List < Messaging.SingleEmailMessage > mailList = new List < Messaging.SingleEmailMessage > ();
            for (ChargentOrders__ChargentOrder__c c: trigger.new) {

                /*    System.debug('$$$ '+tempMap.get(c.id));

                    Messaging.SingleEmailMessage e = new Messaging.SingleEmailMessage();
                    
                    e.setTargetObjectId([Select id from Contact where id='003g000000azcoo'].id);
                    e.setWhatId(c.id);
                    e.setTemplateId(tempMap.get(c.id));
                    e.setSaveAsActivity(false);
                    mailList.add(e);*/
            }

            if (mailList.size() > 0) {
                //Messaging.SendEmailResult[] results = Messaging.sendEmail( mailList );
            }

        }

        if (Trigger.isUpdate && Trigger.isAfter) {
            ChargentOrderTriggerHandler.onAfterUpdate(Trigger.New, Trigger.OldMap);
            WithdrawalDateHandler.onAfterUpdate(Trigger.New, Trigger.OldMap);
        }





        //Sms Notification Logic
        
        //Bypass the SMS Notification through Custom Label - this trigger will affect, while loading the data from integration profile/users
        String profilesString = label.IntegrationBypassProfileId;
        Set<string> profileList = new Set<string>(profilesString.trim().split(','));
        if(!profileList.contains(UserInfo.getProfileId())) {
        
            // Stop sending Text for the Suppress Finance Account (Fl_Suppress_All_Notifications__c )
            // Condition Starts
            Set<id> finId = new Set<id>();

            for (ChargentOrders__ChargentOrder__c co: Trigger.new){
                finId.add(co.Finance_Account_Number__c);
            }
        
            Map<id,Finance_Account__c> finSuppress = new Map<id,Finance_Account__c>([select id,Fl_Suppress_All_Notifications__c from Finance_Account__c where id in: finId]);
        // Suppress Condition ends
        
            For(ChargentOrders__ChargentOrder__c co: Trigger.New) {
        
                if(Trigger.isAfter) {       

                    Communication_Preferences__c cp;
                    NotificationTextMsgs__c msgTemplate = null;
                    if (orderMap.containsKey(co.Finance_Account_Number__c)) {
                        cp = orderMap.get(co.Finance_Account_Number__c);
                    }
                    if (financeActType.containsKey(co.Finance_Account_Number__c)) {
                        String afsHfsFlg = financeActType.get(co.Finance_Account_Number__c).split('::')[0];
                        String finAccNumber = financeActType.get(co.Finance_Account_Number__c).split('::')[1];
                        if (finAccNumber != null && finAccNumber.length() > 4) {
                            finAccNumber = finAccNumber.substring(finAccNumber.length() - 4);
                            system.debug('SMS subscribe : ' + cp.Payment_Confirmations_via_Text__c + ' Payment type ' + co.Payment_Type__c);
                        
                        
                            //Start searching for correct template
                            if(!finSuppress.get(co.Finance_Account_Number__c).Fl_Suppress_All_Notifications__c || finSuppress.get(co.Finance_Account_Number__c).Fl_Suppress_All_Notifications__c==null) {  // Check the Finance Account is not Suppress
                                if ((co.ChargentOrders__Payment_Status__c == 'Recurring' || co.ChargentOrders__Payment_Status__c == 'Complete') && co.ChargentOrders__Payment_Frequency__c == 'Once' && co.Payment_Type__c != 'P' && cp.Payment_Confirmations_via_Text__c) {

                                    if (Trigger.isInsert && Trigger.isAfter) {
                                        if (afsHfsFlg != 'AFS') msgTemplate = NotificationTextMsgs__c.getValues('ScheduledPaymentHonda');
                                        else msgTemplate = NotificationTextMsgs__c.getValues('ScheduledPaymentAcura');
                                    } else if (Trigger.isUpdate && Trigger.isAfter) {
                                        //Check if the One time payment is cancelled
                                        if (co.Payment_Display_Status__c == 'Cancelled' && Trigger.oldMap.get(co.Id).Payment_Display_Status__c != 'Cancelled') {
                                            if (afsHfsFlg != 'AFS') msgTemplate = NotificationTextMsgs__c.getValues('CancelledOTPHonda');
                                            else msgTemplate = NotificationTextMsgs__c.getValues('CancelledOTPAcura');
                                        } else {
                                            if (afsHfsFlg != 'AFS') msgTemplate = NotificationTextMsgs__c.getValues('ModifiedPaymentHonda');
                                            else msgTemplate = NotificationTextMsgs__c.getValues('ModifiedPaymentAcura');
                                        }
                                    }
                                } else if ((co.ChargentOrders__Payment_Status__c == 'Recurring' || co.ChargentOrders__Payment_Status__c == 'Stopped' || co.ChargentOrders__Payment_Status__c == 'Complete') && co.ChargentOrders__Payment_Frequency__c == 'Monthly' && cp.EasyPay_Communications_via_Text__c) {
                                    system.debug('Condition Matched');
                                    if (Trigger.isInsert && Trigger.isAfter) {
                                        if (afsHfsFlg != 'AFS') msgTemplate = NotificationTextMsgs__c.getValues('CreatedEasyPayHonda');
                                        else msgTemplate = NotificationTextMsgs__c.getValues('CreatedEasyPayAcura');
                                    } else if (Trigger.isUpdate && Trigger.isAfter) {
                                        //Check if the One time payment is cancelled
                                        if (co.Payment_Display_Status__c == 'Cancelled' && Trigger.oldMap.get(co.Id).Payment_Display_Status__c != 'Cancelled') {
                                            if (afsHfsFlg != 'AFS') msgTemplate = NotificationTextMsgs__c.getValues('CancelledEasyPayHonda');
                                            else msgTemplate = NotificationTextMsgs__c.getValues('CancelledEasyPayAcura');                                    
                                        } else if (co.Payment_Display_Status__c == 'Suspended' && Trigger.oldMap.get(co.Id).Payment_Display_Status__c != 'Suspended') {
                                            if (afsHfsFlg != 'AFS') msgTemplate = NotificationTextMsgs__c.getValues('SuspendedEasyPayHonda');
                                            else msgTemplate = NotificationTextMsgs__c.getValues('SuspendedEasyPayAcura');
                                        } else {
                                            if (afsHfsFlg != 'AFS') msgTemplate = NotificationTextMsgs__c.getValues('ModifiedEasyPayHonda');
                                            else msgTemplate = NotificationTextMsgs__c.getValues('ModifiedEasyPayAcura');
                                        }
                                    }
                                } else if ((co.ChargentOrders__Payment_Status__c == 'Recurring' || co.ChargentOrders__Payment_Status__c == 'Complete') && co.ChargentOrders__Payment_Frequency__c == 'Once' && co.Payment_Type__c == 'P' && cp.Payment_Confirmations_via_Text__c) {

                                    if (Trigger.isInsert && Trigger.isAfter) {
                                        if (afsHfsFlg != 'AFS') msgTemplate = NotificationTextMsgs__c.getValues('CreatedPayOffHonda');
                                        else msgTemplate = NotificationTextMsgs__c.getValues('CreatedPayOffAcura');
                                    } else if (Trigger.isUpdate && Trigger.isAfter) {
                                        //Check if the One time payment is cancelled
                                        if (co.Payment_Display_Status__c == 'Cancelled' && Trigger.oldMap.get(co.Id).Payment_Display_Status__c != 'Cancelled') {
                                            if (afsHfsFlg != 'AFS') msgTemplate = NotificationTextMsgs__c.getValues('CancelledPayOffHonda');
                                            else msgTemplate = NotificationTextMsgs__c.getValues('CancelledPayOffAcura');
                                        } else {
                                            if (afsHfsFlg != 'AFS') msgTemplate = NotificationTextMsgs__c.getValues('ModifiedPayOffHonda');
                                            else msgTemplate = NotificationTextMsgs__c.getValues('ModifiedPayOffAcura');
                                        }
                                    }
                                }
                                system.debug('msgTemplate' + msgTemplate);
                                if (msgTemplate != null && cp.Text_Number__c != null) {
                                    system.debug('Is SMS sent ' + SMSTaskHelper.istriggerExecuted());
                                    if (!SMSTaskHelper.istriggerExecuted()) {
                                        String template = msgTemplate.MsgTemplate__c;

                                        if (co.ChargentOrders__Payment_Start_Date__c != null) template = template.replace('<Payment Date>', co.ChargentOrders__Payment_Start_Date__c.format());

                                        if (co.Next_Withdrawal_Date__c != null) template = template.replace('<Next Withdrawal Date>', co.Next_Withdrawal_Date__c.format()); 

                                        template = template.replace('<Payment Amount>', String.valueOf(co.ChargentOrders__Charge_Amount__c));
                                        template = template.replace('<Last 4 of Fin Acct Nmbr>', finAccNumber);

                                        list < string > mobileNumbers = new list < string > ();
                                        String mobilenum = cp.Text_Number__c;
                                        if (mobilenum != null) {
                                            mobileNum = mobileNum.replaceAll('\\(', '').replaceAll('\\)', '').replaceAll(' ', '').replaceAll('-', '');
                                            string countryCode = (mobileNum.substring(0, 1) == '1') ? '' : '1';
                                            mobileNum = countryCode + mobileNum;
                                            system.debug('Sending msg to ' + mobileNum + '. msg is ' + template);
                                        }
                                        mobileNumbers.add(mobileNum);
                                        if (!Test.isRunningTest()) {
                                            ExactTargetService.sendSMS(mobileNumbers, true, true, template, cp.Id);
                                            SMSTaskHelper.setTriggerAsExecuted();
                                        }
                                            // Adding task to show the sms activity in the Notification History related list
                                            Task task = new Task();
                                            task.WhatId = co.Id;
                                            task.Subject = 'SMS: PAYMENT NOTIFICATION SENT';
                                            //task.WhoId = 
                                            task.ActivityDate = Date.today();
                                  //        task.Description = 'SMS: PAYMENT NOTIFICATION SENT';
                                            task.Description = template;
                                            task.Priority = 'Normal';
                                            task.Status = 'completed';
                                            insert task;
                                    }
                                }
                            }    
                        }
                    }
                }
            }
        } // SMS logic ends  
    }

    
}