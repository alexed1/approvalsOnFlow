/**
 * Created by Shubham on 1/23/2019.
 */
({
        // Invoke Method Will Populate all the Picklist value to Dual List Box
        invoke : function(component, event, helper) {
            console.log('status order invoke');
            component.set('v.SelectedValue','');
            //Validate Calling Screen
            if(!component.get('v.isEditScreen')){
                console.log('status order',component.get('v.StatusOrder'));
                //Setting up new dual list box with respected picklist values
                var oldOrderList = component.get('v.StatusOrder');
                var res;
                if(oldOrderList){
                   res = oldOrderList.split(";");   
                }
                var valueForList = [];
                for (var i = 0; i < res.length; i++) {
                    valueForList.push({label:res[i],value:res[i],});
                }
                component.set("v.options",valueForList);
            }else{
                console.log('status order edit',component.get('v.StatusOrder'));
                //If Edit screen then set already selected status order to values, and remaining Will be the options
                var res;
                var oldOrderList = component.get('v.StatusOrder');
                var selectedOrderList = component.get('v.SelectedStatusOrder');
                //Split comma seprated values
                if(oldOrderList){
                	res = oldOrderList.split(";");
                }
                //Create a object array which hold label and value from split result.
                var selectedRes = selectedOrderList.split(";");
                var flag =0;
                var items = [];
                for (var i = 0; i < res.length; i++) {
                    var item = {
                           "label": res[i],
                           "value": res[i],
                        };
                        items.push(item);
                }
                var selectedOptionValue = component.get("v.values");
                var newOrder= "";
                for(var i=0; i< selectedOptionValue.length; i++){
                    if(newOrder.length <=0){
                        newOrder = selectedOptionValue[i];
                    }else{
                        newOrder = newOrder + ";" + selectedOptionValue[i];
                    }
                }
                component.set('v.SelectedValue',newOrder);
            }
         },

        // Calling on values change in selected dual box.
        handleChange : function(component, event, helper){
            //Update Selected Values in comma seprated
            var selectedOptionValue = event.getParam("value");
            var newOrder= "";
            for(var i=0; i< selectedOptionValue.length; i++){
                if(newOrder.length <=0){
                   newOrder = selectedOptionValue[i];
                }else{
                     newOrder = newOrder + ";" + selectedOptionValue[i];
                }
            }
            component.set('v.SelectedValue',newOrder);
        }
})