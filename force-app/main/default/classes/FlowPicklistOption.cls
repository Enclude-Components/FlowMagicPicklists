/** 
    Author:             Jiun Ryu
    Company:            Salesforce 
    Description:        FlowPicklistOption.cls
    Date:               20-Jul-2020
    
    History: 
    When           Who                 What 
    
    TODO: 
    
*/
public with sharing class FlowPicklistOption {

    public static final String DEFAULT_ICON  = 'standard:default';
    public static final String DEFAULT_IMAGE = 'https://www.lightningdesignsystem.com/assets/images/logo.svg';

    /**
     * URL of the image for this picklist value. Only used when useIcon = 'false'
     *
     */
    @AuraEnabled
    public String imageUrl {
        get { 
            if (String.isBlank(imageUrl)) {
                return DEFAULT_IMAGE;
            } else {
                return imageUrl;
            }
        }
        set;
    }

    /**
     * Indicates whether to use an image or lightning icon for this picklist value.
     * Default is 'true'.
     *
     */
    @AuraEnabled
    public String useIcon {
        get {
            if (useIcon == NULL) {
                return 'true';
            } else {
                return useIcon;
            }
        }
        set;
    }

    /**
     * The Lightning Design System name of the icon. 
     * Names are written in the format 'utility:down' where 'utility' is the category, and 'down' is the specific icon to be displayed.
     * See https://developer.salesforce.com/docs/component-library/bundle/lightning:icon/specification for more details.
     */
    @AuraEnabled
    public String iconName {
        get { 
            if (String.isBlank(iconName)) {
                return DEFAULT_ICON;
            } else {
                return iconName;
            }
        }
        set;
    }
    
    /**
     * Picklist field value
     *
     */
    @AuraEnabled
    public String optionValue { get; set; }
    
    /**
     * Picklist field label
     *
     */
    @AuraEnabled
    public String optionLabel { get; set; }

    /**
     * Picklist field description that can be displayed as subheading in the visual picklist.
     *
     */
    @AuraEnabled
    public String description { get; set; }

}