import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-header',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './header.component.html',
  styleUrl: './header.component.css',
})
export class HeaderComponent {
  @Input() isCollapsed = false;
  title = 'Obfussor';

  minimizeWindow() {
    // Tauri window minimize functionality
    if (typeof window !== 'undefined' && (window as any).__TAURI__) {
      import('@tauri-apps/api/window').then(({ getCurrentWindow }) => {
        getCurrentWindow().minimize();
      });
    }
  }

  maximizeWindow() {
    // Tauri window maximize functionality
    if (typeof window !== 'undefined' && (window as any).__TAURI__) {
      import('@tauri-apps/api/window').then(({ getCurrentWindow }) => {
        getCurrentWindow().toggleMaximize();
      });
    }
  }

  closeWindow() {
    // Tauri window close functionality
    if (typeof window !== 'undefined' && (window as any).__TAURI__) {
      import('@tauri-apps/api/window').then(({ getCurrentWindow }) => {
        getCurrentWindow().close();
      });
    }
  }
}
