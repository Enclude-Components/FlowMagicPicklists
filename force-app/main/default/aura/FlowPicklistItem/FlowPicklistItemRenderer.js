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
    Description:    FlowPicklistItemRenderer.js
    Date:           20-Jul-2020

    TODO:
    - 
**/

({
	afterRender: function (component, helper) {
		this.superAfterRender();
		helper.selectOption(component);
	},
	rerender : function (component, helper) {
		this.superRerender();
		helper.selectOption(component);
	}
})