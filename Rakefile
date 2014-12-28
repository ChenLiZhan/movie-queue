require './app'
require_relative 'model/movie_notify.rb'

namespace :db do
  desc "Create data store"
  task :migrate do
    begin
      MovieNotify.create_table(5, 6)
      puts "New data store created"
    rescue AWS::DynamoDB::Errors::ResourceInUseException => e
      puts 'Data store exists -- no changes made, no retry attempted'
    end
  end
end
