public with sharing class TaskCreationController {
    private TaskCreationController() {}
    private static final TaskCreationService tcs = new TaskCreationService();

    @AuraEnabled(cacheable=true)
    public static String findUser(String keyWord){
        return JSON.serialize(tcs.findUsers(keyWord));
    }

    @AuraEnabled
    public static String createTask(String userId, String description, Date deadline, String leadId) {
        if (userId != null && leadId != null && leadId.length() > 0 && userId.length() > 0) {
            return tcs.createTask(userId, description, deadline, leadId);
        } else {
            return '';
        }
    }
}
