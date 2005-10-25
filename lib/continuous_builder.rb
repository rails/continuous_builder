module ContinuousBuilder
  class Build
    attr_reader :status, :output, :success, :options
 
    def self.run
      Build.new.run
    end
 
    def initialize(options = {})
      @options = options
    end
 
    def run
      update if @status.nil?    
      make if @success.nil?
    end
 
    def revision
      info['Revision'].to_i
    end
 
    def url
      info['URL']
    end
 
    def commit_message
      `#{options[:env_command]} svn log #{RAILS_ROOT} -rHEAD -v`
    end
 
    def author
      info['Last Changed Author']
    end
 
    def tests_ok?
      run if @success.nil?
      @success == true
    end
 
    def has_changes?
      update if @status.nil?
      @status =~ /[A-Z]\s+[\w\/]+/
    end
 
    private
      def update
        @status = `#{options[:env_command]} svn update #{RAILS_ROOT}`
      end
 
      def info
        @info ||= YAML.load(`#{options[:env_command]} svn info #{RAILS_ROOT}`)
      end
 
      def make
        @output, @success = `cd #{RAILS_ROOT} && RAILS_ENV=test #{options[:env_command]} rake #{options[:task_name]}`, ($?.exitstatus == 0)
      end
  end

  class Notifier < ActionMailer::Base
    def failure(build, application, email_to, email_from, sent_at = Time.now)
      @subject = "[#{application}] Build Failure (##{build.revision})"
      @body    = [ "#{build.author} broke the build!", build.commit_message, build.output ].join("\n\n")
      @recipients, @from, @sent_on = email_to, email_from, sent_at
    end
  end
end