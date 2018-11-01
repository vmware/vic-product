import {NgModule} from "@angular/core";

import {HashListener} from "./hash-listener.directive";
import {ScrollSpy} from "./scrollspy.directive";
import {ClarityModule} from "clarity-angular";
import {CommonModule} from "@angular/common";

@NgModule({
    imports: [
        CommonModule,
        ClarityModule.forChild()
    ],
    declarations: [
        HashListener,
        ScrollSpy
    ],
    exports: [
        HashListener,
        ScrollSpy
    ]
})
export class UtilsModule {
}