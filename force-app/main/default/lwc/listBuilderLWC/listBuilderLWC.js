import { LightningElement, api, wire, track } from 'lwc';
import { getRecordUi } from 'lightning/uiRecordApi';

import BackButton from '@salesforce/label/c.Back';
import ViewCurrentPermissions from '@salesforce/label/c.ViewCurrentPermissions';
import AddNewPermission from '@salesforce/label/c.AddNewPermission';

import { logger, logError }  from 'c/lwcLogger';

export default class ListBuilder extends  LightningElement  {
  @api recordId;
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
  wiredRecord({ error, data }) {
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
    if (existing){
      existing.refresh();
    }
  }

  // do some basic verification error handling (not shareable, perms, etc)

  // serve up the card title
}
