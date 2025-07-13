import { HttpClient } from "@angular/common/http";
import { Injectable } from "@angular/core";
import { Observable } from "rxjs";

@Injectable({ providedIn: 'root' })
export class ApiService {
  constructor(private http: HttpClient) {}

  getProjects(): Observable<any[]> {
    return this.http.get<any[]>('/api/projects');
  }

  getModules(): Observable<any[]> {
    return this.http.get<any[]>('/api/modules');
  }

  getPermissions(): Observable<any[]> {
    return this.http.get<any[]>('/api/permissions');
  }

  saveRole(role: { name: string }): Observable<{ id: number }> {
    return this.http.post<{ id: number }>('/api/roles', role);
  }

  saveRolePermissions(data: Array<{ roleId: number; moduleId: number; permissionId: number }>) {
    return this.http.post('/api/role-permissions', data);
  }
}
