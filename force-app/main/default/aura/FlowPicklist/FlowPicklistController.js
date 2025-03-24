({
    doInit : function(component, event, helper) {
        helper.iniActions(component);
        helper.callServer(
            component,
            "c.getPickList",
            function (response) {
                if (response && response.picklistValues && response.picklistValues.length > 0) {
                    component.set("v.picklistConfig", response);
                    component.set("v.picklistOptions", response.picklistValues);
                    const selectedValue = component.get('v.selectedValue');
                    //console.log(selectedValue);
                    if (selectedValue) {
                        helper.initSelections(component, selectedValue.split(';'));
                    }
                } else {
                    component.set('v.message', 'No configuration found for this picklist field');
                }
            },
            { 
                objectName : component.get('v.sObjectName'),
                fieldName  : component.get('v.picklistField')
            }
        );
    },
    handleSelect : function(component, event, helper) {
        const objectName       = component.get('v.sObjectName');
        const fieldName        = component.get('v.picklistField');
        const isMultiPicklist  = component.get('v.picklistConfig.isMultiPicklist'); 
        const selectedValue    = component.get('v.selectedValue');
        const newSelectedValue = event.getParam('selected');

        if (objectName === event.getParam('objectName') && 
            fieldName  === event.getParam('fieldName')) {
            const picklistOptions = helper.initSelections(component, [ newSelectedValue ]);
            const selected = picklistOptions
            .filter(option => {
                return option.selected === true;
            })
            .map(option => {
                return option.optionValue;
            })
            .join(';');

            component.set('v.selectedValue', selected);
            component.set('v.picklistOptions', picklistOptions);

            if (!isMultiPicklist && selectedValue !== newSelectedValue) {
                helper.handleNavigation(component);
            }
        }
    }
})