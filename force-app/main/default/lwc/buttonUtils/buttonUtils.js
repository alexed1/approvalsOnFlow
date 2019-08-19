import _handleButtonAction from '@salesforce/apex/ListBuilderController.handleButtonAction';
import {logger} from 'c/lwcLogger';

export {
    buttonStyling,
    buttonStylingSingle,
    handleButtonAction,
    generateCapabilityColumns
};

const generateCapabilityColumns = (labels) => {
    let labelsArray = labels.replace(' ', '').split(',');
    return labelsArray.map(curLabel => {
        return getColumnDescriptor(curLabel);
    });
};

const getColumnDescriptor = (curButtonLabel) => {
    return {
        type: 'button',
        label: curButtonLabel,
        typeAttributes: {
            label: curButtonLabel,
            name: curButtonLabel, //this is used to determine an apex method to call
            variant: 'neutral',
            disabled: {fieldName: curButtonLabel.replace(' ', '') + 'buttonDisabled'}
        },
        initialWidth: 100
    }
};

const buttonStyling = (supportedButtonSettings, selectedButtonNames, id, existingShares) => {

    let existing = existingShares.find(
        share => {
            return share.recordId === id;
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


