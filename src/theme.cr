module Lister
  class Theme
    module Color
      def reset_line
        "\033[0m\033[K"
      end

      def fg(color_name)
        esc style(:normal), "3#{color color_name}"
      end

      def fgb(color_name)
        esc style(:bright), "3#{color color_name}"
      end

      def bg(color_name)
        esc style(:normal), "4#{color color_name}"
      end

      def esc(style, color_code)
        "\033[#{style};#{color_code}m"
      end

      def color(name)
        COLORS.index name
      end

      def style(name)
        STYLES.index name
      end

      COLORS = %i[black red green yellow blue magenta cyan white]
      STYLES = %i[normal bright underlined]
    end

    extend Color

    COLOR_MAP = {
      /broken|NOT FOUND|cannot open/ => bg(:red),
      /bash|Bourne/      => fg(:green),
      /zsh/              => fg(:blue),
      /shell|SHELL/      => fg(:magenta),
      /perl/             => fg(:yellow),
      /ruby/             => fg(:red),
      /python/           => fg(:cyan),
      /x86|i386/         => fgb(:blue),
      /link|socket/      => fgb(:yellow),
      /directory/        => fgb(:black),
      /program/          => fgb(:yellow),
      /GIF/              => fgb(:magenta),
      /doom|PWAD/        => fgb(:green),
    }

    property entry : Entry

    def initialize(entry)
      @entry = entry
    end

    def color
      COLOR_MAP.find do |regex, ansi|
        break ansi if regex =~ @entry.type
      end || "\033[0m"
    end

  end
end
