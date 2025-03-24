/** 
    Author:             Jiun Ryu
    Company:            Salesforce 
    Description:        FlowPicklistConfigController.cls
    Date:               20-Jul-2020
    
    History: 
    When           Who                 What 
    
    TODO: 
    
*/
public with sharing class FlowPicklistConfigController {
    
    /**
     * Gets the list of salesforce objects.
     *
     */
	@AuraEnabled
	public static List<ObjectType> getObjects() {
		List<ObjectType> accessibleObjects = new List<ObjectType>();

        for (Schema.SObjectType o : Schema.getGlobalDescribe().Values()) {
            Schema.DescribeSObjectResult sObjectDescribe = o.getDescribe();
            if (sObjectDescribe.isAccessible()) {
                accessibleObjects.add(new ObjectType(
                    sObjectDescribe.getLabel(),
                    sObjectDescribe.getName()
                ));
            }
        }
        accessibleObjects.sort();
        return accessibleObjects;
	}

    /**
     * Gets the list of Picklist/Multipicklist fields for the object.
     *
     * @param objectName: Object name.
     *
     */
	@AuraEnabled
	public static List<PicklistField> getFields(String objectName) {
		List<PicklistField> accessibleFields = new List<PicklistField>();
        
        if (Schema.getGlobalDescribe().containsKey(objectName)) {
            Map<String, Schema.SObjectField> fields = 
                Schema.getGlobalDescribe().get(objectName).getDescribe().SObjectType.getDescribe().fields.getMap();
            
            for (Schema.SObjectField field : fields.values()) {
                Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                if (fieldDescribe.isAccessible() && 
                    (fieldDescribe.getType() == Schema.DisplayType.PICKLIST ||
                     fieldDescribe.getType() == Schema.DisplayType.MULTIPICKLIST)) {

                    accessiblefields.add(new PicklistField(
                        fieldDescribe.getLabel(),
                        fieldDescribe.getName(),
                        (fieldDescribe.getType() == Schema.DisplayType.MULTIPICKLIST)
                    ));
                }
            }
        }
        accessibleFields.sort();
        return accessibleFields;
    }
    
    /**
     * Load and parse visual picklist configuration file
     *
     */
    @AuraEnabled
    public static void initialise() {
        new FlowPicklistHelper.FlowPicklistFileManager().initialise();
    }

    /**
     * Gets visual picklist configuration from the static resource.
     *
     * @param objectName: Object name.
     * @param fieldName: Picklist/Multipicklist field name.
     *
     */
    @AuraEnabled
    public static FlowPicklistConfig getPicklistValues(String objectName, String fieldName) {
        return new FlowPicklistHelper.FlowPicklistFileManager().initialise().getPicklistValues(objectName, fieldName);
    }
 
    /**
     * Gets all visual picklist configurations from the static resource.
     *
     */
    @AuraEnabled
    public static List<FlowPicklistConfig> getPicklistConfigs() {
        return new FlowPicklistHelper.FlowPicklistFileManager().initialise().configs;
    }
 
    /**
     * Compares this ObjectType instance with the ObjectType passed in the argument.
      *
     * @param objectName: Object name.
     * @param fieldName: Picklist/Multipicklist field name.
     * @param valuesJSON: Visual picklist configuration data for the object/field in JSON format.
     *
     */
	@AuraEnabled
	public static void saveConfig(String objectName, String fieldName, String valuesJSON) {
        FlowPicklistHelper.FlowPicklistFileManager reader = new FlowPicklistHelper.FlowPicklistFileManager().initialise();
        List<FlowPicklistOption> picklistValues = (List<FlowPicklistOption>)System.JSON.deserialize(
            valuesJSON, 
            List<FlowPicklistOption>.class
        );
        reader.updateConfig(objectName, fieldName, picklistValues);
        reader.updateResource(System.JSON.serializePretty(reader.configs, true));
    }
}