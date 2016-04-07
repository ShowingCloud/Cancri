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

  def self.post_team_scores(ed, schedule_name, kind, th, t1d, t2d, score_attribute, score1, score2, note)
    if kind == 2 # 对抗
      if t2d.blank? || score2.blank?
        result = [false, '对抗赛下，队伍和成绩均为两个信息']
      else
        score = Score.create!(event_id: ed, schedule_name: schedule_name, kind: kind, th: th, team1_id: t1d, team2_id: t2d, score1: score1, score2: score2, note: note)
        if score.save
          result = [true, '成绩保存成功!']
        else
          result = [false, '成绩保存失败!']
        end
      end
    elsif kind ==1 # 评分
      if score_attribute.blank?
        result = [false, '评分模式下，成绩属性必填']
      else
        score = Score.create!(event_id: ed, schedule_name: schedule_name, kind: kind, th: th, team1_id: t1d, score_attribute: score_attribute, score1: score1, note: note)
        if score.save
          result = [true, '成绩保存成功!']
        else
          result = [false, '成绩保存失败!']
        end
      end
    else
      result = [false, '赛制数据不合法']
    end
    result
  end
end