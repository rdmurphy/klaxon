source "https://rubygems.org"
ruby "3.2.10"

gem "rails", "~> 7.1.0"
gem "pg", "~> 1.6"
gem "sprockets-rails"
gem "dartsass-rails", "~> 0.5.1"
gem "terser", "~> 1.2"

gem "dotenv"
gem "jquery-rails"
gem "bootsnap", require: false

gem "puma", "~> 7.2"

gem "simple_form", "~> 5.4"

gem "jwt"
gem "premailer-rails"
gem "httparty"

gem "diffy"
gem "kramdown"

gem "aws-sdk-sqs", "~> 1.111"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem "rspec-rails"
  gem "guard-rspec", require: false
  gem "factory_bot_rails", "~> 6.5"
  gem "database_cleaner"

  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem "bundler-audit", require: false

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false
end

group :test do
  gem "webmock"
  gem "rails-controller-testing"
  gem "rspec-github", require: false
end

group :development do
  gem "dockerfile-rails", ">= 1.2"
  gem "letter_opener"
  gem "web-console"
end
