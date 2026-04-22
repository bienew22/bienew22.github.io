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
        image:  meta[:image]  || "/assets/img/default/default-link-thumbnail.png",
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
      uri = URI.parse(url)
      host = uri.host

      if host&.include?("leetcode.com")
        return fetch_leetcode_og(url)
      end

      html = URI.open(
        url,
        "User-Agent" => "Mozilla/5.0",
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

    def fetch_leetcode_og(url)
      # 문제 제목 파싱
      uri = URI.parse(url)
      path = uri.path

      slug = path.match(%r{^/problems/([^/]+)/?})&.[](1)

      return nil unless slug
      
      # post 요청 보내기
      graphql = URI("https://leetcode.com/graphql")

      http = Net::HTTP.new(graphql.host, graphql.port)
      http.use_ssl = true
      
      req = Net::HTTP::Post.new(graphql)
      req["Content-Type"] = "application/json"
      req["user-agent"] = "Mozilla/5.0"

      req.body = {
        query: "query getQuestion($titleSlug: String!) { question(titleSlug: $titleSlug) { title content difficulty } }",
        variables: { titleSlug: slug}
      }.to_json

      res = http.request(req)

      json = JSON.parse(res.body)

      q = json.dig("data", "question")

      return nil unless q

      # HTML → 텍스트 변환
      text_desc = Nokogiri::HTML(q["content"]).text.strip.gsub(/\s+/, " ")[0..150]

      {
        title: "[#{q['difficulty']}] #{q['title']}",
        desc: text_desc,
        image: "https://leetcode.com/static/images/LeetCode_Sharing.png",
        domain: "leetcode.com"
      }
    rescue
      nil
    end

  end
end

Liquid::Template.register_tag("linkcard", Jekyll::LinkCardTag)