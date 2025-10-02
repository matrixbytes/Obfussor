import { Component } from "@angular/core";
import { RouterOutlet } from "@angular/router";
import { LayoutComponent } from "./components/layout/layout.component";

@Component({
  selector: "app-root",
  standalone: true,
  imports: [RouterOutlet, LayoutComponent],
  templateUrl: "./app.component.html",
  styleUrl: "./app.component.css",
})
export class AppComponent {
  title = "Obfussor";
}
