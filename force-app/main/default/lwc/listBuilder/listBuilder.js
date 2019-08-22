import {LightningElement, api, wire, track} from 'lwc';

import BackButton from '@salesforce/label/c.Back';
import ViewCurrentPermissions from '@salesforce/label/c.ViewCurrentPermissions';
import AddNewPermission from '@salesforce/label/c.AddNewPermission';

import SupportedButtonsEmptyMessage from '@salesforce/label/c.SupportedButtonsEmptyMessage';
import SupportedAddCapabilitiesEmptyMessage from '@salesforce/label/c.SupportedAddCapabilitiesEmptyMessage';
import ButtonIsNotSupportedMessage from '@salesforce/label/c.ButtonIsNotSupportedMessage';
import SupportedEditCapabilitiesEmptyMessage from '@salesforce/label/c.SupportedEditCapabilitiesEmptyMessage';
import ManagerEmptyMessage from '@salesforce/label/c.ManagerEmptyMessage';

import {refreshApex} from '@salesforce/apex';
import getExistingMembers from '@salesforce/apex/ListBuilderController.getExistingMembers';
import getSupportedButtons from '@salesforce/apex/ListBuilderController.getSupportedButtons';

import {logger, logError} from 'c/lwcLogger';

import {
    getNotSupportedButtons
} from 'c/buttonUtils';


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
    @track loadFinished = false;
    @track cardTitle = '';
    label = {
        BackButton,
        ViewCurrentPermissions,
        AddNewPermission
    };

    @wire(getSupportedButtons, {managerName: '$managerName'})
    _getSupportedButtons(result) {
        this._refreshable = result;
        if (result.error) {
            logError(this.log, this.source, 'wiredSharings', result.error);
        } else if (result.data) {
            this.supportedButtons = JSON.parse(result.data);
            this.loadFinished = true;
        }
    }

    @wire(getExistingMembers, {managerName: '$managerName', recordId: '$recordId'})
    _getExistingMembers(result) {
        this._refreshable = result;
        if (result.error) {
            logError(this.log, this.source, 'wiredSharings', result.error);
        } else if (result.data) {
            this.existingShares = result.data;
        }
    }

    @api refresh() {
        refreshApex(this._refreshable).then(result => {
            let cmpToRefresh = this.template.querySelector('c-add-new-members');
            if (cmpToRefresh) {
                cmpToRefresh.updateSharingLevelButtons();
            }
        });
    }

    get errorMessage() {
        let resultErrors = [];

        if (!this.supportedButtons) {
            resultErrors.push(SupportedButtonsEmptyMessage);
        }
        if (!this.supportedAddCapabilities) {
            resultErrors.push(SupportedAddCapabilitiesEmptyMessage);
        }
        if (!this.supportedEditCapabilities) {
            resultErrors.push(SupportedEditCapabilitiesEmptyMessage);
        }
        if (!this.managerName) {
            resultErrors.push(ManagerEmptyMessage);
        }

        if (this.supportedButtons && (this.supportedAddCapabilities || this.supportedEditCapabilities)) {
            let notSupportedButtnos = getNotSupportedButtons(this.supportedButtons, this.supportedAddCapabilities + ', ' + this.supportedEditCapabilities);

            if (notSupportedButtnos.length > 0) {
                resultErrors.push(ButtonIsNotSupportedMessage + notSupportedButtnos.join(', '));
            }
        }

        if (resultErrors.length) {
            return resultErrors.join('; ');
        } else {
            return false;
        }

    }
}
