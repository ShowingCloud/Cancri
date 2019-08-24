namespace :identifier do

  desc 'create identifier'
  task :create => :environment do
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
            identity = 'C'
          else
            identity = 'G'
        end
        ('000'+(id+128).to_s)[-6..-1].each_byte do |c|
          if c != 48
            identity.concat((c.to_i + 16).chr)
          else
            identity.concat('H')
          end
        end
        has_use = Team.find_by_identifier(identity)
        if has_use.present?
          puts id.to_s+'----event'+has_use.event.name+'event_id:'+ has_use.event_id.to_s+',user:'+has_use.user.try(:nickname)+',user:'+has_use.user_id.to_s
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
