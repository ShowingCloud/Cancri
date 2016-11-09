class CompetitionService

  def self.get_event_score_attrs(event_id)
    EventSaShip.includes(:score_attribute, :score_attribute_parent).where(event_id: event_id, is_parent: 0).order('parent_id asc').map { |s| {
        id: s.id,
        name: s.level==1 ? s.score_attribute.name : s.score_attribute_parent.name+': '+ s.score_attribute.name,
        score_type: s.score_attribute.write_type,
        desc: s.desc.blank? ? nil : s.desc
    } }
  end


  def self.get_events(comp_id)
    Event.includes(:child_events).where(competition_id: comp_id, level: 1).map { |e| {
        id: e.id,
        group: e.group,
        events: e.group.present? ? e.group.split(',').map { |n| {
            name: (e.is_father) ? e.name : '其他',
            group: n.to_i,
            z_e: e.is_father ? e.child_events.select { |a| a.group.index(n) }.map { |z_e| {
                id: z_e.id,
                name: z_e.name
            } } : {id: e.id, name: e.name}
        } } : e.name,
    } }
  end

  def self.get_group_teams(event_id, group, schedule_id, has_score)
    team_sql = Team.joins('left join user_profiles u_p on u_p.user_id = teams.user_id').joins('left join schools s on s.id = teams.school_id')
                   .joins('left join users u on u.id = teams.user_id')
                   .joins("left join scores sc on teams.id=sc.team1_id and sc.schedule_id=#{schedule_id}").where(event_id: event_id, group: group).select(:id, :teacher, :teacher_mobile, :identifier, 'u_p.username', 'u.mobile', 's.name as school_name', 'count(sc.id) as score_num').group(:id, 'u_p.username')
    case has_score.to_i
      when 0 then
        team_sql.having('count(sc.id) = ?', 0)
      when 1 then
        team_sql.having('count(sc.id) > ?', 0)
      else
        team_sql
    end
  end

  def self.post_team_scores(event_id, schedule_id, kind, th, team1_id, score1, last_score, note, device_no, confirm_sign, operator_id)
    score = Score.where(event_id: event_id, schedule_id: schedule_id, kind: kind, th: th, team1_id: team1_id).take
    if score.present?
      if score.update_attributes(score_attribute: score1, last_score: last_score, note: note, device_no: device_no, confirm_sign: confirm_sign, user_id: operator_id)
        result = {status: true, message: '成绩更新成功'}
      else
        result = {status: false, message: '成绩更新失败'}
      end
    else
      score = Score.create(event_id: event_id, schedule_id: schedule_id, kind: kind, th: th, team1_id: team1_id, score_attribute: score1, last_score: last_score, note: note, device_no: device_no, confirm_sign: confirm_sign, user_id: operator_id)
      if score.save
        result = {status: true, message: '成绩保存成功'}
      else
        result = {status: false, message: '成绩保存失败'}
      end
    end
    result
  end

  def self.via_identifier_get_team(identifier)
    team = Team.joins(:event).joins('left join competitions comp on comp.id = events.competition_id').where(identifier: identifier).select(:identifier, :id, :group, 'events.name as event_name', 'events.competition_id as comp_id', 'comp.name as comp_name').take
    if team.present?
      players = TeamUserShip.joins('left join user_profiles up on up.user_id = team_user_ships.user_id').where(team_id: team.id).select('up.username', 'up.grade', 'up.gender')
      result = {status: true, identifier: team.identifier, group: team.group, event_name: team.event_name, comp_name: team.comp_name, players: players}
    else
      result = {status: false, message: '该队伍编码不存在'}
    end
    result
  end
end