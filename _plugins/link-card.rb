# frozen_string_literal: true

require "open-uri"
require "nokogiri"
require "uri"
require "json"
require "openssl"
require "resolv-replace"

module Jekyll
  class LinkCardTag < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
      @url = text.strip
    end

    def render(context)
      # 죽은 도메인 바로 차단
      return default_meta_render if blocked_domain?(@url)

      meta = fetch_og(@url) || {}

      build_card({
        title:  meta[:title]  || @url,
        desc:   meta[:desc]   || "링크를 확인해보세요.",
        image:  meta[:image]  || "/assets/default-thumbnail.png",
        domain: meta[:domain] || safe_domain(@url)
      })
    end

    private

    # 차단 도메인 리스트
    def blocked_domain?(url)
      host = URI.parse(url).host rescue nil
      return false unless host

      blocked = [
        "www.acmicpc.net", # 언젠가 부활하길.
      ]

      blocked.include?(host)
    end

    # 기본 카드 - 차단 또는 잘 못된 링크인 경우.
    def default_meta_render
      build_card({
        title:  @url,
        desc:   "링크를 확인해보세요.",
        image:  "/assets/img/default/default-link-thumbnail.png",
        domain: safe_domain(@url)
      })
    end

    # 카드 HTML 생성
    def build_card(meta)
      title  = meta[:title]
      desc   = meta[:desc]
      image  = meta[:image]
      domain = meta[:domain]

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
    end

    # 안전한 도메인 파싱
    def safe_domain(url)
      URI.parse(url).host
    rescue
      url
    end

    # OG 스크래핑
    def fetch_og(url)
      html = URI.open(
        url,
        "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "\
                        "AppleWebKit/537.36 (KHTML, like Gecko) "\
                        "Chrome/125.0.0.0 Safari/537.36",
        "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "Accept-Language" => "ko-KR,ko;q=0.9",
        open_timeout: 3,
        read_timeout: 3,
        ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE
      ).read

      doc = Nokogiri::HTML.parse(html)

      title = doc.at('meta[property="og:title"]')&.[]("content") ||
              doc.at("title")&.text

      desc = doc.at('meta[property="og:description"]')&.[]("content") ||
             doc.at('meta[name="description"]')&.[]("content")

      image = doc.at('meta[property="og:image"]')&.[]("content")

      domain = URI.parse(url).host rescue url

      {
        title: title,
        desc: desc,
        image: image,
        domain: domain
      }
    rescue
      nil
    end
  end
end

Liquid::Template.register_tag("linkcard", Jekyll::LinkCardTag)