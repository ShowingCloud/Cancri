threads 0,16
workers 1
preload_app!

environment 'production'
daemonize
pidfile '/var/www/rails/dome/robodou/production/tmp/pids/puma.pid'
state_path '/var/www/rails/dome/robodou/production/tmp/pids/puma.state'
stdout_redirect '/var/www/rails/dome/robodou/production/log/stdout', '/var/www/rails/dome/robodou/production/log/stderr', true

bind 'tcp://0.0.0.0:3240'
tag 'Robodou Production'
