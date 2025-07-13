import { Component, OnInit } from '@angular/core';
import { DatePipe } from '@angular/common';

@Component({
  selector: 'app-hospital-dashboard',
  templateUrl: './hospital-dashboard.component.html',
  styleUrls: ['./hospital-dashboard.component.css'],
  standalone:false,
  providers: [DatePipe]
})
export class HospitalDashboardComponent implements OnInit {
  // Pre-authorization statistics
  preAuthStats = { 
    pending: 6, 
    approved: 15, 
    rejected: 3 
  };

  // Treatment records
  treatmentRecords = 22;
  treatmentTrend = 12; // percentage

  // Claim status
  claimStatus = { 
    submitted: 10, 
    paid: 8, 
    disputed: 2 
  };

  // Revenue data
  revenue = 124500;
  revenueTrend = 8; // percentage

  // Current date
  currentDate = new Date();

  // Notifications
  notifications = [
    { 
      icon: 'fa-check-circle', 
      type: 'success',
      message: 'Claim approved and paid ₹22,000', 
      time: '2 hours ago',
      unread: true
    },
    { 
      icon: 'fa-exclamation-triangle', 
      type: 'warning',
      message: 'Claim #235 flagged for DAO vote', 
      time: '1 day ago',
      unread: true
    },
    { 
      icon: 'fa-cloud-upload-alt', 
      type: 'info',
      message: 'Treatment VC issued for Ramesh', 
      time: '3 days ago',
      unread: false
    },
    { 
      icon: 'fa-check-circle', 
      type: 'success',
      message: 'Pre-authorization approved for patient #4567', 
      time: '5 days ago',
      unread: false
    }
  ];

  // Recent activities
  recentActivities = [
    {
      type: 'success',
      title: 'Claim Processed',
      description: 'Claim #7890 for ₹15,200 was processed successfully',
      time: '2 hours ago',
      action: 'View Details'
    },
    {
      type: 'warning',
      title: 'Authorization Required',
      description: 'Pre-auth request for MRI scan requires additional documentation',
      time: '1 day ago',
      action: 'Upload Docs'
    },
    {
      type: 'info',
      title: 'New Treatment Record',
      description: 'Dr. Sharma added treatment records for patient #3421',
      time: '2 days ago',
      action: 'Review'
    }
  ];

  constructor(private datePipe: DatePipe) {}

  ngOnInit(): void {
    // You could add initialization logic here
    // For example, fetching data from a service
  }

  // Method to refresh dashboard data
  refreshDashboard(): void {
    // In a real app, this would call your backend service
    console.log('Refreshing dashboard data...');
    // You would typically update your component properties here
  }
}