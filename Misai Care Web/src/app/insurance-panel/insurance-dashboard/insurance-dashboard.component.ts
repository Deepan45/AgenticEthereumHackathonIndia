import { Component } from '@angular/core';

@Component({
  selector: 'app-insurance-dashboard',
  standalone: false,
  templateUrl: './insurance-dashboard.component.html',
  styleUrls: ['./insurance-dashboard.component.css']
})
export class InsuranceDashboardComponent {
  // Dashboard stats
  totalPolicies = 1242;
  activeClaims = 87;
  disputedClaims = 12;
  pendingApprovals = 23;
  
  // Recent activities
  recentActivities = [
    { type: 'New Policy', client: 'John Smith', time: '10 mins ago', status: 'completed' },
    { type: 'Claim Filed', client: 'Sarah Johnson', time: '25 mins ago', status: 'pending' },
    { type: 'Dispute Resolved', client: 'Michael Brown', time: '1 hour ago', status: 'completed' },
    { type: 'Policy Renewal', client: 'Emily Davis', time: '2 hours ago', status: 'completed' }
  ];

  // Performance metrics
  claimApprovalRate = 92;
  customerSatisfaction = 88;
  resolutionTime = 2.5; // days

  constructor() {}

  ngOnInit(): void {
    // API calls would go here
  }

  getStatusClass(status: string): string {
    return status === 'completed' ? 'text-success' : 'text-warning';
  }
}