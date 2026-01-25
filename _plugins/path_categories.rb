# frozen_string_literal: true

module Jekyll
  # _posts 하위 폴더 경로를 categories로 자동 주입
  # 예) _posts/api/test/2026-01-25-com.md  -> categories: ["api", "test"]
  class PathCategoriesGenerator < Generator
    safe false
    priority :highest

    POSTS_DIR_PREFIX = "_posts/"

    def generate(site)
      # Jekyll 4+: site.posts.docs 로 접근
      posts = site.posts&.docs || []

      posts.each do |doc|
        next unless doc.respond_to?(:path) && doc.path

        # Windows 경로 대응
        normalized = doc.path.tr("\\", "/")

        # _posts/ 이하 상대경로 추출
        rel = if normalized.include?(POSTS_DIR_PREFIX)
                normalized.split(POSTS_DIR_PREFIX, 2)[1]
              else
                # 테마/특수환경에서 _posts 경로가 다를 수 있어 fallback
                normalized
              end

        # 파일명 제외한 디렉토리 목록
        dirs = File.dirname(rel).tr("\\", "/").split("/")

        # "." 또는 비어있으면 (하위 폴더 없음) 스킵
        next if dirs.empty? || dirs == ["."]

        # 기존 categories가 있으면 덮어쓸지/합칠지 정책 선택
        # 1) 덮어쓰기:
        doc.data["categories"] = dirs

        # 2) 기존 categories를 유지하면서 경로 카테고리를 앞에 합치고 싶으면 아래로 교체:
        # existing = Array(doc.data["categories"]).map(&:to_s)
        # doc.data["categories"] = (dirs + existing).uniq
      end
    end
  end
end
