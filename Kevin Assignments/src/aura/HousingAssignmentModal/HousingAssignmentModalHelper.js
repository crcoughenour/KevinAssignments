({
	getData : function(component) {
		var action = component.get("c.getRelatedData");
        action.setParams({"contactId" : component.get("v.recordId")});
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") {
                var wrappedData = response.getReturnValue();
                console.log(wrappedData);
                component.set("v.wrapper",wrappedData);
            }
            else if(state === "INCOMPLETE") {
                console.log("Initialization failed: INCOMPLETE");
            }
            else if(state === "ERROR") {
                var errors = response.getError();
                var errorMessage = "";
                if (errors) {
                    for (var i = 0; i < errors.length; i++) {
                        errorMessage += errors[i].message + "\n";
                    }
                    console.log(errorMessage);
                }
            }
            else {
                console.log("Unknown error")
            }
        });
        $A.enqueueAction(action);
	},
    submitAssignment: function(component, event) {
        var contactId = component.get("v.recordId");
        var bedId = component.get("v.selectedBedId");
        var arrivalDate = component.get("v.arrivalDate");
        
        var action = component.get("c.createAssignment");
        action.setParams({
            "contactId" : contactId,
            "bedId" : bedId,
            "arrivalDate" : arrivalDate
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success",
                    "message": "Housing Assignment Created."
                });
                toastEvent.fire();
                component.set("v.isOpen", false);
            }
            else if(state === "INCOMPLETE") {
                console.log("Initialization failed: INCOMPLETE");
            }
                else if(state === "ERROR") {
                    var errors = response.getError();
                    var errorMessage = "";
                    if (errors) {
                        for (var i = 0; i < errors.length; i++) {
                            errorMessage += errors[i].message + "\n";
                        }
                        console.log(errorMessage);
                    }
                }
                    else {
                        console.log("Unknown error")
                    }
        });
        $A.enqueueAction(action);
    }
})