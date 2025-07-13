import { Component } from '@angular/core';
import { ethers } from 'ethers';
import { Router } from '@angular/router';

@Component({
  selector: 'app-ins-login',
  standalone: false,
  templateUrl: './ins-login.component.html',
  styleUrl: './ins-login.component.css'
})
export class InsLoginComponent {
  mobileNumber = '';
  otp = '';
  otpSent = false;
  otpVerified = false;
  did = '';

  readonly staticMobile = '6382183924';
  readonly staticOTP = '123456';

  constructor(private router: Router) {}

  sendOTP() {
    if (this.mobileNumber === this.staticMobile) {
      this.otpSent = true;
    } else {
      alert('Access only allowed for the configured mobile number.');
    }
  }

  verifyOTP() {
    if (this.mobileNumber === this.staticMobile && this.otp === this.staticOTP) {
      this.otpVerified = true;
    } else {
      alert('Invalid OTP.');
    }
  }

  async connectMetaMask() {
    try {
      if (!(window as any).ethereum) {
        alert('MetaMask is not installed.');
        return;
      }

      const provider = new ethers.BrowserProvider((window as any).ethereum);
      await provider.send("eth_requestAccounts", []);
      const signer = await provider.getSigner();
      const address = await signer.getAddress();

      debugger;

      this.did = `did:ethr:${address}`;
      localStorage.setItem('user_did', this.did);
      this.goToDashboard('insurance');
    } catch (err) {
      console.error(err);
      alert('Failed to connect with MetaMask');
    }
  }

  goToDashboard(project: string) {
    localStorage.setItem('selectedProject', project.toLowerCase());
    this.router.navigate(['/insurance-dashboard']);
  }
}
