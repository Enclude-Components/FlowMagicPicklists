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
    Description:    FlowPicklistItemHelper.js
    Date:           20-Jul-2020

    TODO:
    - 
**/

({
    PARENT_ID : null,
    selectOption : function(component) {
        const selected    = component.get('v.selected');
        const variant     = component.get('v.variant');
        const objectName  = component.get('v.objectName');
        const fieldName   = component.get('v.fieldName');
        const optionValue = component.get('v.optionValue');

        //const elem = document.getElementById(objectName + '_' + fieldName + '_' + optionValue);
        const elem = document.getElementById(optionValue);

        // TODO: refactor
        if (selected && variant !== 'Link') {
            if (elem && !elem.checked) {
                elem.checked = true;
            }
        } 

        if (!selected) {
            if (variant === 'Link') {
                if (elem) {
                    elem.blur();
                }
            } else {
                if (elem && elem.checked) {
                    elem.checked = false;
                }
            }
        } 
    }
})