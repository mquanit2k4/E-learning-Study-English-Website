set :environment, :development
set :output, "log/cron_dev.log"

every 1.day, at: "9:00 am" do
  rake "e_learning:remind_deadline"
end


