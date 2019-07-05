({
    // Invoke will update picklist value for rendered picklist
    invoke : function(component, event, helper){
		var listType = component.get('v.listType');
        if(listType == 'simple'){
            helper.generateFromSimpleList(component.get('v.recordTypeCSV').split(","), component);         
        } else //each list member is complex, which means semicolon separated
        {
            var colsStr = component.get('v.recordTypeCSV').split(',');
            if(colStrArr){
                helper.generateFromCommaSeparatedSublist(colStrArr, component);     
            } 
        }
            
    }
})