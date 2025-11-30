---
title: "[Algorithm] Diameter of tree"
author: bienew22
date: 2025-11-30 21:07:00 +0900
categories: [개념 정리, 알고리즘]
tags: [graph, DFS/BFS, DP]
media_subpath: /assets/img/_algorithm/
---

## **Diameter of tree ?**
트리의 지름(Diameter of tree)는 다음과 같이 정의됩니다.
* 트리의 정점 `a`와 정점 `b` 사이에는 항상 단 한 개의 **경로(path)**가 존재합니다. 해당 경로를 두 정점의 **거리(distance)**라고 합니다.
    * distance: `d(a, b)`
    * path: `p(a, b)`
* 한 정점 `a`와 임의의 정점 `x`에 대해, distance(`a`, `x`)의 최댓값을 정점 `a`에서의 **이심률(Eccentricity)**이라고 합니다.
    * `eec(a) = max(d(a, x)) (x in all vertex)`
* 모든 정점의 이심률 중에서 가장 큰 값을 **트리의 지름**이라고 합니다.
    * `diam(G) = max(eec(x)) (x in all vertex)`

> 트리의 반지름은 모든 이심률 중에서 가장 작은 값을 의미합니다.
가중치가 없는 트리의 경우, 지름은 d이면 반지름은 ceil(d/2)이 됩니다.
{: .prompt-info}

## **DFS/BFS를 통한 구하기**

#### **구하는 방법**
1. 트리에서 임의의 정점 `x`를 선택합니다.
2. 정점 `x`의 이심률에 해당하는 정점 `y`를 찾습니다.
3. 정점 `y`에서 이심률에 해당하는 정점 `z`를 찾습니다.
    * 여기서 구한 `d(y, z)`가 트리의 지름이 됩니다.

#### **증명**
**정의**: 트리의 지름을 이루는 두 정점을 `a`, `b`로 정하겠습니다.

**가정 1: 정점`x`가 지름 경로상에 존재하는 정점이라고 하겠습니다.**
![예시 그래프](/dot-1.png){: w="90%" }
_x 지름 경로상에 존재하는 경우_

이 경우 트리의 지름이 `d(a, b)`가 되게 하기 위해서는 `x`에서 모든 정점에 대한 거리를 정렬했을 때
`d(x, a)`, `d(x, b)` 두 값이 1, 2등으로 가장 커야 합니다. 따라서 정점 `x`의 이심률에 해당하는 정점 `y`는 `a`, `b`가 되고 
`y` 기준으로 찾으면 결국 `a`와 `b`를 찾게 됩니다.

**가정 2: 정점 `x`가 지름 경로상에 존재하지 않는 정점이고, 정점 `y`가 정점 `a`, `b`가 아니라고 가정하겠습니다.**

case 1: `p(x, y)`와 `p(a, b)`가 한 점 이상 공유하는 경우.
: ![예시 그래프](/dot-2.png){: w="70%" }
_두 경로가 한 정점을 공유하는 경우_
    
두 경로가 공유하는 정점을 `c`라고 했을 때, `x`에서 이심률에 해당하는 정점이 `y`가 되려면 `d(c, y)`가 `d(c, a)`와 `d(c, b)`보다 커야 합니다.
이렇게 되면 트리의 지름이 `d(a, y)` 또는 `d(b, y)`가 되므로 **모순이 발생하게 됩니다.**

case 2: `p(x, y)`와 `p(a, b)`가 공유하는 점이 없는 경우.
: ![예시 그래프](/dot-3.png){: w="70%" }
_두 경로가 정점을 공유하지 않는 경우_

트리이므로 두 경로를 연결하는 경로가 존재할 것입니다. 이때 정점 `x`의 이심률이 되는 좌표가 `y`가 되려면 `d(c, y)`가 `d(c, d) + d(d, b)`와 `d(c, d) + d(d, a)` 보다 켜야 합니다. 그러면 트리의 지름이 `d(a, y)` 또는 `d(b, y)`가 되므로 **모순이 발생하게 됩니다.**

**∴ 해당 방법으로 트리의 지름을 구할 수 있습니다.**

#### **구현**
```java
class Main {

    int[] dfs(int[][] graph, int sNode) {
        Stack<int[]> stack = new Stack<>();
        boolean[] visit = new boolean[graph.length];
        int[] res = new int[]{sNode, 0};

        stack.add(new int[] {sNode, 0});
        visit[sNode] = true;

        while(!stack.isEmpty()) {
            int[] now = stack.pop();

            if (now[1] > res[1]) {
                res = now;
            }

            for (int i = 0; i < graph.length; i++) {
                if (graph[now[0]][i] != 0 && !visit[i]) {
                    stack.add(new int[] {i, now[1] + graph[now[0]][i]});
                    visit[i] = true;
                }
            }
        }

        return res;
    }

    void solve() throws Exception {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        // init graph
        int size = Integer.parseInt(br.readLine());

        int[][] graph = new int[size][size];

        for (int i = 0; i < size - 1; i++) {
            StringTokenizer st = new StringTokenizer(br.readLine());
            int s = Integer.parseInt(st.nextToken());
            int e = Integer.parseInt(st.nextToken());
            int v = Integer.parseInt(st.nextToken());

            graph[s][e] = v;
            graph[e][s] = v;
        }

        // find y
        int y = dfs(graph, 0)[0];

        // find e
        int[] e = dfs(graph, y);

        System.out.printf("Diameter of tree Path: %d - %d%n", e[0], y);
        System.out.printf("Diameter of tree: %d%n", e[1]);
    }

    public static void main(String[] args) throws Exception {
        new Main().solve();
    }
}
```

#### **장/단점**
* 장점
    * 구현이 쉽습니다.
    * 메모리 적게 사용됩니다.
* 단점
    * 지름만 필요할 때 최고지만, 다른 정보도 필요할 때 비효율적입니다.


## **DP를 통한 구하기**
#### **구하는 방법**
두 가지 정보에 대하여 DP를 수행합니다.

1. DP[0]: 정점을 루트로 하는 서브 트리에서 가장 긴 경로 길이를 구합니다.
2. DP[1]: 정점을 지나는 정점으로 사용하는 경우 제공할 수 있는 최대 길이를 구합니다.

#### **구현**
```java
class Main {

    int[] dfs(int[][] graph, int sNode, int[] res) {
        // 가장 긴 자식 방향 경로
        int[] first = new int[] {0, sNode};
        int[] second = new int[] {0, sNode};

        int len2 = 0, child2 = 0;   // 두번째로 긴 자식 방향 경로

        for (int i = 0; i < graph.length; i++) {
            if (graph[sNode][i] == 0) {
                continue;
            }

            // 부모 - 자식 관계 성립 시키기.
            graph[i][sNode] = 0;

            int[] child = dfs(graph, i, res);

            if (child[0] + graph[sNode][i] > first[0]) {
                second = first;
                first = new int[] {child[0] + graph[sNode][i], child[1]};

            } else if (child[0] + graph[sNode][i] > len2) {
                second = new int[] {child[0] + graph[sNode][i], child[1]};
            }

        }

        // DP[0]을 수행, 시작과 끝이 정해진 경로이므로 결과에 바로 적용.
        if (res[2] < first[0] + second[0]) {
            res[0] = first[1];
            res[1] = second[1];
            res[2] = first[0] + second[0];
        }

        // DP[1]을 수행, 부모 한테 알림.
        return first;
    }

    void solve() throws Exception {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        //== 입력 받기 및 초기화
        int size = Integer.parseInt(br.readLine());

        int[][] graph = new int[size][size];

        for (int i = 0; i < size - 1; i++) {
            StringTokenizer st = new StringTokenizer(br.readLine());
            int s = Integer.parseInt(st.nextToken());
            int e = Integer.parseInt(st.nextToken());
            int v = Integer.parseInt(st.nextToken());

            graph[s][e] = v;
            graph[e][s] = v;
        }

        int[] res = new int[3];
        dfs(graph, 0, res);

        System.out.printf("Diameter of tree Path: %d - %d%n", res[0], res[1]);
        System.out.printf("Diameter of tree: %d%n", res[2]);
    }

    public static void main(String[] args) throws Exception {
        new Main().solve();
    }
}
```

#### **장/단점**
* 장점
    * 중간값을 활용할 수 있습니다.
        * ex) 특정 노드를 root으로 할 때의 트리의 지름 구하기.
    * 실제 DFS를 1회 수행으로 해를 구할 수 있습니다.
* 단점
    * 구현 난이도가 높습니다.
    * 값 저장 구조를 잘못 관리하면 오류 발생하기 쉽습니다.

> 두 알고리즘의 시간복잡도는 O(N)로 같으므로 상황에 맞게 선택해서 사용하면 됩니다.
{: .prompt-info}

## **참고 문헌**
* <https://codeforces.com/blog/entry/101271>
* <https://00ad-8e71-00ff-055d.tistory.com/115>