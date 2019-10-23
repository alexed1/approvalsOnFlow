import {LightningElement, api, track, wire} from 'lwc';

import {getObjectInfo} from 'lightning/uiObjectInfoApi';
import getObjects from '@salesforce/apex/FieldPickerController.getObjects';

import NonePicklistValueLabel from '@salesforce/label/c.NonePicklistValueLabel';
import FieldIsNotSupportedMessage from '@salesforce/label/c.FieldIsNotSupportedMessage';

export default class PickObjectAndField extends LightningElement {
    @api masterLabel;
    @api objectLabel = 'Object';
    @api fieldLabel = 'Field';
    @api objectType;
    @api field;
    @api supportedObjectTypes;
    @api supportedFieldRelationTypes;

    @api objectDisabled = false;
    @api hideObjectTypeSelect = false;
    @api hideFieldSelect = false;
    @api showFieldType = false;


    @track _objectType;
    @track _field;
    @track objectTypes;
    @track fields;
    @track errors = [];
    @track isLoadFinished = false;

    labels = {
        none: NonePicklistValueLabel,
        fieldNotSupported: FieldIsNotSupportedMessage
    };

    connectedCallback() {
        if (this.objectType)
            this._objectType = this.objectType;

        if (this.objectType && this.field)
            this._field = this.field;
    }

    @wire(getObjects, {supportedObjectTypes: '$supportedObjectTypesList'})
    _getObjects({error, data}) {
        if (error) {
            this.errors.push(error.body.message);
        } else if (data) {
            this.isLoadFinished = true;
            this.objectTypes = data;
        }
    }

    @wire(getObjectInfo, {objectApiName: '$_objectType'})
    _getObjectInfo({error, data}) {
        if (error) {
            this.errors.push(error.body[0].message);
        } else if (data) {
            let fields = data.fields;
            let fieldResults = [];
            for (let field in this.fields = fields) {
                if (Object.prototype.hasOwnProperty.call(fields, field)) {
                    if (this.isTypeSupported(fields[field])) {
                        fieldResults.push({
                            label: fields[field].label,
                            value: fields[field].apiName,
                            dataType: fields[field].dataType,
                            required: fields[field].required,
                            updateable: fields[field].updateable,
                            referenceTo: (fields[field].referenceToInfos.length > 0 ? fields[field].referenceToInfos.map(curRef => {
                                return curRef.apiName
                            }) : [])
                        });
                    }
                }
                if (this._field && !Object.prototype.hasOwnProperty.call(fields, this._field)) {
                    this.errors.push(this.labels.fieldNotSupported + this._field);
                    this._field = null;
                }
            }
            this.fields = fieldResults;
            if (this.fields) {
                this.dispatchDataChangedEvent({...this.fields.find(curField => curField.value == this._field), ...{isInit: true}});
            }
        }
    }

    get isFieldTypeVisible() {
        return (this.fieldType && this.showFieldType);
    }

    isTypeSupported(field) {
        let result = false;
        if (!this.supportedFieldRelationTypes) {
            result = true;
        }
        if (!result && field.referenceToInfos.length > 0) {
            field.referenceToInfos.forEach(curRef => {
                if (this.supportedFieldRelationTypes.toLowerCase().includes(curRef.apiName.toLowerCase())) {
                    result = true;
                }
            });
        }
        return result;
    }

    get supportedObjectTypesList() {
        if (this.supportedObjectTypes) {
            return this.splitValues(this.supportedObjectTypes.toLowerCase());
        } else {
            return [];
        }
    }

    get isError() {
        return this.errors.length > 0;
    }

    get errorMessage() {
        return this.errors.join('; ');
    }

    get isFieldDisabled() {
        return this._objectType == null || this.isError;
    }

    get fieldType() {
        if (this._field) {
            return this.fields.find(e => e.value == this._field).dataType;
        } else {
            return null;
        }
    }

    handleObjectChange(event) {
        this._objectType = event.detail.value;
        this._field = null;
        this.dispatchDataChangedEvent({});
        this.errors = [];
    }

    handleFieldChange(event) {
        this._field = event.detail.value;
        this.dispatchDataChangedEvent(this.fields.find(curField => curField.value == this._field));
    }

    dispatchDataChangedEvent(detail) {
        const memberRefreshedEvt = new CustomEvent('fieldselected', {
            bubbles: true,
            detail: {
                ...detail, ...{
                    objectType: this._objectType,
                    fieldName: this._field
                }
            }
        });
        this.dispatchEvent(memberRefreshedEvt);
    }

    splitValues(originalString) {
        if (originalString) {
            return originalString.replace(/ /g, '').split(',');
        } else {
            return [];
        }
    };
}