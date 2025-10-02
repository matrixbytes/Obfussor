import { Component, Output, EventEmitter } from '@angular/core';
import { RouterModule } from '@angular/router';
import { CommonModule } from '@angular/common';

interface MenuItem {
  label: string;
  icon: string;
  route: string;
  active?: boolean;
}

@Component({
  selector: 'app-sidebar',
  standalone: true,
  imports: [RouterModule, CommonModule],
  templateUrl: './sidebar.component.html',
  styleUrl: './sidebar.component.css'
})
export class SidebarComponent {
  @Output() sidebarToggle = new EventEmitter<boolean>();

  menuItems: MenuItem[] = [
    { label: 'Dashboard', icon: '📊', route: '/dashboard' },
    { label: 'Projects', icon: '📁', route: '/projects' },
    { label: 'Obfuscation Settings', icon: '⚙️', route: '/settings' },
    { label: 'Build', icon: '🔨', route: '/build' },
    { label: 'Reports', icon: '📈', route: '/reports' }
  ];

  isCollapsed = false;

  toggleSidebar() {
    this.isCollapsed = !this.isCollapsed;
    this.sidebarToggle.emit(this.isCollapsed);
  }

  setActive(item: MenuItem) {
    this.menuItems.forEach(menuItem => menuItem.active = false);
    item.active = true;
  }
}