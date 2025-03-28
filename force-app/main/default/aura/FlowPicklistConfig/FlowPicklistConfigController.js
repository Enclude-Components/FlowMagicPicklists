/*
 * Copyright (c) 2023, Salesforce, Inc.
 * SPDX-License-Identifier: Apache-2
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
    Author:         Jiun Ryu
    Company:        Salesforce
    Description:    FlowPicklistConfigController.js
    Date:           20-Jul-2020

    TODO:
    - 
**/

({
    doInit: function (component, event, helper) {
        component.set('v.objectsSpinnerActive', true);
        helper.callServer(
            component,
            "c.initialise",
            function (response) {
                helper.callServer(
                    component,
                    "c.getObjects",
                    function (response) {
                        component.set("v.objects", response);
                        component.set('v.objectsSpinnerActive', false);
                    },
                    null,
                    {}
                );
            },
            function (errors) {
                const error = helper.processError(errors);
                component.set('v.errorMessage', error.message);
                component.set('v.errorResource', error.resource);
                component.set('v.errorType', error.messageType);
            },
            {}
        );
    },
    handleSelectObject: function (component, event, helper) {
        const objectName = component.get('v.selectedObject');
        
        helper.clearError(component);
        component.set('v.selectedField', '');
        component.set('v.fieldsSpinnerActive', true);

        helper.callServer(
            component,
            "c.getFields",
            function (response) {
                component.set("v.fields", response);
                component.set('v.fieldsSpinnerActive', false);
                if (!response || response.length == 0) {
                    component.set('v.errorMessage', 'There is no accessible picklist field for the selected object: ' + objectName);
                    component.set('v.errorType', 'warning');
                }
            },
            null,
            {
                objectName: objectName
            }
        );
    },
    handleSelectField: function (component, event, helper) {
        helper.initPicklistValues(component);
        component.find('picklist-preview-config').refresh();
    },
    handleEdit: function (component, event, helper) {
        component.set('v.saving', true);
        const edit = component.get('v.editing');
        if (edit) {
            //console.log(JSON.stringify(component.get('v.picklistValues')));
            helper.callServer(
                component,
                "c.saveConfig",
                function (response) {
                    helper.showToast('Success', 'Picklist Configuration is updated successfully.', 'success');
                    setTimeout(function() {
                        helper.initPicklistValues(component);
                    }, 100);
                },
                null,
                {
                    objectName : component.get('v.selectedObject'),
                    fieldName  : component.get('v.selectedField'),
                    valuesJSON : JSON.stringify(component.get('v.picklistValues'))
                }
            );

        } 
        component.set('v.editing', !edit);
        component.set('v.saving', false);
    },
    handleSave: function (component, event, helper) {
        const picklistValue = event.getParam('picklistValue');
        const actionType = event.getParam('actionType');

        if (actionType === 'Remove') {
            let picklistValues = component.get('v.picklistValues');
            const matchesValue = (pv) => pv.optionValue === picklistValue;
            const idx = picklistValues.findIndex(matchesValue);
            if (idx === -1) {
                helper.showToast('Error', 'Could not modify this picklist configutaion. Please try again.', 'error', 'sticky');
            } else {
                picklistValues.splice(idx, 1);
                component.set('v.picklistValues', picklistValues);
                component.set('v.editing', true);
                helper.showToast('"' + picklistValue + '" has been removed.',
                                 'To save all your changes, click "Save". To revert this change, click "Cancel".', 
                                 'info',
                                 'sticky');
            }
        }
    },
    handleCancel: function (component, event, helper) {
        helper.initPicklistValues(component);
    }
})