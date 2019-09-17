import {LightningElement, api, wire, track} from 'lwc';

import SupportedButtonsEmptyMessage from '@salesforce/label/c.SupportedButtonsEmptyMessage';
import SupportedAddCapabilitiesEmptyMessage from '@salesforce/label/c.SupportedAddCapabilitiesEmptyMessage';
import ButtonIsNotSupportedMessage from '@salesforce/label/c.ButtonIsNotSupportedMessage';
import SupportedEditCapabilitiesEmptyMessage from '@salesforce/label/c.SupportedEditCapabilitiesEmptyMessage';
import ManagerEmptyMessage from '@salesforce/label/c.ManagerEmptyMessage';

import {refreshApex} from '@salesforce/apex';
import getExistingMembers from '@salesforce/apex/RoleManagerController.getExistingMembers';
import getSupportedButtons from '@salesforce/apex/RoleManagerController.getSupportedButtons';

import {logger, logError} from 'c/lwcLogger';

import {
    getNotSupportedButtons
} from 'c/buttonUtils';


export default class RoleManager extends LightningElement {
    @api recordId;
    @api myRecordId;
    @api editTabName;
    @api addTabName;
    @api availableObjectTypes;
    @api managerName;
    @api supportedAddCapabilities;
    @api supportedEditCapabilities;
    @api layout = 'Tabbed';
    @api memberParams;
    @track existingMembers;
    @track supportedButtons;
    @api ruleName;
    _refreshable;
    @api log = false;
    source = 'RoleManager';
    @track loadFinished = false;
    @api doRender;
    @track cardTitle = '';
    @track errors = [];

    @wire(getSupportedButtons, {managerName: '$managerName'})
    _getSupportedButtons(result) {
        this._refreshable = result;
        if (result.error) {
            this.errors.push(result.error.body.message);
            logError(this.log, this.source, 'getSupportedButtons', result.error);
        } else if (result.data) {
            this.supportedButtons = JSON.parse(result.data);
            this.loadFinished = true;
            if (this.doRender !== false) {
                this.doRender = true;
            }
        }
    }

    @wire(getExistingMembers, {managerName: '$managerName', recordId: '$recordId'})
    _getExistingMembers(result) {
        this._refreshable = result;
        if (result.error) {
            this.errors.push(result.error.body.message);
            logError(this.log, this.source, 'getExistingMembers', result.error);
        } else if (result.data) {
            this.existingMembers = result.data;
            const memberRefreshedEvent = new CustomEvent('membersrefreshed', {
                bubbles: true, detail: {
                    members: result.data
                }
            });

            this.dispatchEvent(memberRefreshedEvent);
        }
    }

    get defaultTab() {
        if (!this.existingMembers || this.existingMembers.length == 0) {
            return this.addTabName;
        } else {
            return this.editTabName;
        }

    }

    get showMarkup() {
        return this.loadFinished && this.doRender;
    }

    @api refresh() {
        refreshApex(this._refreshable).then(result => {
            let cmpToRefresh = this.template.querySelector('c-add-new-members');
            if (cmpToRefresh) {
                cmpToRefresh.updateRowButtons();
            }
        });
    }

    get showExistingTab() {
        return this.layout === 'Tabbed';
    }

    get errorMessage() {
        let resultErrors = [...this.errors];

        if (!this.supportedButtons) {
            resultErrors.push(SupportedButtonsEmptyMessage);
        }
        if (!this.supportedAddCapabilities) {
            resultErrors.push(SupportedAddCapabilitiesEmptyMessage);
        }
        if (!this.supportedEditCapabilities && this.showExistingTab) {
            resultErrors.push(SupportedEditCapabilitiesEmptyMessage);
        }
        if (!this.managerName) {
            resultErrors.push(ManagerEmptyMessage);
        }

        if (this.supportedButtons && (this.supportedAddCapabilities || this.supportedEditCapabilities)) {
            let allButtonsString = this.supportedAddCapabilities + (this.showExistingTab ? (', ' + this.supportedEditCapabilities) : '');
            let notSupportedButtnos = getNotSupportedButtons(this.supportedButtons, allButtonsString);

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
