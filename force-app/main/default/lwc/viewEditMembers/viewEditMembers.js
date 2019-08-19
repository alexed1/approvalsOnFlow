import {LightningElement, api, track} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';

import {
    buttonStyling,
    generateCapabilityColumns,
    handleButtonAction
} from 'c/buttonUtils';

import {logger, logError} from 'c/lwcLogger';

export default class ViewEditMembers extends NavigationMixin(LightningElement) {
    @api recordId;
    @api supportedEditCapabilities;
    @api managerName;
    @api existingShares;
    @api supportedButtons;

    @track columns = [];

    // call this when you know the sharing table is out of sync
    @api refresh() {
        this.dispatchEvent(new CustomEvent('searchrefresh'));
    }
    //TODO: Implement ability to navigate to record on click
    get tableData() {
        const newArray = [];
        if (this.existingShares) {
            this.existingShares.forEach(result => {
                newArray.push({
                    ...result,
                    ...buttonStyling(this.supportedButtons, this.supportedEditCapabilities, result.recordId, this.existingShares)
                });
            });

        }
        return newArray;
    }

    connectedCallback() {
        this.columns = [{
            label: 'Name',
            fieldName: 'label'
        }].concat(generateCapabilityColumns(this.supportedEditCapabilities));
    }

    async handleRowAction(event) {
        console.log('event.detail:::' + JSON.stringify(event.detail));
        //logger(this.log, this.source, 'row action called from datatable', event.detail);
        let actionParams = JSON.stringify({
            'userOrGroupID': event.detail.row.recordId,
            'approvalStepDefinitionId': this.recordId
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
    }
}
