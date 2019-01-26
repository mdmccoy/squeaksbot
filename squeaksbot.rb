require 'dotenv/load'
require 'discordrb'

# frozen_string_literal: true

require 'discordrb'

# bot = Discordrb::Bot.new token: ENV['DISCORD_TOKEN']
return puts "Need a token bub." unless ENV['DISCORD_TOKEN']
bot = Discordrb::Commands::CommandBot.new token: ENV['DISCORD_TOKEN'], prefix: '!'

SCHEDULE = {}
DAYS = %w[Mon Tue Wed Thu Fri Sat Sun]
HOURS = %w[1000 1100 1200 1300 1800 1900 2000]
ADMINS = %w[SqushiRex cmandr1 Squeaks]

# Here we output the invite URL to the console so the bot account can be invited to the channel. This only has to be
# done once, afterwards, you can remove this part if you want
puts "This bot's invite URL is #{bot.invite_url}."
puts 'Click on it to invite it to your server.'


#####################
#
#
#      Schedule Methods
#      Make this a class?
#
#
#####################

def build_schedule(new = false)
  return unless SCHEDULE.empty? || new

  DAYS.each do |day|
    SCHEDULE[day] = build_daily_schedule
  end
  nil
end

def build_daily_schedule
  day = {}
  HOURS.each do |hour|
    day[hour] = %w[empty empty]
  end
  day
end

def print_schedule(event, options = {})
  event << "This weeks schedule -"
  SCHEDULE.each do |day,times|
    event << "#{day}"
    times.each do |hour,slots|
      if options[:full]
        event << "#{hour}:  #{slots[0]}, #{slots[1]}"
      else
        event << "#{hour}:  #{slots[0]}, #{slots[1]}" unless slots[0] == 'empty' && slots[1] == 'empty'
      end           
    end
  end
  nil
end

def signup_instructions(event)
  event << days_help
  event << hours_help
  event << "To signup type '!signup <Day> <Hour>'."
end

def hours_help
  "Hours are in 24 hour military format. Normal hours: #{HOURS.join(', ')}."
end

def days_help
  "Days are in three character abbreviations. Normal days: #{DAYS.join(', ')}."
end

####################
#
#
#     Event Handlers
#
#
####################

bot.command(:schedule) do |event,args|
  build_schedule(args == 'new')

  print_schedule event, full: args == 'full'
end

bot.command(:hours) do |event|
  hours_help
end

bot.command(:instructions) do |event|
  signup_instructions(event)
end

bot.command(:signup) do |event, *args|
  # Signs you up for the slot you asked for
  build_schedule

  return 

  day, hour = args

  return "Wrong Date Format, ex: Mon" unless DAYS.include? day

  return "Wrong Hour Format, ex: 1200" unless HOURS.include? hour

  # This should make sure you can't signup over someone else, so only if the spot in the array is empty
  # Return some type of error message if it is not empty.
  SCHEDULE[day][hour][0] == 'empty' ? SCHEDULE[day][hour][0] = event.user.name : SCHEDULE[day][hour][1]

  # Make this a PM?
  "#{event.user.name} wants to sign up for #{day} at #{hour}"

  print_schedule
end

bot.command(:remove) do |event|
  # Will find your name and remove it from the schedule
  build_schedule

  # Find a better way to do this that isn't iterating through the whole hash.
  SCHEDULE.each do |day, times|
    times.each do |hour, slots|
      next unless slots.include? event.user.name

      slots[0] == event.user.name ? slots[0] = 'empty' : slots[1] = 'empty'
      event.user.pm "You have been removed."
      return "#{event.user.name} was removed from #{day} at #{hour}"                         
    end
  end

  "#{event.user.name} not found."
end

bot.command(:clear) do |event|
  return "You aren't an admin." unless ADMINS.include?(event.user.name)

  build_schedule(true)
  print_schedule event

  nil
end

# This method call has to be put at the end of your script, it is what makes the bot actually connect to Discord. If you
# leave it out (try it!) the script will simply stop and the bot will not appear online.
bot.run