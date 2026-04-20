# Python을 위한 컨텍스트 터널링 (Context Tunneling for Python)

## 1. 문제 (Problem)

**Points-to analysis**는 프로그램의 포인터 변수가 런타임에 어떤 객체를 가리킬 수 있는지를 정적으로 근사하는 기본 프로그램 분석 기법이다. 이 분석의 정밀도와 확장성은 버그 탐지, 보안 취약점 분석, 타입 추론, IDE 자동 완성 등 다양한 downstream 기법의 품질을 결정한다. 특히 **context-sensitivity** — 동일 메서드에 대해 서로 다른 호출 문맥을 구분하여 분석하는 기법 — 는 분석의 정밀도와 확장성에 가장 큰 영향을 미치는 단일 요인이다.

Context tunneling [Jeon, Jeong, Oh, *OOPSLA 2018*]은 기존의 $k$-limited context-sensitive analysis가 모든 호출 지점에서 무조건적으로 context를 갱신하여 중요한 context element를 덜 중요한 것으로 덮어쓰는 문제를 해결하는 기법이다. 핵심 아이디어는 **tunneling relation** $\mathcal{T} \subseteq \mathbb{M} \times \mathbb{M}$을 학습하여, parent method의 context를 child method에 그대로 전파할지(tunneling) 새로운 context element를 추가할지를 선택적으로 결정하는 것이다. Java points-to analysis에서 1-context-sensitive + tunneling이 2-context-sensitive를 네 가지 flavor(call-site, object, type, hybrid) 모두에서 outperform하는 것으로 입증되었다.

그러나 context tunneling은 **Java 전용으로 설계·평가**되었으며, **Python**에 대한 연구는 전무하다. Python은 Java와 근본적으로 다른 언어 특성을 가지며, 이로 인해 context tunneling의 직접 적용에 다음과 같은 도전이 존재한다.

### Python의 언어적 특성과 분석 난제

1. **동적 타이핑(Dynamic Typing)**: Python은 변수에 타입이 없고 런타임에 임의의 객체를 할당할 수 있다. Java에서는 정적 타입 정보가 points-to analysis의 강력한 필터 역할을 하지만, Python에서는 이 필터가 부재하여 points-to set이 훨씬 크고 분석이 본질적으로 더 어렵다. 따라서 context-sensitivity의 중요성이 Java보다 더 크다.

2. **First-class 함수와 고차 함수**: Python에서 함수는 first-class 객체이며, `map`, `filter`, `sorted(key=...)`, decorator 등 고차 함수 패턴이 지배적이다. Java의 context tunneling에서 사용된 atomic feature (Table 1: 메서드 시그니처 기반 A1-A10, 구조적 특성 B1-B13)는 **함수 객체의 동적 전달**을 기술하지 못한다. 고차 함수의 context 구성은 Java의 메서드 호출과 질적으로 다르며, 어떤 context element가 "중요한지"의 기준도 달라진다.

3. **Duck typing과 동적 디스패치**: Python의 메서드 해석은 MRO(Method Resolution Order)를 따르며, `__getattr__`, `__getattribute__`, descriptor protocol 등 동적 메커니즘이 호출 대상을 결정한다. Java의 virtual dispatch보다 해석이 복잡하고, context-sensitivity의 flavor 정의가 달라질 수 있다.

4. **Decorator, 클래스 메타프로그래밍**: `@property`, `@staticmethod`, `@classmethod`, 사용자 정의 decorator 등은 함수를 감싸는(wrapper) 패턴을 생성한다. 이 wrapper chain에서 context가 빠르게 소진되며, 원래 함수의 호출 문맥이 유실된다 — context tunneling이 해결해야 하는 정확히 그 문제이지만, Java에는 없는 패턴이다.

5. **Generator, async/await, comprehension**: Generator 함수(`yield`), 비동기 함수(`async`/`await`), list/dict/set comprehension 등은 Python 고유의 제어 흐름을 생성한다. 이들은 Java의 호출 그래프 모델에서는 고려되지 않은 context 구성 패턴을 만든다.

6. **모듈 시스템과 import 메커니즘**: Python의 `import`는 런타임에 모듈을 로드하고 실행하는 동적 연산이다. 모듈 수준 코드의 실행 순서와 `__init__.py`의 실행이 context 구성에 영향을 미친다.

7. **내장 함수와 C 확장**: `len()`, `print()`, `sorted()` 등 built-in 함수와 NumPy, Pandas 등의 C 확장 모듈은 Python 분석에서 큰 비중을 차지하지만, 정적 분석이 내부를 볼 수 없는 opaque 호출이다. 이들에 대한 context 정책이 필요하다.

### 기존 Python 정적 분석의 한계

기존 Python points-to analysis 또는 type inference 도구들은 context-sensitivity 지원이 제한적이다.

- **Pytype** (Google): flow-sensitive하지만 context-insensitive에 가까운 타입 추론
- **Pyre** (Meta): gradual typing 기반, 전체 프로그램 분석이 아닌 모듈 단위
- **Mypy**: 타입 검사 도구이지 points-to analysis가 아님
- **Scalpel** [Li et al., ASE 2022]: Python의 call graph 구축 + data-flow 분석, 제한적 context-sensitivity
- **PyCG** [Salis et al., ICSE 2021]: Python call graph 생성, context-insensitive
- **YOGI** / **Jedi**: IDE 자동 완성용 추론, 정밀도보다 속도 우선

이 도구들 중 context tunneling은 물론이고, 체계적인 $k$-context-sensitive analysis를 수행하는 것조차 드물다. Python의 동적 특성으로 인해 Java 수준의 정밀한 points-to analysis 자체가 난제이며, context-sensitivity의 효과적 활용은 더욱 미개척 영역이다.

### 연구 공백

Context tunneling은 Java에서 $k$-context-sensitive analysis의 정밀도와 확장성을 동시에 크게 향상시켰다. Python은 동적 타이핑으로 인해 context-sensitivity가 더욱 중요하지만, (a) Python용 체계적 $k$-context-sensitive points-to analysis 프레임워크가 부재하고, (b) Python의 고유 언어 특성(first-class 함수, decorator, generator 등)에 맞는 context-sensitivity flavor와 context tunneling 설계가 연구되지 않았으며, (c) Python 코드베이스에서 tunneling heuristic을 학습하기 위한 atomic feature와 data-driven 알고리즘이 개발되지 않았다.

## 2. 목표 (Goal)

Context tunneling을 **Python points-to analysis**에 확장하여, Python의 고유 언어 특성에 맞는 context tunneling 프레임워크를 설계·구현·평가한다.

- **Python용 context-sensitive points-to analysis 프레임워크**: Python의 의미론을 반영한 $k$-limited context-sensitive analysis를 call-site-sensitivity, object-sensitivity, 그리고 Python 특화 flavor로 정의
- **Python용 context tunneling**: Tunneling relation $\mathcal{T}$를 Python의 함수/메서드/callable에 대해 정의하고, first-class 함수, decorator chain, generator 등 Python 고유 패턴에서 중요한 context element를 보존
- **Python용 atomic feature 및 data-driven 학습**: Python 코드의 구문적·의미적 특성을 포착하는 atomic feature를 설계하고, 원 논문의 non-greedy 학습 알고리즘을 Python 환경에 맞게 적용
- **정밀도 향상**: 1-context-sensitive + tunneling이 2-context-sensitive를 outperform하는 Java에서의 결과를 Python에서도 재현
- **실용적 downstream 효과**: 타입 추론 정확도, 버그 탐지(null 참조, 타입 오류, 미정의 속성 접근), IDE 자동 완성 정밀도 등에서 측정 가능한 개선

## 3. 기본 접근 방법 (Basic Approach)

### (1) Python용 context-sensitive points-to analysis 설계

먼저 context tunneling의 기반이 되는 Python용 $k$-limited context-sensitive analysis를 설계한다.

**프로그램 모델**: Java의 5가지 instruction 유형(allocation, move, load, store, method invocation)을 Python에 맞게 확장한다.
- **Allocation**: `x = C()`, `x = [...]`, `x = {...}`, `x = lambda: ...`, `x = (yield ...)` 등
- **Move**: `x = y`, unpacking `a, b = t`, starred `*args`
- **Load/Store**: attribute access `x.f`, subscript `x[i]`, module attribute `mod.attr`
- **Invocation**: `x = f(args)`, `x = obj.m(args)`, `x = cls(args)` (constructor)
- **Python 고유**: decorator application `@dec`, comprehension, `import`, `yield`/`yield from`, `await`

**Context-sensitivity flavor 정의**:
- **Call-site-sensitivity**: $\text{flavor}_{\text{call}}(\text{invo}, \text{ctx}) = (\text{invo}, \text{ctx})$ — Java와 동일하지만, Python에서는 decorator application site, comprehension entry 등도 call-site에 포함
- **Object-sensitivity**: $\text{flavor}_{\text{obj}}(\text{heap}, \text{hctx}) = (\text{heap}, \text{hctx})$ — Python에서 모든 것이 객체이므로, 함수 객체의 allocation site가 context element가 됨. Java보다 object-sensitivity의 범위가 넓음
- **Function-origin-sensitivity** (Python 특화): First-class 함수의 정의 위치(definition site)를 context element로 사용. 고차 함수 패턴에서 "어디서 정의된 함수가 전달되었는가"를 추적
- **Decorator-aware sensitivity** (Python 특화): Decorator chain에서 원래 함수의 context를 보존하는 특화 flavor

**분석 규칙**: 원 논문의 Figure 3의 분석 규칙을 Python 의미론에 맞게 확장한다. 특히:
- MRO 기반 메서드 해석
- Descriptor protocol (`__get__`, `__set__`)
- `*args`, `**kwargs` 처리
- Generator/async의 send/throw/close 프로토콜
- `with` statement의 `__enter__`/`__exit__` 호출

### (2) Python용 context tunneling 설계

원 논문의 tunneling 메커니즘(Figure 4)을 Python에 적용한다. Tunneling relation $\mathcal{T} \subseteq \mathbb{M} \times \mathbb{M}$ 에서 $\mathbb{M}$은 Python의 callable(함수, 메서드, 클래스, lambda, generator function, async function 등)로 확장된다.

**Python 특화 tunneling 패턴**:
- **Decorator tunneling**: `@decorator`로 감싸진 함수 호출 시, wrapper 함수의 context가 아닌 원래 함수 정의의 context를 보존. Decorator는 Python에서 가장 빈번한 "중요한 context가 덮어쓰여지는" 패턴
- **고차 함수 tunneling**: `map(f, lst)` 호출에서 `f`의 context가 `map` 내부의 반복 호출로 유실되는 것을 방지. `sorted(key=lambda x: x.attr)` 등에서도 동일
- **`__init__` / `__new__` tunneling**: 생성자 체인에서 부모 클래스의 `__init__` 호출 시 context 보존. Java의 constructor chaining과 유사하지만 Python의 MRO가 추가
- **`super()` tunneling**: `super().method()` 호출에서 원래 호출자의 context를 보존
- **Generator/async tunneling**: Generator의 `next()`/`send()` 호출 시 generator를 생성한 context를 보존
- **Comprehension tunneling**: List/dict/set comprehension은 내부적으로 별도 scope를 생성하지만, 상위 scope의 context를 유지해야 정밀한 분석이 가능

### (3) Python용 atomic feature 설계

원 논문의 23개 atomic feature (Table 1: 시그니처 기반 A1-A10, 구조적 특성 B1-B13)에 대응하는 Python용 feature를 설계한다.

**Class A: 시그니처/이름 기반 feature** (Python 생태계의 빈번한 패턴 반영):
- A1: `__init__` 포함 (constructor)
- A2: `__` 로 시작·끝남 (dunder method)
- A3: `_` 로 시작 (private convention)
- A4: `get`/`set` 포함 (accessor pattern)
- A5: `test` 포함 (test method)
- A6: `wrapper` / `inner` / `wrapped` 포함 (decorator 내부 함수)
- A7: `callback` / `handler` 포함
- A8: `lambda` (anonymous function)
- A9: `self` 매개변수 존재 (instance method)
- A10: `cls` 매개변수 존재 (class method)

**Class B: 구조적 특성 feature**:
- B1: Decorator가 적용된 함수
- B2: `*args` 또는 `**kwargs` 매개변수 포함
- B3: `yield` / `yield from` 포함 (generator)
- B4: `async` 함수
- B5: Closure (자유 변수 참조)
- B6: 중첩 함수 (nested function definition)
- B7: `super()` 호출 포함
- B8: Heap allocation 포함 (`C()`, `[]`, `{}`)
- B9: 단일 return 문만 포함 (wrapper/identity 패턴)
- B10: `self.attr = ...` 형태의 attribute 초기화 포함
- B11: Class 내부 메서드 vs. module-level 함수
- B12: `@staticmethod` / `@classmethod`
- B13: `@property`
- B14: 다중 호출 대상 (polymorphic call) 포함
- B15: 재귀 호출 포함

**Class C: Python 생태계 특화 feature**:
- C1: 표준 라이브러리 함수 (`os`, `sys`, `collections` 등)
- C2: 타입 힌트 annotated 함수
- C3: `@dataclass` 등 코드 생성 decorator
- C4: `functools.wraps` 사용 (올바른 wrapper 패턴)
- C5: `abc.abstractmethod` (추상 메서드)

### (4) Data-driven 학습 알고리즘

원 논문의 Algorithm 1-3을 Python 환경에 적용한다.

- **학습 목표**: Boolean formula $\Pi = \langle f_1, f_2 \rangle$ 학습. $f_1$은 child method로 context를 전달(pass)하는 메서드, $f_2$는 parent method로부터 context를 상속(inherit)하는 메서드를 특성화
- **Non-greedy 탐색**: 원 논문의 핵심 — non-monotonic 공간에서 즉각적 이득이 아닌 장기적 이득을 추구하는 seed feature 선택 + 정제 전략을 그대로 적용
- **Training/test 분할**: Python 벤치마크를 training set과 test set으로 분할하여 heuristic의 일반화 성능 평가
- **비용 제약**: $\sum_{P \in \mathbf{P}} \text{cost}(F_P(\mathcal{H}_\Pi(P))) \leq \sum_{P \in \mathbf{P}} \text{cost}(F_P(\emptyset))$ — tunneling이 baseline보다 비용이 높지 않도록 보장

### (5) Python 특화 도전의 해결

- **동적 feature의 정적 근사**: Duck typing으로 인해 call target이 불확실한 경우, 보수적으로 tunneling을 비활성화하는 fallback 전략
- **Opaque 호출 처리**: C 확장 / built-in 함수에 대한 tunneling 정책을 수동 모델링 + 학습된 heuristic으로 혼합
- **점진적 분석**: Python의 대화형 개발 패턴(REPL, Jupyter)에 맞는 incremental analysis 지원
- **Gradual typing 활용**: 이미 타입 힌트가 있는 코드에서는 타입 정보를 활용하여 points-to set을 필터링하고 context tunneling의 효과를 극대화

### (6) 구현

- **분석 프레임워크**: Doop [Bravenboer & Smaragdakis, 2009] 스타일의 Datalog 기반 선언적 분석을 Python용으로 설계하거나, 기존 Python 분석 프레임워크(Code Property Graph, Scalpel 등) 위에 구축
- **Python AST/IR**: CPython bytecode 또는 typed AST를 분석의 입력으로 사용. `ast` 모듈 + type stub 정보 활용
- **Fact 생성**: Python 소스 코드에서 Datalog fact(allocation, assignment, invocation 등)를 추출하는 front-end 개발

## 4. 후보 벤치마크 (Candidate Benchmarks)

### Python 벤치마크 스위트 (DaCapo의 Python 대응)

Python에는 Java의 DaCapo에 직접 대응하는 표준 벤치마크 스위트가 부재하므로, 다음 후보를 조합한다.

**소규모 / 학습용**:
- **micro-benchmark**: Context tunneling의 각 패턴(decorator, 고차 함수, generator 등)을 isolate하여 테스트하는 합성 프로그램
- **Pyperformance** (CPython 공식 벤치마크): richards, deltablue, raytrace, chaos, nbody 등 — 작은 순수 Python 프로그램

**중규모 / 실세계 라이브러리**:
- **Requests** (~14K LoC): HTTP 라이브러리, session/adapter 패턴, decorator 사용
- **Flask** (~12K LoC): 웹 프레임워크, decorator 기반 라우팅, 다중 디스패치
- **Click** (~10K LoC): CLI 프레임워크, 중첩 decorator 패턴이 지배적
- **Pydantic** (~20K LoC): 데이터 검증, metaclass + descriptor + decorator 결합
- **SQLAlchemy** (~100K LoC): ORM, 복잡한 메타프로그래밍, 고차 함수
- **Celery** (~50K LoC): 분산 task queue, decorator 기반 task 정의

**대규모 / 확장성 테스트**:
- **Django** (~250K LoC): 대규모 웹 프레임워크, ORM, 미들웨어 체인
- **CPython stdlib** (~300K LoC): 표준 라이브러리 전체
- **Matplotlib** (~150K LoC): 시각화 라이브러리, 복잡한 객체 계층
- **Scikit-learn** (~200K LoC): ML 라이브러리, 고차 함수 패턴, 파이프라인 패턴

### Downstream task 평가용
- **Typeshed**: Python 표준 라이브러리의 type stub 저장소 — 타입 추론 정확도의 ground truth
- **MyPy test suite**: 타입 검사 테스트 케이스 — 분석 정밀도의 proxy
- **BugsInPy** [Widyasari et al., FSE 2020]: Python 실제 버그 데이터셋 — 버그 탐지 효과 평가
- **PyPI type-annotated 패키지**: typed Python 코드의 대규모 corpus

### Call graph 품질 평가
- **PyCG benchmark** [Salis et al., ICSE 2021]: Python call graph 구축의 표준 벤치마크, micro-benchmark + real-world 프로그램
- **HeaderGen benchmark** [Mir et al., MSR 2023]

## 5. 후보 베이스라인 (Candidate Baselines)

### 5.1 Context-insensitive Python 분석 (하한 기준)
- **PyCG** [Salis et al., ICSE 2021] — Python call graph 생성, context-insensitive, assignment-based
- **Scalpel** [Li et al., ASE 2022] — call graph + data-flow, 제한적 context-sensitivity
- **Pytype** (Google) — flow-sensitive 타입 추론, context-insensitive
- **Pyre** (Meta) — modular 타입 검사, 제한적 interprocedural analysis
- **Code2flow**, **Depend** — 단순 call graph 도구

### 5.2 Context-sensitive Python 분석 (직접 비교 대상)
- **$k$-CFA for Python** (구현 필요): Python용 $k$-call-site-sensitive analysis 직접 구현 — tunneling 없는 baseline
- **$k$-object-sensitive for Python** (구현 필요): Python용 $k$-object-sensitive analysis — tunneling 없는 baseline
- *현재 Python에서 체계적 $k$-context-sensitive points-to analysis를 수행하는 공개 도구가 거의 없어, baseline 자체를 구축해야 할 가능성이 높음*

### 5.3 Java용 context tunneling (원 기법과의 대응 비교)
- **Context Tunneling (Java)** [Jeon, Jeong, Oh, *OOPSLA 2018*] — 원 논문의 구현. Java에서의 성능 향상 패턴과 Python에서의 패턴을 정성적·정량적으로 비교
- **Doop framework** [Bravenboer & Smaragdakis, 2009] — Java points-to analysis 프레임워크. Python 프레임워크 설계의 참조

### 5.4 Data-driven program analysis (학습 알고리즘 비교)
- **Zipper** [Li et al., OOPSLA 2018] — context-sensitivity 선택적 적용, precision-guided
- **Scaler** [Li et al., OOPSLA 2018] — scalability-guided context-sensitivity
- **Turner** [Jeon & Oh, PLDI 2022] — context-sensitivity 자동 선택
- **Data-driven context-sensitivity** [Jeong et al., OOPSLA 2017] — context depth 학습
- **BEAN** [Tan et al., ISSTA 2016] — redundant context element 식별
- *이들은 모두 Java 기반이지만, Python 적용 시 학습 알고리즘의 비교 대상*

### 5.5 동적 언어 정적 분석 (유사 도메인)
- **TAJS** [Jensen et al., SAS 2009] — JavaScript type analysis, context-sensitive
- **SAFE** [Lee et al., PLDI 2012] — JavaScript 정적 분석 프레임워크
- **Phasar** [Schubert et al., TACAS 2019] — LLVM IR 기반 data-flow 분석
- **Wala** (Python support) — IBM Wala 프레임워크의 Python front-end
- *JavaScript 정적 분석에서의 context-sensitivity 전략은 Python과 유사한 동적 언어 특성에 대한 참고*

### 5.6 Python 타입 추론 (downstream 비교)
- **Mypy** — gradual typing 기반 타입 검사
- **Pyright** (Microsoft) — 빠른 타입 검사
- **Pytype** (Google) — 타입 추론
- **Type4Py** [Mir et al., ICSE 2022] — ML 기반 타입 추론
- **TypeWriter** [Pradel et al., FSE 2020] — neural 타입 추론
- *Context tunneling으로 개선된 points-to analysis가 이들 타입 추론 도구의 정확도를 향상시킬 수 있는지 평가*

### 평가 지표

**분석 정밀도**:
- **May-fail casts** (또는 Python 대응: 타입 오류 경고 수) — 낮을수록 정밀
- **Poly virtual calls** (또는 Python 대응: polymorphic call resolution) — 낮을수록 정밀
- **Points-to set 크기**: 변수당 평균 points-to set 크기
- **Call graph edges**: 전체 call graph의 edge 수 — 적을수록 정밀

**분석 비용**:
- **Analysis time** (wall-clock)
- **Reachable methods**: 분석이 도달하는 메서드 수
- **Call graph edges**: 비용의 proxy

**Downstream task**:
- **타입 추론 정확도**: ground truth(type annotation, Typeshed) 대비 precision/recall
- **버그 탐지**: BugsInPy에서 true positive / false positive 수
- **Call graph 품질**: PyCG benchmark에서 precision/recall

**Context tunneling 특화**:
- **$k$-CFA 대비 향상**: 1-CFA+T vs. 1-CFA vs. 2-CFA 비교 (Java 결과 재현 시도)
- **학습된 heuristic의 일반화**: training set 외 프로그램에서의 성능
- **학습 비용**: heuristic 학습 시간

---

## 연구 지형 요약 (Research Landscape Summary)

| 축 | 대표 연구 | 언어 | Context-sensitive | Tunneling | 비고 |
|---|---|---|---|---|---|
| Context tunneling | Jeon, Jeong, Oh [OOPSLA 2018] | Java | ✅ | ✅ | 본 연구의 원 기법 |
| Data-driven context-sensitivity | Jeong et al. [OOPSLA 2017], Zipper, Scaler, Turner | Java | ✅ | ❌ | 학습 알고리즘 참고 |
| Python call graph | PyCG, Scalpel | Python | ❌ | ❌ | Context-insensitive |
| Python 타입 추론 | Pytype, Pyre, Mypy | Python | △ | ❌ | Interprocedural 제한적 |
| 동적 언어 정적 분석 | TAJS, SAFE | JavaScript | ✅ | ❌ | 유사 동적 언어 참고 |
| **본 연구: Python Context Tunneling** | — | **Python** | **✅** | **✅** | **Python 최초 context tunneling** |

**Python용 context tunneling**은 (a) 원 논문의 **tunneling 메커니즘과 data-driven 학습**을 Python에 이식하고, (b) Python 고유의 **first-class 함수, decorator, generator 등에 특화된 context-sensitivity flavor와 atomic feature**를 설계하며, (c) Python 코드베이스에서 학습된 heuristic이 **타입 추론, 버그 탐지 등 실용적 downstream task**에서 측정 가능한 개선을 가져오는지를 검증한다.

### 주요 Open Question
- **Python에서 어떤 context-sensitivity flavor가 가장 효과적인가?** Java에서는 object-sensitivity가 우세하지만, first-class 함수가 지배적인 Python에서는 function-origin-sensitivity가 더 나을 수 있음
- **동적 언어에서 context tunneling의 non-monotonicity가 더 심한가?** Python의 동적 특성으로 인해 tunneling 공간이 더 복잡하고 non-monotonic할 수 있음
- **Decorator chain의 최적 tunneling 전략은?** 2중, 3중 decorator가 적용된 함수에서 어떤 wrapper를 tunnel하고 어떤 wrapper에서 context를 갱신해야 하는가
- **Opaque 호출(C 확장)에 대한 tunneling 정책은 학습 가능한가?** 내부를 볼 수 없는 함수에 대한 tunneling 결정을 summary 또는 외부 모델로 보완할 수 있는가
- **학습된 heuristic의 cross-project 일반화**: Java에서는 DaCapo 내 training→test 일반화를 보였는데, Python에서 Flask에서 학습한 heuristic이 Django에서도 동작하는가
