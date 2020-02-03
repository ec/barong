# frozen_string_literal: true

# twilio whatsapp service
class TwilioWhatsappService
  class << self
    # send confirmation method, that takes as a base TWILIO WHATSAPP api
    # https://www.twilio.com/docs/sms/whatsapp/quickstart
    def send_confirmation(phone, _channel)
      # log about start of the process
      Rails.logger.info("Sending SMS to whatsapp #{phone.number}")

      # calls send_sms method, that implements sender logic by
      # https://www.twilio.com/docs/sms/quickstart/ruby
      # Barong::App.config.sms_content_template - will be sent as a message content
      send_sms(number: phone.number, content: Barong::App.config.sms_content_template.gsub(/{{code}}/, phone.code))
    end

    def send_sms(number:, content:)
      # twilio phone number, configured in /initializers/phone.rb
      from_phone = Barong::App.config.twilio_phone_number
      # twilio client, created in /initializers/phone.rb
      client = Barong::App.config.twilio_client

      # create message for the client, add in a Twilio send queue
      client.messages.create(from: 'whatsapp:' + from_phone, to: 'whatsapp:+' + number, body: content)
    end

    # returns true if given code (FROM whatsapp message) matches number in DB
    # returns false if verification is failed
    def verify_code?(number:, code:, user:)
      user.phones.find_by(number: number, code: code).present?
    end
  end
end
