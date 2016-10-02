require 'yaml'

# Detect productivity
module Productivity
  Dir.chdir('metrics') do
    Dir['*'].each do |e|
      require_relative "metrics/#{e}"
    end
  end

  settings = YAML.load_file('settings.yml')

  @metrics = Metrics.constants.map do |c|
    "Metrics::#{c}".constantize.new settings[c.to_s]
  end

  # Returns a list of pending tasks for the next day and a half
  def self.blocks
    @metrics.map(&:blocks).flatten
  end
end
