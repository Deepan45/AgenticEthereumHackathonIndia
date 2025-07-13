import { Component, OnInit } from '@angular/core';
import { Router } from '@angular/router';

@Component({
  selector: 'app-treatment-records',
  standalone: false,
  templateUrl: './treatment-records.component.html',
  styleUrls: ['./treatment-records.component.css']
})
export class TreatmentRecordsComponent implements OnInit {

  Math = Math;

  allRequests = [
    { 
      patient: 'Ramesh Kumar',
      diagnosis: 'Heatstroke',
      date: '2025-07-11',
      vcHash: '0xabc1234567890def1234567890abcdef12345678',
      status: 'Verified',
      vcUrl: '/assets/sample-vcs/record1.json'
    },
    { 
      patient: 'Sita Devi',
      diagnosis: 'Fracture',
      date: '2025-07-10',
      vcHash: '0xdef9876543210abc9876543210abcdef98765432',
      status: 'Pending',
      vcUrl: '/assets/sample-vcs/record2.json'
    },
  ];

  filteredRequests: any[] = [];
  paginatedRequests: any[] = [];

  pageSize = 8;
  currentPage = 1;
  totalPages = 1;
  searchQuery = '';

  constructor(private router: Router) {}

  ngOnInit(): void {
    this.setFilter();
  }

  setFilter(): void {
    this.currentPage = 1;
    this.applyFilters();
  }

  applyFilters(): void {
    this.filteredRequests = this.allRequests.filter(req => {
      const matchesSearch = req.patient.toLowerCase().includes(this.searchQuery.toLowerCase()) || 
                           req.diagnosis.toLowerCase().includes(this.searchQuery.toLowerCase());
      return matchesSearch;
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
