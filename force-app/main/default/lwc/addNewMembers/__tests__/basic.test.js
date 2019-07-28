// createElement is what we'll use to create our component under test
import { createElement } from 'lwc';

// Import module under test by convention <namespace>/<moduleName>
import addNewMembers from 'ltngsharing/addNewMembers';
import getSharings from '@salesforce/apex/SharingActions.getSharings';
import doSOSL from '@salesforce/apex/AdminTools.doSOSL';

import {registerApexTestWireAdapter } from '@salesforce/wire-service-jest-util';

describe('loads outer component with data', () => {
  const mockGetSharings = registerApexTestWireAdapter(getSharings);
  const mockDoSOSL = registerApexTestWireAdapter(doSOSL);

  it('loads empty', async () => {
    // const getRecordUIWireAdapter = registerLdsTestWireAdapter(getRecordUi);
    
    const element = createElement('ltngsharing-add-new-shares', {
      is: addNewMembers
    });
    await document.body.appendChild(element);

    // there should be action buttons
    const combobox = element.shadowRoot.querySelector(
      'lightning-combobox'
    );
    expect(combobox).toBeTruthy();

    // const buttons = element.shadowRoot.querySelectorAll('lightning-button');
    // expect(buttons).toHaveLength(2);
  });

  it('loads with existing', async () => {

    const element = createElement('ltngsharing-add-new-shares', {
      is: addNewMembers
    });
    document.body.appendChild(element);

    
    mockGetSharings.emit(JSON.stringify([
      
    ]));
    // const card = element.shadowRoot.querySelector('lightning-card');
    // expect(card.title).toBe('PrivateTestObject__c: 0');
    // const combobox = element.shadowRoot.querySelector(
    //   'lightning-combobox'
    // );
    // expect(combobox).toBeTruthy();
  });

  afterEach(() => {
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
  });
});
