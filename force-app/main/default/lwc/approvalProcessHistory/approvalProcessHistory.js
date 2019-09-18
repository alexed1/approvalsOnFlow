import {LightningElement, api, track, wire} from 'lwc';
import getApprovalProcessHistory from '@salesforce/apex/ApprovalProcessHelper.getApprovalProcessHistory';
import {NavigationMixin} from 'lightning/navigation';

export default class approvalProcessHistory extends NavigationMixin(LightningElement) {
    @api recordId = '';
    @track historyData;
    @track openSteps = [];

    @wire(getApprovalProcessHistory, {processId: '$recordId'})
    _getApprovalProcessHistory({error, data}) {
        if (error) {
            this.errors.push(error.body.message);
        } else if (data) {
            this.historyData = JSON.parse(data);
        }
    }

    toggleStep(event) {
        let id = event.currentTarget.dataset.id;
        this.openSteps = this.openSteps.includes(id) ? this.openSteps.filter(i => i !== id) : [...this.openSteps, id];
    }

    generateUrl(objectType, recordId) {
        //TODO: find some other way to generate an url. Navigation service works asyncroniously thus can not be used during rendering.
        if (recordId) {
            return '/lightning/r/' + objectType + '/' + recordId + '/view';
        }
        return '';
    }

    get data() {
        if (this.historyData) {
            return this.historyData.map(curData => {
                let tempData = JSON.parse(JSON.stringify(curData));
                tempData.AP_ApprovalInstanceHistoryItems__r.records = tempData.AP_ApprovalInstanceHistoryItems__r.records.map(curHistoryItem => {
                    let url = this.generateUrl('standard__objectPage', 'User', curHistoryItem.Assigned_User__c);
                    return {
                        ...curHistoryItem, ...{
                            assignedUserName: curHistoryItem.Assigned_User__r ? curHistoryItem.Assigned_User__r.Name : '',
                            assignedUserUrl: curHistoryItem.Assigned_User__r ? this.generateUrl(curHistoryItem.Assigned_User__r.attributes.type, curHistoryItem.Assigned_User__c) : '',
                            originalUserName: curHistoryItem.Original_User__r ? curHistoryItem.Original_User__r.Name : '',
                            originalUserUrl: curHistoryItem.Original_User__r ? this.generateUrl(curHistoryItem.Original_User__r.attributes.type, curHistoryItem.Original_User__c) : ''
                        }
                    };
                });
                return {
                    ...tempData, ...{
                        selected: this.openSteps.includes(curData.Id),
                        iconName: this.openSteps.includes(curData.Id) ? 'utility:chevrondown' : 'utility:chevronright',
                        statusClass: this.getStatusClass(curData.Status__c)
                    }
                };
            });
        } else {
            return [];
        }
    }

    getStatusClass(status) {
        let finalClas = 'slds-badge slds-m-top--xx-small ';
        finalClas += status === 'Approved' ? 'slds-theme_success' : 'slds-theme_warning';
        return finalClas;
    }

    columns = [
        {
            type: 'date',
            fieldName: 'CreatedDate',
            label: 'Date', typeAttributes: {
                year: "numeric",
                month: "long",
                day: "2-digit",
                hour: "2-digit",
                minute: "2-digit"
            }
        },
        {
            type: 'url',
            fieldName: 'assignedUserUrl',
            label: 'Assigned To',
            typeAttributes: {
                label: {fieldName: 'assignedUserName'}
            }
        },
        {
            type: 'url',
            fieldName: 'originalUserUrl',
            label: 'Actual Approver',
            typeAttributes: {
                label: {fieldName: 'originalUserName'}
            }
        },
        {
            type: 'text',
            fieldName: 'Status__c',
            label: 'Status',
        },
        {
            type: 'text',
            fieldName: 'Comments__c',
            label: 'Comments',
        }
    ];
}