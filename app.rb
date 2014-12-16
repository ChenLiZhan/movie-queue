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
      sns_note = Notification.new
      sns_note.subject = subject
      sns_note.message = message
      return sns_note.save
    end
  end

  get '/' do
    "Notification subscriber up and running"
  end

  post '/notification' do
    begin
      sns_msg_type = request.env["HTTP_X_AMZ_SNS_MESSAGE_TYPE"]
      sns_note = JSON.parse request.body.read
      logger.info "SNS_MSG_TYPE: #{sns_msg_type}"
      logger.info "SNS_MSG: #{sns_note}"

      case sns_msg_type
      when 'SubscriptionConfirmation'
        sns_confirm_url = sns_note['SubscribeURL']
        logger.info "SNS_CONFIRM_URL: #{sns_confirm_url}"
        sns_confirmation = HTTParty.get sns_confirm_url
        logger.info "SNS_CONFIRMATION: #{sns_confirmation}"
      when 'Notification'
        note_subject = sns_note['Subject']
        note_message = sns_note['Message']
        logger.info "MSG_SAVED: Subject: #{note_subject}"
        logger.info "MSG_SAVED: Message: #{note_message}"
        unless save_message note_subject, note_message
          halt 500, "Failed to save message"
        end
      end
    rescue Exception => e
      logger.error "EXCEPTION: #{e.message}"
      halt 400, "Could not process SNS notification"
    end

    status 200
  end
end
