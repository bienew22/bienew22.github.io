---
title: "[Algorithm] Manacher's Algorithm"
slug: "algorithm manacher"
author: bienew22
date: 2026-04-19 13:00:00 +0900
# last_modified_at: 2026-02-27 10:24:00 +0900
tags: [palindrome, manacher]
media_subpath: /assets/img/_algorithm/manacher
---


## **Manacher's Algorithm?**
마나커 알고리즘(Manacher's Algorithm)은 문자열에서 각 문자를 중심으로 하는 가장 긴 팰린드롬의 길이를 `O(N`에 찾는 알고리즘입니다.


> **팰린드롬?** <br />
앞으로 읽으나 뒤로 읽으나 똑같은 단어, 문자열, 숫자열 등을 의미합니다.
{: .prompt-info }

---

## **기호 및 변수 정의**
- `S` : 문자열 
- `i` : 현재 탐색하는 팰린드롬의 중심 인덱스
- `P[i]` : `S[i]`를 중심으로 하는 팰린드롬의 반지름
- `C` : 현재까지 가장 오른쪽으로 뻗은 팰린드롬의 중심
- `R` : `C`에 해당하는 팰린드롬의 반지름

---

## **핵심 아이디어**

**1\. 기본 확장 (Brute-force)**
: ![manacher-1](/1.png){: w="60%"}

    `P[i]`를 계산할 때 `i` 기준으로 좌우를 확장하여 탐색하여 계산합니다.


    ![manacher-2](/2.png){: w="60%"}

    한 칸 확장 했을 때, `S[i - 1] == S[i + 1]`이므로 한 칸 더 확장하여 탐색을 수행합니다.

    ![manacher-3](/3.png){: w="60%"}

    여기서 `S[i + 2]`는 문자열 범위를 벗어나게 되면서 `P[i] = 1`으로 결정됩니다.

**2\. 문제점**
: 기본적인 방식은 각 인덱스 `i`를 중심으로 좌우를 직접 비교하여 팰린드롬을 확장하는 구조입니다. 특히 모든 문자가 동일한 문자열 (`aaaaa..`) 같은 경우 탐색마다 거의 문자열 끝까지 확장이 발생하게 됩니다. 이 경우 시간 복잡도가 {% math "O({{N^2}})" %} 되므로 문자열 길이가 커지면 사용하기 어렵습니다.

**3\. 핵심 최적화**
: ![manacher-4](/4.png){: w="60%"}

    현재 위치 `i`가 기존 팰린드롬(가장 오른쪽으로 뻗은) 범위 `(C - P[C], C + P[C])` 안에 있다면
    대칭 위치 `i'`을 이용할 수 있습니다.

    ![manacher-5](/5.png){: w="60%"}

    이 때 이미 계산된 `P[i']` 값을 활용하여 최소한의 반지름(`i - P[i']`)을 바로 알 수 있습니다. 이를 통하여 불필요한 비교를 건너뛰어 바로 `i - P[i'] - 1`부터 비교할 수 있습니다.


즉, 해당 알고리즘은 기존에 탐색했던 값을 활용하는 일종의 DP 성격을 띠는 알고리즘입니다.

---

## **동작 과정**

`i`를 `0 -> N - 1` 증가하면서 `C`와 `R` 값을 이용하여 `P[i]`를 계산합니다. 이때 각 상황에 따라서 확장 위치를 계산합니다.

**case 1 : `i > C + R`**
: ![manacher-6](/6.png){: w="60%"}

    참고할 정보가 없기에 기본 확장으로 팰린드롬의 길이를 구해야 합니다.

**case 2 : `i <= C + R`**
: ![manacher-7](/7.png){: w="60%"}
 
    `P[i']` 값을 이용하여 계산을 단축할 수 있습니다. 여기에 추가로 다음 2가지 경우가 있습니다.

    - `실제 P[i] >= P[i']` 인 경우
        ![manacher-8](/8.png){: w="60%"}
    - `실제 P[i] < P[i']` 인 경우
        ![manacher-9](/9.png){: w="60%"}


    - 이 둘은 모두 `P[i']` 중에서 최소 `C + R - i`만큼만 보장합니다.
        ![manacher-10](/10.png){: w="60%"}

        - 최소 보장 구간은 `C`를 기준으로 하는 내부 구간만큼 보장하는 것입니다.
        - 따라서 `C + R - i + 1` 부터 기본 확장으로 필랜드롬의 길이를 구하면 됩니다.

---

## **짝수 길이 팰린드롬**

![manacher-11](/11.png)
_짝수 길이 팰린드롬_

짝수 길이 팰린드롬의 경우에는 중심이 하나의 문자에 존재하지 않고 두 문자 사이에 위치합니다.
홀수 길이 팰린드롬과 달리 명확한 중심 인덱스를 정의할 수 없습니다. 따라서 홀수와 짝수의 확장 로직은 다음과 같이 달라집니다.

- 홀수 : `S[i - K] == S[i + K]`
- 짝수 : `S[i - K] == S[i + 1 + K]`

이를 해결하기 위하여 **문자 사이에 구분자**을 추가하여 모든 팰린드롬의 길이를 홀수로 변환합니다.


![manacher-12](/12.png)
_변환한 팰린드롬_

사진에는 `#`을 사용하였지만 실제로는 어떤 문자이든 상관이 없습니다.

---

## **구현**

```java
class Manacher {
    String text;
    int[] P;

    public Manacher(String s) {
        this.text = s;

        init();
    }

    // P 초기화.
    private void init() {
        // 1. 전처리 : 문자 사이에 구분자 추가
        char[] S = new int[text.length() * 2 + 1];

        for (int i = 0; i < text.length(); i++) {
            S[i * 2 + 1] = text.charAt(i);
        }

        // 2. P 계산하기
        P = new int[S.length];
        int C = 0;

        for (int i = 0; i < P.length; i++) {
            // C안에서 i의 대칭되는 위치. : C - (i - C)
            int ip = 2 * C - i;

            // C 안에 있는 경우.
            if (i < C + P[C] ) {
                P[i] = Math.min(P[ip], C + P[C] - i);
            }

            // 확장
            while (i - P[i] - 1 >= 0 && i + P[i] + 1 < P.length // 범위 밖 탈출 여부 확인
                    && S[i - P[i] - 1] == S[i + P[i] + 1]) {    // 같은 문자인지 확인
                P[i]++;
            }

            // C 갱신
            if (i + P[i] > C + P[C]) {
                C = i;
            }
        }
    }

    // 최장 팰린드롬 반환.
    public String maxPalindrome() {
        int maxLen = 0;
        int center = 0;

        for (int i = 0; i < P.length; i++) {
            if (P[i] > maxLen) {
                maxLen = P[i];
                center = i;
            }
        }

        int start = (center - maxLen) / 2;

        return text.substring(start, start + maxLen);
    }

    // 문자안에 존재하는 팰리드롬의 개수 반환.
    public int getPalindromeCount() {
        int cnt = 0;
        for (int i = 0; i < P.length; i++) {
            cnt += (P[i] + 1) / 2;
        }
    }
}
```

--- 

## **참고 문헌**
- <https://www.youtube.com/watch?v=gSCH1Ofd9Pg>
- <https://m.blog.naver.com/jqkt15/222108415284>
- <https://hyungjun-950912.tistory.com/219>
- <https://cp-algorithms.com/string/manacher.html>