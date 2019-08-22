import _handleButtonAction from '@salesforce/apex/ListBuilderController.handleButtonAction';
import {logger} from 'c/lwcLogger';

export {
    buttonStyling,
    buttonStylingSingle,
    handleButtonAction,
    generateCapabilityColumns,
    getNotSupportedButtons,
    splitValues
};

const generateCapabilityColumns = (labels) => {
    let labelsArray = labels.replace(/ /g, '').split(',');
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
            disabled: {fieldName: curButtonLabel.replace(/ /g, '') + 'buttonDisabled'}
        },
        initialWidth: 120 //TODO: Calculate based on content
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
    selectedButtonNames.replace(/ /g, '').split(',').forEach(buttonName => {
        let allbs = supportedButtonSettings.filter(curSetting => curSetting.name == buttonName);
        let isDisabled = false;
        if (allbs && allbs.length > 0) {
            for (let i = 0; i < allbs.length; i++) {
                if(allbs[i].matchingRule.matchingAction == 'SUPPORTED'){
                    return false;
                    break;
                }
                else if (
                    (existing !== undefined && allbs[i].matchingRule.matchingAction == 'EXISTS') ||
                    (existing === undefined && allbs[i].matchingRule.matchingAction == 'NOTEXISTS')) {
                    isDisabled = true;
                    break;
                } else if (existing !== undefined && allbs[i].matchingRule.matchingAction == 'VALUEEQUALS') {
                    let disabledValues = allbs[i].matchingRule.disabledValues;
                    if (disabledValues) {
                        for (var fieldName in disabledValues) {
                            if (Object.prototype.hasOwnProperty.call(disabledValues, fieldName)) {
                                disabledValues[fieldName].forEach(fieldValue => {
                                    if (existing.shareRecord[fieldName] == fieldValue) {
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

        resultButtonSettings[buttonName.replace(/ /g, '') + 'buttonDisabled'] = isDisabled;
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

const getNotSupportedButtons = (supportedButtons, buttonsToVerify) =>{
        let notSupportedButtnos = [];

    splitValues(buttonsToVerify).forEach(curButtonName => {
        let newButtons = supportedButtons.filter(el => el.name == curButtonName);
        if (newButtons.length == 0) {
            notSupportedButtnos.push(curButtonName);
        }
    });

    return notSupportedButtnos;
};

const splitValues = (originalString) =>{
    if (originalString) {
        return originalString.replace(/ /g, '').split(',');
    } else {
        return [];
    }
};


