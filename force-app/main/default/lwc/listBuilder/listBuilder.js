import {LightningElement, api, wire, track} from 'lwc';
import {getRecordUi} from 'lightning/uiRecordApi';

import BackButton from '@salesforce/label/c.Back';
import ViewCurrentPermissions from '@salesforce/label/c.ViewCurrentPermissions';
import AddNewPermission from '@salesforce/label/c.AddNewPermission';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

import {refreshApex} from '@salesforce/apex';
import getExistingShares from '@salesforce/apex/ListBuilderController.getExistingShares';
import getSupportedButtons from '@salesforce/apex/ListBuilderController.getSupportedButtons';

import {logger, logError} from 'c/lwcLogger';
import {buttonStylingSingle} from "c/buttonUtils";

export default class ListBuilder extends LightningElement {
    @api recordId;
    @api editTabName;
    @api addTabName;
    @api availableObjectTypes;
    @api managerName;
    @api supportedAddCapabilities;
    @api supportedEditCapabilities;
    @track existingShares;
    @track supportedButtons;
    @api ruleName;
    _refreshable;
    @api log = false;
    source = 'ListBuilder';

    @track cardTitle = '';
    label = {
        BackButton,
        ViewCurrentPermissions,
        AddNewPermission
    };

    connectedCallback() {
        getSupportedButtons({managerName: this.managerName}).then(results => {
            this.supportedButtons = JSON.parse(results);
        }).catch(error => {
            const showToast = new ShowToastEvent({
                title: 'Error retrieving submitters',
                message: result.error,
                variant: 'error',
            });
            dispatchEvent(showToast);
        });
    }

    @wire(getExistingShares, {managerName: '$managerName', approvalStepDefinitionId: '$recordId'})
    _getExistingShares(result) {
        this._refreshable = result;
        if (result.error) {
            logError(this.log, this.source, 'wiredSharings', result.error);
        } else if (result.data) {
            this.existingShares = JSON.parse(result.data);
        }
    }

    @api refresh() {
        // logger(this.log, this.source, 'refreshing');
        refreshApex(this._refreshable).then(result => {
            let cmpToRefresh = this.template.querySelector('c-add-new-members');
            if (cmpToRefresh) {
                cmpToRefresh.updateSharingLevelButtons();
            }
        });
    }

    // take the recordId and get the objectname
    @wire(getRecordUi, {
        recordIds: '$recordId',
        layoutTypes: ['Full'],
        modes: ['View']
    })
    wiredRecord({error, data}) {
        if (error) {
            logError(this.log, this.source, 'getRecordUI', error);
        } else {
            logger(this.log, this.source, 'getRecordUI', data);
            if (!data) return;

            const apiName = data.records[this.recordId].apiName;
            const objLabel = data.objectInfos[apiName].label;
            const nameField = data.objectInfos[apiName].nameFields[0];
            const namedFieldValue = data.records[this.recordId].fields[nameField];

            this.cardTitle = `${objLabel} : ${namedFieldValue.displayValue ||
            namedFieldValue.value}`;
        }
    }


    // refreshExisting() {
    //     const existing = this.template.querySelector('c-existing-shares');
    //     if (existing) {
    //         existing.refresh();
    //     }
    // }

    // do some basic verification error handling (not shareable, perms, etc)

    // serve up the card title
}
