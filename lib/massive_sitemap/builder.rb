# Copyright (c) 2012, SoundCloud Ltd., Tobias Bielohlawek

require "massive_sitemap/builder/base"

module MassiveSitemap
  module Builder
    #shortcut
    def new(writer, options = {}, &block)
      Base.new(writer, options, &block)
    end
    module_function :new

  end
end
