public with sharing class TaskCreationService {
    public User[] findUsers(String keyWord) {
        try {
            SObjectAccessDecision decision = Security.stripInaccessible(AccessType.READABLE, [FIND :keyWOrd IN NAME FIELDS RETURNING User(Id, Name, Email)][0], true);
            return decision.getRecords();
        } catch (NullPointerException npe) {
            return new List<User>();
        }
    }

    public String createTask(String userId, String description, Date activityDate, String leadId) {
        try {
            System.debug('CreateTaskService');
            Task newTask = new Task(Subject = 'Other', WhoId = Id.valueOf(leadId), Priority = 'Normal', Description = description, OwnerId = Id.valueOf(userId), ActivityDate = activityDate);
            System.debug(newTask);
            insert newTask;
            return newTask.Id;
        } catch (Exception e) {
            System.debug(e);
            return '';
        }
    }
}
