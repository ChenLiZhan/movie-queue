require 'aws-sdk'

class Message < AWS::Record::HashModel
  string_attr :subject
  string_attr :message
  timestamps
end
