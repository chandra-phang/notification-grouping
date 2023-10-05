# frozen_string_literal: true

module Logging
  def logger
    Logging.logger
  end

  # Global, memoized, lazy initialized instance of a logger
  def self.logger
    return @logger if @logger

    @logger = Logger.new('app.log')
    @logger.info('Starting application...')
    @logger
  end
end
