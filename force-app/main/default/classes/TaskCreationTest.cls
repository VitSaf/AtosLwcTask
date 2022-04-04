@isTest
public class TaskCreationTest {
    @TestSetup
    static void makeData(){
        Id profId = [SELECT Id, Name FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id;
        User[] testUsers = new List<User>{new User(LanguageLocaleKey = 'en_US', EmailEncodingKey = 'UTF-8', Alias = 'test1123', LastName = 'TestUser111',  Email = 'Test11User123@mail.com', ProfileId = profId, Username = 'testUNamBBe1@mail.com'   , TimeZoneSidKey = 'Europe/Dublin', LocaleSidKey = 'en_IE_EURO', In_progress_tasks__c = 0, Not_started_tasks__c = 0),
                                          new User(LanguageLocaleKey = 'en_US', EmailEncodingKey = 'UTF-8' ,Alias = 'test2645', LastName = 'TestUser2222', Email = 'Test22User321@mail.com', ProfileId = profId, Username = 'testAAAUsername2@mail.com', TimeZoneSidKey = 'Europe/Dublin', LocaleSidKey = 'en_IE_EURO', In_progress_tasks__c = 0, Not_started_tasks__c = 0)};
        
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                                          LocaleSidKey='en_US', ProfileId = p.Id,
                                          TimeZoneSidKey='America/Los_Angeles',
                                          UserName=uniqueUserName);
        testUsers.add(u);
        insert testUsers;
        insert new Lead(LastName = 'TestLead1', Company = 'TestCompany1');
        Task[] tasks = new List<Task>{new Task(Subject = 'Other', WhoId = [SELECT Id FROM Lead LIMIT 1].Id, Priority = 'Normal', Description = 'description', OwnerId = u.Id, ActivityDate = Date.today(), Status = 'Not Started')};
        insert tasks;
        tasks[0].Status = 'In Progress';
        update tasks;
        delete tasks;
    }

    @isTest
    private static void testFindUser() {
        Integer emptyJsonSize = '[]'.length();
        User adminUser = [SELECT Id, Name FROM User WHERE Alias = 'standt' LIMIT 1];
        System.runAs(adminUser) {
            User[] users = [SELECT Id FROM User LIMIT 2];
            Id[] fixedSearchResults = new List<Id>{users[0].Id, users[1].Id};
            Test.startTest();
            try {
                TaskCreationController.findUser(null);
            } catch (Exception e) {
                System.assertNotEquals(e, null);
            }
            Test.setFixedSearchResults(fixedSearchResults);
            String usersFoundJson = TaskCreationController.findUser('test');
            Test.stopTest();
            System.assertNotEquals(usersFoundJson.length(), emptyJsonSize);
        }
    }

    @isTest
    private static void testCreateTask() {
        String description = 'TestDescr';
        Date deadline = Date.today().addDays(1);
        String leadId = [SELECT Id FROM LEAD LIMIT 1].Id;
        User adminUser = [SELECT Id, Name FROM User WHERE Alias = 'standt' LIMIT 1];
        String userId = adminUser.Id;
        System.runAs(adminUser) {
            Test.startTest();
            String createdTaskId = TaskCreationController.createTask(userId, description, deadline, leadId);
            System.assert(createdTaskId.length() > 0);
            try {
                TaskCreationController.createTask(null, null, null, null);
            } catch (Exception e) {
                System.assert(e != null);
            }
            Test.stopTest();
        }
    }
}
