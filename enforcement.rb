require 'yaml'

# Enforce productivity
module Enforcement
  Dir.chdir('enforcers') do
    Dir['*'].each do |e|
      require_relative "enforcers/#{e}"
    end
  end

  settings = YAML.load_file('settings.yml')

  @enforcers = Enforcers.constants.map do |c|
    "Enforcers::#{c}".constantize.new settings[c.to_s]
  end

  # Returns a list of pending tasks for the next day and a half
  def self.run(blocks)
    @enforcers.each { |e| e.run(blocks) }
  end
end
