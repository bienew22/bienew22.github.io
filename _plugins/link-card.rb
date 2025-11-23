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
      @boj_cache ||= {}
    end

    def render(context)
      begin
        meta =
          if boj_problem_url?(@url)
            fetch_boj_via_solvedac(@url) || fetch_og(@url)
          else
            fetch_og(@url)
          end

        title   = meta[:title]
        desc    = meta[:desc]
        image   = meta[:image]
        domain  = meta[:domain]

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

    private

    # 백준 문제 URL 판별 (/problem/12345)
    def boj_problem_url?(url)
      url.match?(%r{\Ahttps?://(www\.)?acmicpc\.net/problem/\d+})
    end

    # solved.ac로 백준 메타 가져오기
    def fetch_boj_via_solvedac(url)
      pid = url[%r{/problem/(\d+)}, 1]
      return nil unless pid

      # 빌드 중 중복 호출 방지 캐시
      return @boj_cache[pid] if @boj_cache.key?(pid)

      api = "https://solved.ac/api/v3/problem/lookup?problemIds=#{pid}"

      json = URI.open(
        api,
        "User-Agent" => "Mozilla/5.0",
        "Accept" => "application/json",
        open_timeout: 5,
        read_timeout: 5
      ).read

      data = JSON.parse(json)
      prob = data&.first
      return nil unless prob

      title_ko = prob["titleKo"] || prob["title"] || pid

      meta = {
        title:  "#{pid}번: #{title_ko}",
        desc:   (prob["titles"]&.first&.dig("title") || title_ko),
        # 썸네일로 티어 아이콘 쓰고 싶으면:
        image:  "https://onlinejudgeimages.s3-ap-northeast-1.amazonaws.com/images/boj-og.png",
        domain: "www.acmicpc.net"
      }

      @boj_cache[pid] = meta
      meta
    rescue
      nil
    end

    # 기존 OG 스크래핑 로직
    def fetch_og(url)
      html = URI.open(url,
        "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "\
                        "AppleWebKit/537.36 (KHTML, like Gecko) "\
                        "Chrome/125.0.0.0 Safari/537.36",
        "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "Accept-Language" => "ko-KR,ko;q=0.9",
        open_timeout: 5,
        read_timeout: 5,
        ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE # SSL 이슈 있을 때만
      ).read

      doc = Nokogiri::HTML.parse(html)

      title = doc.at('meta[property="og:title"]')&.[]("content") ||
              doc.at("title")&.text ||
              url

      desc = doc.at('meta[property="og:description"]')&.[]("content") ||
             doc.at('meta[name="description"]')&.[]("content") ||
             " "

      image = doc.at('meta[property="og:image"]')&.[]("content") || ""

      domain = URI.parse(url).host

      {
        title: title,
        desc: desc,
        image: image,
        domain: domain
      }
    end
  end
end

Liquid::Template.register_tag("linkcard", Jekyll::LinkCardTag)
