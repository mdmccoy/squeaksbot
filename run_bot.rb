require 'dotenv/load'
require 'discordrb'
require './lib/squeaksbot'

return puts "Need a token bub." unless ENV['DISCORD_TOKEN']
bot = SqueaksBot.new token: ENV['DISCORD_TOKEN'], prefix: '?'

bot.command(:schedule) do |event,args|
  bot.build_schedule(args == 'new')
  bot.print_schedule(event, args == 'full')
end
      
bot.command(:signup) do |event, *args|
  bot.build_schedule
  bot.signup(event, args)
  bot.print_schedule(event)
end
  
bot.command(:remove) do |event|
  bot.build_schedule
  bot.remove(event)
end
  
bot.command(:clear) do |event|
  return "You aren't an admin." unless bot.admins.include?(event.user.name)

  bot.build_schedule(true)
  bot.print_schedule(event)

  nil
end
  
bot.command(:fuck) do |event, fucker|
  return "You can't say that." unless bot.admins.include?(event.user.name)

  fucker ||= "VAIN"

  "Fuck you #{fucker}."
end
  
bot.command(:wake_up) do
  "I'm awake."
end

bot.run