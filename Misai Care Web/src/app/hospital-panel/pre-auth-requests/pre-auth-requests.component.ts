import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';

@Component({
  selector: 'app-pre-auth-requests',
  standalone: false,
  templateUrl: './pre-auth-requests.component.html',
  styleUrls: ['./pre-auth-requests.component.css']
})
export class PreAuthRequestsComponent implements OnInit {

  Math = Math;

  statusTabs = [
    { name: 'All', icon: 'fa-list-ul' },
    { name: 'Pending', icon: 'fa-hourglass-half' },
    { name: 'Approved', icon: 'fa-check-circle' },
    { name: 'Rejected', icon: 'fa-times-circle' }
  ];
  currentTab: string = 'All';

  allRequests = [
    { 
      id: 1, 
      patientName: 'Ramesh Kumar', 
      diagnosis: 'Heatstroke', 
      date: '2025-07-11', 
      cost: 22000, 
      status: 'Pending',
      avatar: 'RK',
      bgColor: '#FF9F43'
    },
    { 
      id: 2, 
      patientName: 'Sita Devi', 
      diagnosis: 'Fracture', 
      date: '2025-07-10', 
      cost: 35000, 
      status: 'Approved',
      avatar: 'SD',
      bgColor: '#28C76F'
    },
    { 
      id: 3, 
      patientName: 'Mohan Lal', 
      diagnosis: 'Diabetes Management', 
      date: '2025-07-09', 
      cost: 18000, 
      status: 'Rejected',
      avatar: 'ML',
      bgColor: '#EA5455'
    },
    { 
      id: 4, 
      patientName: 'Priya Sharma', 
      diagnosis: 'Pneumonia', 
      date: '2025-07-08', 
      cost: 27000, 
      status: 'Approved',
      avatar: 'PS',
      bgColor: '#00CFE8'
    },
    { 
      id: 5, 
      patientName: 'John Das', 
      diagnosis: 'Snake Bite', 
      date: '2025-07-07', 
      cost: 15000, 
      status: 'Pending',
      avatar: 'JD',
      bgColor: '#7367F0'
    },
    ...Array.from({ length: 15 }, (_, i) => ({
      id: 6 + i,
      patientName: `Test Patient ${i + 1}`,
      diagnosis: ['General Checkup', 'Fever', 'Allergy', 'Injury', 'Follow-up'][i % 5],
      date: '2025-07-05',
      cost: 12000 + i * 500,
      status: ['Pending', 'Approved', 'Rejected'][i % 3],
      avatar: `TP${i + 1}`,
      bgColor: ['#FF9F43', '#28C76F', '#EA5455', '#00CFE8', '#7367F0'][i % 5]
    }))
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
      const matchesSearch = req.patientName.toLowerCase().includes(this.searchQuery.toLowerCase()) || 
                           req.diagnosis.toLowerCase().includes(this.searchQuery.toLowerCase());
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

  viewRequest(id: number): void {
    this.router.navigate(['/hospital/pre-auth', id]);
  }

  getStatusClass(status: string): string {
    switch(status) {
      case 'Pending': return 'bg-warning-light text-warning';
      case 'Approved': return 'bg-success-light text-success';
      case 'Rejected': return 'bg-danger-light text-danger';
      default: return 'bg-secondary-light text-secondary';
    }
  }
}