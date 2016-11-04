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
end