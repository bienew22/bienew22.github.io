---
title: "[Design Pattern] Bridge"
author: bienew22
date: 2026-03-08 10:00:00 +0900
last_modified_at: 2026-03-10 14:24:00 +0900
tags: [디자인 패턴, 빌더 패턴]
media_subpath: /assets/img/_design-pattern
image:
    path: /base.png
---
제가 느낀 브릿지(Bridge) 패턴의 키워드는 **"ㅁ~~ㅁ"**입니다. 

## **Bridge Pattern**

asdf

---

### **패턴 구조**
![반복자 패턴 다이어그램](/99-iterator.png){: w="90%" .bg-white}

- Aggregate (인터페이스)
    - 집합체(컬렉션) 역할, ConreateIterator 객체를 반환하는 API 제공.
    - java에서는 내장으로 `Iterable`이름으로 제공해주고 있습니다.
- Iterator (인터페이스)
    - 반복자 역할, 요소를 순서대로 검색하는 API 제공.
- ConcreateAggregate (클래스)
    - 실제 컬렉션
- ConcreateIterator (클래스)
    - 실제 반복자
    - 반복에 필요한 정보를 가지고 있음.
    - 어떤 순서으로 순회할지에 대한 로직이 구체화 되어 있음.

---

### **패턴 설명**
아래 예제를 통하여 반복과 구현의 필요성에 대하여 이야기 해보겠습니다.

#### 초기 프로젝트 요구 사항
1. `Class.java`{: .filepath} : 반 별로 학생 목록을 배열로 관리합니다.
2. `Teacher.java`{: .filepath} : 각 반의 담임 선생님은 학생 목록을 확인할 수 있습니다.

#### 브릿지 패턴 적용 X

ㅁㄴㅇㄹ

#### 브릿지 패턴 적용 O

ㅁㄴㅇㄹ

#### 결론
이렇게 구현과 반복을 분리하면, 구현을 수정해도 Client(`Teacher.java`{: .filepath})에서 반복을 수정하지 않아도 됩니다.

---

## **패턴 장/단점**
### **장점**
* 컬렉션 종류 상관 없이 객체 접근 방식을 통일할 수 있습니다.
* 컬렉션 내부 구조를 몰라도 모든 항목에 접근할 수 있습니다.
* 다양한 순회 방법을 제공할 수 있습니다.

### **단점**
* 간단하게 작동하는 경우 패턴을 적용하면 관리해야하는 클래스가 늘어나고, 복잡도가 증가합니다.
    * 상황에 따라서 패턴 적용 여부를 잘 판단해야 합니다.
* 패턴을 사용하는 것보다 특수 컬렉션의 요소를 직접 순회하는 것보다 효율적일 수 있습니다.

---

## **참고 문헌**
* Yuki, H. (2022). JAVA 언어로 배우는 디자인 패턴 입문(김성훈, 옮김). 영진닷컴.
* <https://refactoring.guru/design-patterns/iterator>
* <https://zoosso.tistory.com/1243>