module Themer
  class Builder
    property theme = Theme.new

    def for(id : String, **args)
      color = Color.new.set **args
      @theme[id] = color
      @theme
    end

    def default(**args)
      @theme.default = Color.new.set(**args)
    end
  end
end
