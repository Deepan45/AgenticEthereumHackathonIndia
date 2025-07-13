// import { Component } from '@angular/core';
// import { ToastrService } from 'ngx-toastr';
// import { AuthService } from '../../services/auth.service';
// import { Router } from '@angular/router';

// @Component({
//   selector: 'app-login',
//   standalone: false,
//   templateUrl: './login.component.html',
//   styleUrl: './login.component.css'
// })
// export class LoginComponent {
//   username: string = '';
//   password: string = '';
//   showPassword: boolean = false;

//   constructor(private authService: AuthService, private toastr: ToastrService, private router: Router) { }

//   onSubmit() {
//     if (!this.username || !this.password) {
//       this.toastr.warning('Please fill in all fields', 'Warning');
//       return;
//     }

//     console.log('Logging in with username:', this.username);

//     this.authService.login(this.username, this.password).subscribe(
//       (res: any) => {
//         debugger;
//         const response = typeof res === 'string' ? JSON.parse(res) : res;
//         this.authService.storeToken(response.token);

//         const storedToken = this.authService.getToken();

//         let decoded;
//         if (storedToken !== null)
//           decoded = this.authService.decodeToken(storedToken);

//         let projects: any[] = [];
//         if (decoded && decoded.projects) {
//           projects = decoded.projects.split(',');
//         }
        
//         if (projects.length > 1){
//           // this.router.navigate(['/selection']);
//           this.goToDashboard(projects[0]);
//         } else if (projects.length == 1) {
//           this.goToDashboard(projects[0]);
//         } else {
//           localStorage.setItem('selectedProject', '');
//           console.warn('Unable to route');
//         }
//       },
//       (error: any) => {
//         console.error('Login failed with error:', error);
//         this.toastr.error('Invalid email or password', 'Error');
//       }
//     );
//   }

//   goToDashboard(project: string) {
//     this.router.navigate(['/hospital-dashboard']);
//     // localStorage.setItem('selectedProject', project.toLowerCase());
//     // switch (project.toLowerCase()) {
//     //   case 'attendance':
//     //     this.router.navigate(['/attendance-dashboard']);
//     //     break;
//     //   case 'hotel':
//     //     this.router.navigate(['/kitchen-dashboard']);
//     //     break;
//     //   default:
//     //     console.warn('Unknown project:', project);
//     // }
//   }
// }


import { Component } from '@angular/core';
import { ethers } from 'ethers';
import { Router } from '@angular/router';

@Component({
  selector: 'app-login',
  standalone: false,
  templateUrl: './login.component.html',
})
export class LoginComponent {
  mobileNumber = '';
  otp = '';
  otpSent = false;
  otpVerified = false;
  did = '';

  readonly staticMobile = '6374820017';
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
      this.goToDashboard('hospital');
    } catch (err) {
      console.error(err);
      alert('Failed to connect with MetaMask');
    }
  }

  goToDashboard(project: string) {
    localStorage.setItem('selectedProject', project.toLowerCase());
    this.router.navigate(['/hospital-dashboard']);
  }
}
