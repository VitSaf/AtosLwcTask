public with sharing class TaskHandler {
    public void renewTasksOnUser() {
        if (Trigger.isUpdate) {
            handleUpdate((Map<Id, Task>)Trigger.oldMap, (Map<Id, Task>)Trigger.newMap);
        }
        if (Trigger.isDelete) {
            handleInsertAndDelete((Map<Id, Task>)Trigger.oldMap);
        }
        if (Trigger.isInsert) {
            handleInsertAndDelete((Map<Id, Task>)Trigger.newMap);
        }
    }

    private void handleUpdate(Map<Id, Task> oldMap, Map<Id, Task> newMap ) {
        Set<Id> userIdsToUpdateFields = new Set<Id>();
        for (Id taskId : newMap.keySet()) {
             if (oldMap.get(taskId).status != newMap.get(taskId).status) {
                userIdsToUpdateFields.add(newMap.get(taskId).OwnerId);
             }
        }
        updateFieldsOnUser(userIdsToUpdateFields);
    }

    private void handleInsertAndDelete(Map<Id, Task> taskMap) {
        Set<Id> userIdsToUpdateFields = new Set<Id>();
        for (Task t : taskMap.values()) {
            userIdsToUpdateFields.add(t.OwnerId);
        }
        updateFieldsOnUser(userIdsToUpdateFields);
    }


    private void updateFieldsOnUser(Set<Id> userIds) {
        Map<Id, Integer> usersWithNewNotStartedTasks = new Map<Id, Integer>();
        Map<Id, Integer> usersWithNewTasksInProgress = new Map<Id, Integer>();
        for (Id userId : userIds) {
            usersWithNewNotStartedTasks.put(userId, 0);
            usersWithNewTasksInProgress.put(userId, 0);
        }
        for (Task t : [SELECT Id, Status, Owner.Id FROM Task WHERE Owner.Type='User' AND Owner.Id IN :userIds]) {
            if (t.Status == 'In Progress') {
                usersWithNewTasksInProgress.put(t.OwnerId, usersWithNewTasksInProgress.get(t.OwnerId) + 1);
            }
            if (t.Status == 'Not Started') {
                usersWithNewNotStartedTasks.put(t.OwnerId, usersWithNewNotStartedTasks.get(t.OwnerId) + 1);
            }
        }
        User[] users = [SELECT Id, Name, In_progress_tasks__c, Not_started_tasks__c FROM User WHERE Id IN :userIds];
        for (User u : users) {
            u.In_progress_tasks__c = usersWithNewTasksInProgress.get(u.Id);
            u.Not_started_tasks__c = usersWithNewNotStartedTasks.get(u.Id);
        }
        try {
            update users;
        } catch (Exception e) {
            System.debug(e);
            users[0].addError(e);
        }
    }
}
//SELECT Id, In_progress_tasks__c, Not_started_tasks__c, (SELECT Id, OwnerId, Status FROM Tasks) FROM User