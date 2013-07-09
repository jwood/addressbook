class ApplicationConfig
  class << self

    private

    def method_missing(method, *args)
      app_config[method.to_s]
    end

    def app_config
      @config ||= begin
                    config_file = File.join(Rails.root, 'config', 'application_config.yml')
                    File.exist?(config_file) ? YAML.load_file(config_file) : {}
                  end
    end

  end
end
