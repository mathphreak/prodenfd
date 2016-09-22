# Enforce productivity
module Enforcement
  def self.run(blocks)
    puts 'Todo list:'
    blocks.each { |b| puts b }
  end
end
