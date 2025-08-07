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
    Description:    FlowPicklistController.js
    Date:           20-Jul-2020

    TODO:
    - 
**/

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
                    let selectedValues = JSON.parse(component.get('v.selectedValue'));
                    if (selectedValues) {
                        selectedValues.forEach((oneValue) => {
                            helper.initSelections(component, oneValue);
                        })
                    }
                } else {
                    component.set('v.message', 'No configuration found for this picklist field');
                }
            },
            { 
                objectName : component.get('v.sObjectName'),
                fieldName  : component.get('v.picklistField'),
                quantityFieldName  : component.get('v.quantityField')
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
            const picklistOptions = helper.showSelection(component, [ newSelectedValue ]);
            const selected = helper.convertToString (picklistOptions);
            component.set('v.selectedValue', selected);
            component.set('v.picklistOptions', picklistOptions);

            if (!isMultiPicklist && selectedValue !== newSelectedValue) {
                helper.handleNavigation(component);
            }
        }
    },
    handleQuantitySelect : function(component, event, helper) {
        const objectName       = component.get('v.sObjectName');
        const fieldName        = component.get('v.picklistField');
        const newSelectedValue = event.getParam('selected');
        const quantity = event.getParam('quantity');
        if (objectName === event.getParam('objectName') && 
            fieldName  === event.getParam('fieldName')) {
            const picklistOptions = helper.updateQuantity(component, [ newSelectedValue ], quantity);
            const selected = helper.convertToString (picklistOptions);
            component.set('v.selectedValue', selected);
            component.set('v.picklistOptions', picklistOptions);
        }
    }
})