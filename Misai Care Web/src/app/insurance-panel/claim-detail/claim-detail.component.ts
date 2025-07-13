// src/app/insurance-panel/claims/claim-detail.component.ts
import { Component } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';

@Component({
  selector: 'app-claim-detail',
  standalone: false,
  templateUrl: './claim-detail.component.html',
  styleUrls: ['./claim-detail.component.css']
})
export class ClaimDetailComponent {
  claimId: string = '';
  vcData: any;
  gptSummary: string = '';
  zkVerified: boolean = true;
  showRawJson: boolean = false;

  constructor(private route: ActivatedRoute, public router: Router) {}

  ngOnInit(): void {
    this.claimId = this.route.snapshot.paramMap.get('id') || 'Unknown';

    // Dummy VC data
    this.vcData = {
      id: 'VC123456789',
      patient: 'Ramesh Kumar',
      diagnosis: 'Heatstroke',
      treatment: ['IV fluids', 'Rest', 'CBC'],
      amount: '₹22,000',
      hospital: 'Apollo Hospital',
      issuedAt: '2025-07-11',
      doctor: 'Dr. Anjali Patel',
      policyNo: 'POL2025001'
    };

    this.gptSummary =
      '✅ The treatment aligns with submitted diagnosis. No fraud patterns detected. Patient ABHA verified. Claim looks valid.';

    this.zkVerified = true;
  }

  approveClaim(): void {
    this.showToast('success', 'Claim approved successfully');
    setTimeout(() => this.router.navigate(['/insurance/claims']), 1500);
  }

  rejectClaim(): void {
    this.showToast('error', 'Claim rejected');
  }

  flagForDAO(): void {
    this.showToast('warning', 'Claim flagged for DAO voting');
  }

  toggleJsonView(): void {
    this.showRawJson = !this.showRawJson;
  }

  private showToast(type: string, message: string): void {
    // In a real app, you would use a toast service
    alert(`${type === 'success' ? '✅' : type === 'error' ? '❌' : '🚩'} ${message}`);
  }
}