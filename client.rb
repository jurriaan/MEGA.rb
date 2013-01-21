require './lib/mega.rb'
require 'yaml'

config = YAML.load(open('config.yml'))
password = config['password']
mail = config['user']
password_key = MEGA::Crypto.prepare_key_pw(password)
user_hash = MEGA::Crypto.stringhash(mail,password_key)

DEBUG = true

client = MEGA::Client.new(mail, password)
p client.get_sid
puts "-- MEGA.rb test client --"
puts "Welcome, #{mail}"
puts "Logging in.."
puts "userhash: #{user_hash}" if DEBUG

#p data = api_getsid(mail,password_key,user_hash)
#p sid = data[0]['csid']
#p api_req({a: 'ug'}, sid)
