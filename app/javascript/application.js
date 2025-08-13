// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails";
import "controllers";
import "custom/menu";
import "custom/dropdown";
import { createIcons, icons } from "lucide";
document.addEventListener("DOMContentLoaded", () => {
  createIcons({ icons });
});
