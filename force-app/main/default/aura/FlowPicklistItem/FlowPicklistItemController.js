({
    doInit : function(component, event, helper) {
        /*const isMultiPicklist = component.get('v.isMultiPicklist');
        const objectName      = component.get('v.objectName');
        const fieldName       = component.get('v.fieldName');
        const optionValue     = component.get('v.optionValue');

        //console.log('Initialising for parent: ' + component.get('v.parentId'));
        helper.PARENT_ID = component.get('v.parentId');

        if (isMultiPicklist) {
            component.set('v.itemName', helper.PARENT_ID + '_' + objectName + '_' + fieldName + '_' + optionValue);
        } else {
            component.set('v.itemName', helper.PARENT_ID + '_' + objectName + '_' + fieldName);
        }
        component.set('v.itemValue', helper.PARENT_ID + '_' + objectName + '_' + fieldName + '_' + optionValue);*/
    },
	selectOption : function(component, event, helper) {
        const selectEvent = component.getEvent('selectEvent');
        selectEvent.setParams({
            'selected'   : component.get('v.optionValue'),
            'objectName' : component.get('v.objectName'),
            'fieldName'  : component.get('v.fieldName')
        });
        selectEvent.fire();
    }
})