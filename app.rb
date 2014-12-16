require 'sinatra/base'
require 'json'
require 'httparty'
require_relative 'model/notification'

##
# Fork of CadetService, using DynamoDB instead of Postgres
# - requires config:
#   - create ENV vars AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, and AWS_REGION
class NotificationSubscriber < Sinatra::Base
  enable :logging

  helpers do
    def save_message(subject, message)
      note = Notification.new
      note.subject = subject
      note.message = message
      return note.save
    end
  end

  post '/?' do
    "Notification subscriber up and running"
  end

  post '/subscriber' do
    begin
      msg_type = request.env["HTTP_X_AMZ_SNS_MESSAGE_TYPE"]
      note = JSON.parse(request.body.read)
      logger.info "SNS_MSG_TYPE: #{msg_type}"
      logger.info "SNS_MSG: #{note}"

      case msg_type
      when 'SubscriptionConfirmation'
        sns_confirm_url = note['SubscribeURL']
        logger.info "SNS_CONFIRM_URL: #{sns_confirm_url}"
        sns_confirmation = HTTParty.get sns_confirm_url
        logger.info "SNS_CONFIRMATION: #{sns_confirmation}"
      when 'Notification'
        note_subject = note['Subject']
        note_message = note['Message']
        logger.inf "MSG_SAVED: Subject: #{note_subject}"
        logger.inf "MSG_SAVED: Message: #{note_message}"
        unless save_message note_subject, note_message do
          halt 500, "Failed to save message"
        end
      end
    rescue
      halt 400, "Could not process SNS notification"
    end

    haml :subscriber
  end
end
