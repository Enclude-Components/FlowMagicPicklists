/** 
    Author:             Jiun Ryu
    Company:            Salesforce 
    Description:        ObjectType.cls
    Date:               20-Jul-2020
    
    History: 
    When           Who                 What 
    
    TODO: 
    
*/
public with sharing class ObjectType implements Comparable {
    @AuraEnabled
    public String label { get; set; }
    
    @AuraEnabled
    public String value { get; set; }

    /**
     * Constructor.
     *
     */
    public ObjectType(String label, String value) {
        this.label = label;
        this.value = value;
    }
    
    /**
     * Compares this ObjectType instance with the ObjectType passed in the argument.
     *
     * @param compareTo: The instance of object to be compared.
     *
     */
    public Integer compareTo(Object compareTo) {
        ObjectType ot = (ObjectType)compareTo;
        Integer ret = 0;
        
        if (label > ot.label) {
            ret = 1;
        } else if (label < ot.label) {
            ret = -1;
        }
        return ret;
    }
}