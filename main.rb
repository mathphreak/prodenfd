require_relative 'productivity'
require_relative 'enforcement'

blocks = Productivity.blocks
unless blocks.empty?
  puts 'Insufficient productivity detected. Enforcing...'
  Enforcement.run blocks
end
