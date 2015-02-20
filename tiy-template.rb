VERSION = 'v1.9.1'
def get(prompt)
  yes?(prompt + ' (y/n) >')
end


gem 'hirb'
gem 'kaminari'

#heroku gems
gem 'puma'
gem 'rails_12factor'

#Devise
if get(set_color 'Would you like to use Devise and Figaro?',:magenta)
  gem 'figaro'
  gem 'devise'
  after_bundle do
    puts(set_color 'Installing Figaro', :blue, :bold )
    run('figaro install')

    puts(set_color 'Installing Devise', :blue, :bold )
    generate('devise:install')

    puts(set_color 'Installing Devise Views', :blue, :bold )
    generate('devise:views')
  end

  if get(set_color 'Would you like to use CanCanCan or Pundit?',:magenta)
    if yes?('Use CanCanCan?')
      gem 'cancancan', '~> 1.10'
    else
      gem 'pundit'
    end
  end
end

#Paperclip
if get(set_color 'Would you like to use Paperclip?', :magenta)
  gem 'paperclip', '~> 4.2'
  gem 'aws-sdk', '< 2.0'
  after_bundle do

    puts(set_color 'Injecting Paperclip into Application.yml', :blue, :bold)
    inject_into_file "config/application.yml", after: "#   stripe_publishable_key: pk_live_9lcthxpSIHbGwmdO941O1XVU\n" do
      <<-CODE
      development:
        AWS_BUCKET: '~BUCKET_NAME~'
        AWS_ACCESS_KEY_ID: ~AWS_ACCESS_KEY_ID~
        AWS_SECRET_ACCESS_KEY: ~AWS_SECRET_ACCESS_KEY~

      production:
        AWS_BUCKET: '~BUCKET_NAME~'
        AWS_ACCESS_KEY_ID: ~AWS_ACCESS_KEY_ID~
        AWS_SECRET_ACCESS_KEY: ~AWS_SECRET_ACCESS_KEY~
      CODE
    end

    puts(set_color 'Creating aws.yml with paperclip', :blue, :bold )
    file 'config/aws.yml', <<-CODE
  development:
    access_key_id: Figaro.env.aws_key
    secret_access_key: Figaro.env.aws_secret

  production:
    access_key_id: Figaro.env.aws_key
    secret_access_key: Figaro.env.aws_secret
    CODE

    puts(set_color 'Injecting Paperclip into development.rb', :blue, :bold)
    inject_into_file "config/environments/development.rb", after: "Rails.application.configure do\n" do
      <<-CODE
      config.paperclip_defaults = {
        :storage => 's3',
        :s3_credentials => {
          :bucket => ENV['AWS_BUCKET'],
          :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
          :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
        }
      }
      CODE
    end

    puts(set_color 'Injecting Paperclip into production.rb', :blue, :bold )
    inject_into_file "config/environments/production.rb", after: "Rails.application.configure do\n" do
      <<-CODE
      config.paperclip_defaults = {
        :storage => 's3',
        :s3_credentials => {
          :bucket => ENV['AWS_BUCKET'],
          :access_key_id => ENV['AWS_ACCESS_KEY_ID'],
          :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
        }
      }
      CODE
    end
  end
end

#Active Admin
  if get(set_color 'Would you like to use ActiveAdmin?', :magenta)
    gem 'activeadmin', github: 'activeadmin'
    after_bundle do
      puts(set_color 'Installing Active Admin', :blue, :bold)
      generate('active_admin:install')
    end
  end


#Procfile
puts(set_color 'Creating Procfile', :blue, :bold )
file 'Procfile',<<-CODE
  web: bundle exec puma -t 5:5 -p ${PORT:-3000} -e ${RACK_ENV:-development}
CODE

#PDF_Generators
  if get(set_color 'Would you like to use PDFkit?', :magenta )
    gem 'pdfkit'
    gem 'wkhtmltopdf-binary'
    after_bundle do
      inject_into_file "config/application.rb", after: "require File.expand_path('../boot', __FILE__)\n" do
        <<-CODE
        require 'pdfkit'
        CODE
      end

      inject_into_file "config/application.rb", after: "class Application < Rails::Application\n" do 
        <<-CODE
        config.middleware.use PDFKit::Middleware
        CODE
      end

    end
  end

#Non production gems
gem_group :test, :development do
  gem 'faker'
  gem 'quiet_assets'
  gem 'rspec'
  gem 'rspec-rails'
  gem 'simplecov'

  if get(set_color 'Would you like to use the better errors gem?', :magenta)
    gem 'better_errors'
    gem 'binding_of_caller'
  end
end

#Bootstrap or Bourbon?
if get(set_color 'Would you like to use either Bootstrap or Bourbon?', :magenta)
  if yes?('Use Bootstrap?')
    gem 'bootstrap-sass'

      if get(set_color 'Would you like to use Simple Form?', :magenta)
        gem 'simple_form'
        generate('simple_form:install --bootstrap')
      end

    puts(set_color 'Creating application.scss', :blue, :bold)

    file 'app/assets/stylesheets/application.scss', <<-CODE
    @import 'bootstrap-sprockets';
    @import 'bootstrap';
    CODE

    puts(set_color 'Linking to bootstrap files', :blue, :bold)

    run('rm app/assets/stylesheets/application.css')

    puts(set_color 'Removing old application.css file', :blue, :bold)

    puts(set_color 'Removing old application.js file', :blue, :bold)

    run('rm app/assets/javascripts/application.js')

    puts(set_color 'Creating application.js', :blue, :bold)

    file 'app/assets/javascripts/application.js', <<-CODE
    //= require jquery
    //= require bootstrap-sprockets
    //= require jquery_ujs
    //= require turbolinks
    //= require_tree .
    CODE

    puts(set_color 'Adding bootstrap-sprockets to require', :blue, :bold)

  else

    gem 'bourbon'
    gem 'neat'
    gem 'bitters'

    if get(set_color 'Would you like to use Simple Form?', :magenta)
      gem 'simple_form'
      generate('simple_form:install')
    end

    puts(set_color 'Creating application.scss', :blue, :bold)

    file 'app/assets/stylesheets/application.scss', <<-CODE
    @import 'bourbon';
    @import 'base/base';
    @import 'neat';
    CODE

    puts(set_color 'Removing old application.css', :blue, :bold)

    run('rm app/assets/stylesheets/application.css')

    puts(set_color 'Installing Bitters library', :blue, :bold )

    inside('app/assets/stylesheets') do
      run('bitters install')
    end

    puts(set_color 'Removing old _base.scss', :blue, :bold )

    run('rm app/assets/stylesheets/base/_base.scss')

    puts(set_color 'Creating _base.scss', :blue, :bold )

    file 'app/assets/stylesheets/base/_base.scss', <<-CODE
    @import "variables";
    @import "grid-settings";
    @import "buttons";
    @import "forms";
    @import "lists";
    @import "tables";
    @import "typography";
    CODE
  end
end

#Bundle
after_bundle do
  if get(set_color 'Would you like to create a new git repo and add everything to it?', :magenta)
    git :init
    git add: '--all'
    git commit: "-a -m 'Initial Commit [Generated by TIY Rails Template (#{VERSION})]'"

    if get(set_color 'Would you like to push your git repo to github?', :magenta)
      run('hub create')
      git push: '-u origin master'
      if get(set_color 'Would you like to open your newly created repo on github?', :magenta)
        remote = `git remote -v`
        unless remote.empty?
          url_pieces = remote.scan(/github\.com:(.*)\.git/)
          url = "https://github.com/#{url_pieces.first.first}"
          run("open #{url}")
        end
      end
    end
  end


  puts(set_color 'Stopping Spring', :blue, :bold )
  run('spring stop')

  puts(set_color 'Installing Rspec', :blue, :bold )
  generate('rspec:install')

  puts(set_color'Injecting Simplecov', :blue, :bold )
  inject_into_file "spec/spec_helper.rb", after: "# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration\n" do
    <<-CODE
    require 'simplecov'
    SimpleCov.start
    CODE
  end

  puts(set_color'Running `rake db:test:prepare`',:blue,:bold)
  run('rake db:test:prepare')

#Heroku
  if get(set_color 'Would you like to create a new Heroku repo?', :magenta )
      run('heroku create')

    if get(set_color 'Would you like to push your repo to Heroku', :magenta )
        git push: 'heroku master'
        run('heroku run rake db:migrate')
    end

  end


  rake('db:create') if get(set_color 'Would you like to create your db with `rake db:create`', :magenta)
  yes?(set_color 'Remember to declare your ruby version in your gem file.', :red,  :bold)
  yes?(set_color 'If using cancancan, you need to run the `rails g cancan:ability`command.', :red, :bold)
  yes?(set_color 'If using pundit, you need to put `include Pundit` in your ApplicationController.',:red, :bold)
  yes?(set_color 'You need to run the command `figaro heroku:set -e production`, when using heroku.', :red, :bold)
  yes?(set_color 'The devise gem is installed, but you still need to run `rails generate devise MODEL.', :red, :bold)
  yes?(set_color 'I installed most of paperclip, you still need to add `has_attached_file` to your model', :red, :bold)
  yes?(set_color 'Complete! Your new rails app is finished and ready to go!', :red, :bold)
end

