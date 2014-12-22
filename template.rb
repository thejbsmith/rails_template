def source_paths
  Array(super) +
  [File.join(File.expand_path(File.dirname(__FILE__)),'lib')]
end

#############
# Variables #
#############

lib                   = "#{File.dirname(__FILE__)}/lib"
current_dir           = %x{pwd}.strip
current_ruby_version  = %x{rvm list}.match(/^=(?:\*|>)\s+(.*)\s\[/)[1].strip


#########
# Setup #
#########

# Create gemset
run "rvm gemset create #{app_name}"

# Install bundler
run "rvm #{current_ruby_version}@#{app_name} do gem install bundler"

# Create rvm files
create_file ".ruby-version", "#{current_ruby_version.sub('ruby-', '')}"
create_file ".ruby-gemset", "#{app_name}"

# Insert Ruby version into Gemfile
insert_into_file 'Gemfile', "\nruby '#{current_ruby_version.sub('ruby-', '')}'", after: "source 'https://rubygems.org'\n"


############
# Add Gems #
############

gem 'pg'
gem 'simple_form'
gem 'draper'
gem 'unicorn'
gem 'active_model_serializers'
gem 'bootstrap-sass', '~> 3.3.1'

gem_group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'letter_opener_web', '~> 1.2.0'
  gem 'bullet'
  gem 'foreman'
  gem 'rails-erd'
end

gem_group :development, :test do
  gem 'pry-rails'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'shoulda-matchers'
  gem 'shoulda-callback-matchers', '~> 1.0'
end

gem_group :test do
  gem 'database_cleaner'
end

gem_group :production do
  gem 'rails_12factor'
end

# TODO: Ask if authentication and / or authorization will be needed
# gem 'devise'
# gem 'cancan'

# TODO: Ask if uploading will be needed
# gem 'carrierwave' or 'paperclip'


# Remove sqlite3 from Gemfile
gsub_file "Gemfile", /^gem\s+["']sqlite3["'].*$/,''
# Remove Turbolinks from Gemfile
gsub_file "Gemfile", /^gem\s+["']turbolinks["'].*$/,''


##################
# Bundle Install #
##################

# run bundle install with gemset in order to bundle gems into that gemset
run "rvm #{current_ruby_version}@#{app_name} do bundle install"


##############
# Setup Gems #
##############

# Run SimpleForm generator (and initialize it with bootstrap)
generate 'simple_form:install --bootstrap'

# Set up Rspec
remove_dir 'test'
generate 'rspec:install'

# TODO: Add in any additional setup items for gems (e.g. installing devise, etc.)


#######################
# Set Up Environments #
#######################

inside 'config/environments' do
  # Set up staging environment
  copy_file 'production.rb', 'staging.rb'
end

# Add additional items to environment files
['development', 'production'].each do |environment|
  inside 'config/environments' do
    inject_into_file "#{environment}.rb", :before => "end\n" do
      File.read("#{lib}/config/environments/_#{environment}.rb")
    end
  end
end

inside 'config/environments' do
  gsub_file "production.rb", 'config.assets.compile = false', 'config.assets.compile = true'
end

# TODO: Ask if SendGrid should be used (if so, which environments) and add in settings


###########################
# Set Up Additional Items #
###########################

# Create Procfile
copy_file "#{lib}/Procfile", 'Procfile'

# Create Unicorn file
copy_file "#{lib}/config/unicorn.rb", 'config/unicorn.rb'

# TODO: Create .gitignore file


##################
# Clean up files #
##################

['Gemfile', 'config/database.yml', 'config/routes.rb'].each do |file|
  # Remove comments
  gsub_file(file, /^\s*#.*\n/, '')

  # Remove empty lines
  gsub_file(file, /^\n/, '')
end


#########################
# Initialize repository #
#########################

git :init
git add: "."
git commit: %Q{ -m 'Initial commit' }


# Override bundle install normally run after processing template
def run_bundle
  # We don't want to run anything here since we have already run a bundle install with our gemset above
end
