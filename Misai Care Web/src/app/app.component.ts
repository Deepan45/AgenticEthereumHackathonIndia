import { Component, OnInit } from '@angular/core';
import { Router, NavigationEnd } from '@angular/router';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  standalone: false,
  styleUrl: './app.component.css'
})
export class AppComponent implements OnInit {
  isLoginPage: boolean = false;
  selectedProject: string | null = null;
  isSidebarCollapsed = false;
  
  constructor(private router: Router) { }

  ngOnInit(): void {
  this.router.events.subscribe(event => {
    if (event instanceof NavigationEnd) {
      this.isLoginPage = this.router.url === '/login' || this.router.url === '/ins-login' || this.router.url === '/selection';
      this.selectedProject = localStorage.getItem('selectedProject');

      setTimeout(() => {
        window.dispatchEvent(new Event('resize'));
      }, 100);
    }
  });
}

}

