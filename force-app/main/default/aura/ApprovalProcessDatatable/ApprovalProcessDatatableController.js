/**
 * Created by Shubham on 1/30/2019.
 */
({
        // Set Records in Data Table
    	invoke : function(component, event, helper) {

            var dataArr = new Array();
            var colsStr = component.get('v.columnsStr');
            var fieldNameArr = new Array();
            if(colsStr){
                // Convert Comma Sepreted Values Into List for Columns of Data Table
                var colStrArr = colsStr.split(';');
                if(colStrArr){
                    var colArr = new Array();
                    for(var i = 0; i < colStrArr.length; i++){
                        var colDetailArr = colStrArr[i].split(',');
                        // Setting Up Records In Data Table
                        if(colDetailArr.length === 3){
                        	var colObj = {label: colDetailArr[0], fieldName: colDetailArr[1], type: colDetailArr[2]};
                            colArr.push(colObj);
                            fieldNameArr.push(colDetailArr[1]);
                        }
                    }
                    component.set('v.columns', colArr);
                }
            }
    	},
        // Set Selected Record and RecordId
        setRecordId : function(component, event, helper){
            var selectedRows = event.getParam('selectedRows');
            var key = component.get('v.key');
            var recIds = '';
            if(selectedRows){
                //Store Single Selected Record Id
                if(selectedRows.length === 1){
                    component.set('v.recordId', selectedRows[0][key]);
                }
                else{
                    //Store Multiple Record Id
                    for(let i = 0; i < selectedRows.length; i++){
                        recIds += selectedRows[i][key] + ',';
                    }
                    component.set('v.recordIds', recIds);
                    component.set('v.numOfRowsSelected', selectedRows.length);
                }
            }
        },
})