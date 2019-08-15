import {LightningElement, api, track, wire} from 'lwc';

import Search from '@salesforce/label/c.Search';
import For from '@salesforce/label/c.For';
import TooManyResultsMessage from '@salesforce/label/c.TooManyResultsMessage';
import Type3 from '@salesforce/label/c.TooManyResultsMessage';
import Queues from '@salesforce/label/c.Queues';
import RelatedUsers from '@salesforce/label/c.RelatedUsers';
import PublicGroups from '@salesforce/label/c.PublicGroups';
import Roles from '@salesforce/label/c.Roles';
import Users from '@salesforce/label/c.Users';
// import getSharings from '@salesforce/apex/SharingActions.getSharings';
// import doSOSL from '@salesforce/apex/AdminTools.doSOSL';
import getSubmittersPerType from '@salesforce/apex/InitialSubmittersSelectController.getSubmittersPerType';

import getSharings from '@salesforce/apex/SharingActions.getSharings';
import {logger, logError} from 'c/lwcLogger';

import {refreshApex} from '@salesforce/apex';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

import {
    buttonStyling,
    // sharingButtonColumns,
    shareUpdate,
    shareDelete,
    handleButtonAction,
    generateCapabilityColumns
} from 'c/buttonUtils';

const typeMapping = {
    group: PublicGroups,
    role: Roles,
    user: Users,
    queue: Queues
};
export default class addNewMembers extends LightningElement {
    @api log = false;
    @api recordId;
    @api foo;

    //expect a set of strings representing button labels
    //'user, queue'
    @api availableObjectTypes;
    //Apex class name 'ManageStepApprovers'
    @api managerName;
    //Button labels 'Add, Remove', will determine functions called in apex class
    @api supportedAddCapabilities;
    //Existing shares for current record
    @api existingShares;
    @api supportedButtons;

    // @track readDisabled = false;
    // @track noneDisabled = false;
    // @track editDisabled = false;

    @track label = {
        Search,
        TooManyResultsMessage,
        Type3,
        For
    };
    @track searchString = '';
    source = 'addNewMembers';

    get objectTypes() {
        return this.availableObjectTypes.replace(' ', '').split(',').map(curTypeName => {
            return this.getTypeDescriptor(curTypeName);
        });
    }

    getTypeDescriptor(typeName) {
        return {value: typeName, label: typeMapping[typeName]};
    }

    get tooManyResults() {
        return this.searchResults.length > 199;
    }

    // call this when you know the sharing table is out of sync
    refresh() {
        this.dispatchEvent(new CustomEvent('searchrefresh'));
        // logger(this.log, this.source, 'refreshing');
        // refreshApex(this._refreshable);
    }

    _refreshable;

    @track selectedType = 'user';

    @track columns;

    connectedCallback() {
        this.columns = [{
            label: 'Name',
            fieldName: 'label'
        }].concat(generateCapabilityColumns(this.supportedAddCapabilities));
    }

    @track searchResults = [];
    @track searchDisabled = false;

    viewEditMembers = [];

    // @wire(getSharings, {recordId: '$recordId'})
    // wiredSharings(result) {
    //     this._refreshable = result;
    //     if (result.error) {
    //         logError(this.log, this.source, 'getSharings error', result.error);
    //     } else if (result.data) {
    //         logger(this.log, this.source, 'getSharings returned', result.data);
    //         this.viewEditMembers = JSON.parse(result.data);
    //         this.updateSharingLevelButtons();
    //     }
    // }

    typeChange(event) {
        this.selectedType = event.detail.value;
        logger(this.log, this.source, `type is now ${this.selectedType}`);
        // clear the results
        this.searchResults = [];
        // TODO: how clear the search box
    }

    async actuallySearch() {
        //this.log = true;
        logger(this.log, this.source, 'actually searching!');
        this.searchResults = [];
        this.searchDisabled = true;

        const results =
            await getSubmittersPerType({
                searchString: this.searchString,
                submitterTypes: [this.selectedType]
            });

        logger(this.log, this.source, 'search results', results);
        // const finalResults = results[this.selectedType];

        // results.forEach(result => {
        //     // make some types a bit nicer
        //     if (this.selectedType === 'user') {
        //         result.Name = `${result.Name} (${this.translateTypes(
        //             result.UserType
        //         )})`;
        //     } else if (this.selectedType === 'group') {
        //         result.Name = `${result.Name} (${this.translateTypes(result.Type)})`;
        //     }
        //     finalResults.push(result);
        // });

        this.searchResults = results[this.selectedType];
        this.updateSharingLevelButtons();
        this.searchDisabled = false;
    }

    searchEventHandler(event) {
        const searchString = event.detail.value
            .trim()
            .replace(/\*/g)
            .toLowerCase();

        if (searchString.length <= 1) {
            return;
        }

        this.searchString = searchString;
    }

    listenForEnter(event) {
        if (event.code === 'Enter') {
            this.actuallySearch();
        }
    }

    @api updateSharingLevelButtons() {
        const newArray = [];

        this.searchResults.forEach(result => {
            newArray.push({
                ...result,
                ...buttonStyling(this.supportedButtons, this.supportedAddCapabilities, result.value, this.existingShares)
            });
        });

        this.searchResults = newArray;
    }

    async handleRowAction(event) {
        console.log('event.detail:::'+JSON.stringify(event.detail));
        //logger(this.log, this.source, 'row action called from datatable', event.detail);
        let actionParams = JSON.stringify({
            'userOrGroupID': event.detail.row.value,
            'approvalStepDefinitionId': this.recordId,
            'type': this.selectedType
        });

                try {

                    await handleButtonAction(
                        event.detail.action.name,
                        this.managerName,
                        actionParams
                    );
                    this.refresh();
                } catch (e) {
                    this.toastTheError(e, 'shareUpdate-read');
                }

        // switch (event.detail.action.name) {
        //     case 'read':
        //         try {
        //             await shareUpdate(event.detail.row.Id, this.recordId, 'Read');
        //             this.refresh();
        //         } catch (e) {
        //             this.toastTheError(e, 'shareUpdate-read');
        //         }
        //         break;
        //     case 'read_write':
        //         try {
        //             //logger(this.log, this.source, 'attempting Share update', event.detail);
        //             await shareUpdate(event.detail.row.Id, this.recordId, 'Edit');
        //             this.refresh();
        //         } catch (e) {
        //             this.toastTheError(e, 'shareUpdate-edit');
        //         }
        //         break;
        //     case 'none':
        //         try {
        //             await shareDelete(event.detail.row.Id, this.recordId);
        //             this.refresh();
        //         } catch (e) {
        //             this.toastTheError(e, 'shareUpdate-edit');
        //         }
        //         break;
        //     case 'add_step_approver':
        //         try {
        //             await addStepApprover(event.detail.row.Id, this.recordId, this.selectedType);
        //             this.refresh();
        //         } catch (e) {
        //             this.toastTheError(e, 'shareUpdate-read');
        //         }
        //         break;
        //     default:
        //         this.logError(this.log, this.source, 'handleRowAction switch statement no match found');
        // }
    }

    translateTypes(userType) {
        if (userType === 'PowerCustomerSuccess') {
            return 'Customer + Sharing';
        } else if (userType === 'PowerPartner') {
            return 'Partner';
        } else if (userType === 'CustomerSuccess') {
            return 'Customer';
        } else if (userType === 'CsnOnly') {
            return 'Chatter';
        } else if (userType === 'CSPLitePortal') {
            return 'High Volume Customer';
        }
        return userType;

    }

    toastTheError(e, errorSource) {
        logError(this.log, this.source, errorSource, e);
        this.dispatchEvent(
            new ShowToastEvent({
                message: e.body.message,
                variant: 'error'
            })
        );
    }
}
