source 'https://rubygems.org'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2.11'
# Use SCSS for stylesheets
gem 'sass-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'

gem "nested_form"

#gem 'sidekiq'

# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# this gem hasn't been updated since 2018... it bundles sweet alert 2, but an older version 9.x. I think... when checking
# the sweet alert documentation make sure to look at older versions
gem 'sweetalert2'

gem 'mysql2', '~> 0.5'

gem 'edtf'
gem 'edtf-humanize'

gem 'pundit'

# handle ADS group lookup through LDAP
gem 'ldap_groups_lookup'

#gem 'will_paginate', '~> 3.1.0'
gem 'pagy'

gem 'net-scp'

# gem for connecting through ssh tunnel
gem 'net-ssh'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# jquery UI asset pipeline
gem 'jquery-ui-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'
#
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'

# gem for utilizing the solr server
# gem 'rsolr'
gem 'sunspot_rails'
# progress bar for sunspot rake tasks (like reindexing...)
gem 'progress_bar'

gem 'delayed_job'
gem 'delayed_job_active_record'
gem "daemons"
# Handles background jobs for ingest of Avalon records - based on delayed_job but extended to handle recurring tasks
gem 'delayed_job_recurring'

gem 'rake', '13.0.6'

# dependabot updates
gem "puma", ">= 5.5.1"
gem "rdoc", ">= 6.3.1"
# backported fixes for rack
gem 'rack', '~> 1.6.13', git: 'https://github.com/rails-lts/rack.git', branch: 'lts-1-6-stable'
gem "nokogiri", ">= 1.12.5"
gem "json", ">= 2.3.0"




# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

