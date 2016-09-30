require 'yaml'

# Detect productivity
module Productivity
  Dir.chdir('metrics') do
    Dir['*'].each do |e|
      metric_name = File.basename(e, '.rb')
      require_relative "metrics/#{metric_name}.rb"
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
