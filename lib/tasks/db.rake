namespace :db do

  namespace :export_user do

    desc "Create CSV Files for User Model"
    task :csv => :environment do
      require "#{Rails.root}/app/models/user.rb"
      dir = "#{Rails.root}/db/csv"
      FileUtils.mkdir(dir) unless Dir.exists?(dir)
      unless File.exists?("#{dir}/#{User.to_s.tableize}.csv")
        CSV.open("#{dir}/#{User.to_s.tableize}.csv", 'w+') do |csv|
          csv << User.column_names
          User.all.each do |user|
            csv << User.column_names.map { |attr| user.send(attr) }
          end
        end
        puts "CREATED FILE >> /db/csv/#{User.to_s.tableize}.csv"
      end

    end
  end

  desc "Reset volunteer points and times at the begin of year"
  task :reset_volunteer_point => :environment do
    if UserRole.where(role_id: 3).update_all(points: 0, times: 0)
      puts '============== Reset volunteer points and times successfully========================================'
    else
      puts '============== Fail to reset volunteer points and times ========================================'
    end
  end

end
