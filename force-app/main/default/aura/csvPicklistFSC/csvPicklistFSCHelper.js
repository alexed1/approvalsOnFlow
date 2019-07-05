({
     
    generateFromSimpleList : function(sourceArray, component, helper) {
        var commaSeparatedFinalList = [];
        for (var i = 0; i < sourceArray.length; i++) {
           commaSeparatedFinalList.push({label:sourceArray[i],sourceArray:sourceArray[i],});
        }
        component.set('v.commaSeparatedFinalList',commaSeparatedFinalList );
    },
                 
    //in some use cases, the members of the comma separated list are themselves a pair of
    //separated items. this function further splits things up and uses the 2nd item of the pair
	generateFromCommaSeparatedSublist : function(sourceArray, component, helper) {
        var commaSeparatedFinalList = [];
        console.log('sourceArray is: ' + sourceArray);
        for(var i = 0; i < sourceArray.length; i++){ 
           	var colDetailArr = sourceArray[i].split(';');
        	//TODO: make sure when this is created, we switch to use a semicolon
        	if(colDetailArr.length === 2){
            var colObj = {label: colDetailArr[1], value: colDetailArr[0]};
            commaSeparatedFinalList.push(colObj);
        	}
        }
		
        component.set('v.commaSeparatedFinalList',commaSeparatedFinalList );
        
	}
})