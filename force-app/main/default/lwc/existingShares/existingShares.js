import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';

import getSharings from '@salesforce/apex/LightningSharing.getSharings';

import {
  buttonStylingSingle,
  sharingButtonColumns,
  shareUpdate,
  shareDelete
} from 'c/sharingButtonSupport';

import { logger, logError }  from 'c/lwcLogger';

export default class ExistingShares extends NavigationMixin(LightningElement) {
  @api recordId;
  @api foo;
  @track tableData = [];
  source = 'ExistingShares';

  // call this when you know the sharing table is out of sync
  @api refresh() {
    //Console.log('in refresh');
    logger(this.log, this.source, 'refreshing');
    refreshApex(this._refreshable);
  }

  _refreshable;

  constructor() {
    super();
    this.columns = [
      { label: 'User or Group', fieldName: 'UserOrGroupType' },
      { label: 'Type', fieldName: 'SubType' },
      {
        label: 'Name',
        type: 'button',
        typeAttributes: {
          label: {
            fieldName: 'UserOrGroupName'
          },
          name: 'view',
          variant: 'base'
        }
      },
      { label: 'Reason', fieldName: 'RowCause' },
      { label: 'Access Level', fieldName: 'AccessLevel' }
    ].concat(sharingButtonColumns);
  }

  @wire(getSharings, { recordId: '$recordId' })
  wiredSharings(result) {
    this._refreshable = result;
    if (result.error) {
      logError(this.log, this.source, 'wiredSharings', result.error);
    } else if (result.data) {
      const sharings = JSON.parse(result.data);
      logger(this.log, this.source, 'sharing updated', sharings);

      const newArray = [];
      sharings.forEach(sharing => {
        newArray.push({
          ...sharing,
          ...buttonStylingSingle(sharing)
        });
      });
      this.tableData = newArray;
    }
  }

  async handleRowAction(event) {
    logger(this.log, this.source, 'RowAction called', event.detail);
    
    switch (event.detail.action.name) {
      case 'view':
        this.viewRecordRouter(event.detail.row);
        break;
      case 'none':
        // await this.deleteShare(event.detail.row);
        await shareDelete(event.detail.row.UserOrGroupID, this.recordId);
        this.refresh();
        break;
      case 'read':
        await shareUpdate(
          event.detail.row.UserOrGroupID,
          this.recordId,
          'Read'
        );
        this.refresh();
        // await this.updateShares(event.detail.row, 'Read');
        break;
      case 'read_write':
        // await this.updateShares(event.detail.row, 'Edit');
        await shareUpdate(
          event.detail.row.UserOrGroupID,
          this.recordId,
          'Edit'
        );
        this.refresh();
        break;
      default: 
        this.logError(this.log, this.source, 'handleRowAction switch statement no match found');
    
    }

    // options for the actions
  }

  viewRecordRouter(row) {
    if (row.UserOrGroupType === 'User') {
      this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
          recordId: row.UserOrGroupID,
          actionName: 'view'
        }
      });
    } else if (row.UserOrGroupType === 'Group') {
      const url = `/lightning/setup/PublicGroups/page?address=%2Fsetup%2Fown%2Fgroupdetail.jsp%3Fid%3D${
        row.UserOrGroupID
      }`;
      logError(this.log, this.source, `regular group: ${url}`);
      this[NavigationMixin.Navigate]({
        type: 'standard__webPage',
        attributes: {
          url
        }
      });
    } else if (row.RoleId) {
      const url = `/lightning/setup/Roles/page?address=%2F${row.RoleId}%3Fsetupid%3DRoles`;
      logError(this.log, this.source, `RoleId, group: ${url}`);
      this[NavigationMixin.Navigate]({
        type: 'standard__webPage',
        attributes: {
          url
        }
      });
    }
  }
}
