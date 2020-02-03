# frozen_string_literal: true

require_dependency 'barong/mock_sms'

Barong::App.define do |config|
  # Twilio configuration ----------------------
  # https://github.com/openware/barong/blob/master/docs/configuration.md#twilio-configuration

  config.write(:twilio_provider, TwilioSmsSendService)

  config.set(:phone_verification, 'twilio_whatsapp')
  config.set(:twilio_phone_number, '+14155238886')
  config.set(:twilio_account_sid, 'AC5edb5daf1f4b650f1ce0be3dfc910c73')
  config.set(:twilio_auth_token, 'a5a446eaf410a2f541970a8709c24b6c')
  config.set(:twilio_service_sid, '')
  config.set(:sms_content_template, 'Your verification code for Barong: {{code}}')
end

sid = Barong::App.config.twilio_account_sid
token = Barong::App.config.twilio_auth_token
service_sid = Barong::App.config.twilio_service_sid

case Barong::App.config.phone_verification
when 'twilio_whatsapp'
  raise 'Invalid twilio config' if sid.to_s.empty? || token.to_s.empty?

  client = Twilio::REST::Client.new(sid, token)

  Barong::App.write(:twilio_provider, TwilioWhatsappService)
when 'twilio_sms'
  raise 'Invalid twilio config' if sid.to_s.empty? || token.to_s.empty?

  client = Twilio::REST::Client.new(sid, token)
  Barong::App.write(:twilio_provider, TwilioSmsSendService)

when 'twilio_verify'
  raise 'Invalid twilio config' if sid.to_s.empty? || token.to_s.empty?

  client = Twilio::REST::Client.new(sid, token)
  service = client.verify.services.create(friendly_name: Barong::App.config.app_name) unless service_sid.present?
  Barong::App.write(:twilio_provider, TwilioVerifyService)
when 'mock'
  if Rails.env.production?
    Rails.logger.info("WARNING! Don't use mock phone verification service in production")
  end
  Barong::App.write(:twilio_provider, MockPhoneVerifyService)

else
  raise "Unknown phone verification service #{Barong::App.config.phone_verification}"
end

Barong::App.set(:twilio_client, client) if client
Barong::App.set(:twilio_service_sid, service.sid) if service
Phonelib.strict_check = true
