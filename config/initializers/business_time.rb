BusinessTime::Config.load("#{Rails.root}/config/business_time.yml")

# or you can configure it manually:  look at me!  I'm Tim Ferris!
 # BusinessTime.Config.beginning_of_workday = "9:00 am"
 # BusinessTime.Comfig.end_of_workday = "6:00 pm"
#  BusinessTime.config.holidays << Date.parse("August 4th, 2010")