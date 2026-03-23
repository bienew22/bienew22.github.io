---
title: "[Design Pattern] Singleton"
slug: "singleton pattern"
author: bienew22
date: 2026-01-03 18:00:00 +0900
categories: [개념 정리, Design Pattern]
tags: [design pattern]
media_subpath: /assets/img/_design-pattern
image:
    path: /base.png
---
제가 느낀 싱글톤(Singleton) 패턴의 키워드는 **"유일 객체"**입니다. 

## **Singleton Pattern**
싱글톤 패턴은 인스턴스가 하나만 존재하는 것을 보증하는 패턴입니다.

**왜 굳이 객체를 하나로 강제할까?** <br>
게임을 예로 들어보겠습니다. 사용자는 메인 화면, 전투 화면 등 여러 곳에서 게임 설정을 변경할 수 있습니다.
그런데 만약 '설정을 관리하는 객체'가 화면마다 따로 생성하면 메인 화면에서 설정 바꾸고 다른 화면으로 이동했더니
설정이 그대로 적용되지 않는 다시 설정해야 하는 불편한 상황이 발생합니다.

그래서 설정 관리 객체는 '어디서 접근하든 동일한 객체이어야 합니다.' 이걸 매번 개발자가 신경을 써서 같은 객체를 사용하도록 하는 대신,
자동으로 **하나의 인스턴스만 생성, 공유하도록 보장**해 주는 구조가 바로 싱글톤 패턴입니다.

---

## **패턴 구조**
![팩토리 메서드 패턴 다이어그램](/95-singleton-1.png){: w="45%" .bg-white}

- `private` 접근 제어자를 통하여 외부에서 `new Singleton()`으로 인스턴스 생성을 못 하게 합니다.
- `Singleton.getInstance()`를 통하여 객체를 사용하게 만드는 것이 입니다. 
- `getInstance()` 반환되는 객체는 `static` 변수로 클래스 로딩 시 한 번만 생성되고 이후에는 동일한 인스턴스가 재사용됩니다.

---

## **Lazy initialization**
```java
class Singleton {
    private static Singleton instance;

    // 생성자를 private으로 설정 -> 외부에서 new으로 객체 생성 불가
    private Singleton() {}

    public static Singleton getInstance() {
        if (instance == null) {
            instance = new Singleton();
        }

        return instance;
    }
}
```

- 가장 기본적인 구현 방법입니다.

#### **문제점**
**Thread unsafe** 문제점이 존재합니다. 멀티 스레드 환경에서 동시에 요청할 경우 싱글톤 객체가 여러 번 생성될 수 있습니다.

```java
if (instance == null) {         // B
    instance = new Singleton(); // A
}
```

`thread1`이 A 코드를 실행하면서 싱글톤 객체 생성 중에서 `thread2`으로 컨텍스트 스위칭하고 B 코드에 접근할 때
`thread2` 입장에서는 instance가 아직 `null`이므로 if 문 안으로 진입하게 됩니다. 이렇게 되면 두 스레드는 서로 다른 싱글톤 객체를 생성하게 됩니다.

---

## **Eager initialization**
```java
class Singleton {
    private static final Singleton INSTANCE = new Singleton();

    private Singleton() {}

    public static Singleton getInstance() { return INSTANCE; }

}
```

- 가장 직관적이면서 가장 간단하게 구현하는 방법입니다.
- JVM 클래스 로더에 의해 최초 로딩 시 객체가 생성됩니다.
- 변수 선언과 동시에 초기화해서 멀티 스레드 환경에서도 안전합니다.

#### **단점**
프로그램 실행과 함께 생성되어 메모리를 점유하게 됩니다. 한 번도 사용되지 않으면 자원 낭비가 발생하게 됩니다.

> 객체를 생성하는 비용이 작은 경우 해당 방법을 적용해도 문제없습니다.
{: .prompt-info}

---

## **Thread safe lazy initialization**
```java
class Singleton {
    private static Singleton instance;

    private Singleton() {}

    // 한 순간에 하나의 스레드만 접근 하게 만 듦.
    public static synchronized Singleton getInstance() {
        if (instance == null) {
            instance = new Singleton();
        }

        return instance;
    }
}
```

- 가장 단순한 방법으로 `thread unsafe` 문제를 해결하는 기법입니다.
- `synchronized`를 통하여 `getInstance` 메서드를 한 번에 하나의 스레드만 접근할 수 있게 합니다.

#### **단점**
여러 스레드가 동시에 `getInstance` 접근할 때 동기화 작업 때문에 성능 저하가 발생할 수 있습니다.

---

## **DCL(Double checked locking)**
```java
class Singleton {
    private static Singleton instance;

    private Singleton() {}

    public static volatile Singleton getInstance() {
        if (instance == null) { // 1차 널 체크 (락X)
            synchronized (Singleton.class) {
                if (instance == null) { // 2차 널 체크 (락O)
                    instance = new Singleton();
                }
            }
            instance = new Singleton();
        }

        return instance;
    }
}
```

- Thread safe lazy initialization 기법의 성능 저하 문제를 보완하는 기법입니다.
- 메서드 전체에 동기화 작업을 수행하는 것이 아닌 객체 생성하는 작업에만 동기화 작업 수행합니다.

#### **단점**
`volatile` 키워드를 사용하기 위해서는 JVM 버전이 1.5 이상이어야 합니다.
`volatile` 없이 사용하면 `thread unsafe` 문제가 여전히 발생하게 됩니다.

이유 1 : 가시성 문제
: CPU가 바라보는 데이터와 RAM의 데이터와 일치하지 않아서 Singleton 객체가 여러 개 생성될 수 있습니다.

이유 2 : 객체 생성 과정은 "원자적"이지 않음.
: 객체 생성 과정이 원자적이지 않아서 최적화 과정에서 명령어 순서를 바꿀 수 있습니다.
이렇게 되면 존재하지만, 아직 초기화되지 않는 객체를 다른 스레드가 사용할 수 있습니다.

---

## **Bill Pugh Solution 👍**
```java
class Singleton {
    private Singleton() {}
    
    private static class SingtonHolder {
        private static final Singleton INSTANCE = new Singleton();
    }

    public static Singleton getInstance() { 
        return SingletonHolder.INSTANCE; 
    }

}
```

- inner class를 통하여 구현한 방법입니다.
- DCL에서 발생하는 JVM 버전 제약 문제점을 해결한 방법입니다.
- Singleton 클래스에 Holder 변수가 없으므로 `getInstance` 호출 시 실제 객체를 생성하게 됩니다.
- 현재까지 싱글톤 구현에 가장 권장되는 방법입니다.

#### **단점**
리플랙션을 통하여 내부 생성자 호출 가능하며, 역 직렬화가 수행될 때마다 새로운 객체가 생성되어 싱글톤이 파괴될 수 있습니다.

---

## **Enum initialization 👍**
```java
enum Singleton {
    INSTANCE;

    // 추가 필드 값.
    private int state = 10;
    
    public int getState() {
        return state;
    }
}
```

- enum 클래스 자체가 싱글톤의 성질을 가집니다.
    - 생성자가 private이고, 한 번만 초기화하므로 thread safe 합니다.
- Bill Pugh Solution에서 발생하는 리플랙션으로부터 안전합니다.

#### **단점**
enum의 직렬화 시 자신의 이름만 저장합니다. 따라서 추가 필드 값은 직렬화 포맷에 포함되지 않는다고 합니다.
따라서 역직렬화만으로 enum 내부 상태를 복원할 수 없습니다.

---

## 결론
멀티스레드 환경에서는 다음 두 가지 방법을 추천합니다.

Bill Pugh Solution
: 성능이 중요시되는 환경에서 사용

Enum initialization
: 직렬화, 안전성이 중요시되는 환경에서 사용

---

## **참고 문헌**
* Yuki, H. (2022). JAVA 언어로 배우는 디자인 패턴 입문(김성훈, 옮김). 영진닷컴.
* <https://refactoring.guru/design-patterns/singleton>
* <https://skianything.tistory.com/24>
* <https://ittrue.tistory.com/563>