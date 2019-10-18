import {LightningElement, track, api} from 'lwc';
import {FlowAttributeChangeEvent} from 'lightning/flowSupport';
import getFieldList from '@salesforce/apex/FormulaBuilderController.getFieldList';

export default class FormulaBuilder extends LightningElement {

    @track _fields;
    @api functions;
    @api operators;
    @api formula = '';
    @api name;

    @api
    get fields(){
        return this._fields;
    }
    set fields(value){
        this._fields = value.split(',');
    }
    @api supportedFunctions = [
        'AND', 'OR', 'NOT', 'XOR', 'IF', 'CASE', 'LEN', 'SUBSTRING', 'LEFT', 'RIGHT',
        'ISBLANK', 'ISPICKVAL', 'CONVERTID', 'ABS', 'ROUND', 'CEIL', 'FLOOR', 'SQRT', 'ACOS',
        'ASIN', 'ATAN', 'COS', 'SIN', 'TAN', 'COSH', 'SINH', 'TANH', 'EXP', 'LOG', 'LOG10', 'RINT',
        'SIGNUM', 'INTEGER', 'POW', 'MAX', 'MIN', 'MOD', 'TEXT', 'DATETIME', 'DECIMAL', 'BOOLEAN',
        'DATE', 'DAY', 'MONTH', 'YEAR', 'HOURS', 'MINUTES', 'SECONDS', 'ADDDAYS', 'ADDMONTHS',
        'ADDYEARS', 'ADDHOURS', 'ADDMINUTES', 'ADDSECONDS'
    ];

    @api supportedOperators = ['+', '-', '/', '*', '==', '!=', '>', '<', '>=', '<=', '<>'];

    @api
    get objectName() {
        return this.name
    }

    @api
    get value(){
        return this.formula;
    }

    set value(value){
        this.formula = value;
    }

    set objectName(name) {
        this.name = name;
        getFieldList({objectName: name})
            .then(result => {
                let fields = [];
                result.forEach(fieldName => {
                    let fieldValue = name + '.' + fieldName;
                    fields.push({label: fieldName, value: fieldValue});
                });
                this._fields = fields
            })
    }

    formulaChanged() {
        const memberRefreshedEvt = new CustomEvent('formulachanged', {
            bubbles: true, detail: {
                value: this.formula
            }
        });
        this.dispatchEvent(memberRefreshedEvt);
    }

    connectedCallback() {

        let functions = [];
        let operators = [];

        this.supportedFunctions.forEach(func => {
            let funcValue = func + '()';
            functions.push({label: func, value: funcValue});
        });

        this.functions = functions;

        this.supportedOperators.forEach(operator => {
            operators.push({label: operator, value: operator});
        });

        this.operators = operators;

    }

    selectOperator(event) {
        if (event.detail.value !== '') {
            this.formula = this.formula + ' ' + event.detail.value + ' ';
            event.target.value = '';
        }
    }

    changeFormula(event) {
        this.formula = event.target.value;
        const valueChangeEvent = new FlowAttributeChangeEvent('value', this.formula);
        this.dispatchEvent(valueChangeEvent);
    }

    selectField(event) {
        if (event.detail.value !== '') {
            this.formula = this.formula + event.detail.value + ' ';
            event.target.value = '';
        }
    }
}