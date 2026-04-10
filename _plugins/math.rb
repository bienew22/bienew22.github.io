# _plugins/math/math_tag.rb
module Jekyll
  class MyMathExp < Liquid::Tag
    def initialize(tag_name, markup, tokens)
      super
      @markup = markup
    end

    def render(context)
      text, inline = parse_args(@markup)

      result = parse_pow(text)

      if inline
        "<code class=\"language-plaintext highlighter-rouge my-inline-code\">#{result.strip}</code>"
      else
        result.strip
      end
    end

    private

    # -------------------------
    # argument parsing
    # -------------------------
    def parse_args(markup)
      # 기본값
      inline = true

      # inline=false 파싱
      if markup.include?("inline=false")
        inline = false
        markup = markup.gsub("inline=false", "")
      end

      # 문자열 추출 (따옴표 제거)
      text = markup.strip.gsub(/^"(.*)"$/, '\1')

      [text, inline]
    end

    # -------------------------
    # pow 파싱
    # -------------------------
    def parse_pow(text)
      text.gsub(/\{\{(.*?)\^(.*?)\}\}/) do
        base = $1.strip
        exp  = $2.strip

        "<span class=\"math-power\"><span class=\"math-power__base\">#{base}</span><sup class=\"math-power__exp\">#{exp}</sup></span>"
      end
    end
  end
end

Liquid::Template.register_tag('math', Jekyll::MyMathExp)