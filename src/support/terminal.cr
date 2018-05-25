class Terminal
  lib C
    struct Dimensions
      rows : UInt16
      cols : UInt16
      hpixels : UInt16
      vpixels : UInt16
    end

    fun ioctl(fd : Int32, command : UInt32, ...) : Int32
  end

  enum FD
    STDIN = 0
    STDOUT = 1
    STDERR = 2
  end

  {% if flag?(:linux) %}
    TIOCGWINSZ = 0x5413
  {% elsif flag?(:darwin) %}
    TIOCGWINSZ = 0x40087468
  {% else %} # will cause ioctl to always return -1
    TIOCGWINSZ = 0x00
  {% end %}

  property fd : FD = FD::STDOUT

  def initialize(fd = FD::STDOUT)
    @fd = fd
  end

  def width
    size.last
  end

  def size
    dimensions = C::Dimensions.new
    # ioctl(fd : FD, tiocgwinsz : TIOCGWINSZ, dimensions : Pointer(Dimensions))
    result = C.ioctl fd, TIOCGWINSZ, pointerof(dimensions)

    if result == 0
      [dimensions.rows, dimensions.cols]
    else
      err = Errno.new "ioctl failed to get window size (TIOCGWINSZ=#{TIOCGWINSZ}"
      if err.errno == Errno::ENOTTY
        # NOTE: this just means we've gotten something that isn't a TTY,
        # so we shouldn't truncate the output,
        # we still do for very long lines, so we can fit in a UInt16
        # but hopefully that never comes up... (famous last words)
        [UInt16::MAX, UInt16::MAX]
      else
        # NOTE: if we're hitting this error,
        # then the TIOCGWINSZ is probably fubar for this platform
        raise err
      end
    end
  end
end
