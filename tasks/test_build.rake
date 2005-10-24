desc "Pull latest revision, run unit and functional tests, send email on errors"
task :test_latest_revision => :environment do
  require(File.dirname(__FILE__) + "/../lib/continuos_builder")

  build = ContinousBuilder::Build.new(ENV['RAKE_TASK']  || '')
 
  if build.has_changes? && !build.tests_ok?
    ContinousBuilder::Notifier.deliver_failure(
      build, ENV['NAME'], ENV['EMAIL_TO'], ENV['EMAIL_FROM'] || "'Continuos Builder' <cb@example.com>" 
    )
  end 
end