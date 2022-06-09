module Analytics
  extend self

  delegate :logger, to: :Rails

  def track(event, properties = {})
    logger.info "[Analytics] Tracking Event: #{event} - #{properties.inspect}"
  end
end
