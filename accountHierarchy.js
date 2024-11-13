import { LightningElement, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getFullAccountHierarchy from '@salesforce/apex/AccountHierarchyController.getFullAccountHierarchy';

export default class AccountHierarchy extends NavigationMixin(LightningElement) {
    @api recordId;
    hierarchyData;
    isLoading = true;
    error;

    @wire(getFullAccountHierarchy, { currentAccountId: '$recordId' })
    wiredHierarchy({ error, data }) {
        this.isLoading = true;
        if (data) {
            console.log('Hierarchy data loaded:', JSON.stringify(data, null, 2));
            this.hierarchyData = data;
            this.error = undefined;
        } else if (error) {
            console.error('Error loading hierarchy:', error);
            this.error = 'Error loading account hierarchy: ' + error.body.message;
            this.hierarchyData = undefined;
        }
        this.isLoading = false;
    }

    handleAccountClick(event) {
        const accountId = event.detail;
        console.log('Navigation requested for account:', accountId);
        
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: accountId,
                objectApiName: 'Account',
                actionName: 'view'
            }
        });
    }
}
