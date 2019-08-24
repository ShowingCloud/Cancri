namespace :school do

  desc "Create CSV Files for school"
  task :export_school => :environment do
    require "#{Rails.root}/app/models/school.rb"
    dir = "#{Rails.root}/db/csv"
    FileUtils.mkdir(dir) unless Dir.exists?(dir)
    unless File.exists?("#{dir}/#{School.to_s.tableize}.csv")
      CSV.open("#{dir}/#{School.to_s.tableize}.csv", 'w+') do |csv|
        csv << School.column_names
        School.all.each do |school|
          csv << School.column_names.map { |attr| school.send(attr) }
        end
      end
      puts "CREATED FILE >> #{School.to_s.tableize}.csv"
    end

  end


  desc "import school data from CSV"
  task :import_school => :environment do
    require "#{Rails.root}/app/models/school.rb"
    CSV.foreach("#{Rails.root}/db/csv/schools.csv", headers: true) do |row|
      school_hash = row.to_hash
      User.create!(id: school_hash["id"], name: school_hash["name"], district_id: school_hash["district_id"], status: school_hash["status"], audit: school_hash["audit"], user_add: school_hash["user_add"], user_id: school_hash["user_id"], teacher_role: school_hash["teacher_role"])
    end
  end


end
