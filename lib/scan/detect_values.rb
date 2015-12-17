module Scan
  # This class detects all kinds of default values
  class DetectValues
    # This is needed as these are more complex default values
    # Returns the finished config object
    def self.set_additional_default_values
      config = Scan.config

      FastlaneCore::Project.detect_projects(config)
      Scan.project = FastlaneCore::Project.new(config)

      # Go into the project's folder
      Dir.chdir(File.expand_path("..", Scan.project.path)) do
        config.load_configuration_file(Scan.scanfile_name)
      end

      Scan.project.select_scheme

      default_device_ios if Scan.project.ios?
      default_device_tvos if Scan.project.tvos?
      detect_destination

      return config
    end

    def self.default_device_ios
      config = Scan.config

      if config[:device] # make sure it actually exists
        device = config[:device].to_s.strip.tr('()', '') # Remove parenthesis

        found = FastlaneCore::Simulator.all.find do |d|
          (d.name + " " + d.ios_version).include? device
        end

        if found
          Scan.device = found
          return
        else
          Helper.log.error "Couldn't find simulator '#{config[:device]}' - falling back to default simulator".red
        end
      end

      sims = FastlaneCore::Simulator.all
      xcode_target = Scan.project.build_settings(key: "IPHONEOS_DEPLOYMENT_TARGET")

      # Filter out any simulators that are not the same major version of our deployment target
      if xcode_target.to_s.length > 0
        min_target = xcode_target.split(".").first.to_i
        sims = sims.select { |s| s.ios_version.to_i >= min_target }
      end

      # An iPhone 5s is reasonable small and useful for tests
      found = sims.find { |d| d.name == "iPhone 5s" }
      found ||= sims.first # anything is better than nothing

      Scan.device = found

      raise "No simulators found".red unless Scan.device
    end

    def self.default_device_tvos
      config = Scan.config

      if config[:device] # make sure it actually exists
        device = config[:device].to_s.strip.tr('()', '') # Remove parenthesis

        found = FastlaneCore::SimulatorTV.all.find do |d|
          (d.name + " " + d.tvos_version).include? device
        end

        if found
          Scan.device = found
          return
        else
          Helper.log.error "Couldn't find simulator '#{config[:device]}' - falling back to default simulator".red
        end
      end

      sims = FastlaneCore::SimulatorTV.all
      xcode_target = Scan.project.build_settings(key: "TVOS_DEPLOYMENT_TARGET")

      # Filter out any simulators that are not the same major version of our deployment target
      if xcode_target.to_s.length > 0
        min_target = xcode_target.split(".").first.to_i
        sims = sims.select { |s| s.ios_version.to_i >= min_target }
      end

      # Apple TV 1080p is useful for tests
      found = sims.find { |d| d.name == "Apple TV 1080p" }
      found ||= sims.first # anything is better than nothing

      Scan.device = found

      raise "No simulators found".red unless Scan.device
    end

    # Is it an iOS device or a Mac?
    def self.detect_destination
      if Scan.config[:destination]
        Helper.log.info "It's not recommended to set the `destination` value directly".yellow
        Helper.log.info "Instead use the other options available in `scan --help`".yellow
        Helper.log.info "Using your value '#{Scan.config[:destination]}' for now".yellow
        Helper.log.info "because I trust you know what you're doing...".yellow
        return
      end

      # building up the destination now
      if Scan.project.ios?
        Scan.config[:destination] = "platform=iOS Simulator,id=#{Scan.device.udid}"
      elsif Scan.project.tvos?
        Scan.config[:destination] = "platform=tvOS Simulator,id=#{Scan.device.udid}"
      else
        Scan.config[:destination] = "platform=OS X"
      end
    end
  end
end
