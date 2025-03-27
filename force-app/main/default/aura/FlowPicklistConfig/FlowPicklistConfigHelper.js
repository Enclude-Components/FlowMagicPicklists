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
    Description:    FlowPicklistConfigHelper.js
    Date:           20-Jul-2020

    TODO:
    - 
**/

({
    callServer: function(component, method, callback, errorCallback, params) {
        const action = component.get(method);
        if (params) {
            action.setParams(params);
        }
        
        action.setCallback(this, function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                // pass returned value to callback function
                callback.call(this, response.getReturnValue());
            } else if (state === "ERROR") {
                if (errorCallback) {
                    errorCallback.call(this, response.getError());
                } else {
                    const error = this.processError(response.getError());
                    component.set('v.errorMessage', error.message);
                    this.showToast('Error', error.message, 'error');
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    processError : function(errors) {
        const error = {
            message  : 'Unknown error',
            resource : null
        };
        if (errors) {
            console.log("Errors", errors);
            if (errors[0] && errors[0].message) {
                const errorMessage = errors[0].message;
                try {
                    const errorParsed = JSON.parse(errorMessage);
                    error.message     = errorParsed.message;
                    error.resource    = errorParsed.resource;
                    error.messageType = errorParsed.messageType;
                } catch(e) {
                    error.message = errorMessage;
                }
            }
        }
        return error;
    },
    clearError : function(component) {
        component.set('v.errorMessage', null);
        component.set('v.errorResource', null);
        component.set('v.errorType', null);
    },
    showToast : function(title, message, type, mode) {
        const toastEvent = $A.get("e.force:showToast");
        if (!type) type = 'info';
        if (!mode) mode = 'dismissible';
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type,
            "mode": mode
        });
        toastEvent.fire();
    },
    toggleSpinner : function(component) {
        const spinner = component.find('mySpinner');
        $A.util.toggleClass(spinner, 'slds-hide');
    },
    initPicklistValues : function(component) {
        //component.set('v.picklistValues', []);
        component.set('v.saving', true);
        this.callServer(
            component,
            "c.getPicklistValues",
            function (response) {
                component.set('v.editing', false);
                component.set('v.saving', false);
                component.set("v.picklistValues", response.picklistValues);
                component.find('picklist-preview-config').refresh();
            },
            null,
            {
                objectName: component.get('v.selectedObject'),
                fieldName: component.get('v.selectedField')
            }
        );
    }
})