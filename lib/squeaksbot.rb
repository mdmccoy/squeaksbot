class SqueaksBot < Discordrb::Commands::CommandBot  
  def initialize *args
    super *args
    @hours = %w[1000 1100 1200 1300 1800 1900 2000]
    @days = %w[Mon Tue Wed Thu Fri Sat Sun]
    @schedule = {}
    @admins = %w[SqushiRex cmandr1 Squeaks]
  end

  attr_reader :admins

  def build_schedule(new = false)
    return unless @schedule.empty? || new
  
    @days.each do |day|
      @schedule[day] = build_daily_schedule
    end
    nil
  end
  
  def build_daily_schedule
    day = {}
    @hours.each do |hour|
      day[hour] = %w[empty empty]
    end
    day
  end
  
  def print_schedule(event, full = false)
    event << "Current schedule..."
    @schedule.each do |day,times|
      event << "#{day}"
      times.each do |hour,slots|
        if full
          event << "#{hour}:  #{slots[0]}, #{slots[1]}"
        else
          event << "#{hour}:  #{slots[0]}, #{slots[1]}" unless slots[0] == 'empty' && slots[1] == 'empty'
        end           
      end
    end
    nil
  end

  def signup_help(event)
    event << "Days are in three character abbreviations. Normal days: #{@days.join(', ')}."
    event << "Hours are in 24 hour military format. Normal hours: #{@hours.join(', ')}."
    event << "To signup type '!signup <Day> <Hour>'."
  end

  def signup(event, args)
    day, hour = args

    return "Wrong Date Format, ex: Mon" unless @days.include? day
    return "Wrong Hour Format, ex: 1200" unless @hours.include? hour

    # This should make sure you can't signup over someone else, so only if the spot in the array is empty
    # Return some type of error message if it is not empty.
    @schedule[day][hour][0] == 'empty' ? @schedule[day][hour][0] = event.user.name : @schedule[day][hour][1]

    # Make this a PM?
    event.user.pm "You have signed up for #{day} at #{hour}. !remove to remove."
  end

  def remove(event)
    @schedule.each do |day, times|
      times.each do |hour, slots|
        next unless slots.include? event.user.name
  
        slots[0] == event.user.name ? slots[0] = 'empty' : slots[1] = 'empty'
        event.user.pm "You have been removed."
        return "#{event.user.name} was removed from #{day} at #{hour}"                               
      end
    "#{event.user.name} not found." 
    end
  end


end