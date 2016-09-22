# Enforce productivity
module Enforcement
  require 'sys/proctable'
  require 'win32/process'
  require 'andand'
  include Sys

  private_class_method def self.kill_steam
    system('C:\Program Files (x86)\Steam\Steam.exe', '-shutdown')
    ##
    # ProcTable.ps.each do |p|
    #   next unless p.cmdline.andand.start_with?(
    #       '"C:\Program Files (x86)\Steam\Steam.exe"')
    #   puts p.cmdline
    #   Process.kill 'KILL', p.pid
    # end
  end

  def self.run(blocks)
    puts 'Todo list:'
    blocks.each { |b| puts b }
    steam_running = ProcTable.ps.any? do |p|
      p.cmdline.andand.start_with? '"C:\Program Files (x86)\Steam\Steam.exe"'
    end
    kill_steam if steam_running
    nil
  end
end
