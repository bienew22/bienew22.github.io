# frozen_string_literal: true

require "open-uri"
require "nokogiri"
require "uri"

module Jekyll
  class LinkCardTag < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
      @url = text.strip
    end

    def render(context)
      begin
        # --- 페이지 요청 (403 방지 User-Agent 적용) ---
        html = URI.open(@url,
          "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "\
                          "AppleWebKit/537.36 (KHTML, like Gecko) "\
                          "Chrome/125.0.0.0 Safari/537.36",
          "Accept" => "text/html",
          "Accept-Language" => "ko-KR,ko;q=0.9"
        ).read

        doc = Nokogiri::HTML.parse(html)

        # --- OpenGraph 정보 추출 ---
        title = doc.at('meta[property="og:title"]')&.[]("content") ||
                doc.at("title")&.text ||
                @url

        desc = doc.at('meta[property="og:description"]')&.[]("content") ||
               doc.at('meta[name="description"]')&.[]("content") ||
               " "

        image = doc.at('meta[property="og:image"]')&.[]("content") || ""

        domain = URI.parse(@url).host
        fallback = domain[0,2].upcase  # 이미지 없을 때 카드에 표시할 Fallback

        # --- HTML 출력 ---
        <<~HTML
        <div class="my_link_card">
          <a class="my_link_card_overlay"
            href="#{@url}"
            target="_blank"
            rel="noopener noreferrer"
            aria-label="#{title}"></a>

          <div class="my_link_card_thumb">
            <div class="my_link_card_bg" style="background-image: url('#{image}')"></div>
          </div>

          <div class="my_link_card_body">
            <div class="my_link_card_title">#{title}</div>
            <div class="my_link_card_desc">#{desc}</div>
            <div class="my_link_card_domain">#{domain}</div>
          </div>

        </div>
        HTML

      rescue => e
        "<p>LinkCard Error: #{e.message}</p>"
      end
    end
  end
end

Liquid::Template.register_tag("linkcard", Jekyll::LinkCardTag)
