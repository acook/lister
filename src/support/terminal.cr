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

  enum TIOCGWINSZ
    Default = 0x40087468
    Wrong = 0x0 # this will always cause ioctl to return -1
  end

  property tiocgwinsz : TIOCGWINSZ = get_tiocgwinsz
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
    result = C.ioctl fd, tiocgwinsz, pointerof(dimensions)

    if result == 0
      [dimensions.rows, dimensions.cols]
    else
      err = Errno.new "ioctl failed to get window size (TIOCGWINSZ=#{tiocgwinsz}"
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

  def get_tiocgwinsz
    # TODO: Make this dynamic for other OSes
    # could also use ifdefs to set it at compile-time
    TIOCGWINSZ::Default
  end
end
