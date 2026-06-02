---
title: "[Git] git rebase?"
slug: "git-rebase"
author: bienew22
date: 2026-05-29 20:04:37 +09:00
#last_modified_at: 2026-05-29 20:04:37 +09:00
tags: [git, git rebase]
media_subpath: /assets/img/_git/rebase1
#image:
#   path:
---

## **git rebase?**
git rebase는 해당 브랜치의 커밋들을 새로운 기준 커밋(base) 위에 재적용하여 브랜치의 시작 지점을 변경하고 히스토리를 재구성하는 기능입니다.

사용 예시:
```bash
git checkout develop
git rebase <target>
```

의미:
- `develop` 브랜치의 커밋들을 `target`을 기준으로 다시 적용합니다.
- `<target>`은 특정 커밋 해시 또는 브랜치 이름을 지정할 수 있습니다. 주로 브랜치 이름을 사용합니다.

> Rebase 과정에서 기존 커밋을 **이동시키는 것이 아니라** 변경 내용을 새로운 기준점 위에 다시 적용하여 **새로운 커밋을 생성**합니다.
{: .prompt-info }

---

## **git rebase 동작 과정**

![rebase-work-1](rebase-work-1.png){: w="70%" }

위와 같은 상태에서 `develop` 브랜치에서 `git rebase main` 명령을 수행했다고 했을 때 동작 과정은 다음과 같습니다.

1 단계. 공통 조상 찾기
: `develop`과 `main` 브랜치의 커밋 히스토리을 따라 올라가면서 두 브랜치가 마지막으로 공유하는 커밋인 공통 조상(`merge  base`)을 찾습니다.

    ![rebase-work-2](rebase-work-2.png){: w="70%" }

    예시에서는 `m1` 커밋이 공통 조상입니다.

2 단계. 현재 브랜치의 커밋 추출
: 공통 조상 이후 현재 브랜치(develop)에서 생성된 커밋들의 변경 사항을 추출합니다.

    ![rebase-work-3](rebase-work-3.png){: w="70%" }

    예시에서는 `d1`과 `d2` 커밋의 변경 사항이 추출됩니다.

3 단계. 새로운 기준점 위에 커밋 재적용
: `main` 브랜치의 최신 커밋을 기준으로 추출한 변경 사항을 순서대로 다시 적용합니다.
    
    ![rebase-work-4](rebase-work-4.png){: w="70%" }

    이 과정을 통하여 `develop` 브랜치는 마치 처음부터 `main`의 최신 커밋을 기반으로 작업한 것처럼 히스토리가 재구성됩니다.

> 이미 원격 저장소에 `push`한 커밋을 `rebase`하면 커밋 이력이 변경됩니다. 따라서 협업 중에는 `rebase` 수행하면 다른
사람과 충돌이 발생할 수 있으므로 주의해야 합니다.
{: .prompt-warning }

---

## **git rebase 충돌 해결**

rebase는 현재 브랜치의 커밋들을 **순서대로 기준점 위에 다시** 적용합니다.
이 과정에서 다른 브랜치에서 동일한 파일의 동일한 부분을 수정하면 git이 어떤 내용을 선택해야할지 판단할 수 없어서 충돌이 발생합니다.

충돌이 발생하면 rebase가 중단되고 다음과 같이 메시지가 출력됩니다.

![rebase-conflict-1](rebase-conflict-1.png){: w="70%" }

`git status`를 통하여 충돌이 발생한 파일들을 확인할 수 있습니다.

![rebase-conflict-2](rebase-conflict-2.png){: w="70%" }

이후 다음 3가지 방법 중 하나를 선택할 수 있습니다.

#### **case1. \-\-continue**
가장 일반적인 방법으로 직접 충돌을 해결한 뒤 rebase를 계속 진행하는 것입니다.

충돌이 발생한 파일을 열어보면 다음과 같은 표시가 추가되어 있습니다.

![rebase-conflict-3](rebase-conflict-3.png){: w="70%" }

각 의미는 다음과 같습니다.
- `HEAD` : 현재 rebase의 기준이 되는 브랜치(`<target>`)의 내용
- `7d199a2 (d1)` : 적용하려는 `develop`의 커밋 내용

원하는 형태로 수정하여 충돌을 해결합니다.

![rebase-conflict-4](rebase-conflict-4.png){: w="70%" }

이후 `git add <file | .>`을 통하여 수정한 파일을 추가하고 `git rebase --continue`를 계속 진행합니다. 

만약 다음 커밋에서도 충돌이 발생하면 동일한 과정을 반복합니다. rebase가 완료될 때까지 반복하면 됩니다.    

---

#### **case2. \-\-skip**
현재 커밋을 건너뛰고 다음 커밋으로 넘어가는 명령어 입니다.

![rebase-skip-1](rebase-skip-1.png){: w="70%" }

위 사진 같은 상황에서 `d1`을 `m3` 위에 적용하는 과정에서 충돌이 발생했다고 가정해 보겠습니다.

이때 `git rebase --skip`을 수행하면 `d1`이 제외되고 `d2`부터 적용합니다.

결과적으로 히스토리는 다음과 같이 변경됩니다.

![rebase-skip-2](rebase-skip-2.png){: w="70%" }

> `--skip`은 단순히 충돌을 무시하는 명령이 아닙니다. <br/>
해당 커밋은 더 이상 필요 없으니 rebase 결과에서 **제거하는 것을 의미합니다.**<br/>
<br/>
따라서 커밋 내용을 제대로 확인하지 않고 사용하면 **기능이 누락될 수 있습니다.**
{: .prompt-danger }

---

#### **case3. \-\-abort**
rebase 시작 전 상태로 되돌리는 명령업니다. <br/>
예를 들어 rebase를 진행하는 과정에서 충돌이 너무 많이 발생하거나, 충돌 해결 비용이 지나치게 크다고 판단되는 경우 사용할 수 있습니다.

이 경우 rebase를 취소한 뒤 merge 방식으로 변경 사항을 반영하는 것이 더 안전할 수 있습니다.

---

## **왜 사용하는가?**
`Git Flow`에서 일반적으로 `develop` 브랜치에서 기능 개발을 위한 `feature` 브랜치를 생성합니다.

하지만 하나의 기능을 여러 명이 함께 개발하는 경우, 각각 별도의 작업 브랜치를 생성하여 작업한 뒤 `feature` 브랜치에 병합하게 됩니다.

예를 들어 다음과 같은 상황을 생각해 보겠습니다.
```text
develop
\
 feature/payment
    ├── payment-api
    ├── payment-ui
    └── payment-test
```

각 작업 브랜치(`payment-xxx`)에서 개발을 완료 후 단 순히 `merge`만 수행하면 다음과 같은 히스토리가 만들어집니다.

![rebase-why-2](rebase-why-1.png){: w="70%" }

지금 `feature/payment`에 3개만 merge 했을 뿐인데 꽤 복잡한 히스토리가 만들어진 것을 확인할 수 있습니다.

여기서 더 많은 작업 브랜치가 생성되고 병합된다면 히스토리가 더욱 복잡해지고 변경 이력을 추적하기도 어려줘집니다.

이번에는 작업 브랜치를 병합하기 전에 `rebase`를 수행한 뒤 병합해 보겠습니다.

![rebase-why-2](rebase-why-2.png){: w="70%" }

`feature/payment` 브랜치를 보면 여러 명이 작업했음에도 불구하고 커밋이 하나의 흐름으로 정리된 것을 확인할 수 있습니다.

이때 만약에 어떤 작업 단위가 병합되었는지 시각적으로 구분하고 싶은 경우 `merge`할 때 `--no-ff` 옵션을 사용하여
`Merge Commit`을 남길 수 있습니다.

이때 그래프 모양은 다음과 같습니다.

![rebase-why-3](rebase-why-3.png){: w="70%" }

---

## **참고 문헌**
* <https://seosh817.tistory.com/240>
* <https://tlatmsrud.tistory.com/156>
* <https://velog.io/@pock11/git-rebase-%ED%95%98%EB%8A%94-%EB%B2%95>