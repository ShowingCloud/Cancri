Kaminari.configure do |config|
  config.default_per_page = 20 # 每页个数
  config.max_per_page = nil  # 分页方法的名称
  config.window = 4
  config.outer_window = 0
  config.left = 0
  config.right = 0
  config.page_method_name = :per_page_kaminari
  config.param_name = :page
end
