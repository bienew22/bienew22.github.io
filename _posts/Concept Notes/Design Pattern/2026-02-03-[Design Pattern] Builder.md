---
title: "[Design Pattern] Builder"
author: bienew22
date: 2026-02-03 16:00:00 +0900
categories: [개념 정리, Design Pattern]
tags: [디자인 패턴, 빌더 패턴]
media_subpath: /assets/img/_design-pattern
image:
    path: /base.png
---
제가 느낀 빌터(Build) 패턴의 키워드는 **"객체 복제"**입니다. 

## **Builder Pattern**

---

## **패턴 구조**
![프로토타입 패턴 다이어그램](/94-prototype-1.png){: w="80%" .bg-white}

- **Prototype**
    - 인스턴스 복제를 위한 메소드 결정
- **ConcretePrototype**
    - 자신을 복제하는 방법을 구현
- **Client**
    - `new`가 아닌 복제를 통하여 인스턴스 생성

---

## **구현 예시**

push test
---

## **참고 문헌**
* Yuki, H. (2022). JAVA 언어로 배우는 디자인 패턴 입문(김성훈, 옮김). 영진닷컴.
* <https://refactoring.guru/design-patterns/builder>