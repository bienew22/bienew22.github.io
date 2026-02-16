---
title: "[Design Pattern] Builder"
author: bienew22
date: 2026-02-03 16:00:00 +0900
last_modified_at: 2026-02-16 14:24:00 +0900
categories: [개념 정리, Design Pattern]
tags: [디자인 패턴, 빌더 패턴]
media_subpath: /assets/img/_design-pattern
image:
    path: /base.png
---
제가 느낀 빌더(Builder) 패턴의 키워드는 **"객체 구축"**입니다. 

## **Builder Pattern**
빌더 패턴은 **복잡한 객체 생성**을 한 번의 생성자 호출로 만드는 대신 **생성 과정을 여러 단계로 나누어** 각 구성 요소를 점진적으로 설정하고 조립하여 최종 객체를 완성하도록 하는 패턴입니다.

빌더 패턴은 크게 두 가지 형태가 있습니다. GoF에서 정의한 Builder 패턴과 Joshua Bloch가 Effective Java에서 소개한 Builder 패턴이 존재합니다. 두 패턴은 이름은 같지만 **구조와 사용 목적에는 차이**가 있습니다.

> 실무에서 "빌더 패턴"이라고 이야기하면 보통 Joshua Bloch가 소개한 방식을 의미합니다.
{: .prompt-info }

---

## **GoF Builder Pattern**

디자인 패턴의 원형으로 복잡한 객체의 "조립 절차" 자체를 분리하는 데 목적이 있습니다.

예를 들어 다음과 같은 상황을 생각해 보겠습니다.
- 객체를 여러 단계에 걸쳐 조립해야 합니다.
- 구성 순서가 결과에 영향을 미칩니다.
- 같은 조립 절차를 재사용해야 합니다.
- 조립 방식에 따라 서로 다른 형태의 결과물이 만들어집니다.

이런 경우 생성 로직이 한 클래스에 모두 들어가게 되면, 생성 코드가 너무 비대해지고 변경에 취약해집니다.
이런 문제를 해결하기 위하여 **조립 절차(Director)와 구체적인 구성 내용(Builder)으로 분리**합니다.

---

### **패턴 구조**
![빌더 패턴 다이어그램](/93-builder-1.png){: w="80%" .bg-white}

- **Builder**
    - 객체를 구성하는 단계들을 정의하는 추상 계층.
    - "어떤 단계가 존재하는가?"를 결정.
- **ConcreteBuilder**
    - 실제 구성 내용을 담당.
    - "각 단계가 어떻게 만들 것인가?"를 결정.
- **Director**
    - 조립 순서를 제어하고 동일한 생성 절차로 서로 다른 결과물을 만들 수 있도록 함.
    - "어떤 순서로 만들 것인가?"를 결정.
- **Client**
    - `ConcreteBuilder`을 `Director`에 제공하여 객체 생성을 함.
    - 객체 생성 절차를 몰라도 됨.

---

### **구현 예시**

* **상황 예시**
    - 같은 데이터를 기반으로 TEXT 문서와 JSON 문서를 만들어야 한다고 가정하겠습니다.
* **Data** - 공통 데이터 구조
    ```java
    public class Data {
        public String name;
        public Integer age;

        public Data(String name, Integer age) {
            this.name = name;
            this.age = age;
        }
    }
    ```
* **Builder**
    ```java
    public abstract class Builder {
        Data data;

        public Builder(Data data) { this.data = data; }

        public abstract String buildHead();
        public abstract String buildName();
        public abstract String buildAge();
        public abstract String buildTail();
    }
    ```
* **Director**
    ```java
    public class Director {
        Builder builder;

        public Director(Builder builder) { this.builder = builder; }

        public String construct() {
            StringBuilder sb = new StringBuilder();

            sb.append(builder.buildHead());
            sb.append(builder.buildName());
            sb.append(builder.buildAge());
            sb.append(builder.buildTail());

            return sb.toString();
        }
    }
    ```
* **JsonBuilder**
    ```java
    public class JsonBuilder extends Builder{
        public JsonBuilder(Data data) {
            super(data);
        }

        @Override
        public String buildHead() {
            return "{\n";
        }

        @Override
        public String buildName() {
            return "\tname: " + data.name + ", \n";
        }

        @Override
        public String buildAge() {
            return "\tage: " + data.age + "\n";
        }

        @Override
        public String buildTail() {
            return "}";
        }
    }
    ```
* **TextBuilder**
    ```java
    public class TextBuilder extends Builder{
        public TextBuilder(Data data) {
            super(data);
        }

        @Override
        public String buildHead() {
            return "Let me introduce myself. ";
        }

        @Override
        public String buildName() {
            return "My name is " + data.name;
        }

        @Override
        public String buildAge() {
            return " and my age is " + data.age + ". ";
        }

        @Override
        public String buildTail() {
            return "Nice to meet you.";
        }
    }
    ```
* **Client**
    ```java
    class Main {

        public static void main(String[] args) throws Exception {

            Data data = new Data("admin", 25);

            // Text format
            Director textDirector = new Director(new TextBuilder(data));
            System.out.println(textDirector.construct());

            // Json format
            Director jsonDirector = new Director(new JsonBuilder(data));
            System.out.println(jsonDirector.construct());
        }
    }
    ```

이 처럼 Director 통하여 일관된 프로세스로 객체를 생성하고 재사용할 수 있게 됩니다.

---

## **Bloch Builder Pattern**

해당 패턴은 "파라미터가 많은 생성자 호출이 가져오는 가독성과 안정성 문제"를 해결하는 데 초점을 두고 있습니다.

예를 들어 다음과 같은 생성 코드가 있다고 가정해 보겠습니다.
```java
new Something(a, b, c, d, e, ...);
```
해당 방식에는 여러 단점이 존재합니다.

첫째, 각 파라미터의 의미가 코드만 보고는 명확하게 드러나지 않습니다.
: 변수명을 직접 보지 않는 이상 어떤 값이 어떤 역할을 하는지 한눈에 파악하기 어렵습니다.

둘째, 파라미터 순서가 바뀌는 실수를 유발하기 쉽습니다.
: 특히 타입이 같은 파라미터가 여러 개일 경우 컴파일 단계에서 오류가 발생하지 않기 때문에 런타임 버그로 이어질 가능성이 큽니다.

셋째, 기본값을 가지는 파라미터라도 생성마다 직접 전달해야 하는 불편함이 있습니다.
: 생성자 다형성을 통하여 구현할 수 있지만 생성자 시그니처가 계속 늘어나는 문제로 이어집니다.

    > 생성자 종류가 과도하게 많아지면서 어떤 생성자를 사용해야 하는지 판단하기 어려워지는 문제를 "생성자 폭발 문제"라고 합니다.
    {: .prompt-info }

### **구현 예시**
```java
public class Article {
    private String title;
    private String content;
    private String author;

    public static class Builder {
        private String title;
        private String content;
        private String author;

        Builder title(String title) {
            this.title = title;
            return this;
        }

        Builder content(String content) {
            this.content = content;
            return this;
        }

        Builder author(String author) {
            this.author = author;
            return this;
        }

        Article build() {
            return new Article(this);
        }
    }

    // 빌더를 사용하여 생성하기에 private 설정.
    private Article(Builder builder) {
        this.title = builder.title;
        this.content = builder.content;
        this.author = builder.author;
    }
}

public class Client {
    void use() {
        Article article = new Article.Builder()
                .title("test")
                .content("content")
                .author("bienew22")
                .build();
    }
}

```

---

## **참고 문헌**
* Yuki, H. (2022). JAVA 언어로 배우는 디자인 패턴 입문(김성훈, 옮김). 영진닷컴.
* <https://refactoring.guru/design-patterns/builder>
* <https://rob-coding.tistory.com/53>