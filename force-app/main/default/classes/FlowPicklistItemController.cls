/*
Author Eamon Kelly, Enclude
Based on code from https://my-salesforce-stories.com/display-picklist-field-on-frontend-using-aura-component/
*/
public with sharing class FlowPicklistItemController {
    @AuraEnabled
    public static Map<String,String> getPicklistDetails(){
        try{
           return FlowPicklistItemHelper.getPicklistDetails(Parcel__c.Quantity__c.getDescribe());
        }
        catch(Exception ex){
            System.debug('Exception: ' + ex.getMessage() + 'on Line Number: '+ex.getLineNumber()+'Stack: '+ex.getStackTraceString());
            throw new AuraHandledException('Exception: ' + ex.getMessage() + 'on Line Number: '+ex.getLineNumber());
        }
    }
}