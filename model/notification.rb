require 'aws-sdk'

class Notification < AWS::Record::HashModel
  string_attr :subject
  string_attr :message
  timestamps
end
