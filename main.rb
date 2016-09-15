require_relative "productivity"
require_relative "enforcement"

blocks = Productivity.blocks
unless blocks.empty?
  Enforcement.run blocks
end
