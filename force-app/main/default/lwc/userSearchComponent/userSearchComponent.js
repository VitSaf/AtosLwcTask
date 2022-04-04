import { LightningElement, api, wire } from "lwc";

import findUser from "@salesforce/apex/TaskCreationController.findUser";

export default class UserSearchComponent extends LightningElement {
    queryTerm;
    searchResult;


    options = [];

    // handleKeyUp(evt) {
    //     const isEnterKey = evt.keyCode === 13;
    //     if (isEnterKey) {
    //         this.queryTerm = evt.target.value;
    //         findUser({keyWord : evt.target.value}).then( result => {
    //             if (result) {
                    
    //                 JSON.parse(result).forEach(x => {
    //                     this.options.push({label : x.Name + ", " + x.Email, value  : x.Id});
    //                 });
    //                 this.searchResult = JSON.parse(result);
    //             }
    //             console.log(this.searchResult);
    //         });
    //     }
    // }

    handleChange(event) {
        const selectedEvent = new CustomEvent('selected', { detail: event.detail.value });
        this.dispatchEvent(selectedEvent);
    }

    handleChangeQueryTerm(event) {
        this.queryTerm = event.target.value;
    }

    handleClick() {
        findUser({keyWord : this.queryTerm }).then( result => {
            if (result) {
                JSON.parse(result).forEach(x => {
                    this.options.push({label : x.Name + ", " + x.Email, value  : x.Id});
                });
                this.searchResult = JSON.parse(result);
            }
            console.log(this.searchResult);
        });
    }
}