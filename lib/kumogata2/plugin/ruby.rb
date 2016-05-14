require 'base64'
require 'dslh'

require 'kumogata2'
require 'kumogata2/plugin/ruby/version'
require 'kumogata2/plugin/ruby/string_ext'
require 'kumogata2/plugin/ruby/context'

class Kumogata2::Plugin::Ruby
  Kumogata2::Plugin.register(:ruby, ['rb'], self)

  IGNORE_METHODS = [:system]

  def initialize(options)
    @options = options
  end

  def parse(str)
    context = Kumogata2::Plugin::Ruby::Context.new(@options)
    context.instance_eval(str, @options.path_or_url)
    @post = context.instance_variable_get(:@_post)
    context.instance_variable_get(:@_template)
  end

  def dump(hash)
    devaluate_template(hash).colorize_as(:ruby)
  end

  def post(outputs)
    if @post
      @post.call(outputs)
    end
  end

  private

  def devaluate_template(template)
    exclude_key = proc do |k|
      k = k.to_s.gsub('::', '__')
      k !~ /\A[_a-z]\w+\Z/i and k !~ %r|\A/\S*\Z|
    end

    key_conv = proc do |k|
      k = k.to_s

      if k =~ %r|\A/\S*\Z|
        proc do |v, nested|
          if nested
            "_path(#{k.inspect}) #{v}"
          else
            "_path #{k.inspect}, #{v}"
          end
        end
      else
        k.gsub('::', '__')
      end
    end

    value_conv = proc do |v|
      if v.kind_of?(String) and v =~ /\A(?:0|[1-9]\d*)\Z/
        v.to_i
      else
        v
      end
    end

    dsl = Dslh.deval(template,
      key_conv: key_conv,
      value_conv: value_conv,
      exclude_key: exclude_key
      ignore_methods: IGNORE_METHODS)

    dsl.gsub!(/^/, '  ').strip!

    <<-EOS
template do
  #{dsl}
end
    EOS
  end
end
