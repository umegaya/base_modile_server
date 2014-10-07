require 'slack-notifier'

token = ARGV[0]
name = ARGV[1]
message = ARGV[2]
team = ARGV[3].nil? ? "dokyo" : ARGV[3]

client = Slack::Notifier.new(team, token, username: name)
client.ping message
