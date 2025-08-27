class ReminderMailer < ApplicationMailer
  default from: Settings.default_mail_from

  def course_deadline_warning user_course_id
    @user_course = UserCourse.includes(:user, :course).find(user_course_id)
    @user = @user_course.user
    @course = @user_course.course
    @progress = @user_course.progress || 0
    @days_remaining = (@user_course.end_date - Date.current).to_i

    mail(
      to: @user.email,
      subject: I18n.t("reminder_mailer.course_deadline_warning.subject",
                      course_title: @course.title)
    )
  end
end
