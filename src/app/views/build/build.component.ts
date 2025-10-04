import { Component } from '@angular/core';

@Component({
  selector: 'app-build',
  standalone: true,
  imports: [],
  template: `
    <div class="page">
      <h1>Build</h1>
    </div>
  `,
  styles: [
    `
      .page {
        padding: 0;
      }
      .page h1 {
        margin: 0;
        font-size: 2rem;
        font-weight: 600;
        color: #fff;
      }
    `,
  ],
})
export class BuildComponent {}
