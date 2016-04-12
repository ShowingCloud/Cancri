class CompetitionService
  def self.get_competitions
    Competition.includes(:competition_schedules).map { |x| {
        id: x.id,
        name: x.name,
        status: x.status,
        guide_units: x.guide_units,
        organizer_units: x.organizer_units,
        help_units: x.help_units,
        support_units: x.support_units,
        undertake_units: x.undertake_units,
        schedule: x.competition_schedules.select(:name, :start_time, :end_time).order('start_time asc').map { |s| {
            step: s.name,
            start_time: s.start_time,
            end_time: s.end_time=='' ? nil : s.end_time
        } }
    } }
  end

  def self.get_event_score_attrs(event_id)
    EventSaShip.includes(:score_attribute, :score_attribute_parent).where(event_id: event_id, is_parent: 0).order('parent_id asc').map { |s| {
        id: s.id,
        name: s.level==1 ? s.score_attribute.name : s.score_attribute_parent.name+': '+ s.score_attribute.name,
        desc: s.desc.blank? ? nil : s.desc
    } }
  end

  def self.post_team_scores(ed, schedule_name, kind, th, t1d, t2d, score1, score2, note, confirm_sign)
    if confirm_sign.present?
      if kind == 2 # 对抗
        if t2d.blank? || score2.blank?
          result = [false, '对抗模式下，队伍和成绩均为两个信息']
        elsif score1.length!=1 || (score1.first[1] != '1' && score1.first[1] != '0') || (score2 != '0' && score2 != '1')
          result = [false, '对抗模式下，比分只能为1或0']
        else
          a_s = Score.where(event_id: ed, schedule_name: schedule_name, kind: kind, th: th, team1_id: t1d, team2_id: t2d, score1: score1.first[1], score2: score2).take
          if a_s.present?
            result = [false, '该成绩已登记，请检查场次或其他信息']
          else
            score = Score.create!(event_id: ed, schedule_name: schedule_name, kind: kind, th: th, team1_id: t1d, team2_id: t2d, score1: score1.first[1], score2: score2, note: note, confirm_sign: confirm_sign)
            if score.save
              result = [true, '成绩保存成功!']
            else
              result = [false, '成绩保存失败!']
            end
          end
        end
      elsif kind ==1 # 评分
        if score1.blank?
          result = [false, '请至少输入一项成绩']
        else
          a_s = Score.where(event_id: ed, schedule_name: schedule_name, kind: kind, th: th, team1_id: t1d).take
          if a_s.present?
            result = [false, '该成绩已登记，请检查场次或其他信息']
          else
            r=[]
            score1.each_with_index do |index, s|
              if index == 1
                score = Score.create!(event_id: ed, schedule_name: schedule_name, kind: kind, th: th, team1_id: t1d, score_attribute: s[0], score1: s[1], note: note, confirm_sign: confirm_sign)
              else
                score = Score.create!(event_id: ed, schedule_name: schedule_name, kind: kind, th: th, team1_id: t1d, score_attribute: s[0], score1: s[1], note: note)
              end
              if score.save
                r = [true]+r
              else
                r = [s[0]]+r
              end
            end
            if r.count(true)== score1.length
              r = [true, '保存成功']
            else
              r = [false, r.delete(true).join(',')+'保存失败']
            end
            result = r
          end
        end
      else
        result = [false, '赛制数据不合法']
      end
    else
      result = [false, '无队员签名确认，该成绩不能上传']
    end
    result
  end

  def self.get_events(comp_id)
    Event.where(competition_id: comp_id).joins(:teams).where('teams.event_id=events.id')
  end
end