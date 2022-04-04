public with sharing class TaskCreationController {
    private TaskCreationController() {}

    private static final TaskCreationService tcs = new TaskCreationService();

    @AuraEnabled(cacheable=true)
    public static String findUser(String keyWord){
        try {
            return JSON.serialize(tcs.findUsers(keyWord));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String createTask(String userId, String description, Date deadline, String leadId) {
        try {
            System.debug('CreateTaskController');
            if (userId != null && leadId != null && leadId.length() > 0 && userId.length() > 0) {
                System.debug('CreateTaskController2');
                return tcs.createTask(userId, description, deadline, leadId);
            } else {
                return '';
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}
