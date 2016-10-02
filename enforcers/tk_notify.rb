require 'tk'

# Store notification code outside the Enforcers module.
module Notification
  def self.build_window(block_text)
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

  def self.notify(block_text)
    build_window block_text
    Tk.mainloop
  end
end

if __FILE__ == $PROGRAM_NAME
  blocks = ARGV
  Notification.notify blocks.join("\n")
end
