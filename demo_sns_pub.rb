require 'aws-sdk'

topic_arn = 'arn:aws:sns:us-west-2:819536398009:sns_playtime'

sns = AWS::SNS.new
t = sns.topics[topic_arn]
result = t.publish('The 5th of November', subject: 'Remember Remember')

puts result
