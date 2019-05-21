module Babaloa
  class << self
    def configure
      yield(configuration)
    end

    def configuration
      @configuration ||= Configuration.new
    end
  end

  class Configuration
    attr_accessor :default, :definition

    def initialize
      @default = {}
      @definition = {}
    end

    def define(name, key)
      return unless name || key
      @definition[name]&.[](key)
    end
  end
end
