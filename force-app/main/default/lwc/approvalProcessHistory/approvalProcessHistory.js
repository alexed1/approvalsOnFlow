import {LightningElement, api, track, wire} from 'lwc';
import getApprovalProcessHistory from '@salesforce/apex/ApprovalProcessHelper.getApprovalProcessHistory';
import {NavigationMixin} from 'lightning/navigation';
import {logger} from 'c/lwcLogger';

export default class approvalProcessHistory extends NavigationMixin(LightningElement) {
    @api recordId;
    @track historyData;
    @track openSteps = [];

    connectedCallback() {
        logger(this.log, this.source, `recordId is now ${this.recordId}`);
    }

    @wire(getApprovalProcessHistory, {processInstanceId: '$recordId'})
    _getApprovalProcessHistory({error, data}) {
        if (error) {
            this.errors.push(error.body.message);
        } else if (data) {
            this.historyData = JSON.parse(data);
            this.historyData.sort(this.sortByField('order', -1));
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
                tempData.items = tempData.items.map(curHistoryItem => {
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
                tempData.items.sort(this.sortByField('CreatedDate', -1));
                return {
                    ...tempData, ...{
                        selected: this.openSteps.includes(curData.id),
                        iconName: this.openSteps.includes(curData.id) ? 'utility:chevrondown' : 'utility:chevronright',
                        statusClass: this.getStatusClass(curData.status)
                    }
                };
            });
        } else {
            return [];
        }
    }

    sortByField(fieldName, order) {
        return (a, b) => {
            return (order * ((a[fieldName] > b[fieldName]) ? 1 : ((b[fieldName] > a[fieldName]) ? -1 : 0)));
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