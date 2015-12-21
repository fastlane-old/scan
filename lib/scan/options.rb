require "fastlane_core"
require "credentials_manager"

module Scan
  class Options
    def self.available_options
      containing = Helper.fastlane_enabled? ? './fastlane' : '.'

      [
        FastlaneCore::ConfigItem.new(key: :workspace,
                                     short_option: "-w",
                                     env_name: "SCAN_WORKSPACE",
                                     optional: true,
                                     description: "Path the workspace file",
                                     verify_block: proc do |value|
                                       v = File.expand_path(value.to_s)
                                       raise "Workspace file not found at path '#{v}'".red unless File.exist?(v)
                                       raise "Workspace file invalid".red unless File.directory?(v)
                                       raise "Workspace file is not a workspace, must end with .xcworkspace".red unless v.include?(".xcworkspace")
                                     end),
        FastlaneCore::ConfigItem.new(key: :project,
                                     short_option: "-p",
                                     optional: true,
                                     env_name: "SCAN_PROJECT",
                                     description: "Path the project file",
                                     verify_block: proc do |value|
                                       v = File.expand_path(value.to_s)
                                       raise "Project file not found at path '#{v}'".red unless File.exist?(v)
                                       raise "Project file invalid".red unless File.directory?(v)
                                       raise "Project file is not a project file, must end with .xcodeproj".red unless v.include?(".xcodeproj")
                                     end),
        FastlaneCore::ConfigItem.new(key: :device,
                                     short_option: "-a",
                                     optional: true,
                                     is_string: true,
                                     env_name: "SCAN_DEVICE",
                                     description: "The name of the simulator type you want to run tests on"),
        FastlaneCore::ConfigItem.new(key: :scheme,
                                     short_option: "-s",
                                     optional: true,
                                     env_name: "SCAN_SCHEME",
                                     description: "The project's scheme. Make sure it's marked as `Shared`"),
        FastlaneCore::ConfigItem.new(key: :clean,
                                     short_option: "-c",
                                     env_name: "SCAN_CLEAN",
                                     description: "Should the project be cleaned before building it?",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :code_coverage,
                                     description: "Should generate code coverage (Xcode 7 only)?",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :output_directory,
                                     short_option: "-o",
                                     env_name: "SCAN_OUTPUT_DIRECTORY",
                                     description: "The directory in which all reports will be stored",
                                     default_value: File.join(containing, "test_output")),
        FastlaneCore::ConfigItem.new(key: :output_style,
                                     short_option: "-b",
                                     env_name: "SCAN_OUTPUT_STYLE",
                                     description: "Define how the output should look like (standard, basic or rspec)",
                                     optional: true,
                                     verify_block: proc do |value|
                                       raise "Invalid output_style #{value}".red unless ['standard', 'basic', "rspec"].include?(value)
                                     end),
        FastlaneCore::ConfigItem.new(key: :output_types,
                                     short_option: "-f",
                                     env_name: "SCAN_OUTPUT_TYPES",
                                     description: "Comma seperated list of the output types (e.g. html, junit)",
                                     default_value: "html,junit"),
        FastlaneCore::ConfigItem.new(key: :buildlog_path,
                                     short_option: "-l",
                                     env_name: "SCAN_BUILDLOG_PATH",
                                     description: "The directory were to store the raw log",
                                     default_value: "~/Library/Logs/scan"),
        FastlaneCore::ConfigItem.new(key: :sdk,
                                     short_option: "-k",
                                     env_name: "SCAN_SDK",
                                     description: "The SDK that should be used for building the application",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :open_report,
                                     short_option: "-g",
                                     env_name: "SCAN_OPEN_REPORT",
                                     description: "Don't open the HTML report when tests are completed",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :configuration,
                                     short_option: "-q",
                                     env_name: "SCAN_CONFIGURATION",
                                     description: "The configuration to use when building the app. Defaults to 'Release'",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :destination,
                                     short_option: "-d",
                                     env_name: "SCAN_DESTINATION",
                                     description: "Use only if you're a pro, use the other options instead",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :xcargs,
                                     short_option: "-x",
                                     env_name: "SCAN_XCARGS",
                                     description: "Pass additional arguments to xcodebuild. Be sure to quote the setting names and values e.g. OTHER_LDFLAGS=\"-ObjC -lstdc++\"",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :xcconfig,
                                     short_option: "-y",
                                     env_name: "SCAN_XCCONFIG",
                                     description: "Use an extra XCCONFIG file to build your app",
                                     optional: true,
                                     verify_block: proc do |value|
                                       raise "File not found at path '#{File.expand_path(value)}'".red unless File.exist?(value)
                                     end),
        FastlaneCore::ConfigItem.new(key: :slack_url,
                                     env_name: "SLACK_URL",
                                     description: "Create an Incoming WebHook for your Slack group to post results there",
                                     optional: true,
                                     verify_block: proc do |value|
                                       raise "Invalid URL, must start with https://" unless value.start_with? "https://"
                                     end),
        FastlaneCore::ConfigItem.new(key: :slack_channel,
                                     env_name: "SCAN_SLACK_CHANNEL",
                                     description: "#channel or @username",
                                     optional: true),
        FastlaneCore::ConfigItem.new(key: :skip_slack,
                                     description: "Don't publish to slack, even when an URL is given",
                                     is_string: false,
                                     default_value: false),
        FastlaneCore::ConfigItem.new(key: :slack_only_on_failure,
                                    description: "Only post on Slack if the tests fail",
                                    is_string: false,
                                    default_value: false),
        FastlaneCore::ConfigItem.new(key: :omit_exception_on_failing_tests,
                                    description: "Don't throw an exception if any test fails",
                                    default_value: false,
                                    optional: true,
                                    is_string: false)
      ]
    end
  end
end
