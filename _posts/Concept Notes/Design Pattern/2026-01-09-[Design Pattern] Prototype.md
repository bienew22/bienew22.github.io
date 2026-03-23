---
title: "[Design Pattern] Prototype"
slug: "design prototype pattern"
author: bienew22
date: 2026-01-09 16:00:00 +0900
categories: [개념 정리, Design Pattern]
tags: [design pattern]
media_subpath: /assets/img/_design-pattern
image:
    path: /base.png
---
제가 느낀 프로토타입(Prototype) 패턴의 키워드는 **"객체 복제"**입니다. 

## **Prototype Pattern**
프로토타입 패턴은 새로운 인스턴스를 만들 때 객체를 **새로 생성(`new`)하지 않고, 기존 객체를 복제(`.clone()`)**하여 인스턴스를 생성하는 패턴입니다.

#### **_언제 필요한가?_**

(1) 객체 생성 비용이 큰 경우
: 예를 들어 뱀파이어 서바이벌 게임과 같이 다수의 적을 반복적으로 생성한다고 가정하겠습니다.
만약 적 객체를 생성할 때 필요한 정보(체력, 공격력 등)를 매번 DB에서 조회하여 초기화한다면 새로운 적을 생성할 때마다 DB 접근이 발생하게 됩니다.
이는 대량의 적을 한 번에 생성해야 하는 상황이 발생하게 되면 성능 저하의 주요 원인이 될 수 있습니다.
따라서 이런 경우 적의 기본 정보를 한 번만 로딩하여 프로토타입 객체를 생성하고, 이를 복제하여 적을 생성하는 것이 더 효율적입니다.

(2) 종류가 너무 많아 클래스로 관리하기 어려운 경우
: 예를 들어 전략 시뮬레이션 게임을 한번 생각해 보겠습니다. 보병, 궁수, 포병 등 기본 병종을 기반으로 세부 스펙만 다른 약 100 여종의 병종이 존재한다고 가정 해 보겠습니다. 
이러한 병종들을 모두 개별 클래스로 관리할 경우, 다수의 유사한 구조를 가진 파일을 작성해야 합니다. 
이때 프로토타입 패턴과 Registry 구조를 함께 적용하면, 병종별 공통 구조를 하나의 클래스에서 관리하여 병종이 증가하여도 더 효율적으로 관리할 수 있게 됩니다.

(3) 클래스로 인스턴스 생성이 어려운 경우
: 예를 들어 캐릭터 커스터마이징 기능을 생각해 보겠습니다. 사용자는 캐릭터 외형, 능력치, 장비 등 다양한 요소를 조합하여 캐릭터를 생성합니다. 이러한 조합의 경우의 수가 매우 많아, 각 경우를 미리 클래스로 정의하고 관리하는 것은 불가능합니다. 이때 프로토타입을 적용하여 동일한 설정을 가진 캐릭터가 필요한 경우, 프로토타입 객체를 복제하여 인스턴스를 생성할 수 있습니다.

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
* **Prototype**
    ```java
    public abstract class Prototype implements Cloneable {
        protected abstract Prototype createByClone() 
            throws CloneNotSupportedException;

        /**
         * 모든 하위 클래스에서 단순히 clone()을 통하여 복제하면
         * 아래 처럼 공통적으로 예외 처리 로직이 들어감.
         * 따라서 템플릿 메소드 패턴을 적용하여 예외 처리 로직을 관리.
         */
        public final Prototype cloneMe() {
            
            Prototype p = null;

            try {
                p = (Prototype) createByClone();
            } catch (CloneNotSupportedException e) {
                System.out.println("CloneNotSupportedException");;
            }
            return p;
        }
    }
    ```
    > Java에서 인스턴스 복사하는 메소드로 `clone()`이 존재합니다. `clone()`을 실행할 경우 복사 대상이 되는 클래스는 `Clonable` 인터페이스를 구현해야만 합니다. 해당 인터페이스는 단순히 **'clone 메소드로 복제를 허용한다.'** 표시로 마커 인터페이스라고 부릅니다.
    {: .prompt-info }

* **ConcretePrototype**
    ```java
    public class ConcretePrototype extends Prototype{
        @Override
        protected Prototype createByClone() throws CloneNotSupportedException {
            return (Prototype) clone();
        }
    }
    ```

* **Client**
    ```java
    public class Client {
        public void start() {
            ConcretePrototype origin = new ConcretePrototype();

            ConcretePrototype other = origin.cloneMe();
        }
    }
    ```

* **Registry 사용한 경우**
    ```java
    public class Registry {
        private Map<String, Prototype> map = new HashMap<>();

        public void register(String name, Prototype prototype) {
            map.put(name, prototype);
        }

        public Prototype create(String name) {
            Prototype prototype = map.get(name);

            return prototype.cloneMe();
        }
    }

    public class Client {
        // 등록
        Registry factory = new Registry();

        factory.register("p1", new ConcretePrototype());

        // 복제
        ConcretePrototype clone = factory.create("p1");
    }
    ```

---

## **Java에서 구현**
실제 Java 프로그램으로 인스턴스를 복제해야 하는 경우, clone 보다는 복사 생성자나 복사 팩토리를 사용하는 것이 좋습니다. 그 이유는 `clone()`이 `protected`로 지정되어, 상속 관계가 없는 클래스의 `clone` 메소드를 호출하기 어렵기 때문입니다.

* **복사 생성자**
```java
    public class ConcretePrototype extends Prototype{

        public ConcretePrototype(ConcretePrototype origin) {
            // ... 여기서 속성 복사
            // ex) this.a = origin.getA();
        }

        @Override
        protected Prototype createByClone() throws CloneNotSupportedException {
            return new ConcretePrototype(this);
        }
    }
```

---

## **참고 문헌**
* Yuki, H. (2022). JAVA 언어로 배우는 디자인 패턴 입문(김성훈, 옮김). 영진닷컴.
* <https://refactoring.guru/design-patterns/prototype>
* <https://shan0325.tistory.com/26#google_vignette>