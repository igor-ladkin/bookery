module Analytics
  extend self

  delegate :logger, to: :Rails

  def track(event, properties = {})
    logger.info "Analytics: #{event} - #{properties.inspect}"
  end
end
