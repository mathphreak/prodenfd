require_relative 'productivity'
require_relative 'enforcement'
require 'logger'
require 'English'

logger = Logger.new('logfile.log', 'daily')

loop do
  logger.info 'Running...'

  begin
    blocks = Productivity.blocks
    logger.info "Got blocks: \n" + blocks.join("\n")
    unless blocks.empty?
      logger.info 'Insufficient productivity detected. Enforcing...'
      Enforcement.run blocks
    end
  rescue
    logger.fatal $ERROR_INFO
    raise
  end

  # Wait ten minutes
  logger.info 'Waiting...'
  sleep 60 * 10
end
