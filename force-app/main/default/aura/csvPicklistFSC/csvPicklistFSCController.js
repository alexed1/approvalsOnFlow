({
    // Invoke will update picklist value for rendered picklist
    invoke : function(component, event, helper){
		var listType = component.get('v.listType');
        var curCSVString = component.get('v.CSVString');
        console.log("curCSVString is: " + curCSVString);
        if (typeof curCSVString == 'undefined') {
            //there are no PlanSteps defined yet, so we better not try splitting this string
            component.set('v.commaSeparatedFinalList', []);
        }
        else {
            if(listType == 'simple'){
            	helper.generateFromSimpleList(curCSVString.split(","), component);         
            } 
            else //each list member is complex, which means semicolon separated
            {
                var stringList = curCSVString.split(',');
                console.log("stringList is: " + stringList);
                if(stringList){
                    helper.generateFromCommaSeparatedSublist(stringList, component);     
                } 
            }
        }
        
            
    },
    handleChange : function(component, event, helper){
        console.log("selectedString just changed and is now: " + component.get('v.selectedString'));
    }
    
})