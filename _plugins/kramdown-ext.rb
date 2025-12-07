require "kramdown"

module Kramdown
    module Converter
        class Html

            # 원래 html.rb에 있는 :covert_p에 백업 함수를 추가하여
            # .md -> kramdown -> Kramdown::Element -> html.rb -> .html
            # 여기는 htrml.rb에서 번역을 이어서 수행 함.
            # 기본 적으로 새로 추가한 문법은 모두 :text 타입으로 인식될 예정 이므로
            # :convert_p 함수에 해대서만 백업을 수행하면 됨.
            #
            # 추가로 수정하고 싶은 부분이 생길 시 -> /gems/gems/kramdown 코드를 봐야 함.
            # - element.rb 에서 el 대해 정리되어 있음.
            
            
            # 원래 p 변환 함수 백업
            alias_method :orig_convert_p, :convert_p
            
            def convert_p(el, indent)
                # <> 문장 : 임의로 코드 테스트용 문법 추가
                # 로직에 내가 한 것대로 동작하는 지 확인하기 위함.
                if el.children.any? && el.children.first.type == :text
                    text = el.children.first.value

                    if text.start_with?("<> ")
                        el.children.first.value = text.sub(/\A<>\s+/, "")

                        attr = el.attr.dup

                        style_str = "background-color: red; padding: 0.5rem 0.75rem;"
                        if attr["style"] && !attr["style"].empty?
                            attr["style"] = attr["style"] + "; " + style_str
                        else
                            attr["style"] = style_str
                        end

                        body = inner(el, indent)
                        return format_as_block_html("div", attr, body, indent)
                    end
                end

                # 나머지 문단을 원래 처럼 렌더링.
                orig_convert_p(el, indent)            
            end
        end
    end
end
