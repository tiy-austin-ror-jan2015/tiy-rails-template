TIY-Rails-Template-Generator

This Generator adds this list of features to your new rails app.

SQL table view in your console.
gem 'hirb'

Pagination
gem 'kaminari'

Needed for Heroku deployment
gem 'puma'
gem 'rails_12factor'

Image Uploading
gem 'paperclip', '~> 4.2'
gem 'aws-sdk', '< 2.0'


Secret key to ENV
gem 'figaro'

Authentication/Admin
gem 'devise'
gem 'activeadmin', github: 'activeadmin'

PDF Generator
gem 'pdfkit'
gem 'wkhtmltopdf-binary'

Testing Gems
gem 'faker'
gem 'quiet_assets'
gem 'rspec'
gem 'rspec-rails'
gem 'simplecov'

Error Displays
gem 'better_errors'
gem 'binding_of_caller'

Choice of BootStrap or Bourbon

Initializes your GitHub if you have HUB

Creates your Heroku

And finally runs rake db:migrate


