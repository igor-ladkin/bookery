Rails.application.config.to_prepare do
  Payment.adapter = Payment::SuccessAdapter.new
end
