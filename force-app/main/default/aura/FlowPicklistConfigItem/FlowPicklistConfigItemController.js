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
    Description:    FlowPicklistConfigItemController.js
    Date:           20-Jul-2020

    TODO:
    - 
**/

({
	edit: function (component, event, helper) {
		component.set('v.editing', true);
	},
	handleRemove: function (component, event, helper) {
		component.set('v.editing', false);
		const removeEvent = component.getEvent('saveEvent');
		removeEvent.setParams({
			'picklistValue': component.get('v.pv.optionValue'),
			'actionType' : 'Remove'
		});
		removeEvent.fire();
	},
	setIcon: function (component, event, helper) {
		const iconName      = event.getParam('iconName');
		const picklistValue = event.getParam('picklistValue');
		if (component.get('v.pv.optionValue') === picklistValue) {
			component.set('v.pv.iconName', iconName);
		}
	},
	showIcons: function (component, event, helper) {
		const spinner = component.find('mySpinner');
		$A.util.toggleClass(spinner, 'slds-hide');
		let modalBody;
		$A.createComponent("c:FlowPicklistLightningIcons", {
			'picklistValue': component.get('v.pv.optionValue')
		},
		function (content, status) {
			if (status === "SUCCESS") {
				$A.util.toggleClass(spinner, 'slds-hide');
				modalBody = content;
				component.find('overlayLib').showCustomModal({
					header: "Select Lightning Icon",
					body: modalBody,
					showCloseButton: true,
					cssClass: "icons-modal",
					closeCallback: function () {
					}
				})
			}
		});
	}
})