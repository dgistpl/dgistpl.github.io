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
