import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { LoginComponent } from './login/login.component';
import { AuthGuard } from '../services/auth.guard';
import { HospitalDashboardComponent } from './hospital-panel/hospital-dashboard/hospital-dashboard.component';
import { PreAuthComponent } from './hospital-panel/pre-auth/pre-auth.component';
import { PreAuthRequestsComponent } from './hospital-panel/pre-auth-requests/pre-auth-requests.component';
import { ClaimsStatusComponent } from './hospital-panel/claims-status/claims-status.component';
import { TreatmentSubmissionComponent } from './hospital-panel/treatment-submission/treatment-submission.component';
import { TreatmentRecordsComponent } from './hospital-panel/treatment-records/treatment-records.component';
import { PolicyFormComponent } from './insurance-panel/policy-form/policy-form.component';
import { PolicyListComponent } from './insurance-panel/policy-list/policy-list.component';
import { ClaimDetailComponent } from './insurance-panel/claim-detail/claim-detail.component';
import { ClaimsInboxComponent } from './insurance-panel/claims-inbox/claims-inbox.component';
import { InsuranceDashboardComponent } from './insurance-panel/insurance-dashboard/insurance-dashboard.component';
import { InsLoginComponent } from './ins-login/ins-login.component';

const routes: Routes = [
  { path: 'login', component: LoginComponent },
  { path: 'ins-login', component: InsLoginComponent },

  { path: 'hospital-dashboard', component: HospitalDashboardComponent  }, 
  { path: 'pre-auth', component: PreAuthComponent  }, 
  { path: 'pre-auth-requests', component: PreAuthRequestsComponent  }, 
  { path: 'claims-status', component: ClaimsStatusComponent  }, 
  { path: 'add-treatment', component: TreatmentSubmissionComponent  }, 
  { path: 'treatment-records', component: TreatmentRecordsComponent  }, 

  { path: 'policy-form', component: PolicyFormComponent  }, 
  { path: 'policy-list', component: PolicyListComponent  }, 
  { path: 'claim-detail', component: ClaimDetailComponent  }, 
  { path: 'claims', component: ClaimsInboxComponent  }, 
  { path: 'insurance-dashboard', component: InsuranceDashboardComponent  }, 

  { path: '', redirectTo: '/login', pathMatch: 'full' }
];

@NgModule({
  imports: [RouterModule.forRoot(routes, { onSameUrlNavigation: 'reload' })],
  exports: [RouterModule]
})
export class AppRoutingModule { }
