module Admin::UserCoursesHelper
  def status_badge status
    case status.to_sym
    when :pending
      content_tag :span, t("helpers.admin.user_courses.status.pending"),
                  class: "badge bg-warning text-dark"
    when :approved
      content_tag :span, t("helpers.admin.user_courses.status.approved"),
                  class: "badge bg-success"
    when :rejected
      content_tag :span, t("helpers.admin.user_courses.status.rejected"),
                  class: "badge bg-danger"
    else
      content_tag :span, status.to_s.humanize, class: "badge bg-secondary"
    end
  end

  def status_filter_options
    [
      [t("admin.user_courses.index.status_options.all"), ""],
      [t("admin.user_courses.index.status_options.pending"), :pending],
      [t("admin.user_courses.index.status_options.approved"), :approved],
      [t("admin.user_courses.index.status_options.rejected"), :rejected],
      [t("admin.user_courses.index.status_options.in_progress"), :in_progress],
      [t("admin.user_courses.index.status_options.completed"), :completed]
    ]
  end

  def course_filter_options
    [[t("admin.user_courses.index.status_options.all"), ""]] +
      Course.pluck(:title, :id)
  end
end
