class AddFieldsToUserCoursesAndCourses < ActiveRecord::Migration[7.0]
  def change
    add_column :user_courses, :reason, :text
    add_column :user_courses, :start_date, :date
    add_column :user_courses, :end_date, :date

    add_column :courses, :duration, :integer, null: false, default: 0
  end
end
