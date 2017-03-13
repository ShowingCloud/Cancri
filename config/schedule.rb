# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

#
env :PATH, ENV['PATH']
# set :environment, :development ## default production
set :output, {:error => 'log/crontab_error.log', :standard => 'log/crontab_success.log'}

every '0 0 1 1 *' do
  rake "db:reset_volunteer_point"
end
