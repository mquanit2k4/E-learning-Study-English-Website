module Admin::WordsHelper
  WORD_FORM_ROW = 3

  def filter_time_options
    [
      [t("admin.words.index.filters.all"), :all],
      [t("admin.words.index..filters.today"), :today],
      [t("admin.words.index..filters.last_7_days"), :last_7_days],
      [t("admin.words.index..filters.last_30_days"), :last_30_days]
    ]
  end
end
