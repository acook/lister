module Terminal
  lib C
    struct Dimensions
      rows : UInt16
      cols : UInt16
      hpixels : UInt16
      vpixels : UInt16
    end

    enum TIOCGWINSZ
      Default = 0x40087468
    end

    fun ioctl(fd : Int32, command : UInt32, ...) : Int32
  end

  STDOUT_FD = 1

  def self.width
    size.last
  end

  def self.size
    screen_size = C::Dimensions.new

    # TODO: Make this dynamic for other OSes
    tiocgwinsz = C::TIOCGWINSZ::Default

    # ioctl(fd : FD, tiocgwinsz : TIOCGWINSZ, dimensions : Pointer(Dimensions))
    result = C.ioctl STDOUT_FD, tiocgwinsz, pointerof(screen_size)

    if result == 0
      return [screen_size.rows, screen_size.cols]
    else
      p " -- TIOCGWINSZ = #{tiocgwinsz}"
      p " -- debug: ioctrl failed for some reason"
      err = Errno.new "ioctl failed to get window size"
      p " -- errno: #{err}"
      raise err
      return [UInt16::MAX, UInt16::MAX]
    end
  end
end
