---
title: "[Algorithm] Euclidean Algorithm"
slug: "algorithm eculidean"
author: bienew22
date: 2026-02-23 16:07:00 +0900
last_modified_at: 2026-02-27 10:24:00 +0900
tags: [gcd, euclidean]
media_subpath: /assets/img/_algorithm/
---

## **Euclidean Algorithm?**
유클리드 호제법(Euclidean Algorithm)은 두 정수의 최대 공약수를 효율적으로 구하는 방법입니다. 과정은 다음과 같이 정의됩니다.

> `A ≥ B > 0`인 두 정수 A, B에 대하여  <br />
`A = pB + r (q 정수)`을 만족하는 경우 <br />
`G(A, B) = G(B, r)`를 만족합니다. <br />
`G(A, B)`: A와 B의 최대 공약수를 의미합니다.

해당 성질을 반복하면 **나머지가 0이 되는 순간의 p 값이 최대 공약수**가 됩니다.

---

## **G(A, B) = G(B, r) 증명**

{% capture part1 %}
**전제:** 두 정수 A, B의 최대 공약수를 G라 하자. `G(A, B) = G`

그러면 A = Ga, B = Gb 으로 표현할 수 있습니다. 이 때 a와 b는 서로소입니다.

A = Bp + r 식을 정리하면 다음과 같습니다.

r = A - Bp <br />
r = Ga - Gbp <br />
r = G(a- bp)

**결론1 : A, B, r 모두 G의 배수이다.**
{% endcapture %}

{% include my/notion-toggle.html
title="Part1) A, B, r의 관계 찾기"
level=4
content=part1
open=true
%}

이제 `G(B, r) = G`임을 보이기 위하여, `a - bp`와 `b`가 서로소임을 증명하면 됩니다.

{% capture part2 %}
**가정: a - bp와 b가 서로소가 아님.**
두 수가 서로소가 아니므로 최대공약수인 c(단, c > 1)를 가지게 됩니다. 따라서 다음과 같이 나타낼 수 있습니다.

a - bq = c * n, b = c * m 

이때 n과 m은 서로소입니다.

첫 번째 식에 b = cm을 대입하여 a에 대해 정리하면,

a - c * m * q = c * n<br/>
a = c * (n + m * q)

따라서 a와 b는 모두 c의 배수임을 알 수 있습니다.

그러나 이는 a와 b가 서로소라는 전제와 모순이 발생하게 됩니다.

**결론2: a - bp와 b는 서로소입니다.**
{% endcapture %}

{% include my/notion-toggle.html
title="Part2) a - bq와 b 서로소 증명"
level=4
content=part2
open=true
%}

#### **최종 결론**
결론1와 결론2에 의하여 G(A, B) = G(B, r)이 성립하게 됩니다.

---

## **GCD 구현**
#### 1. 반복을 이용한 구현
```python
def gcd(a, b):
    while b != 0:
        a, b = b, a % b
    return a
```

#### 2. 재귀를 이용한 구현
```python
def gcd(a, b):
    if b == 0:
        return a
    return gcd(b, a % b)
```

> **코드상 a와 b의 대소 관계를 무시해도 되는 이유?**<br />
a < b 인 경우 a % b = a가 되므로 알고리즘 첫 루프(재귀)에서 a와 b는 자연스럽게 위치가 바뀌게 됩니다.
{: .prompt-info }

---

## **LCM 구현 (GCD 응용)**
```python
def lcm(a, b):
    return a  *  b // gcd(a, b)
```