import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';

@Component({
  selector: 'app-claims-inbox',
  standalone: false,
  templateUrl: './claims-inbox.component.html',
  styleUrls: ['./claims-inbox.component.css']
})
export class ClaimsInboxComponent implements OnInit {
  statusTabs: string[] = ['All', 'Submitted', 'Approved', 'Paid', 'Disputed'];
  currentTab: string = 'All';
  tabCounts: {[key: string]: number} = {};

  allClaims = [
    { id: 'CLM001', patient: 'Ramesh Kumar', hospital: 'Apollo', amount: 22000, status: 'Submitted', date: '2025-07-12' },
    { id: 'CLM002', patient: 'Sita Devi', hospital: 'CMC', amount: 18000, status: 'Approved', date: '2025-07-11' },
    { id: 'CLM003', patient: 'Mohan Lal', hospital: 'AIIMS', amount: 35000, status: 'Paid', date: '2025-07-10' },
    { id: 'CLM004', patient: 'Priya Sharma', hospital: 'Ganga Hospital', amount: 27000, status: 'Disputed', date: '2025-07-09' }
  ];

  filteredClaims = [...this.allClaims];

  constructor(private router: Router) {}

  ngOnInit(): void {
    this.calculateTabCounts();
    this.setFilter(this.currentTab);
  }

  calculateTabCounts(): void {
    this.tabCounts['All'] = this.allClaims.length;
    this.statusTabs.filter(t => t !== 'All').forEach(tab => {
      this.tabCounts[tab] = this.allClaims.filter(c => c.status === tab).length;
    });
  }

  setFilter(status: string): void {
    this.currentTab = status;
    this.filteredClaims = status === 'All'
      ? [...this.allClaims]
      : this.allClaims.filter(claim => claim.status === status);
  }

  viewClaim(claimId: string): void {
    this.router.navigate(['/claim-detail']);
  }
}