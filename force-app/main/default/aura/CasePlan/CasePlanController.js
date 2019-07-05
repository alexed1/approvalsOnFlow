({
    doInit: function(component, evt, helper) {
        // Fetch initial data from apex class and set to local variables
        helper._getCaseManagerData(component, component.get('v.recordId'));
    },
    
    
    ////Invoked when you click on any of the case step buttons
    processCaseStepClick : function(component,event,helper){   
        component.set("v.SelectedIndex",event.currentTarget.getAttribute("data-casestepindex"));
        component.set("v.caseStepId",event.currentTarget.getAttribute("data-casestepid"));
        // Setting up a timer to auto refresh a view of component to update UI as per new status.
        var interval = window.setInterval($A.getCallback(() => helper._updateData(component, component.get('v.recordId'), component.get("v.caseManager.curCaseStepDescribes["+component.get("v.SelectedIndex")+"].IsCompleted"),interval)), 1000);
         //Setting up a flow variable to invoke and update case step status
         //FIX: instead of matching the current click to the appropriate case step using an index, match to a name. more reliable
        
        if(!component.get("v.caseManager.curCaseStepDescribes["+component.get("v.SelectedIndex")+"].IsPending")){
           //if the step hasn't already been started, go ahead and start it
            var flowCaseStart = component.find("startCaseStep");
            var inputVariablesCaseStart = [
                {
                   name : "CaseStepId",
                   type : "String",
                   value: event.currentTarget.getAttribute("data-casestepid")
                },
                {
                    name : "StartWhen",
                    type : "String",
                    value: component.get("v.caseManager.curCaseStepDescribes["+component.get("v.SelectedIndex")+"].StartWhen")
                },
                {
                    name : "CaseId",
                    type : "String",
                    value: component.get('v.recordId')
                }

            ];
            // Invokes a flow CaseManager_ProcessCaseStep.
            flowCaseStart.startFlow('CaseManager_ProcessCaseStep',inputVariablesCaseStart);
        }else{
            //the case step has already been started. need to ask user if they want to restart it
            component.set('v.caseStepId',event.currentTarget.getAttribute("data-casestepid"));
            component.set('v.startCaseStepManagement',true);
            component.set('v.alreadyFlowRunning',true);
            //markup in cmp will appear when alreadyFlowRunning is true
        }

    },

    //check to see if there is an incomplete parent step. if not, launch the associated flow
    updateComponentAfterCompletion : function(component, event, helper){
            var isParentComplete;
            if(event.getParam("status") === "FINISHED_SCREEN" || event.getParam("status") === "FINISHED") {
                        helper._getCaseManagerData(component, component.get('v.recordId'));
                        var outputVariables = event.getParam("outputVariables");
                        var outputVar;
                        for(var i = 0; i < outputVariables.length; i++) {
                           outputVar = outputVariables[i];
                           if(outputVar.name === "outputVaribale") {
                               //validating if their is any parent which is not completed the pop up a error
                                console.log('Output ', outputVar.value);
                                if(outputVar.value === "First Complete Parent Case Step!!!"){
                                    component.set('v.startCaseStepManagement',true);
                                    isParentComplete = false;
                                }else{
                                    //Stop the Case Step Management Flow and Set IsParentCompleted to true
                                    component.set('v.startCaseStepManagement',false);
                                    isParentComplete= true;
                                }
                           }
                        }
                        if(isParentComplete){
                            // If Parent Completed then Invoke Associated Flow using flow URL
                            var currentUrl = window.location.href;
                            var returnURLCleanupFlow = encodeURI('/flow/CaseManager_Finish_Case_Step_Processing?CaseStepId='+component.get('v.caseStepId') + '&retURL=/005');
                            var associateFlowUrl = encodeURI('/flow/'+component.get("v.caseManager.curCaseStepDescribes["+component.get("v.SelectedIndex")+"].StepFlow")+'?recordId='+component.get('v.caseStepId')+'&retURL='+returnURLCleanupFlow);
                            window.open(associateFlowUrl, "_blank");
                        }else{
                            // Else Parent step not completed
                            helper._getCaseManagerData(component, component.get('v.recordId'));
                            component.set('v.startCaseStepManagement',false);
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Error",
                                "message": "Please Complete Parent Step first."
                            });
                            toastEvent.fire();
                        }
                }

        },

     //User can restart a step that is in process
     restartFlow : function(component,event,helper){
         component.set('v.alreadyFlowRunning',false);
         var currentUrl = window.location.href;
         var finishFlows = encodeURI('/flow/CaseManager_Finish_Case_Step_Processing?CaseStepId='+component.get('v.caseStepId'));
         var associatedFlowUrl = encodeURI('/flow/'+component.get("v.caseManager.curCaseStepDescribes["+component.get("v.SelectedIndex")+"].StepFlow")+'?recordId='+component.get('v.caseStepId')+'&retURL='+finishFlows);
         window.open(associatedFlowUrl, "_blank");

     },

     //Using to Hide Confirmation Message after Click
     closeFlowMessageModel : function(component,event,helper){
         component.set('v.alreadyFlowRunning',false);
     },

    // AdHoc Case Steps are added to an individual Case and don't change the Plan Steps
    addAdHocCaseStep : function(component, event, helper) {
        component.set("v.openModal",true);
        var flow = component.find("flowCreateStep");
        var inputVariables = [

                    {
                      name : "requestedStepAction",
                      type : "String",
                      value : "add"
                    },
                    {
                        name : "CaseId",
                        type : "String",
                        value : component.get("v.recordId")
                    },
                    {
                        name : "CurrentStatusCase",
                        type : "String",
                        value : component.get("v.caseManager.CaseStatus")
                    },
                    {
                        name : "requestType",
                        type : "String",
                        value : "AdHoc"
                    }
                ];
        
        flow.startFlow("CaseManager_Manage_Case_Steps",inputVariables);
    },

    // CLose Modal Window if User Ending up with Add Steps
    closeModalOnFinish : function(component, event, helper){
        if(event.getParam("status") === "FINISHED_SCREEN" || event.getParam("status") === "FINISHED") {
            component.set("v.openModal",false);
            //Help To Update the View of Component with new Data
            helper._getCaseManagerData(component, component.get('v.recordId'));
        }
    },

    // Hide Modal If User Click on No
    hideModal : function(component, event, helper){
        component.set("v.openModal",false);
        // Update Data for Component
        helper._getCaseManagerData(component, component.get('v.recordId'));
    },

    // User Clicked on Transition Case button
    requestCaseTransition: function(component,event,helper){
        component.set("v.changeCaseStatus",true);
        var oldOrderList = component.get('v.caseManager.recordCasePlan.CaseStatusOrdering__c');
        console.log('in requestCaseTransition, oldOrderList is: ' + oldOrderList);
        var res = oldOrderList.split(",");
        var nextStatus ="";
        var valueForList = [];
        // Checking Next Status Is Available or Not
        for (var i = 0; i < res.length; i++) {
            console.log('inrequestCaseTransition, component.get("v.caseManager.CaseStatus") is: ' + component.get("v.caseManager.CaseStatus"));
            if(res[i] == component.get("v.caseManager.CaseStatus")){
                if(i<res.length){
                    nextStatus = res[i+1];
                }else{
                    nextStatus = "";
                }

            }
        }

        // if Not then Set Empty Next Status
        if(nextStatus == null || nextStatus == undefined){
            nextStatus ="";
        }


        // Setting Up varibales For Case Status Update Flow
        var flow = component.find("nextStatus");
        var inputVariables = [
            {
               name : "CaseRecordId",
               type : "String",
               value: component.get("v.recordId")
            },
            {
                name : "currentCaseStatus",
                type : "String",
                value : component.get("v.caseManager.CaseStatus")
            },
            {
                name : "nextStatus",
                type : "String",
                value : nextStatus
            },
            {
                name:"casePlanId",
                type:"String",
                value:component.get("v.caseManager.recordCasePlan.Id")
            }


        ];
        console.log('inputVariables sent to ProcessCaseTransitionRequest flow are: ' + JSON.stringify(inputVariables));
        // Invoke a flow from here
        flow.startFlow("CaseManager_ProcessCaseTransitionRequest",inputVariables);
    },

    // Invoke on finish of case status change flow
    handleStatusChange : function (component, event, helper) {
          if(event.getParam("status") === "FINISHED_SCREEN") {
             component.set("v.changeCaseStatus",false);
             var outputVariables = event.getParam("outputVariables");
             var outputVar;
             for(var i = 0; i < outputVariables.length; i++) {
                outputVar = outputVariables[i];
                // Refresh Page when Status is Updated
                if(outputVar.name === "AlertMessage") {
                    if(outputVar.value == "Case Status Updated"){
                        window.location.reload(true);
                    }else if( outputVar.value == "Case Plan Setup Completed"){
                        //Show Toast When Case Plan Is Completed
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": outputVar.value
                        });
                        toastEvent.fire();
                    }else{
                        // Show Toast When Required Case Steps is Not Completed
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": outputVar.value
                        });
                        toastEvent.fire();
                    }
                }
             }
          }
       },


})