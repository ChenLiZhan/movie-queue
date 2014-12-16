require 'sinatra/base'
require 'json'
require 'httparty'
require_relative 'model/message'

##
# Fork of CadetService, using DynamoDB instead of Postgres
# - requires config:
#   - create ENV vars AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, and AWS_REGION
class NotificationSubscriber < Sinatra::Base
  enable :logging

  helpers do
    def new_message(req)
      message = Message.new
      message.subject = req[:subject].to_json
      tutorial.usernames = req['usernames'].to_json
      tutorial.badges = req['badges'].to_json
      tutorial
    end
  end

  post '/?' do
    "Notification subscriber up and running"
  end

  post '/subscriber' do
    begin
      msg_type = request.env["HTTP_X_AMZ_SNS_MESSAGE_TYPE"]
      message = JSON.parse(request.body.read)
      logger.info "SNS_MSG_TYPE: #{msg_type}"
      logger.info "SNS_MSG: #{message}"

      case msg_type
      when 'SubscriptionConfirmation'
        confirm_url = message['SubscribeURL']
        logger.info "SNS_CONFIRM: #{confirm_url}"
        
      when 'Notification'
        # handle push notification message here
      end
    rescue
      halt 400
    end

    haml :subscriber
  end
end
