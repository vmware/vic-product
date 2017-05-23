webpackJsonp([1,4],{

/***/ 141:
/***/ (function(module, exports) {

function webpackEmptyContext(req) {
	throw new Error("Cannot find module '" + req + "'.");
}
webpackEmptyContext.keys = function() { return []; };
webpackEmptyContext.resolve = webpackEmptyContext;
module.exports = webpackEmptyContext;
webpackEmptyContext.id = 141;


/***/ }),

/***/ 142:
/***/ (function(module, exports, __webpack_require__) {

"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
__webpack_require__(162);
var platform_browser_dynamic_1 = __webpack_require__(157);
var core_1 = __webpack_require__(10);
var environment_1 = __webpack_require__(161);
var _1 = __webpack_require__(160);
if (environment_1.environment.production) {
    core_1.enableProdMode();
}
platform_browser_dynamic_1.platformBrowserDynamic().bootstrapModule(_1.AppModule);
//# sourceMappingURL=/Users/druk/Sites/vic-product/src/src/src/main.js.map

/***/ }),

/***/ 158:
/***/ (function(module, exports, __webpack_require__) {

"use strict";

var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
var platform_browser_1 = __webpack_require__(33);
var core_1 = __webpack_require__(10);
var forms_1 = __webpack_require__(88);
var http_1 = __webpack_require__(156);
var clarity_angular_1 = __webpack_require__(90);
var app_component_1 = __webpack_require__(89);
var utils_module_1 = __webpack_require__(165);
var app_routing_1 = __webpack_require__(159);
var AppModule = (function () {
    function AppModule() {
    }
    return AppModule;
}());
AppModule = __decorate([
    core_1.NgModule({
        declarations: [
            app_component_1.AppComponent
        ],
        imports: [
            platform_browser_1.BrowserModule,
            forms_1.FormsModule,
            http_1.HttpModule,
            clarity_angular_1.ClarityModule.forRoot(),
            utils_module_1.UtilsModule,
            app_routing_1.ROUTING
        ],
        providers: [],
        bootstrap: [app_component_1.AppComponent]
    })
], AppModule);
exports.AppModule = AppModule;
//# sourceMappingURL=/Users/druk/Sites/vic-product/src/src/src/app/app.module.js.map

/***/ }),

/***/ 159:
/***/ (function(module, exports, __webpack_require__) {

"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
var router_1 = __webpack_require__(47);
exports.ROUTES = [
    { path: '', redirectTo: 'home', pathMatch: 'full' }
];
exports.ROUTING = router_1.RouterModule.forRoot(exports.ROUTES);
//# sourceMappingURL=/Users/druk/Sites/vic-product/src/src/src/app/app.routing.js.map

/***/ }),

/***/ 160:
/***/ (function(module, exports, __webpack_require__) {

"use strict";

function __export(m) {
    for (var p in m) if (!exports.hasOwnProperty(p)) exports[p] = m[p];
}
Object.defineProperty(exports, "__esModule", { value: true });
__export(__webpack_require__(89));
__export(__webpack_require__(158));
//# sourceMappingURL=/Users/druk/Sites/vic-product/src/src/src/app/index.js.map

/***/ }),

/***/ 161:
/***/ (function(module, exports, __webpack_require__) {

"use strict";
// The file contents for the current environment will overwrite these during build.
// The build system defaults to the dev environment which uses `environment.ts`, but if you do
// `ng build --env=prod` then `environment.prod.ts` will be used instead.
// The list of which env maps to which file can be found in `angular-cli.json`.

Object.defineProperty(exports, "__esModule", { value: true });
exports.environment = {
    production: true
};
//# sourceMappingURL=/Users/druk/Sites/vic-product/src/src/src/environments/environment.js.map

/***/ }),

/***/ 162:
/***/ (function(module, exports, __webpack_require__) {

"use strict";

Object.defineProperty(exports, "__esModule", { value: true });
// This file includes polyfills needed by Angular 2 and is loaded before
// the app. You can add your own extra polyfills to this file.
__webpack_require__(179);
__webpack_require__(172);
__webpack_require__(168);
__webpack_require__(174);
__webpack_require__(173);
__webpack_require__(171);
__webpack_require__(170);
__webpack_require__(178);
__webpack_require__(167);
__webpack_require__(166);
__webpack_require__(176);
__webpack_require__(169);
__webpack_require__(177);
__webpack_require__(175);
__webpack_require__(180);
__webpack_require__(358);
//# sourceMappingURL=/Users/druk/Sites/vic-product/src/src/src/polyfills.js.map

/***/ }),

/***/ 163:
/***/ (function(module, exports, __webpack_require__) {

"use strict";
/*
 * Hack while waiting for https://github.com/angular/angular/issues/6595 to be fixed.
 */

var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
var core_1 = __webpack_require__(10);
var router_1 = __webpack_require__(47);
var HashListener = (function () {
    function HashListener(route) {
        var _this = this;
        this.route = route;
        this.sub = this.route.fragment.subscribe(function (f) {
            _this.scrollToAnchor(f, false);
        });
    }
    HashListener.prototype.ngOnInit = function () {
        this.scrollToAnchor(this.route.snapshot.fragment, false);
    };
    HashListener.prototype.scrollToAnchor = function (hash, smooth) {
        if (smooth === void 0) { smooth = true; }
        if (hash) {
            var element = document.querySelector("#" + hash);
            if (element) {
                element.scrollIntoView({
                    behavior: smooth ? "smooth" : "instant",
                    block: "start"
                });
            }
        }
    };
    HashListener.prototype.ngOnDestroy = function () {
        this.sub.unsubscribe();
    };
    return HashListener;
}());
HashListener = __decorate([
    core_1.Directive({
        selector: "[hash-listener]",
        host: {
            "[style.position]": "'relative'"
        }
    }),
    __metadata("design:paramtypes", [typeof (_a = typeof router_1.ActivatedRoute !== "undefined" && router_1.ActivatedRoute) === "function" && _a || Object])
], HashListener);
exports.HashListener = HashListener;
var _a;
//# sourceMappingURL=/Users/druk/Sites/vic-product/src/src/src/utils/hash-listener.directive.js.map

/***/ }),

/***/ 164:
/***/ (function(module, exports, __webpack_require__) {

"use strict";
/*
 * Hack while waiting for https://github.com/angular/angular/issues/6595 to be fixed.
 */

var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
var core_1 = __webpack_require__(10);
var router_1 = __webpack_require__(47);
var ScrollSpy = (function () {
    function ScrollSpy(renderer) {
        this.renderer = renderer;
        this.anchors = [];
        this.throttle = false;
    }
    Object.defineProperty(ScrollSpy.prototype, "links", {
        set: function (routerLinks) {
            var _this = this;
            this.anchors = routerLinks.map(function (routerLink) { return "#" + routerLink.fragment; });
            this.sub = routerLinks.changes.subscribe(function () {
                _this.anchors = routerLinks.map(function (routerLink) { return "#" + routerLink.fragment; });
            });
        },
        enumerable: true,
        configurable: true
    });
    ScrollSpy.prototype.handleEvent = function () {
        var _this = this;
        this.scrollPosition = this.scrollable.scrollTop;
        if (!this.throttle) {
            window.requestAnimationFrame(function () {
                var currentLinkIndex = _this.findCurrentAnchor() || 0;
                _this.linkElements.forEach(function (link, index) {
                    _this.renderer.setElementClass(link.nativeElement, "active", index === currentLinkIndex);
                });
                _this.throttle = false;
            });
        }
        this.throttle = true;
    };
    ScrollSpy.prototype.findCurrentAnchor = function () {
        for (var i = this.anchors.length - 1; i >= 0; i--) {
            var anchor = this.anchors[i];
            if (this.scrollable.querySelector(anchor) && this.scrollable.querySelector(anchor).offsetTop <= this.scrollPosition) {
                return i;
            }
        }
    };
    ScrollSpy.prototype.ngOnInit = function () {
        this.scrollable.addEventListener("scroll", this);
    };
    ScrollSpy.prototype.ngOnDestroy = function () {
        this.scrollable.removeEventListener("scroll", this);
        if (this.sub) {
            this.sub.unsubscribe();
        }
    };
    return ScrollSpy;
}());
__decorate([
    core_1.Input("scrollspy"),
    __metadata("design:type", Object)
], ScrollSpy.prototype, "scrollable", void 0);
__decorate([
    core_1.ContentChildren(router_1.RouterLinkWithHref, { descendants: true }),
    __metadata("design:type", typeof (_a = typeof core_1.QueryList !== "undefined" && core_1.QueryList) === "function" && _a || Object),
    __metadata("design:paramtypes", [typeof (_b = typeof core_1.QueryList !== "undefined" && core_1.QueryList) === "function" && _b || Object])
], ScrollSpy.prototype, "links", null);
__decorate([
    core_1.ContentChildren(router_1.RouterLinkWithHref, { descendants: true, read: core_1.ElementRef }),
    __metadata("design:type", typeof (_c = typeof core_1.QueryList !== "undefined" && core_1.QueryList) === "function" && _c || Object)
], ScrollSpy.prototype, "linkElements", void 0);
ScrollSpy = __decorate([
    core_1.Directive({
        selector: "[scrollspy]",
    }),
    __metadata("design:paramtypes", [typeof (_d = typeof core_1.Renderer !== "undefined" && core_1.Renderer) === "function" && _d || Object])
], ScrollSpy);
exports.ScrollSpy = ScrollSpy;
var _a, _b, _c, _d;
//# sourceMappingURL=/Users/druk/Sites/vic-product/src/src/src/utils/scrollspy.directive.js.map

/***/ }),

/***/ 165:
/***/ (function(module, exports, __webpack_require__) {

"use strict";

var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
var core_1 = __webpack_require__(10);
var hash_listener_directive_1 = __webpack_require__(163);
var scrollspy_directive_1 = __webpack_require__(164);
var clarity_angular_1 = __webpack_require__(90);
var common_1 = __webpack_require__(40);
var UtilsModule = (function () {
    function UtilsModule() {
    }
    return UtilsModule;
}());
UtilsModule = __decorate([
    core_1.NgModule({
        imports: [
            common_1.CommonModule,
            clarity_angular_1.ClarityModule.forChild()
        ],
        declarations: [
            hash_listener_directive_1.HashListener,
            scrollspy_directive_1.ScrollSpy
        ],
        exports: [
            hash_listener_directive_1.HashListener,
            scrollspy_directive_1.ScrollSpy
        ]
    })
], UtilsModule);
exports.UtilsModule = UtilsModule;
//# sourceMappingURL=/Users/druk/Sites/vic-product/src/src/src/utils/utils.module.js.map

/***/ }),

/***/ 320:
/***/ (function(module, exports, __webpack_require__) {

exports = module.exports = __webpack_require__(38)(false);
// imports


// module
exports.push([module.i, ".clr-icon.clr-clarity-logo {\n  background-image: url(/vic-product/images/vmw_oss.svg); }\n\n.hero {\n  background-color: #ddd;\n  text-align: center;\n  padding-bottom: 3em;\n  padding-top: 3em;\n  width: 100%; }\n  .hero .btn-custom {\n    display: inline-block;\n    text-align: center;\n    margin: auto; }\n\n.hero-image img {\n  max-width: 360px; }\n\n.icon {\n  display: inline-block;\n  height: 32px;\n  vertical-align: middle;\n  width: 32px; }\n  .icon.icon-github {\n    background: url(/vic-product/images/github_icon.svg) no-repeat left -2px; }\n\n.nav-group label {\n  display: block;\n  margin-bottom: 1em; }\n\n.sidenav .nav-link {\n  padding: 3px 6px; }\n  .sidenav .nav-link:hover {\n    background: #eee; }\n  .sidenav .nav-link.active {\n    background: #d9e4ea;\n    color: #000; }\n\n.section {\n  padding: .5em 0; }\n\n.contributor {\n  border-radius: 50%;\n  border: 1px solid #ccc;\n  margin-bottom: 1.5em;\n  margin-right: 2.5em;\n  max-width: 104px;\n  text-decoration: none; }\n\n#license {\n  padding-bottom: 50vh; }\n", ""]);

// exports


/*** EXPORTS FROM exports-loader ***/
module.exports = module.exports.toString();

/***/ }),

/***/ 329:
/***/ (function(module, exports) {

module.exports = "<clr-main-container>\n    <header class=\"header header-6\">\n        <div class=\"branding\">\n            <a href=\"https://vmware.github.io/\" class=\"nav-link\">\n                <span class=\"clr-icon clr-clarity-logo\"></span>\n                <span class=\"title\">VMware&reg; Open Source Program Office</span>\n            </a>\n        </div>\n    </header>\n    <div class=\"hero\">\n        <div class=\"hero-image\"><img src=\"images/vic-product.png\" alt=\"VMware vSphere&reg; Integrated Containers&trade;\"></div>\n        <p><a href=\"https://github.com/vmware/vic-product\" class=\"btn btn-primary\"><i class=\"icon icon-github\"></i> Go to GitHub</a></p>\n    </div>\n    <div class=\"content-container\">\n        <div id=\"content-area\" class=\"content-area\" hash-listener #scrollable>\n            <div id=\"overview\" class=\"section\">\n                <h2>What is vSphere Integrated Containers?</h2>\n\n                <p>vSphere Integrated Containers comprises of three main components, all of which are available as open source projects on Github:</p>\n\n                <br>\n\n                <ul>\n                    <li><a href=\"https://vmware.github.io/vic/\">VMware vSphere Integrated Containers Engine</a>, a container runtime for vSphere. vSphere Integrated Containers Engine allows developers who are familiar with Docker to develop in containers and deploy them alongside traditional VM-based workloads on vSphere clusters. vSphere adminitrators can manage these workloads by using vSphere in a way that is familiar.</li>\n                    <li><a href=\"https://vmware.github.io/harbor/\">VMware vSphere Integrated Containers Registry</a>, an enterprise-class container registry server that stores and distributes container images. Also known as VMware Harbor, vSphere Integrated Containers Registry extends the Docker Distribution open source project by adding the functionalities that an enterprise requires, such as security, identity and management.</li>\n                    <li><a href=\"https://vmware.github.io/admiral/\">VMware vSphere Integrated Containers Management Portal</a>, a container management portal. Also known as VMware Admiral, vSphere Integrated Containers Management Portal provides a UI for DevOps teams to provision and manage containers, including the ability to obtain statistics and information about container instances. Cloud administrators can manage container hosts and apply governance to their usage, including capacity quotas and approval workflows. When integrated with vRealize Automation, more advanced capabilities become available, such as deployment blueprints and enterprise-grade Containers-as-a-Service.</li>\n                </ul>\n\n                <p>With these capabilities, vSphere Integrated Containers enables VMware customers to deliver a production-ready container solution to their developers and DevOps teams. By leveraging their existing SDDC, customers can run container-based applications alongside existing virtual machine based workloads in production without having to build out a separate, specialized container infrastructure stack. As an added benefit for customers and partners, vSphere Integrated Containers is modular. So, for example, if your organization already has a container registry in production, you can use that registry with vSphere Integrated Containers Engine and vSphere Integrated Containers Management Portal.</p>\n\n                <p>For more information, see the <a href=\"http://www.vmware.com/products/vsphere/integrated-containers.html\">official vSphere Integrated Containers product page on vmware.com</a>.</p>\n            </div>\n\n            <div id=\"gettingVIC\" class=\"section\">\n                <h2>Get vSphere Integrated Containers</h2>\n\n                <p>To obtain the latest official release of vSphere Integrated Containers, go to the <a href=\"http://www.vmware.com/go/download-vic\">vSphere Integrated Containers download page on vmware.com</a>. You need a vSphere Enterprise Plus License to download an official, supported release of vSphere Integrated Containers.</p>\n\n                <p>You can also obtain open-source releases of vSphere Integrated Containers that are more recent than the latest official release:</p>\n\n                <br>\n                \n                <ul>\n                    <li>\n                        Tagged versions of vSphere Integrated Containers that have been tested and released to the community, but that might not reflect the most up-to-date version of the code:\n                        <ul>\n                            <li><a href=\"https://github.com/vmware/vic\">vSphere Integrated Containers Engine Repository</a></li>\n                            <li><a href=\"https://github.com/vmware/harbor\">vSphere Integrated Containers Registry (Harbor) Repository</a></li>\n                            <li><a href=\"https://github.com/vmware/admiral\">vSphere Integrated Containers Management Portal (Admiral) Repository</a></li>\n                        </ul>\n                    </li>\n                    <li><a href=\"https://storage.googleapis.com/vic-engine-builds/\">Latest built binaries of vSphere Integrated Containers Engine</a>. Builds usually happen after every successful merge into the source code. These builds have been minimally tested for integration.</li>\n                    <li>\n                        Source code is available in the VMware GitHub source repository for each component:\n                        <ul>\n                            <li><a href=\"https://github.com/vmware/vic\">vSphere Integrated Containers Engine Repository</a></li>\n                            <li><a href=\"https://github.com/vmware/harbor\">vSphere Integrated Containers Registry (Harbor) Repository</a></li>\n                            <li><a href=\"https://github.com/vmware/admiral\">vSphere Integrated Containers Management Portal (Admiral) Repository</a></li>\n                        </ul>\n                    </li>\n                </ul>\n            </div>\n\n            <div id=\"documentation\" class=\"section\">\n                <h2>Getting Started</h2>\n                \n                <p>Here are some docs to help get you started. The latest open-source software (OSS) docs reflect the state of the product at the most recent tagged build. As such they are works-in-progess, and not all sections have necessarily been fully updated or reviewed.</p>\n\n                <p>The docs for the latest official VMware release have been fully reviewed and approved for that release.</p>\n\n                <div class=\"row\">\n                    <div class=\"col-lg-5 col-md-8 col-sm-12 col-xs-12\">\n                        <div class=\"card\">\n                            <div class=\"card-header\">vSphere Integrated Containers 1.1.1</div>\n                            <div class=\"card-block\">\n                                <div class=\"card-text\">\n                                    Latest Offical VMware and OSS Release<br>\n                                    <small>Updated 2017-05-18</small>\n                                </div>\n                            </div>\n                            <div class=\"card-footer\">\n                                <a href=\"https://vmware.github.io/vic-product/assets/files/html/1.1/index.html\" class=\"btn btn-sm btn-link\">Go</a>\n                            </div>\n                        </div>\n                    </div>\n                    <div class=\"col-lg-5 col-md-8 col-sm-12 col-xs-12\">\n                        <div class=\"card\">\n                            <div class=\"card-header\">Previous Releases</div>\n                            <div class=\"card-block\">\n                                <div class=\"card-text\">\n                                    Documentation for previous releases\n                                </div>\n                            </div>\n                            <div class=\"card-footer\">\n                                <a href=\"https://vmware.github.io/vic-product/archive/\" class=\"btn btn-sm btn-link\">Go</a>\n                            </div>\n                        </div>\n                    </div>\n                </div>\n            </div>\n\n            <div id=\"support\" class=\"section\">\n                <h2>Support</h2>\n                <p>Full support of vSphere Integrated Containers requires the vSphere Enterprise Plus license and an official VMware release of vSphere Integrated Containers. You obtain an official release from the <a href=\"http://www.vmware.com/go/download-vic\">vSphere Integrated Containers download page on vmware.com</a>. To make a support request, contact <a href=\"http://www.vmware.com/support\">VMware Global Support</a>.</p>\n\n                <p>All other releases of vSphere Integrated Containers are released as open source software and come with no commercial support.</p>\n\n                <p>For general questions, visit the vSphere Integrated Containers channels on Slack.com. If you do not have an @vmware.com or @emc.com email address, sign up at <a href=\"https://code.vmware.com\">https://code.vmware.com</a> to get an invitation.</p>\n\n                <br>\n\n                <ul>\n                    <li><a href=\"https://vmwarecode.slack.com/messages/vic-product\">vSphere Integrated Containers Channel</a></li>\n                    <li><a href=\"https://vmwarecode.slack.com/messages/vic-engine\">vSphere Integrated Containers Engine Channel</a></li>\n                    <li><a href=\"https://vmwarecode.slack.com/messages/harbor\">vSphere Integrated Containers Registry Channel</a></li>\n                    <li><a href=\"https://vmwarecode.slack.com/messages/admiral\">vSphere Integrated Containers Management Portal Channel</a></li>\n                    <li><a href=\"https://vmwarecode.slack.com/messages/vic-doc\">vSphere Integrated Containers Docs Channel</a></li>\n                </ul>\n            </div>\n            <div id=\"contributors\" class=\"section\">\n                <h2>Contributors</h2>\n\n                <p>\n                    <a title=\"tgeorgiev\" href=\"https://github.com/tgeorgiev\"><img alt=\"tgeorgiev\" src=\"https://avatars3.githubusercontent.com/u/344498?v=3\" class=\"contributor\"></a>\n                    <a title=\"rgeorgiev\" href=\"https://github.com/rgeorgiev\"><img alt=\"rgeorgiev\" src=\"https://avatars2.githubusercontent.com/u/171507?v=3\" class=\"contributor\"></a>\n                    <a title=\"angel-ivanov\" href=\"https://github.com/angel-ivanov\"><img alt=\"angel-ivanov\" src=\"https://avatars1.githubusercontent.com/u/14371699?v=3\" class=\"contributor\"></a>\n                    <a title=\"asual\" href=\"https://github.com/asual\"><img alt=\"asual\" src=\"https://avatars0.githubusercontent.com/u/98153?v=3\" class=\"contributor\"></a>\n                    <a title=\"pmitrov\" href=\"https://github.com/pmitrov\"><img alt=\"pmitrov\" src=\"https://avatars2.githubusercontent.com/u/21332291?v=3\" class=\"contributor\"></a>\n                    <a title=\"rageorgiev\" href=\"https://github.com/rageorgiev\"><img alt=\"rageorgiev\" src=\"https://avatars1.githubusercontent.com/u/18466493?v=3\" class=\"contributor\"></a>\n                    <a title=\"AntonioFilipov\" href=\"https://github.com/AntonioFilipov\"><img alt=\"AntonioFilipov\" src=\"https://avatars0.githubusercontent.com/u/7526137?v=3\" class=\"contributor\"></a>\n                    <a title=\"iilieva\" href=\"https://github.com/iilieva\"><img alt=\"iilieva\" src=\"https://avatars2.githubusercontent.com/u/21175375?v=3\" class=\"contributor\"></a>\n                    <a title=\"shadjiiski\" href=\"https://github.com/shadjiiski\"><img alt=\"shadjiiski\" src=\"https://avatars1.githubusercontent.com/u/4493115?v=3\" class=\"contributor\"></a>\n                    <a title=\"sergiosagu\" href=\"https://github.com/sergiosagu\"><img alt=\"sergiosagu\" src=\"https://avatars1.githubusercontent.com/u/2034419?v=3\" class=\"contributor\"></a>\n                    <a title=\"gmuleshkov\" href=\"https://github.com/gmuleshkov\"><img alt=\"gmuleshkov\" src=\"https://avatars3.githubusercontent.com/u/6323141?v=3\" class=\"contributor\"></a>\n                    <a title=\"jdillet\" href=\"https://github.com/jdillet\"><img alt=\"jdillet\" src=\"https://avatars3.githubusercontent.com/u/10244261?v=3\" class=\"contributor\"></a>\n                    <a title=\"lazarin\" href=\"https://github.com/lazarin\"><img alt=\"lazarin\" src=\"https://avatars3.githubusercontent.com/u/676880?v=3\" class=\"contributor\"></a>\n                    <a title=\"eivanova\" href=\"https://github.com/eivanova\"><img alt=\"eivanova\" src=\"https://avatars1.githubusercontent.com/u/1151691?v=3\" class=\"contributor\"></a>\n                    <a title=\"mshipkovenski\" href=\"https://github.com/mshipkovenski\"><img alt=\"mshipkovenski\" src=\"https://avatars1.githubusercontent.com/u/7767427?v=3\" class=\"contributor\"></a>\n                    <a title=\"glechev\" href=\"https://github.com/glechev\"><img alt=\"glechev\" src=\"https://avatars0.githubusercontent.com/u/17747714?v=3\" class=\"contributor\"></a>\n                    <a title=\"zaharii\" href=\"https://github.com/zaharii\"><img alt=\"zaharii\" src=\"https://avatars3.githubusercontent.com/u/6303316?v=3\" class=\"contributor\"></a>\n                    <a title=\"ipantchev\" href=\"https://github.com/ipantchev\"><img alt=\"ipantchev\" src=\"https://avatars2.githubusercontent.com/u/21260087?v=3\" class=\"contributor\"></a>\n                    <a title=\"aangelov-vmware\" href=\"https://github.com/aangelov-vmware\"><img alt=\"aangelov-vmware\" src=\"https://avatars0.githubusercontent.com/u/20043057?v=3\" class=\"contributor\"></a>\n                    <a title=\"igorstoyanov\" href=\"https://github.com/igorstoyanov\"><img alt=\"igorstoyanov\" src=\"https://avatars1.githubusercontent.com/u/1800545?v=3\" class=\"contributor\"></a>\n                    <a title=\"vLynnMa\" href=\"https://github.com/vLynnMa\"><img alt=\"vLynnMa\" src=\"https://avatars1.githubusercontent.com/u/23247549?v=3\" class=\"contributor\"></a>\n                    <a title=\"agovindaraju\" href=\"https://github.com/agovindaraju\"><img alt=\"agovindaraju\" src=\"https://avatars1.githubusercontent.com/u/7880498?v=3\" class=\"contributor\"></a>\n                    <a title=\"asavov\" href=\"https://github.com/asavov\"><img alt=\"asavov\" src=\"https://avatars2.githubusercontent.com/u/2912057?v=3\" class=\"contributor\"></a>\n                    <a title=\"georgievKristiyan\" href=\"https://github.com/georgievKristiyan\"><img alt=\"georgievKristiyan\" src=\"https://avatars3.githubusercontent.com/u/25226626?v=3\" class=\"contributor\"></a>\n                    <a title=\"martin-borisov\" href=\"https://github.com/martin-borisov\"><img alt=\"martin-borisov\" src=\"https://avatars0.githubusercontent.com/u/21335795?v=3\" class=\"contributor\"></a>\n                    <a title=\"caglar10ur\" href=\"https://github.com/caglar10ur\"><img alt=\"caglar10ur\" src=\"https://avatars3.githubusercontent.com/u/205498?v=3\" class=\"contributor\"></a>\n                    <a title=\"mhagen-vmware\" href=\"https://github.com/mhagen-vmware\"><img alt=\"mhagen-vmware\" src=\"https://avatars3.githubusercontent.com/u/19393273?v=3\" class=\"contributor\"></a>\n                    <a title=\"dougm\" href=\"https://github.com/dougm\"><img alt=\"dougm\" src=\"https://avatars0.githubusercontent.com/u/30171?v=3\" class=\"contributor\"></a>\n                    <a title=\"fdawg4l\" href=\"https://github.com/fdawg4l\"><img alt=\"fdawg4l\" src=\"https://avatars0.githubusercontent.com/u/4296242?v=3\" class=\"contributor\"></a>\n                    <a title=\"andrewtchin\" href=\"https://github.com/andrewtchin\"><img alt=\"andrewtchin\" src=\"https://avatars1.githubusercontent.com/u/1649165?v=3\" class=\"contributor\"></a>\n                    <a title=\"jzt\" href=\"https://github.com/jzt\"><img alt=\"jzt\" src=\"https://avatars3.githubusercontent.com/u/128130?v=3\" class=\"contributor\"></a>\n                    <a title=\"hickeng\" href=\"https://github.com/hickeng\"><img alt=\"hickeng\" src=\"https://avatars2.githubusercontent.com/u/3923729?v=3\" class=\"contributor\"></a>\n                    <a title=\"emlin\" href=\"https://github.com/emlin\"><img alt=\"emlin\" src=\"https://avatars3.githubusercontent.com/u/1091772?v=3\" class=\"contributor\"></a>\n                    <a title=\"sflxn\" href=\"https://github.com/sflxn\"><img alt=\"sflxn\" src=\"https://avatars0.githubusercontent.com/u/1330508?v=3\" class=\"contributor\"></a>\n                    <a title=\"cgtexmex\" href=\"https://github.com/cgtexmex\"><img alt=\"cgtexmex\" src=\"https://avatars1.githubusercontent.com/u/726112?v=3\" class=\"contributor\"></a>\n                    <a title=\"hmahmood\" href=\"https://github.com/hmahmood\"><img alt=\"hmahmood\" src=\"https://avatars0.githubusercontent.com/u/6599778?v=3\" class=\"contributor\"></a>\n                    <a title=\"gigawhitlocks\" href=\"https://github.com/gigawhitlocks\"><img alt=\"gigawhitlocks\" src=\"https://avatars0.githubusercontent.com/u/3743903?v=3\" class=\"contributor\"></a>\n                    <a title=\"jooskim\" href=\"https://github.com/jooskim\"><img alt=\"jooskim\" src=\"https://avatars2.githubusercontent.com/u/3834071?v=3\" class=\"contributor\"></a>\n                    <a title=\"anchal-agrawal\" href=\"https://github.com/anchal-agrawal\"><img alt=\"anchal-agrawal\" src=\"https://avatars0.githubusercontent.com/u/4361620?v=3\" class=\"contributor\"></a>\n                    <a title=\"frapposelli\" href=\"https://github.com/frapposelli\"><img alt=\"frapposelli\" src=\"https://avatars3.githubusercontent.com/u/541832?v=3\" class=\"contributor\"></a>\n                    <a title=\"stuclem\" href=\"https://github.com/stuclem\"><img alt=\"stuclem\" src=\"https://avatars1.githubusercontent.com/u/16718369?v=3\" class=\"contributor\"></a>\n                    <a title=\"sgairo\" href=\"https://github.com/sgairo\"><img alt=\"sgairo\" src=\"https://avatars0.githubusercontent.com/u/19394901?v=3\" class=\"contributor\"></a>\n                    <a title=\"matthewavery\" href=\"https://github.com/matthewavery\"><img alt=\"matthewavery\" src=\"https://avatars1.githubusercontent.com/u/8620942?v=3\" class=\"contributor\"></a>\n                    <a title=\"rajanashok\" href=\"https://github.com/rajanashok\"><img alt=\"rajanashok\" src=\"https://avatars1.githubusercontent.com/u/21340516?v=3\" class=\"contributor\"></a>\n                    <a title=\"vburenin\" href=\"https://github.com/vburenin\"><img alt=\"vburenin\" src=\"https://avatars1.githubusercontent.com/u/4350891?v=3\" class=\"contributor\"></a>\n                    <a title=\"mdubya66\" href=\"https://github.com/mdubya66\"><img alt=\"mdubya66\" src=\"https://avatars3.githubusercontent.com/u/15821624?v=3\" class=\"contributor\"></a>\n                    <a title=\"chengwang86\" href=\"https://github.com/chengwang86\"><img alt=\"chengwang86\" src=\"https://avatars2.githubusercontent.com/u/22303971?v=3\" class=\"contributor\"></a>\n                    <a title=\"maplain\" href=\"https://github.com/maplain\"><img alt=\"maplain\" src=\"https://avatars1.githubusercontent.com/u/2901728?v=3\" class=\"contributor\"></a>\n                    <a title=\"corrieb\" href=\"https://github.com/corrieb\"><img alt=\"corrieb\" src=\"https://avatars2.githubusercontent.com/u/1699842?v=3\" class=\"contributor\"></a>\n                    <a title=\"npakrasi\" href=\"https://github.com/npakrasi\"><img alt=\"npakrasi\" src=\"https://avatars0.githubusercontent.com/u/16723048?v=3\" class=\"contributor\"></a>\n                    <a title=\"jakedsouza\" href=\"https://github.com/jakedsouza\"><img alt=\"jakedsouza\" src=\"https://avatars3.githubusercontent.com/u/1404569?v=3\" class=\"contributor\"></a>\n                    <a title=\"lcastellano\" href=\"https://github.com/lcastellano\"><img alt=\"lcastellano\" src=\"https://avatars0.githubusercontent.com/u/7454168?v=3\" class=\"contributor\"></a>\n                    <a title=\"kreamyx\" href=\"https://github.com/kreamyx\"><img alt=\"kreamyx\" src=\"https://avatars0.githubusercontent.com/u/20427375?v=3\" class=\"contributor\"></a>\n                    <a title=\"casualjim\" href=\"https://github.com/casualjim\"><img alt=\"casualjim\" src=\"https://avatars3.githubusercontent.com/u/456109?v=3\" class=\"contributor\"></a>\n                    <a title=\"morris-jason\" href=\"https://github.com/morris-jason\"><img alt=\"morris-jason\" src=\"https://avatars3.githubusercontent.com/u/10388115?v=3\" class=\"contributor\"></a>\n                    <a title=\"reasonerjt\" href=\"https://github.com/reasonerjt\"><img alt=\"reasonerjt\" src=\"https://avatars3.githubusercontent.com/u/2390463?v=3\" class=\"contributor\"></a>\n                    <a title=\"wknet123\" href=\"https://github.com/wknet123\"><img alt=\"wknet123\" src=\"https://avatars0.githubusercontent.com/u/5027302?v=3\" class=\"contributor\"></a>\n                    <a title=\"ywk253100\" href=\"https://github.com/ywk253100\"><img alt=\"ywk253100\" src=\"https://avatars0.githubusercontent.com/u/5835782?v=3\" class=\"contributor\"></a>\n                    <a title=\"hainingzhang\" href=\"https://github.com/hainingzhang\"><img alt=\"hainingzhang\" src=\"https://avatars1.githubusercontent.com/u/2161887?v=3\" class=\"contributor\"></a>\n                    <a title=\"steven-zou\" href=\"https://github.com/steven-zou\"><img alt=\"steven-zou\" src=\"https://avatars3.githubusercontent.com/u/5753287?v=3\" class=\"contributor\"></a>\n                    <a title=\"wemeya\" href=\"https://github.com/wemeya\"><img alt=\"wemeya\" src=\"https://avatars2.githubusercontent.com/u/12540577?v=3\" class=\"contributor\"></a>\n                    <a title=\"yhua123\" href=\"https://github.com/yhua123\"><img alt=\"yhua123\" src=\"https://avatars1.githubusercontent.com/u/19166125?v=3\" class=\"contributor\"></a>\n                    <a title=\"wy65701436\" href=\"https://github.com/wy65701436\"><img alt=\"wy65701436\" src=\"https://avatars0.githubusercontent.com/u/2841473?v=3\" class=\"contributor\"></a>\n                    <a title=\"invalid-email-address\" href=\"https://github.com/invalid-email-address\"><img alt=\"invalid-email-address\" src=\"https://avatars3.githubusercontent.com/u/148100?v=3\" class=\"contributor\"></a>\n                    <a title=\"saga92\" href=\"https://github.com/saga92\"><img alt=\"saga92\" src=\"https://avatars1.githubusercontent.com/u/5730235?v=3\" class=\"contributor\"></a>\n                    <a title=\"xiahaoshawn\" href=\"https://github.com/xiahaoshawn\"><img alt=\"xiahaoshawn\" src=\"https://avatars0.githubusercontent.com/u/10750864?v=3\" class=\"contributor\"></a>\n                    <a title=\"Erkak\" href=\"https://github.com/Erkak\"><img alt=\"Erkak\" src=\"https://avatars2.githubusercontent.com/u/15937486?v=3\" class=\"contributor\"></a>\n                    <a title=\"hmwenchen\" href=\"https://github.com/hmwenchen\"><img alt=\"hmwenchen\" src=\"https://avatars3.githubusercontent.com/u/16629561?v=3\" class=\"contributor\"></a>\n                    <a title=\"perhapszzy\" href=\"https://github.com/perhapszzy\"><img alt=\"perhapszzy\" src=\"https://avatars1.githubusercontent.com/u/7953637?v=3\" class=\"contributor\"></a>\n                    <a title=\"zgdxiaoxiao\" href=\"https://github.com/zgdxiaoxiao\"><img alt=\"zgdxiaoxiao\" src=\"https://avatars3.githubusercontent.com/u/19501217?v=3\" class=\"contributor\"></a>\n                    <a title=\"victoriazhengwf\" href=\"https://github.com/victoriazhengwf\"><img alt=\"victoriazhengwf\" src=\"https://avatars0.githubusercontent.com/u/17972009?v=3\" class=\"contributor\"></a>\n                    <a title=\"rikatz\" href=\"https://github.com/rikatz\"><img alt=\"rikatz\" src=\"https://avatars3.githubusercontent.com/u/7182341?v=3\" class=\"contributor\"></a>\n                    <a title=\"senk\" href=\"https://github.com/senk\"><img alt=\"senk\" src=\"https://avatars1.githubusercontent.com/u/710568?v=3\" class=\"contributor\"></a>\n                    <a title=\"AlexZeitler\" href=\"https://github.com/AlexZeitler\"><img alt=\"AlexZeitler\" src=\"https://avatars2.githubusercontent.com/u/287480?v=3\" class=\"contributor\"></a>\n                    <a title=\"ScorpioCPH\" href=\"https://github.com/ScorpioCPH\"><img alt=\"ScorpioCPH\" src=\"https://avatars1.githubusercontent.com/u/5319646?v=3\" class=\"contributor\"></a>\n                    <a title=\"redkafei\" href=\"https://github.com/redkafei\"><img alt=\"redkafei\" src=\"https://avatars1.githubusercontent.com/u/8327386?v=3\" class=\"contributor\"></a>\n                    <a title=\"int32bit\" href=\"https://github.com/int32bit\"><img alt=\"int32bit\" src=\"https://avatars2.githubusercontent.com/u/5260798?v=3\" class=\"contributor\"></a>\n                    <a title=\"tobegit3hub\" href=\"https://github.com/tobegit3hub\"><img alt=\"tobegit3hub\" src=\"https://avatars3.githubusercontent.com/u/2715000?v=3\" class=\"contributor\"></a>\n                    <a title=\"amandaz\" href=\"https://github.com/amandaz\"><img alt=\"amandaz\" src=\"https://avatars0.githubusercontent.com/u/2898608?v=3\" class=\"contributor\"></a>\n                    <a title=\"laz2\" href=\"https://github.com/laz2\"><img alt=\"laz2\" src=\"https://avatars2.githubusercontent.com/u/800356?v=3\" class=\"contributor\"></a>\n                    <a title=\"nagarjung\" href=\"https://github.com/nagarjung\"><img alt=\"nagarjung\" src=\"https://avatars1.githubusercontent.com/u/9403528?v=3\" class=\"contributor\"></a>\n                    <a title=\"alanwooo\" href=\"https://github.com/alanwooo\"><img alt=\"alanwooo\" src=\"https://avatars2.githubusercontent.com/u/12868735?v=3\" class=\"contributor\"></a>\n                    <a title=\"liubin\" href=\"https://github.com/liubin\"><img alt=\"liubin\" src=\"https://avatars2.githubusercontent.com/u/1212008?v=3\" class=\"contributor\"></a>\n                    <a title=\"feilengcui008\" href=\"https://github.com/feilengcui008\"><img alt=\"feilengcui008\" src=\"https://avatars3.githubusercontent.com/u/4131736?v=3\" class=\"contributor\"></a>\n                    <a title=\"sigsbee\" href=\"https://github.com/sigsbee\"><img alt=\"sigsbee\" src=\"https://avatars1.githubusercontent.com/u/23101283?v=3\" class=\"contributor\"></a>\n                </p>\n            </div>\n\n            <div id=\"contributing\" class=\"section\">\n                <h2>Contributing</h2>\n\n                <p>The vSphere Integrated Containers project team welcomes contributions from the community. If you wish to contribute code, we require that you first sign our <a href=\"https://vmware.github.io/vic-product/assets/files/pdf/vmware_cla.pdf\">Contributor License Agreement</a> and return a copy to <a href=\"mailto:osscontributions@vmware.com\">osscontributions@vmware.com</a> before we can merge your contribution.</p>\n            </div>\n\n            <div id=\"license\" class=\"section\">\n                <h2>License</h2>\n\n                <p>The vSphere Integrated Containers components are licensed under Apache 2 with additional licenses denoted within the <a href=\"https://github.com/vmware/vic/blob/master/LICENSE\">vSphere Integrated Containers Engine</a>, <a href=\"https://github.com/vmware/admiral/blob/master/LICENSE\">Admiral</a>, and <a href=\"https://github.com/vmware/harbor/blob/master/LICENSE\">Harbor</a> open source repositories.</p>\n            </div>\n        </div>\n        <nav class=\"sidenav\" [clr-nav-level]=\"2\">\n            <section class=\"sidenav-content\">\n                <section class=\"nav-group\" [scrollspy]=\"scrollable\">\n                    <label><a class=\"nav-link active\" routerLink=\".\" routerLinkActive=\"active\" fragment=\"overview\">Overview</a></label>\n                    <label class=\"bump-down\"><a class=\"nav-link\" routerLink=\".\" fragment=\"gettingVIC\">Download</a></label>\n                    <label class=\"bump-down\"><a class=\"nav-link\" routerLink=\".\" fragment=\"documentation\">Documentation</a></label>\n                    <label class=\"bump-down\"><a class=\"nav-link\" routerLink=\".\" fragment=\"support\">Support</a></label>\n                    <label class=\"bump-down\"><a class=\"nav-link\" routerLink=\".\" fragment=\"contributors\">Contributors</a></label>\n                    <label class=\"bump-down\"><a class=\"nav-link\" routerLink=\".\" fragment=\"contributing\">Contributing</a></label>\n                    <label class=\"bump-down\"><a class=\"nav-link\" routerLink=\".\" fragment=\"license\">License</a></label>\n                </section>\n            </section>\n        </nav>\n    </div>\n</clr-main-container>\n"

/***/ }),

/***/ 360:
/***/ (function(module, exports, __webpack_require__) {

module.exports = __webpack_require__(142);


/***/ }),

/***/ 89:
/***/ (function(module, exports, __webpack_require__) {

"use strict";

var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
var core_1 = __webpack_require__(10);
var router_1 = __webpack_require__(47);
var AppComponent = (function () {
    function AppComponent(router) {
        this.router = router;
    }
    return AppComponent;
}());
AppComponent = __decorate([
    core_1.Component({
        selector: 'my-app',
        template: __webpack_require__(329),
        styles: [__webpack_require__(320)]
    }),
    __metadata("design:paramtypes", [typeof (_a = typeof router_1.Router !== "undefined" && router_1.Router) === "function" && _a || Object])
], AppComponent);
exports.AppComponent = AppComponent;
var _a;
//# sourceMappingURL=/Users/druk/Sites/vic-product/src/src/src/app/app.component.js.map

/***/ })

},[360]);
//# sourceMappingURL=main.bundle.js.map