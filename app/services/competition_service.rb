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
end