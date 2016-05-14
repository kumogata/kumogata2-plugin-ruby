class Kumogata2::Plugin::Ruby::Context
  IGNORE_METHODS = [:system]

  def initialize(options)
    @options = options
  end

  def template(&block)
    key_converter = proc do |key|
      key = key.to_s
      key.gsub!('__', '::') unless @options.skip_replace_underscore?
      key
    end

    value_converter = proc do |v|
      case v
      when Hash, Array
        v
      else
        v.to_s
      end
    end

    @_template = Dslh.eval({
      key_conv: key_converter,
      value_conv: value_converter,
      scope_hook: proc {|scope|
        define_template_func(scope, @options.path_or_url)
      },
      filename: @options.path_or_url,
      ignore_methods: IGNORE_METHODS,
    }, &block)
  end

  def post(&block)
    @_post = block
  end

  private

  def define_template_func(scope, path_or_url)
    scope.instance_eval(<<-EOS)
      def _include(file, args = {})
        path = file.dup

        unless path =~ %r|\\A/| or path =~ %r|\\A\\w+://|
          path = File.expand_path(File.join(File.dirname(#{path_or_url.inspect}), path))
        end

        open(path) {|f| instance_eval(f.read) }
      end

      def _path(path, value = nil, &block)
        if block
          value = Dslh::ScopeBlock.nest(binding, 'block')
        end

        @__hash__[path] = value
      end
    EOS
  end
end
