require './app'
require_relative 'model/message.rb'

namespace :db do
  desc "Create database"
  task :migrate do
    begin
      Message.create_table(5, 6)
      puts "New data store created"
    rescue AWS::DynamoDB::Errors::ResourceInUseException => e
      puts 'Data store exists -- no changes made, no retry attempted'
    end
  end
end
