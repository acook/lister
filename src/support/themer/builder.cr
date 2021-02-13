module Themer
  class Builder
    property theme = Theme.new

    def for(id : String, **args)
      color = Colorset.new **args
      @theme[id] = color
      @theme
    end

    def default(**args)
      @theme.default = Colorset.new(**args)
    end
  end
end
