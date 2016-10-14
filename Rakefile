require 'rake-jekyll'
require 'yaml'

# most tasks taken from https://github.com/gummesson/jekyll-rake-boilerplate/blob/master/Rakefile
# rake preview

# Set "rake watch" as default task
task :default => :watch

# Load the configuration file
CONFIG = YAML.load_file("_config.yml")

# == Helpers ===================================================================

# Execute a system command
def execute(command)
  system "#{command}"
end

# == Tasks =====================================================================

# rake watch
# rake watch[number]
# rake watch["drafts"]
desc "Serve and watch the site (with post limit or drafts)"
task :watch, :option do |t, args|
  option = args[:option]
  ## Could add --incremental here but it seem to have problems
  ## with subpages and livereload. 
  if option.nil? or option.empty?
    execute("jekyll liveserve --watch")
  else
    if option == "drafts"
      execute("jekyll liveserve --watch --drafts")
    else
      execute("jekyll liveserve --watch --limit_posts #{option}")
    end
  end
end

desc "Launch a preview of the site in the browser"
task :preview do
  port = CONFIG["port"]
  if port.nil? or port.empty?
    port = 4000
  end
  Thread.new do
    puts "Launching browser for preview..."
    sleep 1
    execute("#{open_command} http://localhost:#{port}/")
  end
  Rake::Task[:watch].invoke
end

# == Build web site on Travis-CI ================================================
desc 'Generate site from Travis CI and publish site'
task :travis do

  # if this is a pull request, just error check
  if ENV['TRAVIS_PULL_REQUEST'].to_s.to_i > 0
    puts 'Pull request detected. Executing build only.'
    deploy = false
  elsif ENV['TRAVIS_BRANCH'].to_s.scan(/^master$/).length > 0
    puts 'master branch. Executing build and deploy.'
    deploy = true 
  else
    puts ENV['TRAVIS_BRANCH'].to_s + ' branch is not configured for Travis builds - skipping.'
    deploy = false
  end

  # probably better ways to do this in 'pure' rake
  # but for now executing tasks direclty
  # run build
  system "bundle exec jekyll build"
  
  if deploy
    Rake::Task["deploy"].invoke
  end
  
end

# This task builds the Jekyll site and deploys it to a remote Git repository.
# It's preconfigured to be used with GitHub and Travis CI.
# See http://github.com/jirutka/rake-jekyll for more options.
Rake::Jekyll::GitDeployTask.new(:deploy)  do |t|

end

