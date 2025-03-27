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
    Description:        FlowPicklistHelper.cls
    Date:               11-Oct-2020
    
    History: 
    When           Who                 What 
    
    TODO: 
    
*/
public with sharing class FlowPicklistHelper {

    public static final String NO_STATIC_RESOURCE_EXCEPTION = 'Could not find static resource named "{0}". Please check the static resource file exists.';
    public static final String NO_CUSTOM_SETTING_EXCEPTION  = 'Please set the organization wide default value for the custom setting: Flow Picklist Configuration';
    public static final String PARSE_ERROR_EXCEPTION        = 'Failed to parse the configuration file "{0}". \nError: {1}';
    public static final String NO_OBJECT_EXCEPTION          = 'Object "{0}" does not exist.';
    public static final String NO_FIELD_EXCEPTION           = 'No picklist field "{0}" on "{1}".';
    public static final String NO_ACCESS_EXCEPTION          = 'User does not have access to the field "{0}" on "{1}".';

    public static final String STATIC_RESOURCE_HOME = '/lightning/setup/StaticResources/home';
    public static final String CUSTOM_SETTING_HOME  = '/lightning/setup/CustomSettings/home';

    private static final Integer NOT_FOUND = -1;

    private static final String RESOURCE_CONTENT_TYPE  = 'application/json';
    private static final String RESOURCE_CACHE_CONTROL = 'public';
    
    /**
     * Sends an update request to modify a Static Resource in Salesforce.
     * This method makes a callout to the Tooling API to update the specified static resource.
     * 
     * @param resourceId   The ID of the Static Resource to update.
     * @param resourceName The new name for the Static Resource.
     * @param resourceBody The updated content for the Static Resource (base64 encoded).
     */
    @future(callout=true)
    public static void sendUpdateRequest(String resourceId, String resourceName, String resourceBody) {
        
        if (String.isNotBlank(resourceId) && String.isNotBlank(resourceName) && String.isNotBlank(resourceBody)) {
            // Encode the resource content in Base64
            String base64EncodedBody = EncodingUtil.base64Encode(Blob.valueOf(resourceBody));
            
            HttpRequest req = new HttpRequest();
            Http http = new Http();
            
            // Construct the endpoint URL for updating the Static Resource via the Tooling API
            req.setEndpoint(
                URL.getOrgDomainURL().toExternalForm() + 
                '/services/data/v62.0/tooling/sobjects/StaticResource/' + 
                resourceId
            );
            req.setMethod('PATCH');
            
            // Set request headers
            req.setHeader('Content-Type', 'application/json'); 
            req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
            
            // Construct the request body as a JSON payload
            Map<String, Object> payload = new Map<String, Object>{
                'Name'        => resourceName,
                'ContentType' => RESOURCE_CONTENT_TYPE,
                'Body'        => base64EncodedBody
            }; 
            req.setBody(
                System.JSON.serializePretty(payload)
            );
            
            // Send the HTTP request and log the response
            HttpResponse res = http.send(req);
            System.debug(res);
        }  
    }

    private static AuraHandledException generateException(FlowPicklistExceptionData data) {
        String error = data.serialise();
        AuraHandledException e = new AuraHandledException(error);
        e.setMessage(error);
        return e;
    }

    /**
     * FlowPicklistExceptionData class.
     * 
     */
    public class FlowPicklistExceptionData {
        public String message;
        public String resource;
        public String messageType;

        /**
         * Constructor.
         *
         */
        public FlowPicklistExceptionData(String message, String resource) {
            this.message     = message;
            this.resource    = resource;
            this.messageType = 'warning';
        }

        /**
         * Constructor.
         *
         */
        public FlowPicklistExceptionData(String message, String resource, String messageType) {
            this(message, resource);
            this.messageType = messageType;
        }

        /**
         * serialise
         *
         */
        public String serialise() {
            return JSON.serialize(this);
        }
    }

    /**
     * FlowPicklistFileManager class.
     * Manages reading/writing of the static resource.
     */
    public virtual class FlowPicklistFileManager {
        public String resourceId   { get; set; }
        public String resourceName { get; set; }
        public String resourceBody { get; set; }

        public List<FlowPicklistConfig> configs { get; set; }

        /**
         * Constructor.
         *
         */
        public FlowPicklistFileManager() { }

        /**
         * Reads the static resource name of the org default setting.
         * Reads and parses the content of the static resource into FlowPicklistConfig objects.
         */
        public FlowPicklistFileManager initialise() {
            this.configs = new List<FlowPicklistConfig>();
            setDefaultResource();
            readResource();
            parseResource();
            return this;
        }

        /**
         * Read the static resource name of the org default setting (FlowPicklistConfiguration__c).
         * throws an error if the org default setting is not found.
         */
        public virtual void setDefaultResource() {
            FlowPicklistConfiguration__c defaultResource = FlowPicklistConfiguration__c.getOrgDefaults();
            if (defaultResource == NULL || defaultResource.Static_Resource_Name__c == NULL) {
                throw generateException(new FlowPicklistExceptionData(NO_CUSTOM_SETTING_EXCEPTION, CUSTOM_SETTING_HOME));
            } else {
                this.resourceName = defaultResource.Static_Resource_Name__c;
            }
        }

        /**
         * Read the content of the static resource.
         * throws an error if there is no static resource with the given name.
         */
        protected virtual void readResource() {
            List<StaticResource> resources = [ SELECT Id, Name, Body 
                                               FROM StaticResource 
                                               WHERE Name = :this.resourceName ];
            if (resources.size() > 0) {
                this.resourceId   = resources[0].Id;
                this.resourceBody = resources[0].Body.toString();
            } else {
                throw generateException(
                    new FlowPicklistExceptionData(
                        String.format(NO_STATIC_RESOURCE_EXCEPTION, 
                                      new List<Object>{ this.resourceName }), 
                        STATIC_RESOURCE_HOME)
                );
            }
        }

        /**
         * Parse the resource body into FlowPicklistConfig objects.
         * throws an error if there is any parse error.
         */
        private void parseResource() {
            try {
                List<FlowPicklistConfig> configs = new List<FlowPicklistConfig>();
                if (String.isNotBlank(this.resourceBody)) {
                    this.configs = (List<FlowPicklistConfig>)System.JSON.deserialize(
                        this.resourceBody, 
                        List<FlowPicklistConfig>.class
                    );
                }
            } catch (Exception e) {
                throw generateException(
                    new FlowPicklistExceptionData(
                        String.format(PARSE_ERROR_EXCEPTION, 
                                      new List<Object>{ this.resourceName, e.getMessage() }),
                        null
                    )
                );
            }
        }
    
        /**
         * Gets visual picklist configuration from the static resource.
         * Merges picklist values retrieved from Describe object into the ones from the static resource.
         * Picklist values not stored in the resource will have the default settings for visual picklist.
         *
         * @param objectName: Object name.
         * @param fieldName: Picklist/Multipicklist field name.
         *
         */
        public FlowPicklistConfig getPicklistValues(String objectName, String fieldName) {
            List<FlowPicklistOption> options = new List<FlowPicklistOption>();

            SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
            if (objectType != NULL) {
                Schema.SObjectField objectField = objectType.getDescribe().fields.getMap().get(fieldName);
                if (objectField != NULL) {
                    Schema.DescribeFieldResult fieldDescribe = objectField.getDescribe();

                    if (fieldDescribe.isAccessible() == true) {
                        FlowPicklistConfig config = findConfig(objectName, fieldName);
                        Map<String, FlowPicklistOption> configMap = buildConfigMapFromResource(config);
                        Map<String, FlowPicklistOption> mergedConfigMap = new Map<String, FlowPicklistOption>();

                        List<Schema.PicklistEntry> entries = fieldDescribe.getPickListValues();
                        for (Schema.PicklistEntry entry : entries) {
                            String picklistValue = entry.getValue();
                            FlowPicklistOption opt;
                            if (!configMap.containsKey(picklistValue)) {
                                opt = new FlowPicklistOption();
                                opt.optionValue = picklistValue;
                            } else {
                                opt = configMap.get(picklistValue);
                            }
                            opt.optionLabel = entry.getLabel();
                            mergedConfigMap.put(opt.optionValue, opt);
                        }
                        config.isMultiPicklist = fieldDescribe.getType() == Schema.DisplayType.MULTIPICKLIST;
                        config.picklistValues = mergedConfigMap.values();
                        return config;
                    } else {
                        // Exception - do not have access to field
                        throw generateException(
                            new FlowPicklistExceptionData(
                                String.format(NO_ACCESS_EXCEPTION, 
                                            new List<Object>{ fieldName, objectName }),
                                null,
                                'error'
                            )
                        );
                    }
                } else {
                    // Exception - field does not exist
                    throw generateException(
                        new FlowPicklistExceptionData(
                            String.format(NO_FIELD_EXCEPTION, 
                                          new List<Object>{ fieldName, objectName }),
                            null,
                            'error'
                        )
                    );
                }
            } else {
                // Exception - object does not exist
                throw generateException(
                    new FlowPicklistExceptionData(
                        String.format(NO_OBJECT_EXCEPTION, 
                                      new List<Object>{ objectName }),
                        null,
                        'error'
                    )
                );
            }
        }

        /**
         * Update the static resource with the updates picklist value configurations.
         *
         * @param objectName: Object name.
         * @param fieldName: Picklist/Multipicklist field name.
         * @param picklistValues: Visual picklist configuration data for the object/field.
         *
         */
        public void updateConfig(String objectName, String fieldName, List<FlowPicklistOption> picklistValues) {
            Integer idx = findConfigIndex(objectName, fieldName);
            if (idx == NOT_FOUND) {
                FlowPicklistConfig config = new FlowPicklistConfig(objectName, fieldName, picklistValues);
                this.configs.add(config);
            } else {
                this.configs[idx].picklistValues = picklistValues;
            }
        }

        /**
         * Converts a list of FlowPicklistOption into a map (key = picklist value).
         *
         * @param config: Flow Picklist configuration
         *
         */
        private Map<String, FlowPicklistOption> buildConfigMapFromResource(FlowPicklistConfig config) {
            Map<String, FlowPicklistOption> configMap = new Map<String, FlowPicklistOption>();
            for (FlowPicklistOption opt : config.picklistValues) {
                configMap.put(opt.optionValue, opt);
            }
            return configMap;
        }

        /**
         * Returns a list of FlowPicklistOptions for the given object and field names.
         *
         * @param objectName: Object name.
         * @param fieldName: Picklist/Multipicklist field name.
         *
         */
        @testVisible
        private FlowPicklistConfig findConfig(String objectName, String fieldName) {
            for (FlowPicklistConfig config : this.configs) {
                if (config.matches(objectName, fieldName)) {
                    return config;
                }
            }
            return new FlowPicklistConfig(objectName, fieldName);
        }

        /**
         * Returns the index of the FlowPicklistConfig item for the given object and field names.
         *
         * @param objectName: Object name.
         * @param fieldName: Picklist/Multipicklist field name.
         *
         */
        private Integer findConfigIndex(String objectName, String fieldName) {
            Integer idx = NOT_FOUND;
            for (Integer i = 0; i < this.configs.size() && idx == NOT_FOUND; i++) {
                if (this.configs[i].matches(objectName, fieldName)) {
                    idx = i;
                }
            }
            return idx;
        }

        /**
         * Update the static resource file with the passed JSON body.
         *
         * @param body: resource body in JSON format.
         *
         */
        public protected virtual void updateResource(String body) {
            FlowPicklistHelper.sendUpdateRequest(
                this.resourceId, 
                this.resourceName, 
                body
            );
        }
    }
}