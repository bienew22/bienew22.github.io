---
title: "[Design Pattern] Bridge"
slug: "bridge pattern"
author: bienew22
date: 2026-03-18 10:00:00 +0900
last_modified_at: 2026-03-22 12:24:00 +0900
tags: [design pattern]
media_subpath: /assets/img/_design-pattern
image:
    path: /base.png
---
제가 느낀 브릿지(Bridge) 패턴의 키워드는 **"기능과 구현의 독립적 확장"**입니다. 

## **Bridge Pattern**

브릿지 패턴은 두 장소를 연결하는 다리처럼, '기능 클래스 계층'과 '구현 클래스 계층'을 연결하는 역할을 수행합니다.
이 두 계층의 개념은 '클래스 확장'에 있습니다. 확장에는 두 가지 독립적인 변화 축을 가질 수 있습니다.  

#### **기능 클래스 계층 이란?**

&nbsp;기능 클래스 계층은 **"무엇을 할 것인지"**에 대한 확장을 의미합니다. 예를 들어, 단순한 출력 기능만 제공하던 프린터에 스캔 기능을 추가하면
이는 새로운 기능을 확장한 것입니다. 

```java
interface Printer {
    void print();
}

interface ScannablePrinter extends Printer {
    void scan();
}
```

- `Printer` -> 기본 출력 기능
- `ScannablePrinter` -> 출력 + 스캔 기능

즉, 기능 자체를 확장하는 방향을 의미합니다.

#### **구현 클래스 계층 이란?**

&nbsp;구현 클래스 계층은 **"동일한 기능을 어떻게 수행할 것인가?"**에 대한 확장을 의미합니다. 예를 들어 동일한 출력이라도 콘솔에 출력할 수 있고, 파일에 출력할 수 있습니다.

```java
class ConsolePriter implements Printer {
    public void print() {
        System.out.println("hello");
    }
}

class FilePrinter implements Printer {
    public void print() {
        try (FileWriter tile = new FileWriter("world.txt")) {
            file.write("hello");
        } catch (Exception e) {
            System.err.println("error");
        }
    }
}
```

즉, 구현 방식만 확장하는 방향을 의미합니다.

#### **두 계층 혼재의 문제점**

&nbsp;기능과 구현이 분리되지 않고 하나의 계층에 섞여 있는 경우, 새로운 요구사항이 추가될 때마다 클래스 수가 급격히 증가하는 문제가 발생합니다.

예를 들어 다음과 같은 조합이 필요하다고 하겠습니다.
- 스캔 가능한 프린터 + 콘솔 출력
- 스캔 가능한 프린터 + 파일 출력

이 처럼 기능과 구현이 서로 조합되기 시작하면 각각을 독립적으로 확장할 수 없기에 새로운 조합이 필요할 때마다 별도의 클래스를 추가해야 합니다.

기능의 개수를 N, 구현의 개수를 M개라고 했을 때 최악의 경우 N x M 개의 클래스가 생성되는 구조가 됩니다.

#### **결론**

&nbsp;브릿지 패턴은 기능과 구현을 분리하여 각각 독립적으로 확장할 수 있도록 합니다. 이때 기능 계층이 구현 계층을 **'상속'이 아닌 '조합'**으로 참조하게 합니다.

---

## **패턴 구조**
![브릿지 패턴 다이어그램](/92-bridge-1.png){: w="90%" .bg-white}

- **Abstraction**
    - '기능 클래스 계층'의 최상위 클래스로입니다.
    - 기본 인터페이스를 정의하고, 실제 동작은 `Implementor` 구현 객체에 위임합니다.
    - `impl` 메소드를 사용하여 기본 기능만 존재합니다.
- **RefinedAbstraction**
    - `Abstraction`을 상속받아 기능을 확장한 클래스입니다.
- **Implementor**
    - '구현 클래스 계층'의 최상위 인터페이스입니다.
    - 기능을 수행하기 위한 메서드를 정의합니다.
- **ConcreteImplementor**
    - `Implementor`를 구현한 실제 클래스입니다.
    - 구체적인 동작 방식(예: 콘솔, 파일 출력 등)을 정의합니다.

> Abstraction은 Implementation을 합성으로 포함하고, 실제 동작을 Implementation에 위임하여 두 계층을 연결합니다.
{: .prompt-tip}
---

## **구현 예시**

#### **요구 사항**
프린터 시스템을 만들려고 합니다.

* 프린터는 기본적으로 출력 기능이 존재합니다. (일반 출력, 양면 출력 등)
* 출력 방식은 다양하게 존재합니다. (콘솔 출력, 파일 출력 등)

#### **구현 계층**
출력을 "어떻게 할 것인가"를 정의합니다.

- **Implementor**
    ```java
    interface PrintImpl {
        void print(String message);
    }
    ```
- **ConcreteImplementor**
    ```java
    class ConsolePrint implements PrintImpl {   // ---- 콘솔 출력
        public void print(String message) {
            System.out.println(message);
        }
    }

    class FilePrint implements PrinterImpl {    // ---- 파일 출력
        public void print(String message) {
            try (FileWriter file = new FileWriter("output.txt")) {
                file.write(message);
            } catch (Exception e) {
                System.err.println("file print error");
            }
        }
    }
    ```

#### **기능 계층**
프린터가 "무엇을 할 것인가"를 정의합닏다.

- **Abstraction**
    ```java
    class BasicPrinter {
        PrintImpl printImpl;

        public BasicPrinter(PrintImpl impl) {
            printImpl = impl;
        }

        public void print(String some) {
            printImpl.print(some);
        }
    }
    ```
- **RefinedAbstraction**
    ```java
    class DoubleSidePrinter extends BasicPrinter {  // ---- 양면 출력 기능 추가
        public DoubleSidePrinter(PrintImpl impl) {
            super(impl)
        }

        public void doubleSidePrint(String some) {
            impl.print("[heads]" + some);
            impl.print("[tails]" + some);
        }
    }
    ```

#### **사용**
```java
public class Main {
    public static void main(Stringp[] args) {
        // 콘솔에 출력하는 기본 프린터
        BasicPrinter bPrinter = new BasicPrinter(new ConsolePrint());

        // 콘솔에 출력하는 양면 프린터
        DoubleSidePrinter dsPrinter = new DoubleSidePrinter(new ConsolePrint());

        // 파일에 출력하는 기본 프린터
        BasicPrinter bfPrinter = new BasicPrinter(new FilePrint())
    }
}
```

---

## **새로운 기능 추가 시 고려할 점**

브릿지 패턴을 적용하다 보면 **새로운 기능을 추가하려 할 때 기존 `Implementor`의 메소드만으로는 구현할 수 없는** 상황을 마주할 수 있습니다.
이 경우에는 기능을 어떤 방식으로 확장할지 고민해 봐야 합니다.

**방법1 : Implementor 인터페이스 확장**
: 가장 직관적인 방법으로 `Implementor`에 새로운 기능을 추가하는 것입니다.

    ```java
    interface PrintImpl {
        void print(String message);
        void printColor(String message, Color color);        // 새로운 기능 추가
    }
    ```

    그리고 **모든 구현체를 수정**합니다.

**방법2 : 구현 계층 분리**
: 다른 방법으로 구현 계층을 **기능별로 분리**하는 것입니다.

    ```java
    interface PrintImpl {
        void print(String message);
    }

    interface ScanImpl {
        void scan();
    }
    ```

    스캔 기능과 출력 기능을 다른 계층으로 분리하고 기능 계층에서 조합하여 사용합니다.

    ```java
    // 출력 기능 + 스캔 기능이 있는 프린터
    class ScannablePrinter extends BasicPrinter {
        private ScanImpl scanImpl;

        public ScannablePrinter(PrinterImpl print, ScanImpl scan) {
            super(print);
            scanImpl = scan;
        }

        public void scan() {
            scanImpl.scan();
        }

    }
    ```

<br/>
두 방법은 각각의 장단점이 있으며, 상황에 따라서 적절한 방식을 선택하는 것이 중요합니다.

---

## **패턴 장/단점**
### **장점**
* 기능과 구현의 독립적으로 확장할 수 있습니다.
* 변경에 대한 영향 범위가 축소할 수 있습니다.

### **단점**
* 구조 복잡도가 증가합니다.
    - 작은 규모에서는 오히려 과한 설계가 될 수 있습니다.
- 설계 난이도가 상승합니다.
    - "어디까지를 기능으로 보고, 어디까지를 구현으로 분리할 것인가"를 잘 못하면 오히려 구조가 꼬일 수 있습니다.

---

## **참고 문헌**
* Yuki, H. (2022). JAVA 언어로 배우는 디자인 패턴 입문(김성훈, 옮김). 영진닷컴.
* <https://refactoring.guru/design-patterns/bridge>
* <https://bloodstrawberry.tistory.com/1402>