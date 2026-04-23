---
title: "[LeetCode] Zigzag Conversion"
slug: "leetcode zigzag conversion"
description: "LeetCode 'Zigzag Conversion' 문제 풀이"
author: bienew22
date: 2026-04-22 15:00:00 +0900
tags: [leetcode, simulation]
media_subpath: /assets/img/_leetcode/zigzag-conversion
math: false
---

### **문제**
{% linkcard https://leetcode.com/problems/zigzag-conversion/ %}

### **문제 정리**

요약
: * 문자열(`s`)과 행의 개수(`numRows`)가 주어집닏다. 
- 각 문자를 다음과 같이 지그재그로 배치합니다.
    ![배치 예시](/1.png){: w="60%" }
- 배치된 문자들을 라인별로 합쳐진 결과를 리턴합니다.
    ![조합 예시](/2.png){: w="60%" }

입력 조건
: - `s.length : 1 ~ 1,000`
    - 문자열은 `a-zA-Z`, `,`, `.`으로 구성됨.
- `numRows : 1 ~ 1,000`

출력
: 새로 합쳐진 문자열 반환.

---

### **문제 풀이**
간단한 시뮬레이션 문제입니다. 여기서 핵심은 **각 문자가 변환하였을 때 인덱스를 어떻게 관리하는냐** 입니다.

**이동 규칙**
: ![이동 규칙](/3.png){: w="60%" }

    배치 방법을 "문자를 먼저 배치 후에 이동 한다"로 생각해보겠습니다. 먼저 세로로 `numRows - 1` 만큼 이동한 다음에 대각선으로 `numRows - 1` 만큼 이동하는 것을 확인할 수 있습니다.

    즉, 한 방향으로 `numRow - 1` 만큼 이동 후에 이동 방향을 바꿉니다.

    ![사이클 규칙](/4.png){: w="60%" }

    또한 끝까지 한 번 이동하는 것을 한 사이클이라고 생각하면 짝 수 사이클(0 포함)은 아래로 이동하고, 홀수 사이클은 대각으로 이동하는 규칙을 찾을 수 있습니다.

    이를 통하여 이동 횟수가 `numRow - 1`의 짝수 배수(0 포함) 이면 세로로 이동하고, 홀수 배수이면 대각으로 이동하는 것을 알 수 있습니다.


**인덱스 관리**
: **O(n^2)**
    : 가장 직관적인 방법으로, 실제로 지그재그 형태를 2차원 배열에 그대로 시뮬레이션하는 방법입니다.
    `numRows * s.length` 크기의 2차원 배열을 생성합니다. 각 문자의 위치 `(row, col)` 계산 후에 문자를 하나씩 채워 넣습니다. 모든 문자를 배치 후에 행 기준으로 순서대로 읽어서 문자열을 생성합니다.

    **O(nlogn) 방법**
    : 좌표를 직접 저장하지 않고, 각 문자의 위치를 1차원의 값(key)으로 변환합니다. `(key, char)` 형태로 저장한 뒤, key 기준으로 정렬 후 순서대로 문자를 이어 붙여서 문자열을 생성합니다.

    **O(n) 방법**
    : 가장 효율적인 방식으로, 각 행을 기준으로 문자열을 관리하는 것입니다. `numRows`개의 `StringBuilder`을 준비합니다. 각 문자의 위치를 계산하여 `row`에 해당하는 `StringBuilder`에 문자를 추가합니다. 모든 문자를 처리한 뒤, 각 행의 문자열을 순서대로 이어붙이면 됩니다. 여기서 중요한 것은 각 문자의 `col`값은 필요는 없다는 것입니다.

---

### **O(n^2) 풀이 코드**
```java
public class Solution {

    public String convert(String s, int numRows) {
        if (numRows == 1 || s.length() <= numRows) {
            return s;
        }

        char[][] map = new char[numRows][];
        for (int i = 0; i < map.length; i++)
            map[i] = new char[s.length()];

        int row = 0, col = 0;
        int moveCnt = 0;

        for (int i = 0; i < s.length(); i++) {
            map[row][col] = s.charAt(i);

            if ((moveCnt / (numRows - 1)) % 2 == 0) {
                row += 1;
            } else {
                col += 1;
                row -= 1;
            }
            moveCnt += 1;
        }
        
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < map.length; i++) {
            for (int j = 0; j < map[i].length; j++) {
                if (map[i][j] == 0) {
                    continue;
                }
                sb.append(map[i][j]);
            }
        }
        
        return sb.toString();
    }
}
```

---

### **O(nlogn) 풀이 코드**
```java
public class Solution {

    static class Point implements Comparable<Point> {
        int value;
        char c;

        public Point(int v, char c) {
            this.value = v;
            this.c = c;
        }

        @Override
        public int compareTo(Point o) {
            return Integer.compare(this.value, o.value);
        }
    }

    public String convert(String s, int numRows) {
        if (numRows == 1) {
            return s;
        }
        
        Point[] points = new Point[s.length()];

        int y = 0, x = 0;
        int moveCnt = 0;

        for (int i = 0; i < s.length(); i++) {
            points[i] = new Point(y * s.length() + x, s.charAt(i));

            // 직각으로 내려가는 경우.
            if ((moveCnt / (numRows - 1)) % 2 == 0) {
                y += 1;
            } else {
                x += 1;
                y -= 1;
            }

            moveCnt += 1;
        }

        Arrays.sort(points); // 정렬
        
        StringBuilder sb = new StringBuilder();

        Arrays.stream(points).forEachOrdered(p -> sb.append(p.c));

        return sb.toString();
    }
}
```

---

### **O(n) 풀이 코드**
```java
public class Solution {

    public String convert(String s, int numRows) {
        if (numRows == 1 || s.length() <= numRows) {
            return s;
        }

        StringBuilder[] sbs = new StringBuilder[numRows];
        StringBuilder res = new StringBuilder();

        for (int i = 0; i < sbs.length; i++) {
            sbs[i] = new StringBuilder();
        }

        int row = 0;
        for (int moveCnt = 0; moveCnt < s.length(); moveCnt++) {
            sbs[row].append(s.charAt(moveCnt));

            if ((moveCnt / (numRows - 1)) % 2 == 0) {
                row++;
            } else {
                row--;
            }
        }

        Arrays.stream(sbs).forEachOrdered(res::append);

        return res.toString();
    }
}
```