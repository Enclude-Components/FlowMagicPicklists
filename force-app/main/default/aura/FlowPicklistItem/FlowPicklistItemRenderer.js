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