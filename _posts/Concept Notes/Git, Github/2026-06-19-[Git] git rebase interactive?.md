---
title: "[Git] Interactive rebase?"
slug: "git-interactive-rebase"
author: bienew22
date: 2026-06-19 14:26:19 +09:00
last_modified_at: 2026-06-19 14:26:29 +09:00
tags: [git, git rebase]
media_subpath: /assets/img/_git/rebase2
#image:
#   path:
---

> `git rebase`에 대한 자세한 내용은 ["git rebase?"](https://blog.bienew.me/posts/git-rebase/)를 참고하세요.
{: .prompt-info }

## **Interactive rebase?**

**Interactive rebase**는 이미 만들어진 커밋 히스토리를 사용자가 직접 편집할 수 있는 기능입니다.

---

### **왜 필요한가?**

실제 개발하다 보면 커밋 히스토리가 항상 깔끔하게 만들어지지 않습니다.

```bash
1aq9 최종 회원가입 기능 구현
baac 버그 수정
w1jo 오타 수정
aw5w 회원가입 기능 구현
```

위와 같이 하나의 기능에 대해 여러 개의 불필요한 커밋이 생성될 수 있습니다.

또는 다음과 같이 커밋 메시지에 오타가 있을 수 있습니다.

```bash
w9f0 커밋 오타
```

심지어 커밋에 포함되면 안되는 민감한 정보가 실수로 커밋되는 경우가 있습니다.

```yaml
api-key: top-secret-but-add-in-commit
```

이 처럼 이미 생성된 커밋을 수정하거나, 여러 커밋을 하나로 합치거나, 커밋 메시지를 변경하고 싶은 상황이 발생합니다.

물론 git reset 등을 이용해 커밋을 되돌릴 수는 있지만 과거의 특정 커밋 하나만 수정하기 위해 해당 시점까지 모든 커밋을 되돌린 후 다시 작업하는 것은 매우 비효율적입니다.

이러한 문제를 해결하기 위해 Git은 Interactive rebase(git rebase -i) 기능을 제공합니다. 이를 통해 과거의 특정 커밋을 수정하거나, 커밋 순서를 변경하거나, 여러 커밋을 하나로 합치는 등 커밋 히스토리를 원하는 형태로 정리할 수 있습니다.

---

### **사용 방법**

명렁어 구조
: ```bash
    git rebase -i <기준 커밋>
    git rebase --interactive <기준 커밋>
    ```

해석
: **\<기준 커밋\> 이후의 커밋**들을 대상으로 Interactive rebase를 수행합니다.


예를 들어 아래와 같이 커밋 히스토리가 있다고 가정해 보겠습니다.

![git status](/rebase-base-1.png){: w="80%" }

이 상태에서 `commit 3`을 기준으로 하여 다음 명령어를 수행하면

```bash
git rebase -i 6730
# 또는
gir rebase -i HEAD~2
```

다음와 같이 vim(vi) 편집기가 실행됩니다.

![git rebase -i 6730](/rebase-base-2.png){: w="80%" }

편집기에는 오래된 커밋부터 최신 커밋 순서로 `[command] [commit hash] [commit mesage]` 형태의 목록이 표시됩니다.

파일을 저장하고 vim(vi)를 종료하면 Git은 각 커밋에 적용된 `command`를 순서대로 읽어 수행합니다.

> **HEAD~N 의미**<br/>
    현재 HEAD에서 부모 방향으로 N번 이동한 커밋을 의미합니다.<br/>
    이 때 `rebase -i`에서 해석할 때에는 해당 커밋 이후 커밋들을 대상으로 지정합니다.<br/>
    따라서 편리하게 **"최근 N개의 커밋을 대상으로 지정한다."**고 생각하면 될 것 같습니다.
{: .prompt-tip }

---

## **p, pick**
해당 커밋을 그대로 사용하는 명렁어입니다.

아래 같은 상황에서 

![rebase base 1](/rebase-before-1.png){: w="80%" }

interactive rebase 화면에서 모든 커밋을 `pick` 상태로 둔 뒤
![rebase pick 1](/rebase-pick-1.png){: w="80%" }

파일 저장하고 vim을 종료하면 rebase가 수행됩니다.

하지만 `pick`은 커밋을 그대로 적용하는 명령어이므로 결과적으로 커밋 히스토리가 아무런 변화가 발생하지 않습니다.

![rebase pick 2](/rebase-before-1.png){: w="80%" }

따라서 위와 같이 `rebase` 전후의 커밋 히스토리가 동일한 것을 확인할 수 있습니다.

---

## **r, reword**
해당 커밋의 커밋 메시지만 수정하는 명령어입니다.

아래 같은 상황에서 

![rebase before 1](/rebase-before-1.png){: w="80%" }

interactive rebase 화면에서 `commit 4`를 `reword` 상태로 변경합니다.

![rebase reword 1](/rebase-reword-1.png){: w="80%" }

이후 파일 저장하고 vim 종료하면 바로 `commit  4`의 커밋 메시지 수정할 수 있는 화면이 표시됩니다.

![rebase reword 2](/rebase-reword-2.png){: w="80%" }

여기서 기존 메시지를 "4-1"으로 변경한 뒤 저장하고 종료합니다.

rebase가 완료되면 아래와 같이 커밋 메시지가 변경된 것을 확인할 수 있습니다.

![rebase reword 3](/rebase-reword-3.png){: w="80%" }

다만 주의할 점은 커밋 해시가 변경된 것을 확인할 수 있습니다. 즉, 기존 커밋을 새로운 커밋으로 교체하는 작업이 수행되었다고 해석할 수 있습니다.

---

## **e, edit**
커밋 내용 자체를 수정하는 명령어 입니다. 
`reword`가 커밋 메시지만 수정할 수 있다면 `edit`은 커밋에 포함된 파일과 변경사항까지 수정할 수 있습니다.

아래 같은 상황에서
![rebase edit 1](/rebase-edit-1.png){: w="80%" }

interactive rebase 화면에서 `commit 4-1`를 `edit` 상태로 변경합니다.
![rebase edit 2](/rebase-edit-2.png){: w="80%" }

이후 파일 저장하고 vim 종료하면 rebase가 진행되다가 해당 커밋에서 일시 중지됩니다.
![rebase edit 3](/rebase-edit-3.png){: w="80%" }

이 시점에서 `HEAD`가 `commit 4-1`을 가리키고 있는 것을 확인할 수 있습니다.

이제 원하는 작업을 자유롭게 수행할 수 있습니다. 예를들어
- `git reset`을 이용한 커밋 분리
- `git commit --amend`을 이용한 현재 커밋 수정
- 새로운 커밋 추가

등 작업이 가능합니다.

간단한 예시로 `commit 4-1` 이후에 새로운 커밋인 `commit 4-2`를 추가해 보겠습니다.

![rebase edit 4](/rebase-edit-4.png){: w="80%" }

작업이 완료되면 `git rebase --continue`를 실행하여 rebase를 계속 진행합니다.

그러면 아래와 같이 `commit 4-1`과 `commit 5`사이에 `commit 4-2`가 생성된 것을 확인할 수 있습니다.

![rebase edit 5](/rebase-edit-5.png){: w="80%" }

또한 Rebase 과정에서 새로운 커밋이 다시 생성되었으므로, 기존 커밋들의 해시 역시 변경된 것을 확인할 수 있습니다.

---

## **s, squash**
현재 커밋을 이전 커밋과 합치는 명령어입니다.
주로 하나의 기능을 개발하는 과정에서 발생하는 여러 작은 커밋을 하나의 커밋으로 정리할 때 사용합니다.

아래 같은 상황에서

![rebase squash 1](/rebase-squash-1.png){: w="80%" }

`commit 4-2`을 `commit 4-1`과 합치도록 하겠습니다. 우선 `commit 4-2`의 상태를 `squash` 상태로 변경합니다.

![rebase squash 2](/rebase-squash-2.png){: w="80%" }

이후 파일 저장하고 vim 종료하면 `commit 4-2`는 이전 커밋인 `commit 4-1`과 병합하게 됩니다.

충돌이 발생하지않는 경우, 다음과 같이 바로 병합된 커밋의 메시지를 작성하는 화면이 표시됩니다.

![rebase squash 3](/rebase-squash-3.png){: w="80%" }

기본적으로 두 커밋의 메시지가 모두 포함된 상태로 열립니다.
여기서는 커밋 메시지를 `commit 4`으로 수정하고 저장하면 다음과 같은 결과가 나타나게 됩니다.

![rebase squash 4](/rebase-squash-4.png){: w="80%" }

또한 두 커밋이 하나의 새로운 커밋으로 재생성되므로, 기존 커밋들의 해시 역시 변경됩니다.

---

## **f, fixup**
`squash`와 마찬가지로 이전 커밋을 합치는 기능을 수행합니다. 다만 `squash`와 차이점은 현재 커밋 메시지를 버린다는 점입니다.

예를 들어 `squash`에서 했던것와 동일하게 `commit 4-2`과 `commit 4-1`을 병합해보면 다음과 같은 결과를 확인할 수 있습니다.

![rebase fixup 1](/rebase-fixup-1.png){: w="80%"  }

`squash`와 달리 커밋 메시지를 수정하는 화면이 별도로 표시되지 않습니다. 대신 `commit 4-2`의 변경 사항만 `commit 4-1`에 병합되고,
`commit 4-2` 메시지는 삭제되어 `commit 4-1`의 커밋 메시지만 유지됩니다.

---

## **그 외**
위에 언급한 명령어 외에도 `drop`, `exec`, `break` 등의 명령어가 존재합니다. 하지만 개발하면서 해당 명령어들을 사용할 기회가 많지 않았기 때문에 이번 글에는 다루지 않았습니다.

대부분의 경우에는 위 명령어들만으로도 커밋 메시지 수정, 분리, 병합 등 필요한 작업을 충분히 수행할 수 있습니다.

---

## **주의 사항**

이번 글에서 반복적으로 언급한 내용으로 Interactive Rebase를 수행하면 **커밋 해시(Hash)**가 변경되는 것입니다.

이는 이전에 작성한 [git rebase?](https://blog.bienew.me/posts/git-rebase/) 글에서도 설명했듯이, Rebase는 기존 커밋을 수정하는 것이 아니라 새로운 커밋을 생성하는 방식으로 동작하기 때문입니다.

따라서 이미 원격 저장소에 Push한 커밋에 대해 Rebase를 수행하면 커밋 이력이 변경됩니다.

특히 여러 사람이 함께 작업하는 브랜치에서 이미 **공유된 커밋을 Rebase한 후 강제로 Push(git push --force)할 경우, 다른 개발자의 작업 이력과 충돌하거나 예상치 못한 문제가 발생할 수 있습니다.**

따라서 공유된 브랜치에서는 Rebase 사용에 주의해야 하며, Rebase가 필요한 경우 팀 내에서 충분히 협의한 후 진행하는 것이 좋습니다.

---

## **참고 문헌**
* <https://docs.github.com/ko/get-started/using-git/about-git-rebase>
* <https://wormwlrm.github.io/2020/09/03/Git-rebase-with-interactive-option.html>
