// // src/app/insurance-panel/policy/policy-list.component.ts
// import { Component } from '@angular/core';
// import { Router } from '@angular/router';

// @Component({
//   selector: 'app-policy-list',
//   standalone: false,
//   templateUrl: './policy-list.component.html',
//   styleUrls: ['./policy-list.component.css']
// })
// export class PolicyListComponent {
//   policies = [
//     {
//       id: 'POL001',
//       name: 'Health Protect Plus',
//       type: 'Family Floater',
//       premium: 4500,
//       coverage: '₹5 Lakh',
//     },
//     {
//       id: 'POL002',
//       name: 'Critical Illness Plan',
//       type: 'Individual',
//       premium: 7200,
//       coverage: '₹10 Lakh',
//     }
//   ];

//   constructor(private router: Router) {}

//   deletePolicy(id: string): void {
//     this.policies = this.policies.filter(policy => policy.id !== id);
//     alert('Policy deleted!');
//   }
// }


import { Component } from '@angular/core';
import { Router } from '@angular/router';

@Component({
  selector: 'app-policy-list',
  standalone: false,
  templateUrl: './policy-list.component.html',
  styleUrls: ['./policy-list.component.css']
})
export class PolicyListComponent {

  Math = Math;

  allRequests = [
    {
      id: 'POL001',
      name: 'Health Protect Plus',
      type: 'Family Floater',
      premium: 4500,
      coverage: '₹5 Lakh',
    },
    {
      id: 'POL002',
      name: 'Critical Illness Plan',
      type: 'Individual',
      premium: 7200,
      coverage: '₹10 Lakh',
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
    this.setFilter();
  }

  setFilter(): void {
    this.currentPage = 1;
    this.applyFilters();
  }

  applyFilters(): void {
    this.filteredRequests = this.allRequests.filter(req => {
      const matchesSearch = req.name.toLowerCase().includes(this.searchQuery.toLowerCase()) || 
                           req.type.toLowerCase().includes(this.searchQuery.toLowerCase());
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

  deletePolicy(id: string): void {
    this.allRequests = this.allRequests.filter(policy => policy.id !== id);
    this.applyFilters();
  }
}