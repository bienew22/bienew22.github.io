---
title: "[Design Pattern] Template Method"
author: bienew22
date: 2025-12-23 12:59:00 +0900
categories: [개념 정리, Design Pattern]
tags: [디자인 패턴, 템플릿 메서드 패턴]
media_subpath: /assets/img/_design-pattern
---
본문으로 들어가기에 앞서 제가 생각하는 템플릿 메서드(Template Method) 패턴의 핵심은 **"처리 과정의 은닉"**입니다. 
해당 글을 읽고 해당 워딩을 이해 되면 좋을 것 같습니다.

## **Template Method Pattern**
템플릿이란 어떤 것을 만들 때 기본적인 틀이나 형식을 제공하여 사용자가 내용을 채워 넣을 수 있도록 만든 양식을 의미합니다.
여기서 알 수 있듯이 템플릿 메소드 내에서 기본적인 형식이 제공되고 자세한 건 사용자(하위 클래스)가 내용을 채워 넣을 수 있도록 하는 것입니다.

식당에 비유하면 손님은 식당이 어떤 순서로 주문을 처리하고, 결제를 수행하고, 음식을 조리하는지 등 전체 과정의 순서를 몰라도 상관이 없습니다.
이러한 **전체적인 운영 절차는 식당 내부에 이미 고정된 규칙으로 정의** 되어 있기 때문입니다.
손님은 **주문할 음식과 카드 정보만 제공**해 주면 됩니다. 그 이후의 과정은 정해진 절차대로 진행되고 손님은 결국 음식을 받을 수 있게 됩니다.

이와 같이 템플릿 메소드 패턴은 알고리즘(처리 순서 등) 전체 구조는 상위 클래스에서 통제하고,
변경이 필요한 부분은 하위 클래스에서 구현하도록 하여 사용자별로 내부 구현에 의존하지 않고 일관된 방식으로 기능을 사용할 수 있게 합니다.

## **패턴 구조**
![템플릿 메서드 패턴 다이어그램](/97-template-method-1.png){: w="95%" .bg-white}

- AbstractClass
    - 템플릿 메소드가 정의되어 있습니다.
    - 템플릿 메소드는 하위 클래스에 의하면 변경되면 안 됩니다.
    - 템플릿 메소드에서 사용될 추상 메소드를 선언합니다.
- ConcreataClass
    - `AbstractClass` 내용을 구현.

### **구현 예시**
```java
abstract class AbstractClass {
    // abstract method
    abstract void head();
    abstract void body();
    
    // hook method
    void tail() {};

    // final을 통하여 오버라이딩 제한.
    final void templateMethod() {
        // 처리의 순서. 
        head();
        body();
        tail();
    }
}

class ConcreateClass extends AbstractClass {
    void head() { 
        // 필수 구현
    };
    void body() { 
        // 필수 구현
    };
    void tail() { 
        // 선택적 구현
    }
}
```

> hook method?
<br>
알고리즘 흐름에 영향을 주되, 구현 여부는 하위 클래스의 선택에 맡기는 것을 의미합니다.
즉, 기본 구현이 있는 상태에서 필요할 때만 오버라이드하여 사용합니다.
{: .prompt-info }

## **간단 예제**
아래 예제를 통하여 간단하게 사용 예시를 보겠습니다.

### **프로젝트 초기 요구 사항**
* bienew 식당은 두 가지 요리를 제공합니다.
* 하나는 파스타이고 다른 하나는 스테이크를 제공합니다.

### **Template Method 패턴 적용 ✖**

```java
class PastaOrder {
    public void order(String cardNo) {
        System.out.println("[검증] 주문 정보 확인");
        System.out.println("[결제] 카드 결제 수행 : " + cardNo);
        System.out.println("[조리] 파스타 조리");
        System.out.println("[서빙] 파스타 서빙");
    }
}

class SteakOrder {
    public void order(String cardNo) {
        System.out.println("[검증] 주문 정보 확인");
        System.out.println("[결제] 카드 결제 수행 : " + cardNo);
        System.out.println("[조리] 스테이크 조리");
        System.out.println("[서빙] 스테이크 서빙");
    }
}
```

코드를 보면 메뉴마다 처리 흐름이 같고, 클래스별로 복붙(중복 코드 多)된걸 확인할 수 있습니다.
하지만 새로운 요리를 추가하는 것에는 크게 어렵지 않다고 느낄 수 있습니다. 

```java
class _food name_Order {
    public void order(String cardNo) {
        System.out.println("[검증] 주문 정보 확인");
        System.out.println("[결제] 카드 결제 수행 : " + cardNo);
        System.out.println("[조리] _food name_ 조리");
        System.out.println("[서빙] _food name_ 서빙");
    }
}
```

이처럼 `_food name_` 부분을 실제 음식 이름으로 교체하면 바로 새로운 요리가 추가 됩니다.
하지만 만약에 **영수증 발급** 같은 단계가 추가되면 이제 수정이 좀 복잡해집니다. 
모든 메뉴 클래스에서 똑같이 해당 로직을 추가하여 수정해야 합니다.

### **Template Method 패턴 적용 ✔**

```java
class OrderTemplate {
    // 템플릿 메소드 - 전체 흐름을 고정.
    public final void order(String payInfo) {
        System.out.println("[검증] 주문 정보 확인");
        System.out.println("[결제] 카드 결제 수행 : " + cardNo);
        cook();
        serve();
    }

    // 변경 지점 - 조리 방법, 서빙 방법
    protected abstract void cook();
    protected abstract void serve();
}

class PastaOrder extends OrderTemplate {
    @Override
    protected void cook() { 
        System.out.println("[조리] 파스타 조리"); 
    }

    @Override
    protected void serve() {
        System.out.println("[서빙] 파스타 서빙");
    }
}

class SteakOrder extends OrderTemplate {
    @Override
    protected void cook() { 
        System.out.println("[조리] 스테이크 조리"); 
    }

    @Override
    protected void serve() {
        System.out.println("[서빙] 스테이크 서빙");
    }
}

class Client {
    void use() {
        OrderTemplate userOrder = new SteakOrder();

        userOrder.order("1111-1111-1111-1111"); 
    }
}
```

새로운 메뉴 추가의 경우 메뉴마다 처리를 추가할 필요 없이 `OrderTemplate`을 상속하여 구현하기만 하면 됩니다.
또 한 로직이 변경(영수증 발급 추가)되면 `OrderTemplate::order`만 수정하면 다른 모든 메뉴에 적용이 됩니다.

즉, 기능 추가와 수정이 더욱 간편해진 것을 확인할 수 있습니다.

## **패턴 장/단점**
### **장점**
- 처리 흐름을 템플릿 메소드에서 관리하기에 일관성을 보장할 수 있습니다.
- 중복 코드를 줄일 수 있습니다.
- 유지보수 시 수정 범위 최소화할 수 있습니다.

### **단점**
- 상속에 강하게 의존하게 됩니다.
- 템플릿 메소드를 수정하면 모든 하위 클래스에 영향을 줍니다.
    - 변경의 영향 범위가 넓습니다.
- 훅 메소드가 많아지면 실제 실행 흐름 파악하기 어려워질 수 있음.

## **참고 문헌**
* Yuki, H. (2022). JAVA 언어로 배우는 디자인 패턴 입문(김성훈, 옮김). 영진닷컴.
* <https://refactoring.guru/design-patterns/template-method>
* <https://www.crocus.co.kr/1531>
* <https://happyalways0511.tistory.com/22>