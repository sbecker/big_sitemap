require "massive_sitemap/builder/base"

module MassiveSitemap
  module Builder

    def new(writer, options = {}, &block)
      Base.new(writer, options, &block)
    end
    module_function :new

  end
end
