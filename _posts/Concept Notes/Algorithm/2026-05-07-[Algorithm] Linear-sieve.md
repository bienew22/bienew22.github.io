---
title: "[Algorithm] Linear Sieve"
slug: "algorithm-linear-sieve"
author: bienew22
date: 2026-05-07 16:27:25 +09:00
tags: [math, linear sieve]
media_subpath: /assets/img/_algorithm
math: true
---

## **Linear Sieve?**
Linear Sieve 또는 오일러의 체라 불리는 알고리즘으로 N 이하의 소수를 선형 시간 `O(N)` 내에 찾아내는 소수 판별 알고리즘입니다. 

기존의 에라토스테네스의 체의 합성수는 여러 번 방문하는 비효율적인 부분을 개선하여 각 합성수를 정확히 한 번만 처리하도록 만든 알고리즘입니다.

> 기존의 에라토스테네스의 체를 개선했다는 의미에서 **선형 에라토스테네스의 체**라고도 합니다.
{: .prompt-tip }

---

## **에라토스테네스의 체의 한계**

에라토스테네스의 체의 동작과정을 보면 다음과 같습니다.

```java
for (int i = 2; i <= n; i++) {
    // 소수 아니면 다음 수로 넘김
    if (is_prime[i]) {  
        continue;
    } 

    // 현재 소수에 대하여 소수의 배수들을 소수 아니라고 마킹
    for (int j = 2; j * i <= n; j++) {
        is_prime[i] = true;
    }
}
```

합성수 `12`를 예시로 보면

- `i = 2, j = 6`
- `i = 3, j = 4`

처럼 하나의 합성수를 여러 번 방문하여 소수 여부를 중복으로 처리합니다.

실제 에라토스테네스의 체의 시간 복잡도가 `O(NloglogN)`인 이유도 이런 중복 마킹 때문입니다. 

오일러의 체는 이런 중복 마킹 문제를 해결하여 **모든 합성수를 한 번만 처리**하도록 최적화합니다.

> **합성수?** <br />
1보다 큰 자연수 중에서 소수가 아닌 수로, 약수의 개수가 3개 이상인 수
{: .prompt-info }

---

## **핵심 아이디어**

오일러의 체의 핵심은 **합성수를 _최소 소인수_ 기준으로 단 한 번만 생성한다.** 입니다.

> **최소 소인수?** <br />
소인수분해했을 때 나타나는 가장 작은 소수
{: .prompt-info }

예를들어 `30`은 다음과 같이 여러 방식으로 표현할 수 있습니다.

- 30 = 15 x 2
- 30 = 10 x 3
- 30 = 6 x 5

이중 최소 소인수는 `2`이므로 오일러의 체는 `15 x 2`인 경우만 허용하고 나머지 방식은 처리하지 않습니다. 

이를 위해 오일러의 체는 현재 수 `x`와 지금까지 발견한 소수(`p`)들을 이용하여 `x * p`를 생성하여 합성수임을 판정합니다.

이때 중요한 조건인 **`p`는 `x`의 최소 소인수보다 크지 않은 소수만 사용**하는 것입니다.

이 조건 덕분에 모든 합성수는 한 번만 생성되어 시간복잡도를 `O(N)`로 줄일 수 있습니다.

---

## **왜 중복이 발생하지 않을까?**

만약 `x`의 최소 소인수인 `p` 보다 큰 소수 `Q`를 사용한다고 가정해 보겠습니다.

그러면 오일러의 체는 다음과 같이

$$
t = x \times Q
$$

를 생성하여 `t`가 합성수임을 판정합니다. 그러나 `p`는 `x`의 최소 소인수이므로 `x`는 다음과 같이 표현할 수 있습니다.

$$
x = k \times p
$$

이를 위 식에 대입하면

$$
t = k \times p \times Q
$$

가 됩니다. 여기서 `t`는 이후 `k * Q`로 합성수 만드는 과정에서 다시 생성될 수 있습니다. 결국 최소 소인수보다 큰 수를 사용하면 동일한 합성수를 여러 번 방문하게 됩니다.

따라서 오일러의 체는 `p`가 최소 소인수 되는 순간 반복으로 종료하여, 최소 소인수를 기준으로 정확히 한 번만 생성되도록 보장합니다.

---

## **구현**

```java
class Main {
    public ArrayList<Integer> linearSieve(int num) {
        // 소수 집합 - 오름 차순
        ArrayList<Integer> primes = new ArrayList<>();
        
        // isComposite[n]
        // true - 합성수, false - 소수
        boolean[] isComposite = new boolean[num + 1];

        // 각 수에 대하여 합성수 생성하여 false으로 마킹
        for (int n = 2; n <= num; n++) {
            // 소수인 경우
            if (!isComposite[n]) {
                primes.add(n);
            }

            // 소수의 배수 제거
            for (int prime: primes) {
                int compose = prime * n;
                if (compose > num) {
                    break;
                }

                isComposite[compose] = true;

                // n이 prime의 배수이면 
                // 해당 prime이 n의 최소 소인수를 의미
                if (n % prime == 0) {
                    break;
                }
            }
        }

        return primes;
    }
}
```

--- 

## **응용**

오일러의 체는 단순히 소수만 구하는 것이 아니라 각 수의 최소 소인수(SPF, Smallest Prime Factor)를 함께 저장한다면 다양한 연산을 쉽게 처리할 수 있습니다.

### **0. 최소 소인수를 저장**
기존 구현 코드를 다음과 같이 수정하면 각 수의 최소 소인수를 저장할 수 있게 됩니다.

```java
class Main {
    public ArrayList<Integer> linearSieve(int num) {
        // 소수 집합 - 오름 차순
        ArrayList<Integer> primes = new ArrayList<>();
        
        // spf[n]: 정수 n의 최소 소인수
        int[] spf = new int[num + 1];

        for (int n = 2; n <= num; n++) {
            // 소수인 경우
            if (spf[n] == 0) {
                spf[n] = n; // 소수의 최소 소인수는 자기 자신
                primes.add(n);
            }

            // 소수의 배수 제거
            for (int prime: primes) {
                int compose = prime * n;
                if (compose > num) {
                    break;
                }

                spf[compose] = prime;

                if (n % prime == 0) {
                    break;
                }
            }
        }

        return primes;
    }
}
```

---

### **1. 소인수 분해**

아이디어
: 각 수의 최소 인수를 알고 있다면, 어떤 수 `x` 소인수 분해는 `x /= spf[x]`를 반복하여 구할 수 있습니다. 즉, 최소 소인수를 계속 제거하는 방식으로 소인수 분해가 가능합니다.

구현
: 

    ```java
    public List<Integer> factorize(int x) {
        List<Integer> factors = new ArrayList<>();

        while (x > 1) {
            factors.add(spf[x]);
            x /= spf[x];
        }

        return factors;
    }
    ```

---

### **2. 약수 개수**

아이디어
: 어떤 수 `n`에 대해 {% math "n = {{p^a}} x m" %}, (`p`는 `n`의 최소 소인수, `m`: `p`으로 더 이상 나우어지지 않는 수) 라고 했을 때
약수의 개수 함수 `d(n)`는 소인수의 지수만으로 결정되므로 `d(n) = (a + 1) x d(m)`가 성립합니다. 따라서 최소 소인수의 지수, 약수 개수를 이용하면 현재 수의 약수 개수를 즉시 계산할 수 있습니다.

구현
: 

    ```java
    class Main {
        
        public int[] numOfDivisors(int num) {
            ArrayList<Integer> primes = new ArrayList<>();

            int[] spf = new int[num + 1];   // 최소 소인수
            int[] exp = new int[num + 1];   // 최소 소인수의 지수
            int[] div = new int[num + 1];   // 약수 개수

            div[1] = 1;


            for (int n = 2; n <= num; n++) {

                // 소수인 경우
                if (spf[n] == 0) {
                    spf[n] = n;
                    exp[n] = 1;

                    // 소수의 약수 개수는 2개
                    div[n] = 2;

                    primes.add(n);
                }

                for (int prime : primes) {
                    int composite = prime * n;

                    if (composite > num) {
                        break;
                    }

                    spf[composite] = prime;

                    // prime이 n의 최소 소인수인 경우
                    if (n % prime == 0) {

                        // exponent 증가
                        exp[composite] = exp[n] + 1;

                        /*
                        * 점화식 유도
                        * n = m × prime^exp[n]
                        * d(n) = d(m) × (exp[n] + 1)
                        * 
                        * composite = m × prime^(exp[n] + 1)
                        * d(composite) = d(m) x (exp[n] + 2)
                        * 
                        * d(m) = d(n) / (exp[n] + 1)
                        */
                        div[composite] = div[n] / (exp[n] + 1) * (exp[n] + 2);

                        break;
                    }

                    // 새로운 소인수가 추가되는 경우
                    exp[composite] = 1;

                    // 약수 개수 2배
                    div[composite] = div[n] * 2;
                }
            }

            return div;
        }
    }
    ```

---

## **참고 문헌**
- <https://codeforces.com/blog/entry/54090>
- <https://ps.mjstudio.net/linear-sieve>
- <https://ahgus89.github.io/algorithm/Linear-sieve/>

