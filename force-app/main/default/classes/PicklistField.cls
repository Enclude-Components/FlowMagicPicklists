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
    Description:        PicklistField.cls
    Date:               20-Jul-2020
    
    History: 
    When           Who                 What 
    
    TODO: 
    
*/
public with sharing class PicklistField implements Comparable {
    @AuraEnabled
    public String label { get; set; }
    
    @AuraEnabled
    public String value { get; set; }

    /**
     * Constructor.
     * 
     *  @param label: Picklist label.
     *  @param value: Picklist value.
     *  @param isMultiPicklist: Indicates whether or not this picklist is a multi-picklist.
     *
     */
    public PicklistField(String label, String value, Boolean isMultiPicklist) {
        this.label = label;
        this.value = value;
    }
    
    /**
     * Compares this PicklistField instance with the PicklistField passed in the argument.
     *
     * @param compareTo: The instance of object to be compared.
     *
     */
    public Integer compareTo(Object compareTo) {
        PicklistField pf = (PicklistField)compareTo;
        Integer ret = 0;
        
        if (label > pf.label) {
            ret = 1;
        } else if (label < pf.label) {
            ret = -1;
        }
        return ret;
    }
}