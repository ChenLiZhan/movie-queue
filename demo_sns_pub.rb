require 'aws-sdk'

topic_arn = 'arn:aws:sns:ap-northeast-1:503315808870:sns_playtime'

sns = AWS::SNS.new
t = sns.topics[topic_arn]
result = t.publish('The 5th of November', subject: 'Remember Remember')

puts result
