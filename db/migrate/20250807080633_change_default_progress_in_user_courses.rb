class ChangeDefaultProgressInUserCourses < ActiveRecord::Migration[7.0]
  def change
    change_column_default :user_courses, :progress, from: nil, to: 0
  end
end
