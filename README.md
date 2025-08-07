# 🪄 Flow Magic - Picklists  

Take the UX of your Salesforce flows to the next level and convert your picklist fields into visually engaging selectors. Visual selectors boost productivity and engagement by providing context and simplicity.  


#### **Manual Deployment Using SFDX**  
For developers who want to modify the source before deploying:  

1. Clone the repository:  
   ```sh
   git clone https://github.com/Enclude-Components/FlowMagicPicklists.git
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


This project is based on the Salesforce Labs https://github.com/SalesforceLabs/FlowMagicPicklists.git and modified to include a quantity field for Capuchin Day Centre
