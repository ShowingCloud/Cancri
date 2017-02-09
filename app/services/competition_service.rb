class CompetitionService

  def self.get_event_score_attrs(event_id, schedule_id)
    EventSaShip.includes(:score_attribute, :score_attribute_parent).where(event_id: event_id, schedule_id: schedule_id, is_parent: 0).order('sort asc').map { |s| {
        id: s.id,
        name: s.level==1 ? s.score_attribute.name : s.score_attribute_parent.name+': '+ s.score_attribute.name,
        score_type: s.score_attribute.try(:write_type),
        value_type: s.score_attribute.try(:desc),
        in_rounds: s.in_rounds,
        formula: s.formula
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
    case has_score
      when '0' then
        team_sql.having('count(sc.id) = ?', 0)
      when '1' then
        team_sql.having('count(sc.id) > ?', 0)
      else
        team_sql
    end
  end

  def self.post_team_scores(event_id, schedule_id, kind, th, team1_id, score_attribute, formula, note, device_no, confirm_sign, operator_id)
    score_gs = JSON.parse(formula.strip)
    score_attribute = JSON.parse(score_attribute.strip)
    score_process = score_attribute['process']
    # score_gs = formula
    # score_attribute = score_attribute

    if score_gs.is_a?(Hash) && score_process.present?
      rounds = score_gs['rounds'].to_i
      order = score_gs['order']
      order_num = order['num']
      first_sort = order['1']['sort']
      formula = score_gs['formula']
      score_length = score_process.length
      if order_num == 2
        second_sort_by = order['2']['id']
      end
      if order_num == 3
        second_sort_by = order['2']['id']
        third_sort_by = order['3']['id']
      end
      if rounds == score_length # 成绩轮数与规定相同
        rounds_score =[] # 多轮最终成绩的集合
        score_process.each do |val|
          if val['valid']
            last_score_by_id = score_gs['last_score_by']['id']

            if last_score_by_id =='0' || ((score_gs['trigger_attr']['id'].length >0) && (val["#{score_gs['trigger_attr']['id']}"]['val'] == score_gs['trigger_attr']['val']))
              one_round_score = 0.0
              formula.each do |f|
                if f['id'] == '0'
                  formula_ele = (event_id == '27' && val['76'].present? && (val['76']['val'].to_f > 100)) ? 30 : f['xishu']
                else
                  formula_ele = (val["#{f['id']}"]['val']).to_f*f['xishu']
                end

                case f['symbol'].to_i
                  when 1
                    one_round_score+=formula_ele
                  when 2
                    one_round_score-=formula_ele
                  when 3
                    one_round_score*=formula_ele
                  when 4
                    one_round_score/=formula_ele
                  else
                    one_round_score+=formula_ele
                end
              end

              one_round_score = one_round_score.round(2)
              if event_id.to_i == 30 # 云霄飞车
                one_round_score = one_round_score.abs
              end

              case order_num
                when 1
                  rounds_score << [one_round_score.round(2), 0, 0]
                when 2
                  rounds_score << [one_round_score.round(2), val["#{second_sort_by}"]['val'].to_f, 0]
                when 3
                  rounds_score << [one_round_score.round(2), val["#{second_sort_by}"]['val'].to_f, val["#{third_sort_by}"]['val'].to_f]
                else
                  rounds_score << [one_round_score.round(2), 0, 0]
              end
            else ## 不用公式
              case order_num
                when 1
                  rounds_score << [val["#{last_score_by_id}"]['val'].to_f.round(2), 0, 0]
                when 2
                  rounds_score << [val["#{last_score_by_id}"]['val'].to_f.round(2), val["#{second_sort_by}"]['val'].to_f, 0]
                when 3
                  rounds_score << [val["#{last_score_by_id}"]['val'].to_f.round(2), val["#{second_sort_by}"]['val'].to_f, val["#{third_sort_by}"]['val'].to_f]
                else
                  rounds_score << [val["#{last_score_by_id}"]['val'].to_f.round(2), 0, 0]
              end
            end
          else
            rounds_score << 'invalid'
          end
        end

        last_score = rounds_score - ['invalid']
        if last_score ==[]
          last_score = [[-10000, 0]]
        else
          case order_num
            when 1
              last_score = last_score.sort_by { |h| ["#{(first_sort == 1) ? h[0] : -h[0]}".to_f] }
            when 2
              last_score = last_score.sort_by { |h| ["#{(first_sort == 1) ? h[0] : -h[0]}".to_f, "#{ (order['2']['sort'] ==1) ? h[1] : -h[1]}".to_f] }
            when 3
              last_score = last_score.sort_by { |h| ["#{(first_sort == 1) ? h[0] : -h[0]}".to_f, "#{ (order['2']['sort'] ==1) ? h[1] : -h[1]}".to_f, "#{ (order['3']['sort'] ==1) ? h[2] : -h[2]}".to_f] }
            else
              last_score = last_score.sort_by { |h| ["#{(first_sort == 1) ? h[0] : -h[0]}".to_f] }
          end
        end
        score_attribute['rounds_scores'] = rounds_score
        score_row = Score.where(event_id: event_id, schedule_id: schedule_id, kind: kind, th: th, team1_id: team1_id).take
        if score_row.present?
          if score_row.update_attributes(score_attribute: score_attribute, score: last_score[0][0], order_score: last_score[0][1], sort_score: last_score[0][2], schedule_rank: nil, note: note, device_no: device_no, confirm_sign: confirm_sign, user_id: operator_id)
            result = [true, '成绩更新成功']
          else
            result = [false, '成绩更新失败']
          end
        else
          score_row = Score.create(event_id: event_id, schedule_id: schedule_id, kind: kind, th: th, team1_id: team1_id, score_attribute: score_attribute, score: last_score[0][0], order_score: last_score[0][1], sort_score: last_score[0][2], note: note, device_no: device_no, confirm_sign: confirm_sign, user_id: operator_id, last_score: true)
          if score_row.save
            result =[true, '成绩保存成功']
          else
            result =[false, '成绩保存失败']
          end
        end
      else
        result = [false, '成绩轮数为'+rounds.to_s+',您传了'+score_length.to_s+' 轮']
      end
    else
      result = [false, '公式或成绩不存在,请联系工作人员']
    end
    {status: result[0], message: result[1]}
  end

  def self.via_identifier_get_team(identifier)
    team = Team.joins(:event, :school).joins('left join competitions comp on comp.id = events.competition_id').where(identifier: identifier).select(:identifier, :id, :group, :teacher, 'events.name as event_name', 'events.competition_id as comp_id', 'comp.name as comp_name', 'schools.name as school_name').take
    if team.present?
      players = TeamUserShip.joins('left join user_profiles up on up.user_id = team_user_ships.user_id').where(team_id: team.id).select(:id, :status, 'up.username', 'up.grade', 'up.bj', 'up.gender','up.birthday')
      result = {status: true, identifier: team.identifier, team_id: team.id, teacher: team.teacher, school_name: team.school_name, group: team.group, event_name: team.event_name, comp_name: team.comp_name, players: players}
    else
      result = {status: false, message: '该队伍编码不存在'}
    end
    result
  end
end