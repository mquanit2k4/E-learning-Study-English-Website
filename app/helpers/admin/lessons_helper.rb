module Admin::LessonsHelper
  def filter_time_options
    [
      [t("admin.lessons.index.filters.all"), :all],
      [t("admin.lessons.index..filters.today"), :today],
      [t("admin.lessons.index..filters.last_7_days"), :last_7_days],
      [t("admin.lessons.index..filters.last_30_days"), :last_30_days]
    ]
  end
end
