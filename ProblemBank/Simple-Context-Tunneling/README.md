# 단순하고 원칙적인 컨텍스트 터널링 기법 (Simple, Principled, and Easy-to-Implement Context Tunneling)

## 1. 문제 (Problem)

Context tunneling [Jeon, Jeong, Oh, *OOPSLA 2018*]은 $k$-limited context-sensitive points-to analysis의 정밀도와 확장성을 동시에 향상시키는 강력한 기법이다. 핵심 아이디어 자체는 단순하고 우아하다: 모든 호출 지점에서 무조건 context를 갱신하는 대신, **중요한 context element만을 선택적으로 유지**한다. 1-context-sensitive + tunneling이 4가지 flavor 모두에서 2-context-sensitive를 outperform하는 결과는 이 아이디어의 잠재력을 명확히 보여준다.

그러나 이 아이디어를 **실현하는 방법** — 즉 어떤 context element가 "중요한지"를 결정하는 방법 — 은 단순하지도, 원칙적이지도, 구현이 쉽지도 않다.

### 현재 접근법의 복잡성

원 논문의 data-driven 접근법은 다음과 같은 복잡한 파이프라인을 요구한다:

1. **Atomic feature 설계** (Table 1): 23개의 수작업 설계된 feature — 10개의 시그니처 기반 feature(A1-A10)와 13개의 구조적 feature(B1-B13). Feature 집합의 선택이 결과에 큰 영향을 미치며(Table 5), 다른 언어·분석·도메인으로 전이 시 feature를 재설계해야 함

2. **Boolean formula 모델** (§4.2): Tunneling relation을 두 개의 boolean formula $\Pi = \langle f_1, f_2 \rangle$로 parameterize. $f_1$은 child에 context를 전달하는 메서드, $f_2$는 parent로부터 context를 상속하는 메서드를 특성화. DNF(Disjunctive Normal Form)로 표현

3. **Non-greedy 학습 알고리즘** (Algorithm 1-3): Seed feature 선택(ChooseSeed) → conjunctive refinement(RefineSeed with ChooseRefiner) → 평가(BetterHeuristicFound, HasPotential) → 반복. Non-monotonic 공간을 탐색하기 위한 정교한 전략

4. **Training infrastructure**: 학습에 53~137시간 소요. DaCapo 스위트의 training/test 분할, 정밀 분석기(Doop) 실행 환경, 대규모 Java 프로그램의 fact 생성 등 인프라 필요

5. **분석 프레임워크 의존성**: Doop [Bravenboer & Smaragdakis, 2009] 프레임워크 위에서 구현. Doop의 Datalog 규칙을 수정하여 tunneling을 통합 (Figure 4의 규칙 변경)

이 복잡성은 context tunneling의 **채택 장벽(adoption barrier)** 을 형성한다:

- **새로운 언어에 적용하려면**: 해당 언어용 atomic feature 재설계 + 학습 인프라 구축 + training 프로그램 확보 + 수일간의 학습 실행이 필요
- **새로운 분석 flavor에 적용하려면**: Feature의 적합성 재평가 + 학습 재실행이 필요 (원 논문에서도 4가지 flavor 각각에 대해 별도로 학습)
- **새로운 분석 프레임워크에 통합하려면**: Doop 스타일의 Datalog 규칙을 해당 프레임워크의 분석 규칙으로 재작성해야 함
- **재현 및 검증**: 학습된 heuristic(Appendix A의 복잡한 boolean formula)의 정당성을 이해하거나 검증하기 어려움

### 연구 공백

Context tunneling의 **아이디어** 는 보편적이고 강력하지만, 현재의 **실현 방법** 은 language-specific, framework-specific, feature-engineering-heavy하다. 다음과 같은 접근법은 아직 탐구되지 않았다:

- **프로그램의 구조적 성질로부터 직접 유도**되는 tunneling 규칙 — 학습 없이, 분석 대상 프로그램의 call graph, 타입 계층, 호출 패턴 등에서 원칙적으로(principled) 도출
- **언어·분석 flavor에 독립적**인 범용 tunneling 기준 — Java의 특정 feature에 의존하지 않고, 임의의 $k$-context-sensitive analysis에 적용 가능
- **수 줄의 코드로 구현 가능**한 단순한 규칙 — 기존 분석기에 최소한의 수정으로 통합 가능
- **이론적 근거가 명확**한 tunneling 기준 — 왜 이 기준이 효과적인지를 형식적으로 설명 가능

## 2. 목표 (Goal)

Context tunneling의 효과를 달성하면서, **단순하고(simple), 원칙적이며(principled), 구현이 쉬운(easy-to-implement)** tunneling 기법을 개발한다.

- **단순성(Simple)**: Tunneling 규칙이 1~3개의 명확한 조건으로 표현되며, Appendix A의 복잡한 boolean formula 대신 한 문장으로 기술 가능
- **원칙성(Principled)**: Tunneling 규칙이 프로그램 분석의 이론적 성질(context의 정보량, call graph 구조, 정밀도에 대한 영향 등)로부터 직접 유도되며, 왜 효과적인지에 대한 formal justification 존재
- **구현 용이성(Easy-to-implement)**: 기존 $k$-context-sensitive analysis에 수십 줄 이내의 코드 수정으로 통합 가능. 별도의 학습 단계, training 데이터, feature 설계가 불필요
- **범용성(General)**: 특정 언어(Java)나 분석 flavor(hybrid)에 국한되지 않고, 임의의 언어·flavor·$k$에 적용 가능
- **효과성 유지**: 원 논문의 data-driven heuristic에 근접하거나, 최소한 tunneling 없는 baseline을 유의미하게 outperform
