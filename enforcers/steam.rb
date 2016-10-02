require 'sys/proctable'
# require 'win32/process'
require 'andand'

module Enforcers
  # Kill Steam if Steam is running.
  class Steam
    include Sys

    def initialize(settings)
      @steam_path = settings['steam-path']
    end

    def run(blocks)
      steam_running = ProcTable.ps.any? do |p|
        p.cmdline.andand.start_with? "\"#{@steam_path}\""
      end
      kill_steam if steam_running
      do_notify(blocks) if steam_running
      nil
    end

    private

    def kill_steam
      system(@steam_path, '-shutdown')
      ##
      # ProcTable.ps.each do |p|
      #   next unless p.cmdline.andand.start_with?(
      #       '"C:\Program Files (x86)\Steam\Steam.exe"')
      #   puts p.cmdline
      #   Process.kill 'KILL', p.pid
      # end
    end

    def do_notify(blocks)
      puts 'Todo list:'
      blocks.each { |b| puts b }
      system('rubyw', 'enforcers/tk_notify.rb', *blocks)
    end
  end
end
