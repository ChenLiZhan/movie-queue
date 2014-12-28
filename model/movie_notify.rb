require 'aws-sdk'

class MovieNotify < AWS::Record::HashModel
  string_attr :subject
  string_attr :message
  timestamps
end
