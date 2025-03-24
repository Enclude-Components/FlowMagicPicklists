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