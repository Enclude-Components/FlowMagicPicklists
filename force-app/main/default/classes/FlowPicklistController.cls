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
    Author:             Jiun Ryu
    Company:            Salesforce 
    Description:        FlowPicklistController.cls
    Date:               20-Jul-2020
    
    History: 
    When           Who                 What 
    
    TODO: 
    
*/
public with sharing class FlowPicklistController {
    /**
     * Gets visual picklist configuration from the static resource.
     *
     * @param objectName: Object name.
     * @param fieldName: Picklist/Multipicklist field name.
     *
     */
    @AuraEnabled
    public static FlowPicklistConfig getPickList(String objectName, String fieldName) {
        return new FlowPicklistHelper.FlowPicklistFileManager().initialise().getPicklistValues(objectName, fieldName);
    }
}