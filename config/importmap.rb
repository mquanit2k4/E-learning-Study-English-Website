# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin "lucide", to: "https://cdn.jsdelivr.net/npm/lucide@latest/+esm"
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/custom", under: "custom"
pin "@rails/request.js", to: "https://ga.jspm.io/npm:@rails/request.js@0.0.12/src/index.js"
pin "jquery", to: "https://ga.jspm.io/npm:jquery@3.7.1/dist/jquery.js"
pin "trix"
pin "@rails/actiontext", to: "actiontext.js"
