module DelegationMacros
  macro delegate_via(*methods, to object, via wrap)
    {% for method in methods %}
      def {{method.id}}(*args, **options)
        {{wrap.id}} {{object.id}}.{{method.id}}(*args, **options)
      end

      def {{method.id}}(*args, **options)
        {{wrap.id}} {{object.id}}.{{method.id}}(*args, **options) do |*yield_args|
          yield *yield_args
        end
      end
    {% end %}
  end

	macro delegate_attr(*methods, to object, using attr)
    {% for method in methods %}
      def {{method.id}}(*args, **options)
        {{object.id}}.{{method.id}}({{attr.id}}, *args, **options)
      end

      def {{method.id}}(*args, **options)
        {{object.id}}.{{method.id}}({{attr.id}}, *args, **options) do |*yield_args|
          yield *yield_args
        end
      end
    {% end %}
	end

	macro delegate_attr_via(*methods, to object, using attr, via wrap)
    {% for method in methods %}
      def {{method.id}}(*args, **options)
        {{wrap.id}} {{object.id}}.{{method.id}}({{attr.id}}, *args, **options)
      end

      def {{method.id}}(*args, **options)
        {{wrap.id}} {{object.id}}.{{method.id}}({{attr.id}}, *args, **options) do |*yield_args|
          yield *yield_args
        end
      end
    {% end %}
	end
end
