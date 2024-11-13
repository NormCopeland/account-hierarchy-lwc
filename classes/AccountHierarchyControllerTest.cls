@IsTest
private class AccountHierarchyControllerTest {
    
    @TestSetup
    static void setupTestData() {
        // Create parent account
        Account parentAccount = new Account(
            Name = 'Parent Account',
            Type = 'Household',
            Receipt_Type__c = 'Tax Receipt'
        );
        insert parentAccount;
        
        // Create first child account
        Account childAccount1 = new Account(
            Name = 'Child Account 1',
            Type = 'Household',
            ParentId = parentAccount.Id,
            Receipt_Type__c = 'Tax Receipt'
        );
        insert childAccount1;
        
        // Create second child account
        Account childAccount2 = new Account(
            Name = 'Child Account 2',
            ParentId = parentAccount.Id,
            Type = 'Household',
            Receipt_Type__c = 'Tax Receipt'
        );
        insert childAccount2;
        
        // Create grandchild account
        Account grandchildAccount = new Account(
            Name = 'Grandchild Account',
            ParentId = childAccount1.Id,
            Type = 'Household',
            Receipt_Type__c = 'Tax Receipt'
        );
        insert grandchildAccount;
    }
    
    @IsTest
    static void testGetHierarchyFromParent() {
        Account parentAccount = [SELECT Id FROM Account WHERE Name = 'Parent Account'];
        
        Test.startTest();
        AccountHierarchyController.AccountWrapper result = 
            AccountHierarchyController.getFullAccountHierarchy(parentAccount.Id);
        Test.stopTest();
        
        // Verify parent account details
        System.assertEquals('Parent Account', result.Name, 'Parent account name should match');
        System.assertEquals(null, result.ParentId, 'Parent account should have no parent');
        System.assertEquals(2, result.childAccounts.size(), 'Parent should have 2 child accounts');
        
        // Verify child accounts and grandchild
        AccountHierarchyController.AccountWrapper childWithGrandchild = null;
        for(AccountHierarchyController.AccountWrapper child : result.childAccounts) {
            if(child.Name == 'Child Account 1') {
                childWithGrandchild = child;
            }
        }
        
        System.assertNotEquals(null, childWithGrandchild, 'Should find Child Account 1');
        System.assertEquals(1, childWithGrandchild.childAccounts.size(), 'Child 1 should have one grandchild');
        System.assertEquals('Grandchild Account', childWithGrandchild.childAccounts[0].Name, 'Grandchild name should match');
    }
    
    @IsTest
    static void testGetHierarchyFromChild() {
        Account childAccount = [SELECT Id FROM Account WHERE Name = 'Child Account 1'];
        
        Test.startTest();
        AccountHierarchyController.AccountWrapper result = 
            AccountHierarchyController.getFullAccountHierarchy(childAccount.Id);
        Test.stopTest();
        
        System.assertEquals('Parent Account', result.Name, 'Should return parent account as root');
        System.assertEquals(2, result.childAccounts.size(), 'Should show all siblings');
        
        // Verify grandchild is present
        Boolean foundGrandchild = false;
        for(AccountHierarchyController.AccountWrapper child : result.childAccounts) {
            if(child.Name == 'Child Account 1') {
                System.assertEquals(1, child.childAccounts.size(), 'Should have grandchild');
                System.assertEquals('Grandchild Account', child.childAccounts[0].Name, 'Grandchild name should match');
                foundGrandchild = true;
            }
        }
        System.assert(foundGrandchild, 'Should find grandchild in hierarchy');
    }
    
    @IsTest
    static void testGetHierarchyFromGrandchild() {
        Account grandchildAccount = [SELECT Id FROM Account WHERE Name = 'Grandchild Account'];
        
        Test.startTest();
        AccountHierarchyController.AccountWrapper result = 
            AccountHierarchyController.getFullAccountHierarchy(grandchildAccount.Id);
        Test.stopTest();
        
        System.assertEquals('Parent Account', result.Name, 'Should return top parent as root');
        
        // Verify full hierarchy
        Boolean foundGrandchild = false;
        for(AccountHierarchyController.AccountWrapper child : result.childAccounts) {
            if(child.Name == 'Child Account 1') {
                System.assertEquals(1, child.childAccounts.size(), 'Should have grandchild');
                System.assertEquals('Grandchild Account', child.childAccounts[0].Name, 'Grandchild name should match');
                foundGrandchild = true;
            }
        }
        System.assert(foundGrandchild, 'Should find grandchild in hierarchy');
    }
    
    @IsTest
    static void testSingleAccountHierarchy() {
        Account singleAccount = new Account(
            Name = 'Single Account',
            Type = 'Household',
            Receipt_Type__c = 'Tax Receipt'
        );
        insert singleAccount;
        
        Test.startTest();
        AccountHierarchyController.AccountWrapper result = 
            AccountHierarchyController.getFullAccountHierarchy(singleAccount.Id);
        Test.stopTest();
        
        System.assertEquals('Single Account', result.Name, 'Account name should match');
        System.assertEquals(null, result.ParentId, 'Should have no parent');
        System.assertEquals(0, result.childAccounts.size(), 'Should have no children');
    }
}
