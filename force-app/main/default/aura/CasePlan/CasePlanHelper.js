({
    _getCaseManagerData : function(component, recordId){
        // Fetch Initial Data On Load of a Component
        component.set('v.startCaseStepManagement',true);
        component.set("v.recordId", recordId);
        var actionVar = component.get("c.manageCase");
        actionVar.setParams({ recordId : recordId });
        // Setting Up Callback Result to Aura Attributes
        actionVar.setCallback(this, function(response) {
            console.log('return value from getCaseManagerData is: '+ response.getReturnValue() );
            component.set("v.caseManager",response.getReturnValue());
            if($A.util.isEmpty(component.get("v.caseManager.recordCasePlan"))){
                component.set("v.notEmpty",false);
            }
        });

        $A.enqueueAction(actionVar);
    },

    // Invoke by a Time form Controller
    _updateData : function(component, recordId, isCompleted,interval){
            // Updating the latest data to component and refresh a view
            if(!isCompleted){
                component.set('v.startCaseStepManagement',true);
                component.set("v.recordId", recordId);
                var actionVar = component.get("c.manageCase");

                if(actionVar != undefined){
                    actionVar.setParams({ recordId : recordId });
                    actionVar.setCallback(this, function(response) {
                        component.set("v.caseManager",response.getReturnValue());
                    });
                    $A.enqueueAction(actionVar);
                }

            }else{
                // After Completing of First Flow It Will Auto Stop
                window.clearInterval(interval);
            }

        },


})