require 'rails/generators'

module Generators
  module Rails
    module WebpackerAssets
      class WebpackerAssetsGenerator < ::Rails::Generators::NamedBase
        def create_assets_file
          create_file "app/javascript/packs/#{file_name}.js", <<-FILE
        // your content
          FILE
          create_file "app/assets/stylesheets/#{file_name}.scss", <<-FILE
        // your content
          FILE
        end
      end
    end
  end
end