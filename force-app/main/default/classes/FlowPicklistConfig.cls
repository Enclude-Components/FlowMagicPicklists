/** 
    Author:             Jiun Ryu
    Company:            Salesforce 
    Description:        FlowPicklistConfig.cls
    Date:               20-Jul-2020
    
    History: 
    When           Who                 What 
    
    TODO: 
    
*/
public with sharing class FlowPicklistConfig {

	@AuraEnabled
	public String objectName { get; set; }
	
	@AuraEnabled
	public String fieldName { get; set; }

	@AuraEnabled
	public transient Boolean isMultiPicklist { 
		get {
			if (this.isMultiPicklist == NULL) {
				return false;
			}
			return this.isMultiPicklist;
		} 
		set; 
	}

	@AuraEnabled
	public List<FlowPicklistOption> picklistValues { get; set; }

	/**
     * Default Constructor.
     *
     */
	public FlowPicklistConfig() {
		picklistValues = new List<FlowPicklistOption>();
	}

	/**
     * Constructor.
     *
	 * @param objectName: Object name.
	 * @param fieldName: Picklist/Multipicklist field name.
	 * @param picklistValues: Visual picklist configuration data for the object/field.
	 * 
     */
	public FlowPicklistConfig(String objectName, String fieldName, List<FlowPicklistOption> picklistValues) {
		this.objectName      = objectName;
		this.fieldName       = fieldName;
		this.picklistValues  = picklistValues;
	}

	/**
     * Constructor.
     *
	 * @param objectName: Object name.
	 * @param fieldName: Picklist/Multipicklist field name.
	 * 
     */
	public FlowPicklistConfig(String objectName, String fieldName) {
		this(objectName, fieldName, new List<FlowPicklistOption>());
	}

	/**
     * Checks if the key attributes (objectName, fieldName) match
     *
	 * @param objectName: Object name.
	 * @param fieldName: Picklist/Multipicklist field name.
	 * 
     */
	public Boolean matches(String objectName, String fieldName) {
		return this.objectName == objectName && 
		       this.fieldName == fieldName;
	}
}