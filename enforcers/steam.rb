require 'sys/proctable'
# require 'win32/process'
require 'andand'

module Enforcers
  # Kill Steam if Steam is running.
  class Steam
    include Sys

    def initialize(settings)
      @steam_folder = settings['steam-folder']
      @steam_path = "#{@steam_folder}\\Steam.exe"
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
      ProcTable.ps.each do |p|
        next if p.cmdline.nil?
        next unless p.cmdline.start_with?("\"#{@steam_path}\"",
                                          "\"#{@steam_folder}\\steamapps")
        if p.cmdline.start_with?("\"#{@steam_path}\"")
          system(@steam_path, '-shutdown')
        else
          Process.kill 'KILL', p.pid
        end
      end
    end

    def do_notify(blocks)
      puts 'Todo list:'
      blocks.each { |b| puts b }
      pid = spawn('rubyw', 'enforcers/tk_notify.rb', *blocks)
      Process.detach pid
    end
  end
end
