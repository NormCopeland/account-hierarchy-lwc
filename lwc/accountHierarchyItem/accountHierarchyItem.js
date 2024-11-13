import { LightningElement, api } from 'lwc';

export default class AccountHierarchyItem extends LightningElement {
    @api account;
    @api currentAccountId;
    showChildren = true;

    get isCurrentAccount() {
        return this.account.Id === this.currentAccountId;
    }

    get hasChildAccounts() {
        return this.account.childAccounts && this.account.childAccounts.length > 0;
    }

    get accountClass() {
        return `slds-truncate ${this.isCurrentAccount ? 'current-account' : ''}`;
    }

    get toggleIcon() {
        return this.showChildren ? 'utility:chevrondown' : 'utility:chevronright';
    }

    toggleChildren(event) {
        event.stopPropagation();
        this.showChildren = !this.showChildren;
    }

    handleClick(event) {
        event.preventDefault();
        event.stopPropagation();
        console.log('Click handled for account:', this.account.Name);
        this.dispatchEvent(new CustomEvent('accountclick', {
            detail: this.account.Id,
            bubbles: true,
            composed: true
        }));
    }

    handleChildClick(event) {
        // Explicitly bubble up the event
        console.log('Child click bubbling for:', event.detail);
        this.dispatchEvent(new CustomEvent('accountclick', {
            detail: event.detail,
            bubbles: true,
            composed: true
        }));
    }
}
