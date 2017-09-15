require_relative 'productivity'
require_relative 'enforcement'
require 'logger'
require 'English'
require 'active_support/core_ext/numeric/time'

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
  rescue StandardError
    logger.error $ERROR_INFO
  end

  logger.info 'Waiting...'
  sleep 2.minutes.to_i
end
