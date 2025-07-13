import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { environment } from '../environments/environment';
@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private apiUrl = `${environment.authUrl}/Auth/login`;
  private tokenKey = 'authToken';

  constructor(private http: HttpClient, private router: Router) {}

  login(username: string, password: string) {
    return this.http.post(this.apiUrl, { username, password }, { responseType: 'text' });
  }

  storeToken(token: string): void {
    localStorage.setItem(this.tokenKey, token);
    console.log('Stored Token:', token);

    const decodedPayload = this.decodeToken(token);
    if (decodedPayload) {
      console.log('Decoded JWT Payload:', decodedPayload);
      debugger
      const empCode = decodedPayload.empcode; 
      console.log('Extracted Emp Code:', empCode);

      localStorage.setItem('empCode', empCode);
    }
  }

  getEmpCode(): string | null {
    const token = this.getToken();
    if (!token) return null;

    const decodedPayload = this.decodeToken(token);
    return decodedPayload ? decodedPayload.empcode : null; 
  }

  getToken(): string | null {
    return localStorage.getItem(this.tokenKey);
  }

  decodeToken(token: string): any | null {
    try {
      const payload = JSON.parse(atob(token.split('.')[1]));
      console.log("Decoded Token:", payload);
      return payload;
    } catch (error) {
      console.error('Invalid JWT Token:', error);
      return null;
    }
  }

  getdetails() {
    const token = this.getToken();
    if (!token) return null;
    const decodedPayload = this.decodeToken(token);
    return decodedPayload;
  }

  logout(): void {
    localStorage.removeItem(this.tokenKey);
    localStorage.removeItem('selectedProject');
    this.router.navigate(['/login']);
  }

  insLogout(): void {
    localStorage.removeItem(this.tokenKey);
    localStorage.removeItem('selectedProject');
    this.router.navigate(['/ins-login']);
  }

  isAuthenticated(): boolean {
    const token = this.getToken();
    return token != null; 
  }
}
