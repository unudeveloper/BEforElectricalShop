require_relative "test_application"

desc 'Run a command against the local sample application'
task :local do
  test_application = ActiveAdmin::TestApplication.new(
    rails_env: 'development',
    template: 'rails_template_with_data'
  )

  test_application.generate

  # Discard the "local" argument (name of the task)
  argv = ARGV[1..-1]

  if argv.any?
    # If it's a rails command, auto add the rails script
    if %w(generate console server dbconsole g c s runner).include?(argv[0]) || argv[0] =~ /db:/
      argv.unshift('rails')
    end

    command = ['bundle', 'exec', *argv].join(' ')
    gemfile = ENV['BUNDLE_GEMFILE'] || File.expand_path("../Gemfile", __dir__)
    env = { 'BUNDLE_GEMFILE' => gemfile }

    Dir.chdir(test_application.app_dir) do
      Bundler.with_original_env { Kernel.exec(env, command) }
    end
  end
end
