import { BrowserModule } from '@angular/platform-browser';
import { NgModule } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { HttpModule } from '@angular/http';
import { ClarityModule } from 'clarity-angular';
import { AppComponent } from './app.component';
import { UtilsModule } from "../utils/utils.module";
import { ROUTING } from "./app.routing";
import { ContributorService } from "../services/contributors.service";

@NgModule({
    declarations: [
        AppComponent
    ],
    imports: [
        BrowserModule,
        FormsModule,
        HttpModule,
        ClarityModule.forRoot(),
        UtilsModule,
        ROUTING
    ],
    providers: [ContributorService],
    bootstrap: [AppComponent]
})
export class AppModule {
}
