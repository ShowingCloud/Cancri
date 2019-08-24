namespace :teams do

  desc 'create identifier'
  task :identifier => :environment do
    teams = Team.where('identifier is NULL')
    if teams.present?
      teams.each do |team|
        group = team.group
        id = team.id
        case group
          when 1 then
            identity = 'X'
          when 2 then
            identity = 'Z'
          when 3 then
            identity = 'J'
          when 4 then
            identity = 'S'
          else
            identity = 'W'
        end
        ((id+128000).to_s).each_byte do |c|
          if c != 48
            identity.concat((c.to_i + 16).chr)
          else
            identity.concat('O')
          end
        end
        has_use = Team.find_by_identifier(identity)
        if has_use.present?
          puts id.to_s
          puts 'id:'+has_use.id.to_s+',event:'+has_use.event.name+',user:'+has_use.user.try(:nickname)
        else
          team.identifier = identity
          if team.save
            puts 'OK'+'--'+id.to_s
          else
            puts 'fail'+'--'+id.to_s
          end
        end

      end
    else
      puts 'no teams'
    end
  end
end
