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
    Description:    FlowPicklistHelper.js
    Date:           20-Jul-2020

    TODO:
    - 
**/

({
    PARENT_ID : null,
    NAVIGATION_ACTIONS : {
        'BACK'   : 'BACK',
        'NEXT'   : 'NEXT',
        'FINISH' : 'FINISH',
        'PAUSE'  : 'PAUSE'
    },
    ERRORS : {
        'UNKNOWN_ERROR' : 'Unknown error'
    },
    callServer: function(component, method, callback, params) {
        const action = component.get(method);
        if (params) {
            action.setParams(params);
        }
        
        action.setCallback(this,function(response) {
            const state = response.getState();
            if (state === "SUCCESS") {
                callback.call(this, response.getReturnValue());
            } else if (state === "ERROR") {
                this.processError(component, response.getError());
            }
        });
        
        $A.enqueueAction(action);
    },
    processError : function(component, errors) {
        let errorMessage = this.ERRORS.UNKNOWN_ERROR;
        if (errors && errors[0] && errors[0].message) {
            errorMessage = errors[0].message;
            try {
                const error = JSON.parse(errorMessage);
                errorMessage = error.message; 
            } catch(e) {

            } finally {
                component.set('v.message', errorMessage);
                //this.showToast('Error', errorMessage, 'error', 'sticky');
            }
        } else {
            component.set('v.message', errorMessage);
            //this.showToast('Error', errorMessage, 'error', 'sticky');
        }
    },
    showToast : function(title, message, type, mode) {
        const toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title"   : title,
            "message" : message,
            "type"    : type,
            "mode"    : mode
        });
        toastEvent.fire();
    },
    iniActions : function(component) {
        const availableActions = component.get('v.availableActions');
        availableActions.forEach(action => {
            if (action == this.NAVIGATION_ACTIONS.PAUSE) {
                component.set('v.canPause', true);
            } else if (action == this.NAVIGATION_ACTIONS.BACK) {
                component.set('v.canBack', true);
            } else if (action == this.NAVIGATION_ACTIONS.NEXT) {
                component.set('v.canNext', true);
            } else if (action == this.NAVIGATION_ACTIONS.FINISH) {
                component.set('v.canFinish', true);
            }
        });
    },
    initSelections : function(component, selectedValues) {
        const isMultiPicklist = component.get('v.picklistConfig.isMultiPicklist'); 
        let picklistOptions = component.get('v.picklistOptions');
        picklistOptions.forEach(picklistOption => {
            if (selectedValues.name.includes(picklistOption.optionValue)) {
                if (picklistOption.selected !== true) {
                    picklistOption.quantity = selectedValues.quantity; // TODO display this value
                    picklistOption.selected = true;
                } else {
                    picklistOption.selected = false;
                }
            } else if (!isMultiPicklist) {
                picklistOption.selected = false;
            }
        });
        return picklistOptions;
    },
    handleNavigation : function(component) {
        const transitionOnSelect = component.get('v.transitionOnSelect');
        if (transitionOnSelect) {
            const canNext   = component.get('v.canNext');
            const canFinish = component.get('v.canFinish');
            const navigate  = component.get('v.navigateFlow');
            if (canNext) {
                navigate(this.NAVIGATION_ACTIONS.NEXT);
            } else if (canFinish) {
                navigate(this.NAVIGATION_ACTIONS.FINISH);
            }
        }
    }
})