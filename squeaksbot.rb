require 'dotenv/load'
require 'discordrb'

# frozen_string_literal: true

# This simple bot responds to every "Ping!" message with a "Pong!"

require 'discordrb'

# This statement creates a bot with the specified token and application ID. After this line, you can add events to the
# created bot, and eventually run it.
#
# If you don't yet have a token to put in here, you will need to create a bot account here:
#   https://discordapp.com/developers/applications
# If you're wondering about what redirect URIs and RPC origins, you can ignore those for now. If that doesn't satisfy
# you, look here: https://github.com/meew0/discordrb/wiki/Redirect-URIs-and-RPC-origins
# After creating the bot, simply copy the token (*not* the OAuth2 secret) and put it into the
# respective place.
bot = Discordrb::Bot.new token: ENV['DISCORD_TOKEN']

# Here we output the invite URL to the console so the bot account can be invited to the channel. This only has to be
# done once, afterwards, you can remove this part if you want
puts "This bot's invite URL is #{bot.invite_url}."
puts 'Click on it to invite it to your server.'


#####################
#
#
#      Private Methods
#
#
#####################

def build_weekly_schedule
  schedule = {}
  %w[Mon Tue Wed Thu Fri Sat Sun].each do |day|
    schedule[day] = build_daily_schedule
  end
  schedule
end

def build_daily_schedule
  schedule = {}
  %w[1000 1100 1200 1300 1800 1900 2000].each do |hour|
    schedule[hour] = %w[empty empty]
  end
  schedule
end


####################
#
#
#     Event Handlers
#
#
####################

bot.message(content: 'Ping!') do |event|
  event.respond 'Pong!'
end

bot.message(content: '!schedule') do |e|
  build_weekly_schedule.each do |day,times|
    e << "#{day}"
    times.each do |hour,slots|
      e << "#{hour}:  #{slots[0]}, #{slots[1]}"
    end
  end
  e
end

# This method call has to be put at the end of your script, it is what makes the bot actually connect to Discord. If you
# leave it out (try it!) the script will simply stop and the bot will not appear online.
bot.run