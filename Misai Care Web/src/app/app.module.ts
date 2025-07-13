import { NgModule, CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { AppRoutingModule } from './app-routing.module';
import { FormsModule } from '@angular/forms';
import { HttpClientModule } from '@angular/common/http';
import { ToastrModule } from 'ngx-toastr';
import { SweetAlert2Module } from '@sweetalert2/ngx-sweetalert2';
import { AppComponent } from './app.component';
import { LoginComponent } from './login/login.component';
import { LeafletModule } from '@asymmetrik/ngx-leaflet';
import { NgChartsModule } from 'ng2-charts';
import { ReactiveFormsModule } from '@angular/forms';
import { GoogleMapsModule } from '@angular/google-maps';
import { NgxPaginationModule } from 'ngx-pagination';
import { LoadingSpinnerComponent } from './shared/loading-spinner/loading-spinner.component';
import { SharedModule } from './shared/shared.module';
import { HospitalDashboardComponent } from './hospital-panel/hospital-dashboard/hospital-dashboard.component';
import { HospitalSidenavComponent } from './hospital-panel/hospital-sidenav/hospital-sidenav.component';
import { PreAuthComponent } from './hospital-panel/pre-auth/pre-auth.component';
import { ZXingScannerModule } from '@zxing/ngx-scanner';
import { PreAuthRequestsComponent } from './hospital-panel/pre-auth-requests/pre-auth-requests.component';
import { ClaimsStatusComponent } from './hospital-panel/claims-status/claims-status.component';
import { TreatmentSubmissionComponent } from './hospital-panel/treatment-submission/treatment-submission.component';
import { TreatmentRecordsComponent } from './hospital-panel/treatment-records/treatment-records.component';
import { PolicyListComponent } from './insurance-panel/policy-list/policy-list.component';
import { PolicyFormComponent } from './insurance-panel/policy-form/policy-form.component';
import { ClaimDetailComponent } from './insurance-panel/claim-detail/claim-detail.component';
import { ClaimsInboxComponent } from './insurance-panel/claims-inbox/claims-inbox.component';
import { InsLoginComponent } from './ins-login/ins-login.component';
import { InsuranceSidenavComponent } from './insurance-panel/insurance-sidenav/insurance-sidenav.component';
import { InsuranceDashboardComponent } from './insurance-panel/insurance-dashboard/insurance-dashboard.component';

@NgModule({
  declarations: [
    AppComponent,
    LoginComponent,
    HospitalDashboardComponent,
    HospitalSidenavComponent,
    PreAuthComponent,
    PreAuthRequestsComponent,
    ClaimsStatusComponent,
    TreatmentSubmissionComponent,
    TreatmentRecordsComponent,
    PolicyListComponent,
    PolicyFormComponent,
    ClaimDetailComponent,
    ClaimsInboxComponent,
    InsLoginComponent,
    InsuranceSidenavComponent,
    InsuranceDashboardComponent
],
  imports: [
    BrowserModule,
    NgChartsModule,
    BrowserAnimationsModule,
    AppRoutingModule,
    FormsModule,
    GoogleMapsModule,
    HttpClientModule,
    NgxPaginationModule,
    ToastrModule.forRoot({
      preventDuplicates: true,
    }),
    SweetAlert2Module.forRoot(),
    LeafletModule,
    ReactiveFormsModule,
    SharedModule,
    ZXingScannerModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
