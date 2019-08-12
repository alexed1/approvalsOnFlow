import {LightningElement, api, wire, track} from 'lwc';
import {getRecordUi} from 'lightning/uiRecordApi';

import BackButton from '@salesforce/label/c.Back';
import ViewCurrentPermissions from '@salesforce/label/c.ViewCurrentPermissions';
import AddNewPermission from '@salesforce/label/c.AddNewPermission';
import Queues from '@salesforce/label/c.Queues';
import RelatedUsers from '@salesforce/label/c.RelatedUsers';
import PublicGroups from '@salesforce/label/c.PublicGroups';
import Roles from '@salesforce/label/c.Roles';
import Users from '@salesforce/label/c.Users';

import {logger, logError} from 'c/lwcLogger';

export default class ListBuilder extends LightningElement {
    @api recordId;
    @api availableObjectTypes = [
        // {value: 'group', label: PublicGroups},
        // {value: 'role', label: Roles},
        {value: 'user', label: Users},
        {value: 'queue', label: Queues},

    ];
    @api supportedAddCapabilities;
    
    
    
    /* =
    
    
    [
        {
            type: 'button',
            typeAttributes: {
                label: 'Add Step Approver',
                name: 'add_step_approver',
                variant: 'neutral'
                // disabled: { fieldName: 'readDisabled' }
            },
            initialWidth: 150
        },
        {
            type: 'button',
            typeAttributes: {
                label: 'Remove Step Approver',
                name: 'remove_step_approver',
                variant: 'neutral'
                // disabled: { fieldName: 'noneDisabled' }
            },
            initialWidth: 150
        }
    ]; */
    // @api supportedAddCapabilities = [
    //   {
    //     type: 'button',
    //     typeAttributes: {
    //       label: 'None',
    //       name: 'none',
    //       variant: 'neutral',
    //       disabled: { fieldName: 'noneDisabled' }
    //     },
    //     initialWidth: 85
    //   },
    //   {
    //     type: 'button',
    //     typeAttributes: {
    //       label: 'Read',
    //       name: 'read',
    //       variant: 'neutral',
    //       disabled: { fieldName: 'readDisabled' }
    //     },
    //     initialWidth: 80
    //   },
    //   {
    //     type: 'button',
    //     typeAttributes: {
    //       label: 'Read/Write',
    //       name: 'read_write',
    //       variant: 'neutral',
    //       disabled: { fieldName: 'editDisabled' }
    //     },
    //     initialWidth: 125
    //   }
    // ];
    @api supportedEditCapabilities;
    
    /* = [
        {
            type: 'button',
            typeAttributes: {
                label: 'None',
                name: 'none',
                variant: 'neutral',
                disabled: { fieldName: 'noneDisabled' }
            },
            initialWidth: 85
        },
        {
            type: 'button',
            typeAttributes: {
                label: 'Read',
                name: 'read',
                variant: 'neutral',
                disabled: { fieldName: 'readDisabled' }
            },
            initialWidth: 80
        },
        {
            type: 'button',
            typeAttributes: {
                label: 'Read/Write',
                name: 'read_write',
                variant: 'neutral',
                disabled: { fieldName: 'editDisabled' }
            },
            initialWidth: 125
        }
    ]; */

    @api ruleName;

    @api editTabName;
    @api addTabName;

    @api log = false;
    source = 'ListBuilder';

    @track cardTitle = '';
    label = {
        BackButton,
        ViewCurrentPermissions,
        AddNewPermission
    };

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


    refreshExisting() {
        const existing = this.template.querySelector('c-existing-shares');
        if (existing) {
            existing.refresh();
        }
    }

    // do some basic verification error handling (not shareable, perms, etc)

    // serve up the card title
}
