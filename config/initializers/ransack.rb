# Configure Ransack search attributes for Admin namespace

Ransack.configure do |config|
  # Enable searching on associations by default
  config.search_key = :q

  # Configure sanitization
  config.sanitize_custom_scope_booleans = true
end
