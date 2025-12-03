---
title: "[Design Pattern] Iterator"
author: bienew22
date: 2025-11-27 21:00:00 +0900
last_modified_at: 2025-12-03 17:00:00 +0900
categories: [개념 정리, Design Pattern]
tags: [디자인 패턴, 반복자 패턴]
media_subpath: /assets/img/_design-pattern
---
본문으로 들어가기에 앞서 제가 생각하는 반복자(Iterator) 패턴의 핵심은 **"구현과 분리하여 반복할 수 있음"**입니다. 
해당 글을 읽고 해당 워딩을 이해 되면 좋을 것 같습니다.

## **Iterator Pattern**
저희는 코드를 작성하다 보면은 루프를 다양하게 사용됩니다. 
```java
Object[] arr = ...;
for (int i = 0; i < arr.length; i++) {
    ... do something ...
}
```
특히 위코드 처럼 어떤 데이터 집합에 대하여 많이 사용됩니다. 
여기서 반복자(Iterator) 패턴은 변수 **i의 기능을 대신**하는 것으로 데이터 집합에 대하여 **순차적인 접근을 지원하는 패턴입니다.**

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

> Client는 실제 반복을 인터페이스 객체를 통하여 반복하므로 실제 컬렉션 구현과 반복을 분리하게 됩니다.
{: .prompt-tip }

### **패턴 설명**
아래 예제를 통하여 반복과 구현의 필요성에 대하여 이야기 해보겠습니다.

#### 초기 프로젝트 요구 사항
1. `Class.java`{: .filepath} : 반 별로 학생 목록을 배열로 관리합니다.
2. `Teacher.java`{: .filepath} : 각 반의 담임 선생님은 학생 목록을 확인할 수 있습니다.

#### 반복자 패턴 적용 X
초기 요구사항대로 구현하면 다음과 같습니다.
```java
class Class {
    Student[] st = new Student[30];
    ...
}

class Teacher {
    void readAll() {
        for (int i = 0; i < myClass.st.length; i++) {
            System.out.println(myClass.st[i]);
        }
    }
}
```

하지만 매년 학생의 수가 변경 되면서 `Class.java`{: .filepath}에서 기존 배열에서 List으로 바꾸어서 관리하려고 합니다.

```java
class Class {
    List<Student> st = new ArrayList();
    ...
}

class Teacher {
    void readAll() {
        // 여기도 바뀜...
        for (int i = 0; i < myClass.st.size(); i++) { 
            System.out.println(myClass.st[i]);
        }
    }
}
```

보시면 요구사항이 `Class.java`{: .filepath}만 수정되었는데 `Teacher.java`{: .filepath}도 수정해야 했습니다.
만약에 `Class.java`{: .filepath}의 `st`를 다른 여러 파일에서도 사용하고 있다면 다른 파일들도 수정해야합니다.

#### 반복자 패턴 적용 O
반복자 패턴을 적용하여 구현하면 다음과 같습니다.
```java
class Class implements Iterable<Book> {
    Student[] st = ...;

    @override
    Iterator<Student> iterator() {
        return new StudentIterator(this);
    }
}

class StudentIterator implements Iterator<Student> {
    ... 순회 전략 및 관련 정보 존재 ...
}

class Teacher {
    void readAll() {
        Iterator<Student> it = myClass.iterator();

        while(it.hasNext()) {
            System.out.println(it.next());
        }

        // 확장 for문을 통하여 순회 가능.
        for (Student st: myClass) {
            ...
        }
    }
}
```

여기서 `Teacher.java`{: .filepath}에서는 학생 목록 확인할 때 실제 구현이 아닌 인터페이스로 접근합니다.
따라서 `Class.java`{: .filepath}에서 배열에서 List로 수정해도 `Teacher.java`{: .filepath}를 수정하지 않아도 됩니다.

> ConcreateAggregate의 구현이 완전히 바뀌게 되면 그에 맞게 ConcreateIterator 또한 수정해야 합니다.
{: .prompt-info}

#### 결론
이렇게 구현과 반복을 분리하면, 구현을 수정해도 Client(`Teacher.java`{: .filepath})에서 반복을 수정하지 않아도 됩니다.

## **패턴 장/단점**
### **장점**
* 컬렉션 종류 상관 없이 객체 접근 방식을 통일할 수 있습니다.
* 컬렉션 내부 구조를 몰라도 모든 항목에 접근할 수 있습니다.
* 다양한 순회 방법을 제공할 수 있습니다.

### **단점**
* 간단하게 작동하는 경우 패턴을 적용하면 관리해야하는 클래스가 늘어나고, 복잡도가 증가합니다.
    * 상황에 따라서 패턴 적용 여부를 잘 판단해야 합니다.
* 패턴을 사용하는 것보다 특수 컬렉션의 요소를 직접 순회하는 것보다 효율적일 수 있습니다.

## **참고 문헌**
* Yuki, H. (2022). JAVA 언어로 배우는 디자인 패턴 입문(김성훈, 옮김). 영진닷컴.
* <https://refactoring.guru/design-patterns/iterator>
* <https://zoosso.tistory.com/1243>
