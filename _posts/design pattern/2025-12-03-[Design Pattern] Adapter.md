---
title: "[Design Pattern] Adapter"
author: bienew22
date: 2025-12-03 16:59:00 +0900
categories: [개념 정리, Design Pattern]
tags: [디자인 패턴, 어댑터 패턴]
media_subpath: /assets/img/_design-pattern
---
본문으로 들어가기에 앞서 제가 생각하는 어댑터(Adapter) 패턴의 핵심은 **"수정 없이 호환성 추가"**입니다. 
해당 글을 읽고 해당 워딩을 이해 되면 좋을 것 같습니다.

## **Adapter Pattern**
일상생활에서 사용하는 충전기는 220V의 교류 전원을 전자기기가 사용할 수 있도록 직류 전원으로 변환해 주는 역할을 합니다.
이처럼 어댑터 패턴은 서로 호환되지 않아 함께 동작할 수 없는 클래스들을 중간에서 **변환, 중재하여 처음부터 호환**되는 것처럼 사용할 수 있도록 도와주는 패턴입니다.
즉, 이미 제공된 것(220V 교류 전원)과 필요한 것(직류 전원) 사이의 차이를 메우는 것입니다.

> 무언가를 포장해서 다른 용도로 사용할 수 있도록 변환해 주어서 Adapter Pattern은 Wrapper Pattern이라고도 불립니다.
{: .prompt-tip }

## **패턴 구조**
어댑터 패턴은 기존 클래스를 **상속**을 통하여 호환성을 추가하거나, 기존 클래스의 역할을 **위임** 받아서 호환성을 추가하는 방법이 존재합니다.

### **상속을 사용**
![반복자 패턴 다이어그램](/98-adapter-1.png){: w="95%" .bg-white}
_상속을 사용한 구현 했을 때 다이어그램_

- Target (인터페이스)
    - 최종 목표로 되는 인터페이스.
    - Client가 필요로 하고 실제로 사용하는 것.
- Adapter (클래스)
    - 호환성이 없는 Adaptee과 Target을 연결해 주는 역할.
    - 상속을 이용하여 구현됨.
- Adaptee (클래스)
    - 이미 제공되는 것들.

#### **구현 예시**
```java
// 사용자의 요구 사항.
interface Target {
    void needA();
    void needB();
}

// 기존에서 제공하던 기능. (요구사항 A를 만족 시킴.)
class Adaptee {
    void provided() {
        System.out.println("hello");
    }
}

class Adapter extends Adaptee implements Target {
    // 어댑터를 통하여 요구사항 A는 기존꺼를 사용하여 제공.
    void needA() { provied(); }
    
    // 없는 요구사항 B는 구현하여 제공.
    void needB() { ...구현... }
}

// Client는 Target Interface를 통하여 서비스에 접근.
class Client {  
    void use {
        Target target = new Adapter();
        target.needA();
    }
}
```

### **위임을 사용**
![반복자 패턴 다이어그램](/98-adapter-2.png){: w="95%" .bg-white}
_위임을 사용한 구현 했을 때 다이어그램_

- Target (인터페이스)
    - 최종 목표로 되는 인터페이스.
    - Client가 필요로 하고 실제로 사용하는 것.
- Adapter (클래스)
    - 호환성이 없는 Adaptee과 Target을 연결해 주는 역할.
    - 객체 주입을 통하여 구현됨.
- Adaptee (클래스)
    - 이미 제공되는 것들.

#### **구현 예시**
```java
// 사용자의 요구 사항.
interface Target {
    void needA();
    void needB();
}

// 기존에서 제공하던 기능. (요구사항 A를 만족 시킴.)
class Adaptee {
    void provided() {
        System.out.println("hello");
    }
}

class Adapter implements Target {
    Adaptee adpatee;

    // 어댑터를 통하여 요구사항 A를 Adaptee에 위임.
    void needA() { adaptee.provied(); }
    
    // 없는 요구사항 B는 구현하여 제공.
    void needB() { ...구현... }
}

// Client는 Target Interface를 통하여 서비스에 접근.
class Client {  
    void use {
        Target target = new Adapter(new Adaptee());
        target.needA();
    }
}
```

> Java에서는 다중 상속을 지원하지 않기 때문에 상속보다는 위임을 사용하는 것을 권장합니다. 
{: .prompt-tip}

### **패턴 설명**
어댑터 패턴을 처음으로 접하면 "필요한 기능을 기존 클래스에 추가하면 되지 굳이 복잡하게 Adapter 패턴 같은 것을 고민해 봐야 하는가?"
라는 의문이 생길 수 있습니다.

지금까지 설명을 봤을 때 기존 클래스를 직접 수정하는 것이 더 편해 보일 수 있습니다. 
하지만 기존 클래스의 경우에는 이미 충분한 테스트 거쳐 안정적으로 동작하는 경우가 많습니다.
이를 수정하면 해당 클래스를 사용하는 모든 코드에 대해 다시 테스트해야 하는 부담이 생깁니다. 
반면 어댑터 패턴을 사용하면 기존 클래스를 수정하지 않고 새로운 기능을 제공하기에 버그 발생하게 되면 어댑터 클래스 중심으로 살펴보면 됩니다.

## **간단 예제**
아래 예제를 통하여 간단하게 사용 예시를 보겠습니다.

#### **프로젝트 초기 요구 사항**
* bienew 회사는 대부분 사람이 카드 사용하므로 결제 시스템을 카드사 API를 사용하기로 합니다.
* 다음처럼 다양한 결제 시스템이 외부 라이브러리로 존재합니다.

```java
class CardAPI {
    public void request(int amount) {
        System.out.println("카드사 결제: " + amount);
    }
}

class TossAPI {
    public void tossPay(int amount) {
        System.out.println("Toss 결제: " + amount);
    }
}

...else...
```

#### **Adapter 패턴을 적용 X**
```java
class Client {
    // 클라이언트가 직접 카드사 통해 결제.
    CardAPI pay;

    Client(CardApi pay) { this.pay = pay; }

    void pay(int amount) {
        pay.request(amount);
    }
}

class Main {
    void main() {
        // 사용자에게 10000원 결제 요청.
        Client aClient = new Client(new CardAPI());
        aClient.pay(10000);
    }
}
```

이렇게 봤을 때 크게 문제 될 거 없어 보입니다. 
하지만 고객이 늘어나면서 일부 고개들은 항상 카드를 들고 다녀야 해야 불편함을 호소합니다. 
이에 회사는 Toss API 도입하여 모바일로 더욱 편리하게 결제할 수 있도록 하려고 합니다.
단, 일부 고객은 Toss를 사용하지 않으므로 기존 서비스는 유지하려고 합니다.

```java
class Client {
    // 두 API는 다르므로 사용자가 모두 가져고 상황에 맞게 결제해야합니다.
    CardAPI pay;
    TossAPI toss;

    Client(CardApi pay) { this.pay = pay; }
    Client(TossAPI toss) { this.toss = toss; }

    void pay(int amount) { pay.request(amount);}
    void tossPay(int amount) { toss.tossPay(amount); }
}

class Main {
    void main() {
        // 사용자에게 10000원 결제 요청.
        Client aClient = new Client(new CardAPI());
        aClient.pay(10000);

        // 이제 사용자에게 토스로 결제 요청 가능.
        Client bClient = new Client(new TossAPI());
        bClient.tossPay(10000);
    }
}
```

여기서부터는 좀 이상한 느낌이 듭니다. 만약에 결제 시스템이 100개를 사용하게 되면 사용자는 100개의 결제 시스템 API를 알고 있어야 하고 그것에 맞게 100개의 결제 메소드가 존재해야 합니다. 
이렇게 되면 사용자는 실제로 카드로 결제를 수행했는데 토스로 결제되는 문제도 발생할 수 있습니다.

#### **Adapter 패턴을 적용 O**
```java
// 타겟 인터페이스.
interface Payment {
    void pay(int amount);
}

// 카드사 결제를 위한 어댑터.
class CardAdapter implements Payment {
    CardAPI pay;

    CardAdapter(CardAPI api) = { pay = api; }

    @Override
    void pay(int amount) {
        pay.request(amount);
    }
}

class Clinet {
    // 클라이언트는 더 이상 직접 결제 API에 접근 하지 않고
    // 새로운 인터페이스를 통하여 접근하게 됨.
    Payment payment;

    Client(Payment payment) { this.payment = payment; }

    void pay(int amount) {
        payment.pay(amount);
    }
}

class Main {
    void main() {
        Client aClient = new Client(new Payment(new CardAPI()));
        aClient.pay(10000);
    }
}
```

여기서 `Client`는 결제를 실제 결제 시스템이 아닌 인터페이스로 접근하게 됩니다.
따라서 새로운 결제 수단을 추가해도 요청하는 쪽에서 요청 방법만 수정하면 됩니다.

```java
interface Payment {
    void pay(int amount);
}

// 토스 결제를 위한 어댑터 추가.
class TossAdapter implements Payment {
    TossAPI pay;

    TossAdapter(TossAPI api) = { pay = api; }

    @Override
    void pay(int amount) {
        pay.tossPay(amount);
    }
}

class Clinet {
    Payment payment;

    Client(Payment payment) { this.payment = payment; }

    void pay(int amount) {
        payment.pay(amount);
    }
}

class Main {
    void main() {
        // 카드사 결제 요청.
        Client aClient = new Client(new Payment(new CardAPI()));
        aClient.pay(10000);

        // 토스 통한 결제 요청.
        Client bClient = new Client(new Payment(new TossAPI()));
        bClient.pay(10000);
    }
}
```

이처럼 서로 다른 결제 시스템을 통하여 결제를 수행하지만, 사용자의 요청을 획일화시킬 수 있습니다.
이렇게 결제 시스템이 100개 사용하더라도 결제 요청하는 쪽에서 결제 방법만 수정하면 됩니다.

## **패턴 장/단점**
### **장점**
* 기존 클래스 코드를 수정하지 않고 어댑터를 통하여 작동하기 때문에 개방 폐쇄 원칙(OCP)을 만족하게 됩니다.
* 서로 다른 인터페이스를 가진 클래스들을 통합할 수 있음.

### **단점**
* 다수의 새로운 인터페이스와 클래스들이 추가되면서 코드의 복잡성이 증가합니다. 따라서 때로는 기존 클래스를 수정하는 것이 더 효율적일 수 있습니다.
* 기존 시스템과 너무 다르면 어댑터 클래스에서 너무 많은 일을 수행하게 될 수 있습니다.
    * `Target`과 `Adaptee`가 너무 동떨어지면 사용하지 않는 것이 좋습니다.

## **참고 문헌**
* Yuki, H. (2022). JAVA 언어로 배우는 디자인 패턴 입문(김성훈, 옮김). 영진닷컴.
* <https://refactoring.guru/design-patterns/adapter>
* <https://jusungpark.tistory.com/22>