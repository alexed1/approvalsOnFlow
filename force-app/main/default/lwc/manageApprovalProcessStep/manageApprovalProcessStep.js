import {LightningElement, api, track, wire} from 'lwc';

import getApprovalProcessSteps from '@salesforce/apex/ManageApprovalSteps.getApprovalProcessSteps';
import saveApprovalSteps from '@salesforce/apex/ManageApprovalSteps.saveApprovalSteps';

export default class manageApprovalProcessStep extends LightningElement {
    @api approvalProcessId;
    @api steps = [];   //alex: removed @track here so I could expose this to flow
    @api selectedRecords = []; //alex: removed @track here so I could expose this to flow

    @wire(getApprovalProcessSteps, {approvalProcessId: '$approvalProcessId'})
    _getApprovalProcessSteps(result) {
        if (result.error) {
        } else if (result.data) {
            this.steps = result.data;
        }
    }

    handleDataRefresh(event) {
        if (event.detail.selectedRecords) {
            this.selectedRecords = event.detail.selectedRecords;
        }
        if (event.detail.values) {
            this.steps = event.detail.values;
        }
    }

    handleSave() {
        saveApprovalSteps({
            appSteps: this.steps.map(curStep => {
                return {
                    "Id": curStep.value,
                    "Order__c": this.steps.findIndex(curItem => curItem.value === curStep.value)
                }
            })
        }).then(result => {
            this.showToast({
                detail: {
                    title: 'Success',
                    message: 'Step order successfully changed.',
                    variant: 'success',
                    autoClose: true
                }
            });
        }).catch(error => {
            this.showToast({
                detail: {
                    title: 'Error',
                    message: error.body.message,
                    variant: 'error',
                    autoClose: true
                }
            });
        });
    }

    showToast(event) {
        this.template.querySelector('c-toast-message').showCustomNotice(event);
    }
}