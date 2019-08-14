// import upsertPerm from '@salesforce/apex/SharingActions.upsertPerm';
// import deletePerm from '@salesforce/apex/SharingActions.deletePerm';
import  _handleButtonAction from '@salesforce/apex/ListBuilderController.handleButtonAction';
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

const generateCapabilityColumns = (labels) => {
    debugger;
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
            disabled: false
            // disabled: {fieldName: 'noneDisabled'}
        },
        initialWidth: 85
    }
};

// const sharingButtonColumns = [
//   {
//     type: 'button',
//     typeAttributes: {
//       label: 'None',
//       name: 'none',
//       variant: 'neutral',
//       disabled: { fieldName: 'noneDisabled' }
//     },
//     initialWidth: 85
//   },
//   {
//     type: 'button',
//     typeAttributes: {
//       label: 'Read',
//       name: 'read',
//       variant: 'neutral',
//       disabled: { fieldName: 'readDisabled' }
//     },
//     initialWidth: 80
//   },
//   {
//     type: 'button',
//     typeAttributes: {
//       label: 'Read/Write',
//       name: 'read_write',
//       variant: 'neutral',
//       disabled: { fieldName: 'editDisabled' }
//     },
//     initialWidth: 125
//   }
// ];

const buttonStylingSingle = existing => {
    // CEO ID: 00G9A0000011wy7UAA
    if (existing && existing.RowCause === 'Owner') {
        return {
            readDisabled: true,
            editDisabled: true,
            noneDisabled: true
        };
    }

    const output = {
        readDisabled: false,
        editDisabled: false,
        noneDisabled: false
    };

    if (existing) {
        if (existing.AccessLevel === 'Read') {
            output.readDisabled = true;
        } else if (existing.AccessLevel === 'Edit') {
            output.editDisabled = true;
        }
    } else {
        output.noneDisabled = true;
    }

    return output;
};

const buttonStyling = (id, viewEditMembers) => {
    // it could be a group or a role on a group
    const existing = viewEditMembers.find(
        share => share.UserOrGroupID === id || share.RoleId === id
    );
    return buttonStylingSingle(existing);
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


