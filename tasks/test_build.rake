desc "Pull latest revision, run unit and functional tests, send email on errors"
task :test_latest_revision => :environment do
  require(File.dirname(__FILE__) + "/../lib/continuous_builder")

  build = ContinuousBuilder::Build.new(
    :task_name   => ENV['RAKE_TASK']   || '',
    :env_command => ENV['ENV_COMMAND'] || "/usr/bin/env"
  )
 
  if build.has_changes? && !build.tests_ok?
    ContinuousBuilder::Notifier.deliver_failure(
      build, ENV['NAME'], ENV['EMAIL_TO'], ENV['EMAIL_FROM'] || "'Continuous Builder' <cb@example.com>" 
    )
  end 
end