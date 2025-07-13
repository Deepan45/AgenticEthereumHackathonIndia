// src/app/insurance-panel/policy/policy-form.component.ts
import { Component } from '@angular/core';
import { Router } from '@angular/router';

@Component({
  selector: 'app-policy-form',
  standalone: false,
  templateUrl: './policy-form.component.html',
  styleUrls: ['./policy-form.component.css']
})
export class PolicyFormComponent {
  public policy = {
    name: '',
    type: 'Individual',
    premium: null as number | null,
    ageGroup: '',
    coverage: '',
    illnesses: '',
    document: null as File | null
  };

  constructor(public router: Router) {}

  onFileChange(event: Event): void {
    const input = event.target as HTMLInputElement;
    if (input.files && input.files.length > 0) {
      this.policy.document = input.files[0];
    }
  }

  savePolicy(): void {
    console.log('Saving policy:', this.policy);
    alert('Policy saved successfully!');
    this.router.navigate(['/insurance/policy/list']);
  }
}