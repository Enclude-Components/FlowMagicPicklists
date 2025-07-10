/*
Author Eamon Kelly, Enclude
Based on code from https://my-salesforce-stories.com/display-picklist-field-on-frontend-using-aura-component/
*/
public with sharing class FlowPicklistItemController {
    @AuraEnabled
    public static Map<String,String> getPicklistDetails(String objectName, String fieldName){
        try{
            Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objectName);
            Sobject Object_name = targetType.newSObject();
            Schema.sObjectType sobject_type = Object_name.getSObjectType(); 
            Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
            Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
            return FlowPicklistItemHelper.getPicklistDetails(field_map.get(fieldName).getDescribe());
        }
        catch(Exception ex){
            System.debug('Exception: ' + ex.getMessage() + 'on Line Number: '+ex.getLineNumber()+'Stack: '+ex.getStackTraceString());
            throw new AuraHandledException('Exception: ' + ex.getMessage() + 'on Line Number: '+ex.getLineNumber());
        }
    }
}