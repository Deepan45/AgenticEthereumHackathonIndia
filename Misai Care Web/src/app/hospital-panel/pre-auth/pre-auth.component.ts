import { Component, ViewChild, OnDestroy } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { ZXingScannerComponent } from '@zxing/ngx-scanner';
import { BarcodeFormat } from '@zxing/library';
import { BrowserQRCodeReader } from '@zxing/browser';

declare var bootstrap: any;

@Component({
  selector: 'app-pre-auth',
  templateUrl: './pre-auth.component.html',
  standalone: false,
  styleUrls: ['./pre-auth.component.css']
})
export class PreAuthComponent implements OnDestroy {
  @ViewChild('scanner') scanner?: ZXingScannerComponent;

  diagnosis: string = '';
  estimatedCost: number | null = null;
  suggestedTreatment: string = '';
  qrInput: string = '';
  isScannerActive: boolean = false;

  patientName: string = '';
  policyNumber: string = '';
  abhaId: string = '';

  allowedFormats = [BarcodeFormat.QR_CODE];
  qrReader = new BrowserQRCodeReader();

  qrCodeResult: any = {};

  modalInstance: any;

  constructor(private http: HttpClient) {}

  openScanModal(): void {
    this.isScannerActive = true;
    setTimeout(() => {
      // const modalElement = document.getElementById('scanModal');
      // if (modalElement) {
      //   const modal = new bootstrap.Modal(modalElement, { backdrop: 'static' });
      //   modal.show();
      // }
      const modalElement = document.getElementById('scanModal');
      if (modalElement) {
        this.modalInstance = new bootstrap.Modal(modalElement, { backdrop: 'static' });
        this.modalInstance.show();
      }
    }, 100);
  }

  handleQrScan(data: string): void {
    this.qrInput = data;
    this.parseQrData(data);
    this.closeScanModal();
  }

  async onQrImageUpload(event: Event): Promise<void> {
    const input = event.target as HTMLInputElement;
    if (!input.files || input.files.length === 0) return;

    const file = input.files[0];
    const reader = new FileReader();

    reader.onload = async () => {
      const imageDataUrl = reader.result as string;

      try {
        const result = await this.qrReader.decodeFromImageUrl(imageDataUrl);
        const qrText = result?.getText(); // ✅ Correct way
        console.log('QR Result:', qrText);

        this.parseQrData(qrText);
        this.closeScanModal();
      } catch (err) {
        console.error('QR decoding error:', err);
      }
    };

    reader.readAsDataURL(file);
  }

  parseQrData(data: string): void {
    try {
      const parsed = JSON.parse(data);
      console.log('Parsed QR Data:', parsed);

      this.patientName = parsed?.PatientName || '';
      this.abhaId = parsed?.abhaId || '';
      this.qrInput = parsed?.did || data;
      this.policyNumber = parsed?.policyNumber || '';

    } catch {
      console.warn('QR data is not JSON, using raw value');
      console.log('Raw QR data:', data);
      this.qrInput = data;
    }
  }

  closeScanModal(): void {
    if (this.modalInstance) {
      this.modalInstance.hide();

      const modalElement = document.getElementById('scanModal');
      if (modalElement) {
        modalElement.addEventListener(
          'hidden.bs.modal',
          () => {
            this.isScannerActive = false;

            const video = modalElement.querySelector('video') as HTMLVideoElement;
            if (video?.srcObject) {
              const stream = video.srcObject as MediaStream;
              stream.getTracks().forEach(track => track.stop());
              video.srcObject = null;
            }
          },
          { once: true }
        );
      }
    }
  }

  submitPreAuth(): void {
    if (
      !this.patientName?.trim() ||
      !this.abhaId?.trim() ||
      !this.diagnosis?.trim() ||
      !this.suggestedTreatment?.trim() ||
      this.estimatedCost == null ||
      !this.policyNumber?.trim()
    ) {
      console.error('All fields are required to submit the pre-auth request.');
      alert('Please fill in all required fields before submitting.');
      return;
    }

    const today = new Date().toISOString().split('T')[0];
    const payload = {
      abhaId: this.abhaId,
      payload: {
        patientName: this.patientName,
        procedure: this.suggestedTreatment,
        diagnosis: this.diagnosis,
        requestedAmount: this.estimatedCost,
        dateOfAdmission: today,
        insurancePolicy: this.policyNumber
      }
    }

    this.http.post('http://192.168.8.135:4000/api/pre-auth', payload).subscribe({
      next: () => {
        this.patientName = '';
        this.abhaId = '';
        this.diagnosis = '';
        this.estimatedCost = null;
        this.suggestedTreatment = '';
        this.policyNumber = '';

        console.log('Pre-Authorization submitted successfully!');
      },
      error: (err) => {
        console.error('Error submitting pre-auth request:', err);
      }
    });
  }

  ngOnDestroy(): void {
    this.closeScanModal();
  }
}
