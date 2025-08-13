class ChangeGradeDefaultInUserLessons < ActiveRecord::Migration[7.0]
  def change
    change_column_default :user_lessons, :grade, 0
    add_index :courses, :title, unique: true
  end
end
