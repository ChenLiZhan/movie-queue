require 'aws-sdk'

AWS.config(
  access_key_id: ENV['AWS_ACCESS_KEY_ID'],
  secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
  region: ENV['AWS_REGION']
)

topic_arn = 'arn:aws:sns:ap-northeast-1:503315808870:user'

sns = AWS::SNS.new(region: ENV['AWS_REGION'])
t = sns.topics[topic_arn]
