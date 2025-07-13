import { Component, EventEmitter, OnInit, AfterViewInit, Output } from '@angular/core';
import { Router } from '@angular/router';
import { AuthService } from '../../../services/auth.service'; 
import { HttpClient } from '@angular/common/http';

@Component({
  selector: 'app-insurance-sidenav',
  standalone: false,
  templateUrl: './insurance-sidenav.component.html',
  styleUrl: './insurance-sidenav.component.css'
})
export class InsuranceSidenavComponent implements OnInit, AfterViewInit {
  @Output() toggleSidebar = new EventEmitter<void>();

  userDetails: any;

  constructor(
    private router: Router,
    private authService: AuthService,
    private http: HttpClient,
  ) {}

  ngOnInit(): void {
    this.userDetails = this.authService.getdetails();
  }

  ngAfterViewInit(): void {
    setTimeout(() => {
      window.dispatchEvent(new Event('resize'));
    }, 100);
  }

  logout(): void {
    this.authService.insLogout();
  }

  onToggleSidebar(): void {
    this.toggleSidebar.emit();
  }
}

