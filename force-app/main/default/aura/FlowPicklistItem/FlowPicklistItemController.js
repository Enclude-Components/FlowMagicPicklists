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

    EK added support for quantity 
    - 
**/

({
    doInit : function(component, event, helper) {
        helper.getPicklistValues(component, event, helper);
    },
	selectOption : function(component, event, helper) {
        const selectEvent = component.getEvent('selectEvent');
        selectEvent.setParams({
            'selected'   : component.get('v.optionValue'),
            'objectName' : component.get('v.objectName'),
            'fieldName'  : component.get('v.fieldName')
        });
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
        quantitySelectEvent.fire();
     }

})