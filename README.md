# 🪄 Flow Magic - Picklists  

Take the UX of your Salesforce flows to the next level and convert your picklist fields into visually engaging selectors. Visual selectors boost productivity and engagement by providing context and simplicity.  

## Deployment Options  

### **Option 1: Install from the AppExchange** 

🔗 **[Flow Magic - Picklists](https://appexchange.salesforce.com/appxListingDetail?listingId=a0N3A00000FeFBAUA3)**  

1. Click the link above to visit the AppExchange listing.  
2. Install the managed package in your Salesforce org.  
3. Follow the [Setup Guide](#setup-guide) to configure the component in your flows.  

### **Option 2: Deploy from Source (For Developers & Customisation)**  
If you prefer to install from source, you can deploy directly from this repository.  

#### **Deploy via GitHub SF Deploy**  
Click the button below to deploy the app to your Salesforce org:  

<div>
    <a href="https://githubsfdeploy.herokuapp.com/?owner=SalesforceLabs&repo=FlowMagicPicklists&ref=main">
        <img alt="Deploy to Salesforce"
        src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
    </a>
</div>

#### **Manual Deployment Using SFDX**  
For developers who want to modify the source before deploying:  

1. Clone the repository:  
   ```sh
   git clone https://github.com/SalesforceLabs/FlowMagicPicklists.git
   cd FlowMagicPicklists
2. Authorise your Salesforce org:
   ```sh
   sfdx org login web -a MyOrg
3. Deploy source to your org:
   ```sh
   sfdx project deploy start -d force-app/main/default -o MyOrg
4. Assign **Flow Magic Picklists Admin** permission set to the admin user.
5. Follow the [Setup Guide](#setup-guide) to configure the component in your flows.

## Setup Guide
Follow the instructions in the official guide to install and configure Flow Magic - Picklists:
[Setup Instructions](https://salesforce.quip.com/tJYNAjcCFYWn)

## License  
This project is licensed under the Apache License 2.0. See the [LICENSE](./LICENSE.txt) file for details.
