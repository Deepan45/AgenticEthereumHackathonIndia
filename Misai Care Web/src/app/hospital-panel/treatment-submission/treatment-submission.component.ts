import { Component, ViewChild, OnDestroy } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { ZXingScannerComponent } from '@zxing/ngx-scanner';
import { BarcodeFormat } from '@zxing/library';
import { BrowserQRCodeReader } from '@zxing/browser';

declare var bootstrap: any;

@Component({
  selector: 'app-treatment-submission',
  standalone: false,
  templateUrl: './treatment-submission.component.html',
  styleUrls: ['./treatment-submission.component.css']
})
export class TreatmentSubmissionComponent implements OnDestroy {
  @ViewChild('scanner') scanner?: ZXingScannerComponent;

  diagnosis: string = '';
  estimatedCost: number | null = null;
  suggestedTreatment: string = '';
  qrInput: string = '';
  isScannerActive: boolean = false;

  patientName: string = 'Ramesh Kumar';

  abhaId: string = '';
  dischargeText: string = '';
  dischargePdf: File | null = null;
  attachments: File[] = [];
  qrReader = new BrowserQRCodeReader();

  allowedFormats = [BarcodeFormat.QR_CODE];

  modalInstance: any;
  modalConfirmationInstance: any;

  constructor(private http: HttpClient) {}

  onDischargePdfUpload(event: any): void {
    const file = event.target.files[0];
    if (file && file.type === 'application/pdf') {
      this.dischargePdf = file;
    }
  }

  onAttachmentUpload(event: any): void {
    this.attachments = Array.from(event.target.files);
  }

  openScanModal(): void {
    this.isScannerActive = true;
    setTimeout(() => {
      const modalElement = document.getElementById('scanModal');
      if (modalElement) {
        this.modalInstance = new bootstrap.Modal(modalElement, { backdrop: 'static' });
        this.modalInstance.show();
      }
    }, 100);
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

      this.patientName = parsed?.patientName || '';
      this.abhaId = parsed?.abhaId || '';
      this.qrInput = parsed?.did || data;

    } catch {
      console.warn('QR data is not JSON, using raw value');
      console.log('Raw QR data:', data);
      this.qrInput = data;
    }
  }


  handleQrScan(result: string): void {
    this.qrInput = result;
    this.closeScanModal();
  }

  submitTreatmentRecord(): void {
  // Basic validation
  if (!this.abhaId) {
    alert('ABHA ID not available. Please upload a valid QR.');
    return;
  }

  if (!this.dischargeText && !this.dischargePdf) {
    alert('Please provide discharge summary text or upload a PDF.');
    return;
  }

  const formData = new FormData();

  formData.append('abhaId', this.abhaId);

  if (this.dischargeText) {
    formData.append('dischargeSummaryText', this.dischargeText);
  }

  if (this.dischargePdf) {
    formData.append('dischargeSummaryFile', this.dischargePdf, this.dischargePdf.name);
  }

  if (this.attachments && this.attachments.length > 0) {
    this.attachments.forEach((file) => {
      formData.append('attachments', file, file.name);
    });
  }

  this.http.post('http://192.168.8.135:4000/api/treatment/submit', formData).subscribe({
    next: () => {
      const modalElement = document.getElementById('confirmationModal');
      if (modalElement) {
        this.modalConfirmationInstance = new bootstrap.Modal(modalElement, { });
        this.modalConfirmationInstance.show();
      }

      this.dischargeText = '';
      this.dischargePdf = null;
      this.attachments = [];
      this.qrInput = '';
      this.abhaId = '';
      this.patientName = '';

      const fileInputs = document.querySelectorAll('input[type="file"]') as NodeListOf<HTMLInputElement>;
      fileInputs.forEach(input => input.value = '');

      this.closeScanModal();
    },
    error: (err) => {
      console.error('Error submitting treatment record:', err);
      alert('An error occurred while submitting the treatment record.');
    }
  });
}

closeConfirmationModal() {
  if (this.modalConfirmationInstance) {
      this.modalConfirmationInstance.hide();

      const modalElement = document.getElementById('confirmationModal');
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



  ngOnDestroy(): void {
    this.closeScanModal();
  }
}

