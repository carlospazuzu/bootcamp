# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
# Add Yarn node_modules folder to the asset load path.
Rails.application.config.assets.paths << Rails.root.join('node_modules')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in the app/assets
# folder are already added.
# Rails.application.config.assets.precompile += %w( admin.js admin.css )
Rails.application.config.assets.precompile += %w( application.css lp.css completion.css )

# Rubyが落ちるエラーがあり、原因としてSprocketsの関係で、assetsが並列でコンパイルされていることが考えられる。
# ソースは以下。
# https://github.com/rails/sprockets/issues/581
# https://www.tmp1024.com/articles/fix-rails-6-segmentation-error
# そのため、assetsの並列コンパイルをやめる設定を記述した。
Rails.application.config.assets.configure do |env|
  env.export_concurrent = false
end
