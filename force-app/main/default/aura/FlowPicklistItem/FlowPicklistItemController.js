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
    Description:    FlowPicklistItemController.js
    Date:           20-Jul-2020

    TODO:
    - 
**/

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
        helper.getPicklistValues(component, event, helper);
    },
	selectOption : function(component, event, helper) {
//        alert (JSON.stringify(component.find("mygroup")));
//        alert (component.find("mygroup").get("v.value"));
        const selectEvent = component.getEvent('selectEvent');
        selectEvent.setParams({
            'selected'   : component.get('v.optionValue'),
            'objectName' : component.get('v.objectName'),
            'fieldName'  : component.get('v.fieldName')
        });
//            'quantity'   : component.get('v.optionValue' + 'q').get("v.value")
        selectEvent.fire();
    },
   	changeQuantity : function(component, event, helper) {
        var changeValue = event.getParam("value");
        const quantitySelectEvent = component.getEvent('quantitySelectEvent');
        quantitySelectEvent.setParams({
            'selected'   : component.get('v.optionValue'),
            'objectName' : component.get('v.objectName'),
            'fieldName'  : component.get('v.fieldName'),
            'quantity'   : event.getParam("value")
        });
//            'quantity'   : component.get('v.optionValue' + 'q').get("v.value")
        quantitySelectEvent.fire();
     }

})