// import upsertPerm from '@salesforce/apex/SharingActions.upsertPerm';
// import deletePerm from '@salesforce/apex/SharingActions.deletePerm';
import _handleButtonAction from '@salesforce/apex/ListBuilderController.handleButtonAction';
//TODO: import method to determine button availability to be used in: disabled: {fieldName: 'noneDisabled'}
import {logger} from 'c/lwcLogger';

export {
    buttonStyling,
    buttonStylingSingle,
    // shareDelete,
    // shareUpdate,
    handleButtonAction,
    generateCapabilityColumns
};

const generateCapabilityColumns = (labels, existingShares) => {
    let labelsArray = labels.replace(' ', '').split(',');
    return labelsArray.map(curLabel => {
        return getColumnDescriptor(curLabel);
    });
};

//generate the object structure needed by Datatable, for a given label. 
const getColumnDescriptor = (curButtonLabel) => {
    return {
        type: 'button',
        typeAttributes: {
            label: curButtonLabel,
            name: curButtonLabel, //this is used to determine an apex method to call
            variant: 'neutral',
            disabled: {fieldName: curButtonLabel.replace(' ','')+'buttonDisabled'}
        },
        initialWidth: 85
    }
};

const buttonStyling = (supportedButtonSettings, selectedButtonNames ,id, existingShares) => {

    // it could be a group or a role on a group
    let existing = existingShares.find(
        share => {
            return share.Name === id;
        }
    );

    // return {buttonDisabled: existing !== undefined}
    return buttonStylingSingle(supportedButtonSettings, selectedButtonNames, existing);
};

const buttonStylingSingle = (supportedButtonSettings, selectedButtonNames, existing) => {
    //TODO: implement ability to utilize custom functions for button endbling/disabling
    let resultButtonSettings = {};
        selectedButtonNames.replace(' ','').split(',').forEach(buttonName =>{
            let bs = supportedButtonSettings.find(curSetting => curSetting.name == buttonName);
            let isDisabled;
            if(
                (existing !== undefined && bs.matchingRule.matchingAction == 'EXISTS') ||
                (existing === undefined && bs.matchingRule.matchingAction == 'NOTEXISTS')){
                isDisabled = true;
            }else {
                isDisabled = false;
            };
            resultButtonSettings[buttonName.replace(' ','')+'buttonDisabled'] =isDisabled;
        });
        return resultButtonSettings;

    // // CEO ID: 00G9A0000011wy7UAA
    // if (existing && existing.RowCause === 'Owner') {
    //     return {
    //         readDisabled: true,
    //         editDisabled: true,
    //         noneDisabled: true
    //     };
    // }
    //
    // const output = {
    //     readDisabled: false,
    //     editDisabled: false,
    //     noneDisabled: false
    // };
    //
    // if (existing) {
    //     if (existing.AccessLevel === 'Read') {
    //         output.readDisabled = true;
    //     } else if (existing.AccessLevel === 'Edit') {
    //         output.editDisabled = true;
    //     }
    // } else {
    //     output.noneDisabled = true;
    // }
    //
    // return output;
};


// const shareDelete = async (UserOrGroupID, recordId) => {
//     await deletePerm({
//         UserOrGroupID,
//         recordId
//     });
// };
//
// const shareUpdate = async (UserOrGroupID, recordId, level) => {
//     await upsertPerm({
//         UserOrGroupID,
//         recordId,
//         level
//     });
// };

const handleButtonAction = async (buttonName, managerName, paramsString) => {
    await _handleButtonAction({
        buttonName,
        managerName,
        paramsString
    });
};


