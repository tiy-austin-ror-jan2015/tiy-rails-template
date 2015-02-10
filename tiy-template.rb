VERSION = 'v1.5.0'
def get(prompt)
  yes?(prompt + ' (y/n) >')
end

#heroku gems
gem 'puma'
gem 'rails_12factor'
#

#Figaro
gem 'figaro'

#Devise
gem 'devise'

#Procfile
puts 'Creating Procfile'
file 'Procfile',<<-CODE
  web: bundle exec puma -t 5:5 -p ${PORT:-3000} -e ${RACK_ENV:-development}
CODE

#Non production gems
gem_group :test, :development do
  gem 'faker'

  if get('Would you like to use the better errors gem?')
    gem 'better_errors'
    gem 'binding_of_caller'
  end
end

#Bootstrap or Bourbon?

if get('Would you like to use either Bootstrap or Bourbon?')
  if yes?('Use Bootstrap?')
    gem 'bootstrap-sass'

      if get('Would you like to use Simple Form?')
        gem 'simple_form'
        generate('simple_form:install --bootstrap')
      end

    puts 'Creating application.scss'

    file 'app/assets/stylesheets/application.scss', <<-CODE
    @import 'bootstrap-sprockets';
    @import 'bootstrap';
    CODE

    puts 'Linking to bootstrap files'

    run('rm app/assets/stylesheets/application.css')

    puts 'Removing old application.css file'

    puts 'Removing old application.js file'

    run('rm app/assets/javascripts/application.js')

    puts 'Creating application.js'

    file 'app/assets/javascripts/application.js', <<-CODE
    //= require jquery
    //= require bootstrap-sprockets
    //= require jquery_ujs
    //= require turbolinks
    //= require_tree .
    CODE

    puts 'Adding bootstrap-sprockets to require'

  else

    gem 'bourbon'
    gem 'neat'
    gem 'bitters'

    if get('Would you like to use Simple Form?')
      gem 'simple_form'
      generate('simple_form:install')
    end

    puts 'Creating application.scss'

    file 'app/assets/stylesheets/application.scss', <<-CODE
    @import 'bourbon';
    @import 'base/base';
    @import 'neat';
    CODE

    puts 'Removing old application.css'

    run('rm app/assets/stylesheets/application.css')

    puts 'Installing Bitters library'

    inside('app/assets/stylesheets') do
      run('bitters install')
    end

    puts 'Removing old _base.scss'

    run('rm app/assets/stylesheets/base/_base.scss')

    puts 'Creating _base.scss'

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
  if get('Would you like to create a new git repo and add everything to it?')
    git :init
    git add: '--all'
    git commit: "-a -m 'Initial Commit [Generated by TIY Rails Template (#{VERSION})]'"

    if get('Would you like to push your git repo to github?')
      run('hub create')
      git push: '-u origin master'
      if get('Would you like to open your newly created repo on github?')
        remote = `git remote -v`
        unless remote.empty?
          url_pieces = remote.scan(/github\.com:(.*)\.git/)
          url = "https://github.com/#{url_pieces.first.first}"
          run("open #{url}")
        end
      end
    end
  end

  puts 'Running Devise Generator'
  generate(devise:install)

  puts 'Installing Figaro'
  run('figaro install')

#Heroku
  if get('Would you like to create a new Heroku repo?')
      run('heroku create')

    if get('Would you like to push your repo to Heroku')
        git push: 'heroku master'
        run('heroku run rake db:migrate')
    end

  end


  rake('db:create') if get('Would you like to create your db with `rake db:create`')
  yes?('Remember to declare your ruby version in your gem file.')
  yes?('You need to run the command figaro heroku:set -e production, when using heroku.')
  yes?('Complete! Your new rails app is finished and ready to go!')
end

