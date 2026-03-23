---
title: "[Design Pattern] Factory Method"
author: bienew22
date: 2025-12-31 10:00:00 +0900
categories: [개념 정리, Design Pattern]
tags: [design pattern]
media_subpath: /assets/img/_design-pattern
image:
    path: /base.png
---
제가 느낀 팩토리 메서드(Factory Method) 패턴의 키워드는 **"생성 책임 위임"**입니다. 

## **Factory Method Pattern**
팩토리 메서드 패턴은 **템플릿 메서드 패턴을 인스턴스 생성에 적용한 패턴**입니다.

인스턴스 생성을 일종의 공장(Factory) 클래스에 위임하여 클라이언트에서 `new Object()` 방법으로 객체를 생성하는 것이 아닌, 
`factory.create("some param")`처럼 공장을 통하여 객체를 생성하게 됩니다.

## **패턴 구조**
![팩토리 메서드 패턴 다이어그램](/96-factory-method-1.png){: w="80%" .bg-white}

- Factory 
    - 최상위 클래스로 인스턴스를 생성하는 템플릿 메서드를 정의
- Product
    - 실제 생성 할 인스턴스의 추상화
- ConcreteFactory
    - 실제 인스턴스 생성 과정을 정의
- ConcreteProduct
    - 실제 생성 할 인스턴스

### **구현 예시**
```java
interface Product {
    // 실제 인스턴스들이 공통으로 수행하는 일.
    void use();
}

abstract class Factory {
    // 객체 생성 과정을 정의하는 탬플릿
    final Product create() {
        // ... 전체 객체 생성 전처리 ...
        Product res = createProduct();  // 객체 생성
        // ... 전체 객체 생성 후처리 ...

        return res;
    }

    // 팩토리 메서드 : 실제 인스턴스를 생성을 하위 클래스에 위임
    abstract protected Product createProduct();
}

class ConcreteProduct implements Product {
    // something...
}

class ConcreteFactory extends Factory {
    @Override
    ConcreteProduct createProduct() {
        // 타입 전용 전처리 ...
        ConcreteProduct ins = new ConcreteProduct();
        // 타입 전용 후처리 ...
        return ins;
    }
}

class Client {
    void use() {
        Factory factory = new ConcreteFactory();
        Product pro = factory.create();

        pro.use();
    }
}
```

## **간단 예제**
아래 예제를 통하여 간단하게 사용 예시를 보겠습니다.

### **프로젝트 초기 요구 사항**
- 알림 어플리케이션를 개발하려고 합니다.
- 사용자에게 알림을 주는 방법으로는 앱 푸시, 문자 방식이 존재합니다.

### **Factory Method 패턴 적용 ✖**
```java
class SmsNotification {
    void send() {
        System.out.println("문자 알림 전송");
    }
}

class PushNotification {
    void send() {
        System.out.println("푸시 알림 전송");
    }
}

class NotificationService {
    public void notify(String type) {
        if (type.equals("SMS")) {
            new SmsNotification().send();
        } else if (type.equals("PUSH")) {
            new PushNotification().send();
        }
    }
}
```

해당 코드는 다음과 같은 문제가 발생하게 됩니다.
1. 객체 생성 과정이 복잡해지면 서비스에서 너무 많은 일을 하게 됩니다.
```java
if (type.equals("SMS")) {
    SmsNotification noti = new SmsNotification();
    
    // 여기서 뭔가 많을 일 수행
    noti.initSession();
    noti.validate();
    noti.connect();
    noti.commnuti();
    // 등등

    noti.send();
}
```
    - 이렇게 모든 로직이 서비스 메서드 내부에 들어오면 **유지 보수하기 너무 힘들게 됩**니다.
2. 생성 로직과 사용 로직이 강하게 결합하게 됩니다.
    - SRP(단일 책임 원치)을 위반하게 됩니다.

> 단, 실제로 구체 객체(ConcreteProduct) 종류가 몇 개 안 되고 또한 추가되지 않는다면 현재 방법이 더욱 좋은 코드일수 있습니다.
{: .prompt-info }

### **Factory Method 패턴 적용 ✔**

* **추상화 계층**
```java
interface Notification {
    void send();
}
abstract class NotificationFactory {
    public final Notification create() {
        Notification res = createNotification();
        return res;
    }

    abstract Notification createNotification();
}
```

* **앱 푸시 구현**
```java
class PushNotification implements Notification {
    void send() {
        System.out.println("앱 푸시 알림 전송!");
    }
}
class PushNotificationFactory extends NotificationFactory {
    Notification createNotification() {
        return new PushNotification();
    }
}
```

* **문자 알림 구현**
```java
class SmsNotification implements Notification {
    void send() {
        System.out.println("문자 알림 전송!");
    }
}
class SmsNotificationFactory extends NotificationFactory {
    Notification createNotification() {
        return new SmsNotification();
    }
}
```

* **서비스 계층**
```java
class NotificationService {
    public void notify(String type) {
        NotificationFactory factory;
        if (type.equals("SMS")) {
            factory = new SmsNotificationFactory();
        } else if (type.equals("PUSH")) {
            factory = new PushNotificationFactory();
        }

        Notification notification = factory.create();

        notification.send();
    }
}
```

이를 통하여 서비스에서는 사용자의 요청에 따라서 어떤 알림을 전송할지 선택만 하면 됩니다.

## **패턴 장/단점**
### **장점**
- 객체 생성과 사용을 분리하여 서비스 코드가 가벼워지고 역할이 명확해집니다.

### **단점**
- 관리해야 하는 클래스가 늘어납니다.
    - 한 객체에 한 공장이라서 객체가 늘어가면 팩토리 클래스도 증가합니다.
- 구조가 복잡해 보일 수 있고, 소규모 프로젝트에서는 과설계가 될 가능성이 존재합니다.

## **참고 문헌**
* Yuki, H. (2022). JAVA 언어로 배우는 디자인 패턴 입문(김성훈, 옮김). 영진닷컴.
* <https://refactoring.guru/ko/design-patterns/factory-method>
* <https://bcp0109.tistory.com/367>