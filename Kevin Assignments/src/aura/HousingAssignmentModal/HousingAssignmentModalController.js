({
	doInit : function(component, event, helper) {
        helper.getData(component);
	},
    onSelect : function(component, event, helper) {
        //Set the selected bed id attribute
        var selectedRowText = event.getSource().get("v.text");
        component.set("v.selectedBedId", selectedRowText);
        
        //And uncheck the other checkboxes, i.e. max selected = 1
        var getCheckAllId = component.find("cboxRow");
        for(var i = 0; i < getCheckAllId.length; i++) {
            if(getCheckAllId[i].get("v.text") != selectedRowText) {
                getCheckAllId[i].set("v.value", "false");
            }
        }
    },
    openModal: function(component, event, helper) {
        component.set("v.isOpen", true);
    },
    
    closeModal: function(component, event, helper) { 
        component.set("v.isOpen", false);
    },
    onSubmit: function(component, event, helper) {
        helper.submitAssignment(component, event);
    }
})