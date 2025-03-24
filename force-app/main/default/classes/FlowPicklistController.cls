/** 
    Author:             Jiun Ryu
    Company:            Salesforce 
    Description:        FlowPicklistController.cls
    Date:               20-Jul-2020
    
    History: 
    When           Who                 What 
    
    TODO: 
    
*/
public with sharing class FlowPicklistController {
    /**
     * Gets visual picklist configuration from the static resource.
     *
     * @param objectName: Object name.
     * @param fieldName: Picklist/Multipicklist field name.
     *
     */
    @AuraEnabled
    public static FlowPicklistConfig getPickList(String objectName, String fieldName) {
        return new FlowPicklistHelper.FlowPicklistFileManager().initialise().getPicklistValues(objectName, fieldName);
    }
}