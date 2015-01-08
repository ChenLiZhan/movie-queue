require 'sinatra/base'
require 'json'
require 'httparty'
require_relative 'model/movie_notify'

##
# Fork of CadetService, using DynamoDB instead of Postgres
# - requires config:
#   - create ENV vars AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, and AWS_REGION
class NotificationSubscriber < Sinatra::Base
  enable :logging

  helpers do
    def save_message(subject, message)
      begin
        sns_note = MovieNotify.new
        sns_note.subject = subject
        sns_note.message = message
        sns_note.save
      rescue => e
        logger.error e
        halt 500, "Failed to save message to data store"
      end
    end
  end

  get '/' do
    "Notification subscriber up and running"
  end

  post '/search' do
    begin
      sns_msg_type = request.env["HTTP_X_AMZ_SNS_MESSAGE_TYPE"]
      sns_note = JSON.parse request.body.read

      case sns_msg_type
      when 'SubscriptionConfirmation'
        sns_confirm_url = sns_note['SubscribeURL']
        sns_confirmation = HTTParty.get sns_confirm_url
      when 'Notification'
        save_message sns_note['Subject'], sns_note['Message']
        param = {
          movie: sns_note['Message']
          sqs_key: sns_note['Subject']
        }
        options = {
          headers: { 'Content-Type' => 'application/json' },
          body: param.to_json
        }

        result = HTTParty.post('https://serene-citadel-5567.herokuapp.com/api/v2/movie', options)
      end
    rescue => e
      logger.error e
      halt 400, "Could not fully process SNS notification"
      return
    end

    status 200
  end
end
