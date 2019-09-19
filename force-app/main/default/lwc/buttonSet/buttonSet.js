import {LightningElement, api} from 'lwc';
import {
    FlowNavigationNextEvent,
    FlowNavigationBackEvent,
    FlowNavigationFinishEvent,
    FlowNavigationPauseEvent,
    FlowNavigationResumeEvent
} from 'lightning/flowSupport';

export default class buttonSet extends LightningElement {
    @api buttonLabels;
    @api buttonAlignment;
    @api buttonNavigationDirective;

    get buttons() {
        let buttonDescriptor = [];
        let buttons = this.splitValues(this.buttonLabels);
        let navigationDirective = this.splitValues(this.buttonNavigationDirective);

        if (buttons.length != navigationDirective.length) {
            console.log('Number of items in navigation directive string should be equal to number of items in button string.')
            return [];
        }

        buttons.forEach((buttonName, index) => {
            buttonDescriptor.push(
                {
                    label: buttonName,
                    variant: 'brand',
                    navigationDirective: navigationDirective[index]
                }
            );
        });

        return buttonDescriptor;
    }

    get elementClass() {
        const alClass = ((align) => {
            switch (align) {
                case 'right':
                    return 'slds-float_right';
                    break;
                case 'center':
                    return 'slds-align_absolute-center';
                    break;
                default:
                    return 'slds-float_left'
            }
        });
        return alClass(this.buttonAlignment);
    }

    handleButtonClick(event) {
        let nextNavigationEvent;
        let eventParam = '';
        switch (event.currentTarget.dataset.navigation) {
            case 'next':
                nextNavigationEvent = new FlowNavigationNextEvent(eventParam);
                break;
            case 'back':
                nextNavigationEvent = new FlowNavigationBackEvent(eventParam);
                break;
            case 'pause':
                nextNavigationEvent = new FlowNavigationPauseEvent(eventParam);
                break;
            case 'resume':
                nextNavigationEvent = new FlowNavigationResumeEvent(eventParam);
                break;
            default:
                nextNavigationEvent = new FlowNavigationFinishEvent(eventParam);
        }

        this.dispatchEvent(nextNavigationEvent);
    }

    splitValues(originalString) {
        if (originalString) {
            return originalString.replace(/ /g, '').split(',');
        } else {
            return [];
        }
    };
}