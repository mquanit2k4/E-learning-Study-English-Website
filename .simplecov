SimpleCov.start "rails" do
  add_filter do |source_file|
    !source_file.filename.include?("app/models/test.rb")
  end

  add_group "Models", "app/models"

  minimum_coverage 50
  minimum_coverage_by_file 50

  formatter SimpleCov::Formatter::HTMLFormatter

  refuse_coverage_drop
end
