trigger TaskTrigger on Task (after insert, after update, after delete) {
    new TaskHandler().renewTasksOnUser();
}