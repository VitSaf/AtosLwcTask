import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from 'lightning/navigation';

import createTask from "@salesforce/apex/TaskCreationController.createTask";

export default class CreateTaskComponent extends  NavigationMixin(LightningElement)  {

    userId;
    taskDescription;
    deadlineDate;
    newTaskId;

    @api recordId;

    userSelected(event) {
        this.userId = event.detail;
    }

    changeDescription(event) {
        this.taskDescription = event.target.value;
    }

    changeDeadlineDate(event) {
        this.deadlineDate = event.target.value;
    }

    get isFieldsFilled() {
        return !(this.deadlineDate && this.taskDescription && this.userId && this.isCorrectDate());
    }

    handleClick() {
        const payload = {userId : this.userId, description : this.taskDescription, deadline : this.deadlineDate, leadId : this.recordId};
        console.log(payload);
        createTask(payload).then( result => {
            if (result) {
                console.log(result);
                this.newTaskId = result;
                this.showNotification("Success!", "Task created succesfully", "success");
                this.navigateToNewRecordViewPage();
            } else {
                this.showNotification("Fail!", "Something gone wrong", "error");
            }
        });
    }

    get minDate() {
        return new Date(Date.now()).toISOString();
    }

    isCorrectDate() {
        return Date.parse(this.deadlineDate) - Date.now() > 0;
    }

    showNotification(msg, t, v) {
        const evt = new ShowToastEvent({
            title   : t,
            message : msg,
            variant : v
        });
        this.dispatchEvent(evt);
    }

    navigateToNewRecordViewPage() {
        // View a custom object record.
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.newTaskId,
                objectApiName: 'Task', // objectApiName is optional
                actionName: 'view'
            }
        });
    }
}