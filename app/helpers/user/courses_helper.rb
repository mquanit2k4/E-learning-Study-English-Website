module User::CoursesHelper
  def enrolment_status_options
    [
      [t(".status_all"), nil],
      [t(".pending"), :pending],
      [t(".rejected"), :rejected],
      [t(".approved"), :approved],
      [t(".in_progress"), :in_progress],
      [t(".completed"), :completed],
      [t(".not_enrolled"), :not_enrolled]
    ]
  end
end
