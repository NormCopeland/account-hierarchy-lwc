public with sharing class AccountHierarchyController {
    @AuraEnabled(cacheable=true)
    public static AccountWrapper getFullAccountHierarchy(Id currentAccountId) {
        // First get the top most parent
        Id topParentId = getTopParentId(currentAccountId);
        
        // Query the full hierarchy using a self-relationship query
        List<Account> allRelatedAccounts = [
            SELECT Id, Name, ParentId,
                   (SELECT Id, Name, ParentId 
                    FROM ChildAccounts 
                    ORDER BY Name)
            FROM Account 
            WHERE Id = :topParentId 
            OR ParentId = :topParentId 
            OR Parent.ParentId = :topParentId
            ORDER BY Name
        ];
        
        // Create a map of all accounts
        Map<Id, Account> accountMap = new Map<Id, Account>(allRelatedAccounts);
        
        // Get the top parent account
        Account topParent = accountMap.get(topParentId);
        
        return buildHierarchyWrapper(topParent, accountMap);
    }
    
    private static Id getTopParentId(Id accountId) {
        Account acc = [SELECT Id, ParentId FROM Account WHERE Id = :accountId];
        if (acc.ParentId == null) {
            return acc.Id;
        }
        return getTopParentId(acc.ParentId);
    }
    
    private static AccountWrapper buildHierarchyWrapper(Account acc, Map<Id, Account> accountMap) {
        AccountWrapper wrapper = new AccountWrapper();
        wrapper.Id = acc.Id;
        wrapper.Name = acc.Name;
        wrapper.ParentId = acc.ParentId;
        wrapper.childAccounts = new List<AccountWrapper>();
        
        // Add immediate children
        if (acc.ChildAccounts != null) {
            for (Account childAcc : acc.ChildAccounts) {
                // Get the full child account from the map to include its children
                Account fullChildAcc = accountMap.get(childAcc.Id);
                if (fullChildAcc != null) {
                    wrapper.childAccounts.add(buildHierarchyWrapper(fullChildAcc, accountMap));
                }
            }
        }
        
        return wrapper;
    }
    
    public class AccountWrapper {
        @AuraEnabled public Id Id;
        @AuraEnabled public String Name;
        @AuraEnabled public Id ParentId;
        @AuraEnabled public List<AccountWrapper> childAccounts;
    }
}
