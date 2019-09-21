import {LightningElement, track, api} from 'lwc';

export default class orderedListBox extends LightningElement {
    @track label = 'Select Options';
    @track _values = [];
    @track _selectedRecords = [];

    isStringArray = false;
    isValid = true;

    set selectedRecords(values) {
        this._selectedRecords = values;
    }

    @api
    get selectedRecords() {
        return this._selectedRecords;
    }

    set values(inputValues) {
        if (inputValues && Array.isArray(inputValues) && inputValues.length > 0) {
            if (inputValues[0].label === undefined || inputValues[0].value === undefined) {
                if (typeof inputValues[0] !== 'string') {
                    this.isValid = false;
                } else {
                    this.isStringArray = true;
                    this._values = inputValues.map(curValue => {
                        return {label: curValue, value: curValue}
                    });
                }
            } else {
                this._values = inputValues;
            }
        } else {
            this.isValid = false;
            this._values = [];
        }
    }

    @api
    get values() {
        if (this.isStringArray) {
            return this._values.map(curEl => curEl.value);
        } else {
            return this._values;
        }
    }

    @api
    validate() {
        if (this.isValid) {
            return {isValid: true};
        } else {
            return {
                isValid: false,
                errorMessage: 'Values is empty or not valid array of Strings.'
            };
        }
    }

    get records() {
        if (this._values) {
            return this._values.map(curRec => {
                return {...curRec, ...{selected: this.selectedRecords.find(curSel => curSel == curRec.value) !== undefined}};
            });
        } else {
            return [];
        }
    }

    setSelected(event) {
        let selectedRecords = this.selectedRecords;
        if (event.ctrlKey) {
            selectedRecords.push(event.currentTarget.dataset.recordid);
        } else {
            selectedRecords = [event.currentTarget.dataset.recordid];
        }

        this._selectedRecords = selectedRecords;

        this.dispatchDataRefreshEvent({
            selectedRecords: selectedRecords
        });
    }

    dispatchDataRefreshEvent(detail) {
        const dataRefreshEvent = new CustomEvent('datarefresh', {
            bubbles: true, detail: detail
        });
        this.dispatchEvent(dataRefreshEvent);
    }

    moveUp() {
        this.moveIndex(-1);

    }

    moveDown() {
        this.moveIndex(1);
    }

    moveIndex(shift) {
        let finalValues;
        this._values.forEach(curRec => {
            if (this.selectedRecords.find(curSel => curSel == curRec.value) !== undefined) {
                let originalIndex = this._values.findIndex(curItem => curItem.value === curRec.value);
                let newIndex = originalIndex + shift;
                if (newIndex >= 0 && newIndex < this._values.length) {
                    finalValues = this.move(originalIndex, newIndex, ...this._values);
                }
            }
        });
        //flow output
        if (finalValues) {
            this._values = finalValues;
            this.dispatchDataRefreshEvent({values: finalValues});
        }
    }

    move(from, to, ...a) {
        from === to ? a : (a.splice(to, 0, ...a.splice(from, 1)), a);
        return a;
    }
}