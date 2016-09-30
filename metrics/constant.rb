module Metrics
  # If enabled, always offer set block.
  class Constant
    def initialize(settings)
      @enabled = settings['enabled']
      @message = settings['message']
    end

    def blocks
      if @enabled
        [@message]
      else
        []
      end
    end
  end
end
