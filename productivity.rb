# Detect productivity
module Productivity
  metric_names = Dir.chdir('metrics') do
    Dir['*'].map { |e| File.basename(e, '.rb') }
  end

  metric_names.each { |m| require_relative "metrics/#{m}.rb" }

  settings = YAML.load_file('settings.yml')

  @metrics = Metrics.constants.map do |c|
    "Metrics::#{c}".constantize.new settings[c.to_s]
  end

  # Returns a list of pending tasks for the next day and a half
  def self.blocks
    @metrics.map(&:blocks).flatten
  end
end
