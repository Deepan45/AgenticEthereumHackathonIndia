import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';

@Component({
  selector: 'app-claims-status',
  standalone: false,
  templateUrl: './claims-status.component.html',
  styleUrls: ['./claims-status.component.css']
})
export class ClaimsStatusComponent implements OnInit {

  Math = Math;

  statusTabs = [
    { name: 'All', icon: 'fa-list-ul' },
    { name: 'Submitted', icon: 'fa-hourglass-half' },
    { name: 'Approved', icon: 'fa-check-circle' },
    { name: 'Paid', icon: 'fa-check-circle' },
    { name: 'Disputed', icon: 'fa-times-circle' }
  ];
  currentTab: string = 'All';

  allRequests = [
    { 
      id: 'CLM001', 
      patient: 'Ramesh Kumar', 
      status: 'Submitted', 
      amount: 22000, 
      daoFlag: false,
      avatar: 'RK',
      bgColor: '#FF9F43'
    },
    { 
      id: 'CLM002', 
      patient: 'Sita Devi', 
      status: 'Approved', 
      amount: 18000, 
      daoFlag: false,
      avatar: 'SD',
      bgColor: '#28C76F' 
    },
    { 
      id: 'CLM003', 
      patient: 'Mohan Lal', 
      status: 'Paid', 
      amount: 35000, 
      daoFlag: false,
      avatar: 'ML',
      bgColor: '#EA5455' 
    },
    { 
      id: 'CLM004', 
      patient: 'Priya Sharma', 
      status: 'Disputed', 
      amount: 27000, 
      daoFlag: true,
      avatar: 'PS',
      bgColor: '#00CFE8' 
    },
    { 
      id: 'CLM005', 
      patient: 'John Das', 
      status: 'Submitted', 
      amount: 15000, 
      daoFlag: true,
      avatar: 'JD',
      bgColor: '#7367F0'
    }
  ];

  filteredRequests: any[] = [];
  paginatedRequests: any[] = [];

  pageSize = 8;
  currentPage = 1;
  totalPages = 1;
  searchQuery = '';

  constructor(private router: Router) {}

  ngOnInit(): void {
    this.setFilter(this.currentTab);
  }

  setFilter(status: string): void {
    this.currentTab = status;
    this.currentPage = 1;
    this.applyFilters();
  }

  applyFilters(): void {
    this.filteredRequests = this.allRequests.filter(req => {
      const matchesStatus = this.currentTab === 'All' || req.status === this.currentTab;
      const matchesSearch = req.patient.toLowerCase().includes(this.searchQuery.toLowerCase()) || 
                           req.status.toLowerCase().includes(this.searchQuery.toLowerCase());
      return matchesStatus && matchesSearch;
    });

    this.totalPages = Math.ceil(this.filteredRequests.length / this.pageSize);
    this.updatePaginatedData();
  }

  updatePaginatedData(): void {
    const startIndex = (this.currentPage - 1) * this.pageSize;
    const endIndex = startIndex + this.pageSize;
    this.paginatedRequests = this.filteredRequests.slice(startIndex, endIndex);
  }

  goToPage(page: number): void {
    if (page >= 1 && page <= this.totalPages) {
      this.currentPage = page;
      this.updatePaginatedData();
    }
  }

  getStatusClass(status: string): string {
    switch(status) {
      case 'Submitted': return 'bg-warning-light text-warning';
      case 'Approved': return 'bg-success-light text-success';
      case 'Disputed': return 'bg-danger-light text-danger';
      case 'Paid': return 'bg-danger-light text-success';
      default: return 'bg-secondary-light text-secondary';
    }
  }
}
