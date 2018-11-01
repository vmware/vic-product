import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import { ContributorService } from '../services/contributors.service';

@Component({
    selector: 'my-app',
    templateUrl: './app.component.html',
    styleUrls: ['./app.component.scss']
})
export class AppComponent implements OnInit {
    
    constructor(private contributorSvc: ContributorService) {}
    public contributors = [];

    ngOnInit() {
        this.contributorSvc.getContributors().subscribe(results => {
            this.contributors = results;
            // console.log("Contribs: ", results);
        });

    }
}