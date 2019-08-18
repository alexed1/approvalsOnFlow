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

const getColumnDescriptor = (curButtonLabel) => {
    return {
        type: 'button',
        typeAttributes: {
            label: curButtonLabel,
            name: curButtonLabel, //this is used to determine an apex method to call
            variant: 'neutral',
            disabled: {fieldName: curButtonLabel.replace(' ', '') + 'buttonDisabled'}
        },
        initialWidth: 85
    }
};

const buttonStyling = (supportedButtonSettings, selectedButtonNames, id, existingShares) => {

    let existing = existingShares.find(
        share => {
            return share.Name === id;
        }
    );

    return buttonStylingSingle(supportedButtonSettings, selectedButtonNames, existing);
};

const buttonStylingSingle = (supportedButtonSettings, selectedButtonNames, existing) => {

    let resultButtonSettings = {};
    selectedButtonNames.replace(' ', '').split(',').forEach(buttonName => {
        let allbs = supportedButtonSettings.filter(curSetting => curSetting.name == buttonName);
        let isDisabled = false;
        if (allbs && allbs.length > 0) {
            for (let i = 0; i < allbs.length; i++) {
                if (
                    (existing !== undefined && allbs[i].matchingRule.matchingAction == 'EXISTS') ||
                    (existing === undefined && allbs[i].matchingRule.matchingAction == 'NOTEXISTS')) {
                    isDisabled = true;
                    break;
                } else if (allbs[i].matchingRule.matchingAction == 'VALUEEQUALS') {
                    let disabledValues = allbs[i].matchingRule.disabledValues;
                    if (disabledValues) {
                        for (var fieldName in disabledValues) {
                            if (Object.prototype.hasOwnProperty.call(disabledValues, fieldName)) {
                                disabledValues[fieldName].forEach(fieldValue => {
                                    if (existing[fieldName] == fieldValue) {
                                        isDisabled = true;
                                    }
                                });
                            }
                        }
                        if (isDisabled) {
                            break;
                        }
                    }
                }
            }
        }

        resultButtonSettings[buttonName.replace(' ', '') + 'buttonDisabled'] = isDisabled;
    });
    return resultButtonSettings;
};

const handleButtonAction = async (buttonName, managerName, paramsString) => {
    await _handleButtonAction({
        buttonName,
        managerName,
        paramsString
    });
};


