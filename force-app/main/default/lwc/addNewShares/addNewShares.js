import { LightningElement, api, track, wire } from 'lwc';

import Search from '@salesforce/label/c.Search';
import PublicGroups from '@salesforce/label/c.PublicGroups';
import Roles from '@salesforce/label/c.Roles';
import Users from '@salesforce/label/c.Users';
import For from '@salesforce/label/c.For';
import TooManyResultsMessage from '@salesforce/label/c.TooManyResultsMessage';
import Type3 from '@salesforce/label/c.TooManyResultsMessage';

import getSharings from '@salesforce/apex/LightningSharing.getSharings';
import doSOSL from '@salesforce/apex/LightningSharing.doSOSL';

import { logger, logError }  from 'c/lwcLogger';

import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import {
  buttonStyling,
  sharingButtonColumns,
  shareUpdate,
  shareDelete
} from 'c/sharingButtonSupport';

export default class AddNewShares extends LightningElement {
  @api log = false;
  @api recordId;
  @api foo;
  
  @track label = {
    Search,
    TooManyResultsMessage,
    Type3,
    For
  };
  @track searchString = '';
  source = 'addNewShares';

  get tooManyResults() {
    return this.searchResults.length > 199;
  }

  // call this when you know the sharing table is out of sync
  @api refresh() {
    logger(this.log, this.source, 'refreshing');
    refreshApex(this._refreshable);
  }

  _refreshable;

  types = [
    { value: 'group', label: PublicGroups },
    { value: 'userrole', label: Roles },
    { value: 'user', label: Users }
  ];

  selectedType = 'user';

  columns = [{ label: 'Name', fieldName: 'Name' }].concat(sharingButtonColumns);

  @track searchResults = [];
  @track searchDisabled = false;

  existingShares = [];

  @wire(getSharings, { recordId: '$recordId' })
  wiredSharings(result) {
    this._refreshable = result;
    if (result.error) {
      logError(this.log, this.source, 'getSharings error', result.error);
    } else if (result.data) {
      logger(this.log, this.source, 'getSharings returned', result.data);
      this.existingShares = JSON.parse(result.data);
      this.updateSharingLevelButtons();
    }
  }

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

    const results = JSON.parse(
      await doSOSL({
        searchString: this.searchString,
        objectType: this.selectedType
      })
    );
    logger(this.log, this.source, 'search results', results);
    const finalResults = [];

    results.forEach(result => {
      // make some types a bit nicer
      if (this.selectedType === 'user') {
        result.Name = `${result.Name} (${this.translateTypes(
          result.UserType
        )})`;
      } else if (this.selectedType === 'group') {
        result.Name = `${result.Name} (${this.translateTypes(result.Type)})`;
      }
      finalResults.push(result);
    });

    this.searchResults = finalResults;
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

  updateSharingLevelButtons() {
    const newArray = [];

    this.searchResults.forEach(result => {
      newArray.push({
        ...result,
        ...buttonStyling(result.Id, this.existingShares)
      });
    });

    this.searchResults = newArray;
  }

  async handleRowAction(event) {
    //logger(this.log, this.source, 'row action called from datatable', event.detail);

    switch (event.detail.action.name) {
      case 'read':
        try {
          await shareUpdate(event.detail.row.Id, this.recordId, 'Read');
          this.refresh();
        } catch (e) {
          this.toastTheError(e, 'shareUpdate-read');
        }
        break;
      case 'read_write':
        try {
          //logger(this.log, this.source, 'attempting Share update', event.detail);
          await shareUpdate(event.detail.row.Id, this.recordId, 'Edit');
          this.refresh();
        } catch (e) {
          this.toastTheError(e, 'shareUpdate-edit');
        }
        break;
      case 'none':
        try {
          await shareDelete(event.detail.row.Id, this.recordId);
          this.refresh();
        } catch (e) {
          this.toastTheError(e, 'shareUpdate-edit');
        }
        break;
      default: 
        this.logError(this.log, this.source, 'handleRowAction switch statement no match found');
    }
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
