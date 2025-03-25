@isTest
public class FlowPicklistTest {
    
    static String getTestData() {
        return '[{"objectName" : "Account", "fieldName" : "Rating", '+ 
            '"picklistValues": [{"iconName":"action:close",' + 
            '"imageUrl":"https://v1.lightningdesignsystem.com/assets/images/logo.svg",' + 
            '"optionLabel":"Hot","optionValue":"Hot","useIcon":"true",' + 
            '"description":"Very active account"},' + 
            '{"iconName":"action:check",' + 
            '"imageUrl":"https://v1.lightningdesignsystem.com/assets/images/logo.svg",' + 
            '"optionLabel":"Warm","optionValue":"Warm","useIcon":"false",' + 
            '"description":"Account is fairly active"},' + 
            '{"iconName":"action:check",' + 
            '"imageUrl":"https://v1.lightningdesignsystem.com/assets/images/logo.svg",' + 
            '"optionLabel":"Cold","optionValue":"Cold",' + 
            '"description":"Account is not active"}' + 
            ']}]';
    }
    
    static String getTestData_EdgeCases() {
        return '[{"objectName" : "Account", "fieldName" : "Rating", '+ 
            '"picklistValues": [{"iconName":"action:close",' +
            '"optionLabel":"Hot","optionValue":"Hot","useIcon":"false",' + 
            '"description":"Very active account"},' + 
            '{"imageUrl":"https://v1.lightningdesignsystem.com/assets/images/logo.svg",' + 
            '"optionLabel":"Warm","optionValue":"Warm","useIcon":"true",' + 
            '"description":"Account is fairly active"},' + 
            '{"iconName":"action:check",' + 
            '"imageUrl":"https://v1.lightningdesignsystem.com/assets/images/logo.svg",' + 
            '"optionLabel":"Cold","optionValue":"Cold",' + 
            '"description":"Account is not active"}' + 
            ']}]';
    }
    
    class MockHttpResponse implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody('{"id": "12345", "success": true}');
            return res;
        }
    }

    static final String TEST_RESOURCE  = 'TestConfig';
    static final String TEST_SESSIONID = 'TestSessionID';

    @testSetup static void setup() {
        // Create custom setting 
        FlowPicklistConfiguration__c config = new FlowPicklistConfiguration__c();
        config.Static_Resource_Name__c = TEST_RESOURCE;
        config.SetupOwnerId = UserInfo.getOrganizationId();
        insert config;      
    }

    static void assertPicklistOption(String expectedLabel, 
                                     String expectedValue, 
                                     String expectedDesc, 
                                     String expectedUseIcon, 
                                     String expectedIcon, 
                                     String expectedImage, 
                                     FlowPicklistOption actual) {
                                         
        System.assertEquals(expectedLabel,   actual.optionLabel);
        System.assertEquals(expectedValue,   actual.optionValue);  
        System.assertEquals(expectedDesc,    actual.description);  
        System.assertEquals(expectedUseIcon, actual.useIcon);
        if (actual.useIcon == 'true') {
            System.assertEquals(expectedIcon,    actual.iconName);
        } else {
            System.assertEquals(expectedImage,   actual.imageUrl);
        }
    }

    static void assertException(AuraHandledException e, String expectedMessage, String expectedResource) {
        String error = e.getMessage();
        FlowPicklistHelper.FlowPicklistExceptionData data = (FlowPicklistHelper.FlowPicklistExceptionData)JSON.deserialize(
            error, 
            FlowPicklistHelper.FlowPicklistExceptionData.class
        );
        System.assertEquals(expectedMessage, data.message);
        System.assertEquals(expectedResource, data.resource);
    }

    public class FlowPicklistTestWrapper extends FlowPicklistHelper.FlowPicklistFileManager {
        
        public FlowPicklistTestWrapper(String testBody) {
            this.resourceName = 'TestResource';
            this.resourceId   = 'TestId';
            this.resourceBody = testBody;
        }

        public override void readResource() {
        }
        
        public override void updateResource(String body) {
            this.resourceBody = body;
            super.updateResource(body);
        }
    }
    
    /*
     * FlowPicklistController tests
     */
    static testMethod void test_FlowPicklistController_getPickList() {
        try {
            FlowPicklistConfig config = FlowPicklistController.getPickList('Account', 'Rating');
            // Shouldn't be here
            throw new System.AssertException('Test failed - AuraHandledException not generated');
        } catch (AuraHandledException e) {
            assertException(e, String.format(FlowPicklistHelper.NO_STATIC_RESOURCE_EXCEPTION, 
                                             new List<Object>{ TEST_RESOURCE }), 
                            FlowPicklistHelper.STATIC_RESOURCE_HOME);
        } catch (Exception e) {
            throw new System.AssertException('Test failed - Exception type is not AuraHandledException');
        }
    }

    /*
     * FlowPicklistConfigController tests
     */
    static testMethod void test_FlowPicklistConfigController_getObjects() {
        List<ObjectType> objectTypes = FlowPicklistConfigController.getObjects();
        System.assert(objectTypes.size() > 0);
    }
    
    static testMethod void test_FlowPicklistConfigController_getFields() {
        List<PicklistField> picklistFields = FlowPicklistConfigController.getFields('Account');
        System.assert(picklistFields.size() > 0);
    }

    static testMethod void test_FlowPicklistConfigController_getPicklistValues() {
        try {
            FlowPicklistConfig config = FlowPicklistConfigController.getPicklistValues('Account', 'Rating');
            // Shouldn't be here
            throw new System.AssertException('Test failed - AuraHandledException not generated');
        } catch (AuraHandledException e) {
            assertException(e, String.format(FlowPicklistHelper.NO_STATIC_RESOURCE_EXCEPTION, 
                                             new List<Object>{ TEST_RESOURCE }), 
                            FlowPicklistHelper.STATIC_RESOURCE_HOME);
        } catch (Exception e) {
            throw new System.AssertException('Test failed - Exception type is not AuraHandledException');
        }
    }

    static testMethod void test_FlowPicklistConfigController_getPicklistConfigs() {
        try {
            List<FlowPicklistConfig> configs = FlowPicklistConfigController.getPicklistConfigs();
            // Shouldn't be here
            throw new System.AssertException('Test failed - AuraHandledException not generated');
        } catch (AuraHandledException e) {
            assertException(e, String.format(FlowPicklistHelper.NO_STATIC_RESOURCE_EXCEPTION, 
                                             new List<Object>{ TEST_RESOURCE }), 
                            FlowPicklistHelper.STATIC_RESOURCE_HOME);
        } catch (Exception e) {
            throw new System.AssertException('Test failed - Exception type is not AuraHandledException');
        }
    }

    static testMethod void test_FlowPicklistConfigController_saveConfig() {
        try {
            FlowPicklistConfigController.saveConfig('Account', 
                                                    'Rating', 
                                                    '[{"iconName":"action:close",' + 
                                                    '"imageUrl":"https://v1.lightningdesignsystem.com/assets/images/logo.svg",' + 
                                                    '"optionLabel":"Hot","optionValue":"Hot","useIcon":"true",' + 
                                                    '"description":"Very active account"},' + 
                                                    '{"iconName":"action:check",' + 
                                                    '"imageUrl":"https://v1.lightningdesignsystem.com/assets/images/logo.svg",' + 
                                                    '"optionLabel":"Warm","optionValue":"Warm","useIcon":"true",' + 
                                                    '"description":"Account is fairly active"},' + 
                                                    '{"iconName":"action:check",' + 
                                                    '"imageUrl":"https://v1.lightningdesignsystem.com/assets/images/logo.svg",' + 
                                                    '"optionLabel":"Cold","optionValue":"Cold","useIcon":"true",' + 
                                                    '"description":"Account is not active"}' + 
                                                    ']');
            throw new System.AssertException('Test failed - AuraHandledException not generated');
        } catch (AuraHandledException e) {
            assertException(e, String.format(FlowPicklistHelper.NO_STATIC_RESOURCE_EXCEPTION, 
                                             new List<Object>{ TEST_RESOURCE }), 
                            FlowPicklistHelper.STATIC_RESOURCE_HOME);
        } catch (Exception e) {
            throw new System.AssertException('Test failed - Exception type is not AuraHandledException');
        }
    }


    /*
     * FlowPicklistHelper tests
     */
    static testMethod void test_FlowPicklistHelper_getPicklistValues() {
        FlowPicklistHelper.FlowPicklistFileManager reader = new FlowPicklistTestWrapper(getTestData()).initialise();
        
        String objectName = 'Account';
        String fieldName  = 'Rating';
        FlowPicklistConfig config = reader.getPicklistValues(objectName, fieldName);
        System.assertNotEquals(null, config);
        Assert.isTrue(config.picklistValues.size() > 0);
        
        // Test with different field name
        fieldName = 'AccountSource';
        config = reader.getPicklistValues(objectName, fieldName);
        System.assertNotEquals(null, config);
        Assert.isTrue(config.picklistValues.size() > 0);
    }

    static testMethod void testError_FlowPicklistHelper_getPicklistValues_NoObject() {
        FlowPicklistHelper.FlowPicklistFileManager reader = new FlowPicklistTestWrapper(getTestData()).initialise();
        
        String objectName = 'NonExistingObject';
        String fieldName  = 'Rating';

        try {
            FlowPicklistConfig config = reader.getPicklistValues(objectName, fieldName);
            // Shouldn't be here
            throw new System.AssertException('Test failed - AuraHandledException not generated');
        } catch (AuraHandledException e) {
            assertException(e, String.format(FlowPicklistHelper.NO_OBJECT_EXCEPTION, 
                                             new List<Object>{ objectName }), null);
        } catch (Exception e) {
            throw new System.AssertException('Test failed - Exception type is not AuraHandledException');
        }
    }

    static testMethod void testError_FlowPicklistHelper_getPicklistValues_NoField() {
        FlowPicklistHelper.FlowPicklistFileManager reader = new FlowPicklistTestWrapper(getTestData()).initialise();
        
        String objectName = 'Account';
        String fieldName  = 'NonExistingField';

        try {
            FlowPicklistConfig config = reader.getPicklistValues(objectName, fieldName);
            // Shouldn't be here
            throw new System.AssertException('Test failed - AuraHandledException not generated');
        } catch (AuraHandledException e) {
            assertException(e, String.format(FlowPicklistHelper.NO_FIELD_EXCEPTION, 
                                             new List<Object>{ fieldName, objectName }), null);
        } catch (Exception e) {
            throw new System.AssertException('Test failed - Exception type is not AuraHandledException');
        }
    }
    
    static testMethod void testError_FlowPicklistHelper_getPicklistValues_InvalidData() {
        String objectName = 'Account';
        String fieldName  = 'Rating';

        try {
            FlowPicklistHelper.FlowPicklistFileManager reader = new FlowPicklistTestWrapper('i_am_not_json').initialise();

            FlowPicklistConfig config = reader.getPicklistValues(objectName, fieldName);
            // Shouldn't be here
            throw new System.AssertException('Test failed - AuraHandledException not generated');
        } catch (AuraHandledException e) {
            // Pass
            System.assert(true);
        } catch (Exception e) {
            throw new System.AssertException('Test failed - Exception type is not AuraHandledException');
        }
    }

    static testMethod void testError_FlowPicklistHelper_parseResource() {
        try {
            FlowPicklistHelper.FlowPicklistFileManager reader = new FlowPicklistTestWrapper('i_am_not_json').initialise();
            // Shouldn't be here
            throw new System.AssertException('Test failed - AuraHandledException not generated');
        } catch (AuraHandledException e) {
            // Pass
            System.assert(true);
        } catch (Exception e) {
            throw new System.AssertException('Test failed - Exception type is not AuraHandledException');
        }
    }
    
    static testMethod void test_FlowPicklistHelper_parseResource() {
        FlowPicklistHelper.FlowPicklistFileManager reader = new FlowPicklistTestWrapper(getTestData()).initialise();
        List<FlowPicklistConfig> configs = reader.configs;
        System.assertEquals(1, configs.size());
        FlowPicklistConfig config = configs[0];
        List<FlowPicklistOption> options = config.picklistValues;
        System.assertEquals(3, options.size());
        assertPicklistOption('Hot',  'Hot',  'Very active account',      'true',  'action:close', null,                                     options[0]);
        assertPicklistOption('Warm', 'Warm', 'Account is fairly active', 'false', null,           FlowPicklistOption.DEFAULT_IMAGE,         options[1]);
        assertPicklistOption('Cold', 'Cold', 'Account is not active',    'true',  'action:check', null,                                     options[2]);
    }
    
    static testMethod void test_FlowPicklistHelper_parseResource_edgeCases() {
        FlowPicklistHelper.FlowPicklistFileManager reader = new FlowPicklistTestWrapper(getTestData_EdgeCases()).initialise();
        List<FlowPicklistConfig> configs = reader.configs;
        System.assertEquals(1, configs.size());
        FlowPicklistConfig config = configs[0];
        List<FlowPicklistOption> options = config.picklistValues;
        System.assertEquals(3, options.size());
        assertPicklistOption('Hot',  'Hot',  'Very active account',      'false', 'action:close',     FlowPicklistOption.DEFAULT_IMAGE,
                             options[0]);
        assertPicklistOption('Warm', 'Warm', 'Account is fairly active', 'true',  'standard:default', FlowPicklistOption.DEFAULT_IMAGE, 
                             options[1]);
    }

    static testMethod void test_FlowPicklistHelper_updateConfig() {
        FlowPicklistHelper.FlowPicklistFileManager reader = new FlowPicklistTestWrapper(getTestData()).initialise();
        FlowPicklistConfig config = reader.findConfig('Account', 'Rating');
        List<FlowPicklistOption> options = config.picklistValues;
        for (FlowPicklistOption option : options) {
            option.useIcon = 'false';
        }
        reader.updateConfig('Account', 'Rating', options);

        FlowPicklistConfig actual = reader.findConfig('Account', 'Rating');
        for (FlowPicklistOption option : actual.picklistValues) {
            System.assertEquals('false', option.useIcon);
        }
    }

    static testMethod void test_FlowPicklistHelper_updateConfig_notFound() {
        FlowPicklistHelper.FlowPicklistFileManager reader = new FlowPicklistTestWrapper(getTestData()).initialise();
        reader.updateConfig('Account', 'RandomField__c', new List<FlowPicklistOption>());
        FlowPicklistConfig config = reader.findConfig('Account', 'RandomField__c');
        System.assertNotEquals(null, config);
        System.assertEquals(0, config.picklistValues.size());
    }

    static testMethod void test_FlowPicklistHelper_updateResource() {
        FlowPicklistHelper.FlowPicklistFileManager reader = new FlowPicklistTestWrapper(getTestData()).initialise();
        FlowPicklistConfig config = reader.findConfig('Account', 'Rating');
        for (FlowPicklistOption option : config.picklistValues) {
            option.useIcon = 'false';
        }
        try {
            Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
            Test.startTest();
            String resourceBody = JSON.serializePretty(config.picklistValues, true);
            reader.updateResource(resourceBody);
            System.assertEquals(resourceBody, reader.resourceBody);
            Test.stopTest();
        } catch (Exception e) {
            throw new System.AssertException('Test failed - Should not have thrown the exception');
        }
    }
    
    
}