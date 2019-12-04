import {LightningElement, track, api} from 'lwc';

const defaults = {
    csv: 'csv',
    list: 'list',
    originalObject: 'object',
    valueField: 'value',
    labelField: 'label',
    originalObjectOutputNotSupported: 'Object output is not supported for this option type.',
    valueLabelFieldNamesNotSupported: 'Value and Label field names should be left empty for this option type.',
    canNotUseValuesForOutput: 'Values for output can be used only with "csv" or "list" input type.'
};

export default class dualListBox extends LightningElement {

    @api label;
    @api sourceLabel;
    @api fieldLevelHelp;
    @api selectedLabel;

    @api min;
    @api max;
    @api disableReordering;
    @api size;
    @api required;
    @api requiredOptions;

    @api selectedValuesStringFormat;
    @api allOptionsStringFormat = defaults.csv;//csv;list;object
    @api useWhichObjectKeyForData = defaults.valueField;
    @api useWhichObjectKeyForLabel = defaults.labelField;
    @api useObjectValueAsOutput = false; //used with csv or list
    @track _options; //always json{label,value}
    @track _optionsOriginal; //stores original values
    @track _value; //['value1','value2','value3']

    @api
    getValues(valueType) {
        return this.formatValuesGet(this._value, valueType);
    }

    @api
    getOptions(valueType) {
        return this.formatOptionsGet(this._options, valueType);
    }

    @api
    get selectedOptions() {
        return this.getValues(this.selectedValuesStringFormat);
    }

    set selectedOptions(value) {
        if (!this.isError) {
            this._value = this.formatValuesSet(value, this.selectedValuesStringFormat);
        }
    }

    @api
    get allOptions() {
        return this.getOptions(this.allOptionsStringFormat);
    }

    set allOptions(value) {
        if (!this.isError) {
            this._optionsOriginal = value;
            this._options = this.formatOptionsSet(value, this.allOptionsStringFormat);
        }
    }

    get isError() {
        if (this.selectedValuesStringFormat === defaults.originalObject && this.allOptionsStringFormat !== defaults.originalObject) {
            return defaults.originalObjectOutputNotSupported;
        }
        if (this.allOptionsStringFormat !== defaults.originalObject &&
            (
                (this.useWhichObjectKeyForData || this.useWhichObjectKeyForLabel) &&
                this.useWhichObjectKeyForData !== defaults.valueField || this.useWhichObjectKeyForLabel !== defaults.labelField)
        ) {
            return defaults.valueLabelFieldNamesNotSupported;
        }
        if (this.useObjectValueAsOutput && this.selectedValuesStringFormat === defaults.originalObject) {
            return defaults.canNotUseValuesForOutput;
        }
    }

    formatValuesSet(value, optionType) {
        if (!value) {
            return;
        }
        if (optionType === defaults.csv) {
            return value.replace(/[\s]+/, '').split(',');
        } else if (optionType === defaults.list) {
            return value;
        } else if (optionType === defaults.originalObject) {
            return value.map(curItem => curItem[this.useWhichObjectKeyForData]);
        }
    }

    formatValuesGet(items, optionType) {
        if (!items) {
            return;
        }
        let selectedValues = this.useObjectValueAsOutput ? items : items.map(curItem => {
            return this._options.find(curFilterItem => curItem === curFilterItem.value).label;
        });
        if (optionType === defaults.csv) {
            return selectedValues.join(',');
        } else if (optionType === defaults.list) {
            return selectedValues;
        } else if (optionType === defaults.originalObject) {
            return this._optionsOriginal.filter(curOriginal => {
                return items.includes(curOriginal[this.useWhichObjectKeyForData]);
            });
        }
    }

    formatOptionsSet(items, optionType) {
        if (!items) {
            return;
        }
        if (optionType === defaults.csv) {
            let localItems = items.replace(/[\s]+/, '').split(',');
            return localItems.map(curItem => {
                return {label: curItem, value: curItem}
            });
        } else if (optionType === defaults.list) {
            return items.map(curItem => {
                return {label: curItem, value: curItem}
            });
        } else if (optionType === defaults.originalObject) {
            return items.map(curItem => {
                return {label: curItem[this.useWhichObjectKeyForLabel], value: curItem[this.useWhichObjectKeyForData]}
            });
        }
    }

    formatOptionsGet(items, optionType) {
        if (!items) {
            return;
        }
        if (optionType === defaults.csv) {
            return items.map(curItem => this.useObjectValueAsOutput ? curItem.value : curItem.label).join(',');
        } else if (optionType === defaults.list) {
            return items.map(curItem => this.useObjectValueAsOutput ? curItem.value : curItem.label);
        } else if (optionType === defaults.originalObject) {
            return items.map(curItem => {
                return this._optionsOriginal.find(curFilterItem => curItem.value === curFilterItem[this.useWhichObjectKeyForData]);
            });
        }
    }

    handleChange(event) {
        this._value = event.detail.value;
    }
}