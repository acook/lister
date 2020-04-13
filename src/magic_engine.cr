module Lister
  class MagicEngine
    property options : Options | Nil

    property magic : Magic::TypeChecker
    property magic_mime : Magic::TypeChecker

    def initialize(options = nil)
      @options = options

      # the default flags set it to only return MIME types,
      #   which is an extremely limited subset of possible types
      #   the below line could be used instead, but
      #   the current flags also search compressed files
      (@magic = Magic::TypeChecker.new).look_into_compressed_files.return_error_as_text
      (@magic_mime = Magic::TypeChecker.new).get_mime_type.return_error_as_text
    end

    def type(entry)
      raw_type = magic.of entry
      # remove the full path prefix from libmagic's result
      raw_type.sub(/^#{entry}:\s+/, "").strip
    end

    def mime(entry)
      magic_mime.file entry
    end
  end
end
