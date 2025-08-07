public with sharing class FlowPicklistItemHelper {
    public static Map<String,String> getPicklistDetails(Schema.DescribeFieldResult fieldDescription){
        try{
            Map<String,String> labelVsValueMapForPicklist = new Map<String,String>();
            List<Schema.PicklistEntry> picklistEntries = fieldDescription.getPicklistValues();
            for(Schema.PicklistEntry pEntry : picklistEntries){
                labelVsValueMapForPicklist.put(pEntry.getLabel(),pEntry.getValue());
            }
            return labelVsValueMapForPicklist;
        }
        catch(Exception ex){
            System.debug('Exception: ' + ex.getMessage() + 'on Line Number: '+ex.getLineNumber()+'Stack: '+ex.getStackTraceString());
            throw new AuraHandledException('Exception: ' + ex.getMessage() + 'on Line: '+ex.getLineNumber());
        }
    }
}