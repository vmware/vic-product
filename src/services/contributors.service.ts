import { Injectable } from '@angular/core';
import { Http, Response } from '@angular/http';

import { Observable } from 'rxjs/Observable';
import 'rxjs/add/observable/forkJoin';
import 'rxjs/add/operator/map';

@Injectable()
export class ContributorService {
  constructor(
    private http: Http
  ) {}

  getContributors(): Observable<any> {
    // do work to merge three http calls into one observable.
    return Observable.forkJoin([
        this.http.get('https://api.github.com/repos/vmware/vic-product/contributors')
                 .map(res => res.json())
    ])
    .map((data: any[]) => {
      let contributors = [];
      // console.logco("observable data", data); // make sure we are getting datas from github.

      // concat all the data into one array
      contributors = contributors.concat(data[0]);

    // create a uniqueContributors array
    let uniqueContributors = [];
    // filteredContributors filters contributors array, add it to uniqueContributors if its not already there.
    var filteredContributors = contributors.filter(el => {
      if (uniqueContributors.indexOf(el.id) === -1) {
        uniqueContributors.push(el.id);
        return true;
      } else {
        return false;
      }
    });
    contributors = filteredContributors;
    return contributors;
  });
  }
}
