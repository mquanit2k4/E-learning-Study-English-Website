class Ability
  include CanCan::Ability

  def initialize user
    user ||= User.new

    case user.role
    when "admin"
      admin_abilities
    when "user"
      user_abilities(user)
    else
      guest_abilities
    end
  end

  private

  def admin_abilities
    can :manage, :all
    can :access, :admin
  end

  def user_abilities user
    can :access, :user

    profile_access(user)
    word_access
    test_access(user)
    lesson_access(user)
    course_access(user)
  end

  def profile_access user
    can %i(show edit update), User, id: user.id
  end

  def word_access
    can :read, Word
  end

  def test_access user
    can %i(read update), TestResult, user_id: user.id
  end

  def lesson_access user
    can %i(show study test_history), Lesson do |lesson|
      lesson.course.user_courses.exists?(user_id: user.id,
                                         enrolment_status: %i(in_progress
                                                              completed))
    end
  end

  def course_access user
    can :enroll, Course
    can :start, Course do |course|
      user.user_courses.exists?(course_id: course.id,
                                enrolment_status: :approved)
    end
    can :show, Course do |course|
      user.user_courses.exists?(course_id: course.id,
                                enrolment_status: %i(in_progress completed))
    end
  end

  def guest_abilities
    can :read, Course
  end
end
