# Enforce productivity
module Enforcement
  require 'sys/proctable'
  require 'win32/process'
  require 'andand'
  require 'tk'
  include Sys

  private_class_method def self.build_window(block_text)
    root = TkRoot.new { title 'prodenfd' }
    TkLabel.new(root) do
      text block_text.encode Encoding::US_ASCII, undef: :replace, replace: ''
      pack do
        padx 15
        pady 15
        side 'left'
      end
    end
  end

  private_class_method def self.notify(block_text)
    build_window block_text
    Tk.restart
    Tk.mainloop
  end

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
    notify(blocks.join("\n")) if steam_running
    nil
  end
end
