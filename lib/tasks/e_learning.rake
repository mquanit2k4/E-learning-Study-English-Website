namespace :e_learning do
  desc "Nhắc nhở học viên: khóa học còn 7 ngày kết thúc mà tiến độ < 50%"
  task remind_deadline: :environment do
    ELeaningTasks.remind_deadline
  end
end

module ELeaningTasks
  module_function

  def remind_deadline
    puts "=== Bắt đầu nhắc nhở học viên khi khóa học sắp kết thúc ==="

    target_date = 7.days.from_now.to_date
    user_courses = fetch_target_user_courses(target_date)
    puts "Tìm thấy #{user_courses.count} user_courses sắp kết thúc sau 7 ngày"

    mail_count = process_user_courses(user_courses)

    puts ">>> Hoàn tất! Đã gửi #{mail_count} email nhắc nhở"
  end

  def fetch_target_user_courses target_date
    UserCourse.includes(:user, :course)
              .where(end_date: target_date)
              .where(enrolment_status: %i(in_progress approved))
  end

  def process_user_courses user_courses
    mail_count = 0
    user_courses.find_each do |user_course|
      puts "Kiểm tra: #{user_course.user.email} - #{user_course.course.title}"

      progress = user_course.progress || 0
      if progress < 50
        send_reminder(user_course, progress)
        mail_count += 1
      else
        puts "- Bỏ qua #{user_course.user.email} " \
             "(tiến độ: #{progress}% >= 50%)"
      end
    end
    mail_count
  end

  def send_reminder user_course, progress
    ReminderMailer.course_deadline_warning(user_course.id).deliver_now
    puts "- Đã gửi mail cho #{user_course.user.email} " \
         "(#{user_course.course.title}, progress: #{progress}%)"
  rescue StandardError => e
    puts "- Lỗi khi gửi mail cho #{user_course.user.email}: #{e.message}"
  end
end
