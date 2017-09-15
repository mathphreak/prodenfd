require 'sys/proctable'
# require 'win32/process'
require 'andand'

module Enforcers
  # Kill Steam if Steam is running.
  class BattleDotNet
    include Sys

    def initialize(settings)
      @bnet_folder = settings['bnet-folder']
    end

    def run
      bnet_running = ProcTable.ps.any? do |p|
        p.cmdline.andand.start_with? "\"#{@bnet_folder}"
      end
      kill_bnet if bnet_running
      bnet_running
    end

    private

    def kill_bnet
      ProcTable.ps.each do |p|
        next if p.cmdline.nil?
        next unless p.cmdline.start_with?("\"#{@bnet_folder}")
        Process.kill 'KILL', p.pid
      end
    end
  end
end
