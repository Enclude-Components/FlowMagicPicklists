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

    private static final String SESSION_ID = 'sessionId';
    private static final String VF_SESSION = '/apex/FlowPicklistSession';

    private static final Integer NOT_FOUND = -1;

    private static final String RESOURCE_CONTENT_TYPE  = 'application/json';
    private static final String RESOURCE_CACHE_CONTROL = 'public';

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
        public String resourceName { get; set; }
        public String resourceBody { get; set; }

        private MetadataService.MetadataPort service;

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
            List<StaticResource> resources = [ SELECT Name, Body 
                                               FROM StaticResource 
                                               WHERE Name = :this.resourceName ];
            if (resources.size() > 0) {
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
        public void updateResource(String body) {
            this.service = createStaticResourceService();

            MetadataService.StaticResource resource = createStaticResourceRequest(body);
            service.SessionHeader.sessionId = retrieveSessionId(getContent(VF_SESSION));

            /**
             * https://salesforce.stackexchange.com/questions/110515/getting-session-id-in-lightning
             * Suggested solution is either using a visualforce page or named credential to retrieve the session ID.
             */
            //service.SessionHeader.sessionId = UserInfo.getSessionId();
            List<MetadataService.SaveResult> results = updateMetadata(resource);
            if (results.size() > 0) {
                if (results[0].success == false) {
                    throw generateException(
                        new FlowPicklistExceptionData(
                            results[0].errors[0].message,
                            null,
                            'error'
                        )
                    );
                }
            }
        }

        public virtual List<MetadataService.SaveResult> updateMetadata(MetadataService.StaticResource resource) {
            return this.service.updateMetadata(new MetadataService.Metadata[] { resource });
        }

        /**
         * Retrieves the content of the given page in string.
         *
         * @param pageName: Visualforce page name.
         *
         */
        protected virtual String getContent(String pageName) {
            return new PageReference(pageName).getContent().toString();
        }

        /**
         * Retrieves the session ID from the given content
         *
         * @param content: page content.
         *
         */
        private String retrieveSessionId(String content) {
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(content);
            return (String)m.get(SESSION_ID);
        }
    
        /**
         * Initialises and returns a MetadataPort instance.
         *
         */
        private MetadataService.MetadataPort createStaticResourceService() {
            MetadataService.MetadataPort service = new MetadataService.MetadataPort();
            service.SessionHeader = new MetadataService.SessionHeader_element();
            return service;
        }
    
        /**
         * Set up a MetadataService request for static resource.
         *
         * @param body: resource body.
         *
         */
        private MetadataService.StaticResource createStaticResourceRequest(String body) {
            MetadataService.StaticResource resource = new MetadataService.StaticResource();

            resource.fullName     = this.resourceName;
            resource.contentType  = RESOURCE_CONTENT_TYPE;
            resource.cacheControl = RESOURCE_CACHE_CONTROL;
            resource.content      = EncodingUtil.base64Encode(Blob.valueOf(body));

            return resource;
        }
    }
}