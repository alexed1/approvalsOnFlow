import {LightningElement, api, track, wire} from 'lwc';
import getSubmittersPerType from '@salesforce/apex/InitialSubmittersSelectController.getSubmittersPerType';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class initialSubmittersSelect extends LightningElement {
    NONE_TYPE = {label: '--None--', value: ''};

    @api typeOptions = [
        {label: 'Creator', value: 'Creator'},
        {label: 'Owner', value: 'Owner'},
        {label: 'Public Group', value: 'Public Group'},
        {label: 'Role', value: 'Role'},
        {label: 'Role and Subordinates', value: 'Role and Subordinates'},
        {label: 'User', value: 'User'},
        {label: 'Queue', value: 'Queue'}
    ];

    @track submittersByType;
    @track selectedType;
    @track submitterSearchString;
    @track selectedSubmitters = [];

    connectedCallback() {
        getSubmittersPerType({
            submitterTypes: this.typeOptions.map(option => option.value)
        }).then(results => {
            this.submittersByType = results;
        }).catch(error => {
            const showToast = new ShowToastEvent({
                title: 'Error retrieving submitters',
                message: result.error,
                variant: 'error',
            });
            dispatchEvent(showToast);
        });
    }

    get availableSubmitters() {
        var submittersToReturn;
        if (!this.submittersByType || !this.selectedType || !this.submittersByType[this.selectedType]) {
            return [this.NONE_TYPE];
        } else {
            if (this.submitterSearchString) {
                submittersToReturn = this.submittersByType[this.selectedType].filter(
                    submitter => {
                        return submitter.label.toLowerCase().includes(this.submitterSearchString.toLowerCase())
                    }
                );
            } else {
                submittersToReturn = this.submittersByType[this.selectedType]
            }
        }
        return submittersToReturn.map(submitter => {
            return {value: submitter.value, label: this.selectedType + ': ' + submitter.label};
        });
    }

    handleSubmitterTypeChange(event) {
        this.selectedType = event.detail.value;
    }

    handleSelectedSubmitterChange(event) {
        this.selectedSubmitters = event.detail.value;
    }

    handleSearchKeyUp(event) {
        const isEnterKey = event.keyCode === 13;
        if (isEnterKey) {
            this.submitterSearchString = event.target.value;
        }
    }
}