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

## 3. 기본 접근 방법 (Basic Approach)

### (1) Context element의 "중요도"에 대한 원칙적 정의

원 논문의 핵심 관찰을 재해석한다: context tunneling이 효과적인 이유는 **중요한 context element를 유지하기 때문**이다. "중요하다"를 data-driven feature 대신 **프로그램 분석의 원리로부터 직접 정의**한다.

**후보 정의 1: Context uniqueness (구별력)**
- Context element $e$가 "중요하다" ⟺ $e$를 포함한 context와 포함하지 않은 context가 서로 다른 points-to set을 유발하는 경우가 많다
- 직관: 많은 호출 경로가 합류하는 메서드(예: utility 메서드, library 메서드)에서는 context element의 구별력이 중요. 단일 호출자만 있는 메서드에서는 context element가 무의미
- 측정: Call graph에서 메서드 $m$의 caller 수 $|\text{callers}(m)|$. Caller가 많을수록 context element의 구별력이 중요

**후보 정의 2: Information-theoretic importance**
- Context element $e$의 중요도를 해당 element가 points-to set에 대해 제공하는 **상호 정보량(mutual information)** 으로 정의
- $I(e; \text{ptsto}) = H(\text{ptsto}) - H(\text{ptsto} \mid e)$
- Context에 $e$를 포함할 때 points-to set의 불확실성이 크게 감소하면 $e$는 중요

**후보 정의 3: Call graph structural importance**
- Context element $e$ = call-site (또는 allocation-site 등)의 중요도를 call graph 상의 위치로 정의
- **Branching point**: $e$ 이후 호출 경로가 분기하는 정도. 분기가 많은 call-site일수록 중요
- **Merging point**: $e$ 이전에 여러 경로가 합류하는 정도. 합류가 많은 메서드에 도달하는 call-site일수록 중요

### (2) 단순한 tunneling 규칙 후보

위의 원칙적 정의를 **구현 가능한 단순 규칙**으로 변환한다.

**규칙 A: Caller-count tunneling**
- $m_2$가 호출될 때 tunneling 적용 ⟺ $m_2$의 caller 수가 임계값 $\theta$ 이하
- 직관: Caller가 적은 메서드는 context element로 구별할 필요가 적으므로 parent의 context를 그대로 상속. Caller가 많은 메서드는 context element가 필수적이므로 정상 갱신
- 구현: Call graph 구축 후 $|\text{callers}(m)|$ 계산 — 1줄의 조건문
- 임계값 $\theta$는 고정값(예: 1) 또는 통계적(예: median caller count)

**규칙 B: Wrapper/identity tunneling**
- $m_1$이 "wrapper" 또는 "identity" 패턴 ⟺ $m_1$이 argument를 변환 없이 다른 메서드에 전달
- 직관: Wrapper 메서드는 의미 있는 context element를 생성하지 않으므로 tunnel. 원 논문의 학습된 heuristic에서 B9("단일 return 문만 포함")가 중요 feature로 나타난 것과 일치
- 구현: 메서드 body의 instruction 수 또는 return-argument 패턴 검사
- **Formal characterization**: $m_1$이 argument $x$를 받아 $m_2(x)$를 호출하고 그 결과를 반환하는 경우 (flow-through pattern)

**규칙 C: Depth-based tunneling**
- Call chain에서 현재 depth $d$와 context element의 "age"를 비교. 가장 오래된(least recent) context element부터 제거하는 대신, **가장 정보량이 적은** element를 제거
- 직관: 기존 $k$-CFA는 $k$ most recent element를 유지하지만, recency가 반드시 중요도와 일치하지 않음 (이것이 context tunneling의 핵심 관찰)
- 단순 규칙: "가장 적은 수의 distinct context를 생성하는 element를 제거" — 구별력이 낮은 element를 우선 제거

**규칙 D: Type-hierarchy tunneling**
- Object-sensitivity에서, allocation-site의 클래스가 deep inheritance chain의 일부이면 tunneling
- 직관: `Object`, `AbstractList`, `AbstractCollection` 등 추상 상위 클래스의 allocation-site는 구별력이 낮음. 원 논문의 학습된 heuristic에서 object-sensitivity의 $f_1$이 "sub-object" 패턴을 포착한 것(§5.3)과 일치
- 구현: 클래스의 inheritance depth 또는 subclass 수 검사

**규칙 E: Allocation fan-out tunneling**
- Allocation-site $h$를 context element로 사용할 때, $h$가 속한 메서드에서 생성되는 allocation-site의 수가 많으면 tunneling
- 직관: 많은 객체를 생성하는 메서드(예: factory, builder)의 allocation-site는 개별적으로는 구별력이 있으므로 context element로 유지해야 함. 반대로 단일 allocation만 있는 메서드의 allocation-site는 메서드 identity와 동일하므로 tunneling 가능
- 구현: 메서드 내 allocation instruction 수 검사

### (3) 규칙의 조합과 평가

- **단일 규칙 평가**: 각 규칙을 독립적으로 적용하여 baseline 대비 성능 측정
- **규칙 조합**: 2~3개 규칙의 conjunction/disjunction으로 결합하여 효과 측정. 규칙 수가 적을수록 좋음
- **임계값의 robust 선택**: 임계값이 필요한 규칙(A, E)에서 값을 프로그램 통계(median, percentile)로 자동 결정하여 프로그램 의존성 최소화
- **Flavor별 적용**: Call-site-sensitivity, object-sensitivity, type-sensitivity, hybrid 각각에 규칙을 적용하여 flavor 독립성 검증

### (4) 이론적 정당화

단순 규칙이 왜 효과적인지를 형식적으로 설명한다.

- **정밀도 보존 조건**: "tunneling이 정밀도를 해치지 않는 충분 조건"을 형식화. 예: "메서드 $m$의 모든 호출이 동일한 context element $e$를 생성한다면, $e$를 tunnel해도 정밀도 손실 없음" — 이는 규칙 A ($|\text{callers}(m)| = 1$)의 형식적 근거
- **정밀도 향상 조건**: "tunneling이 정밀도를 높이는 충분 조건"을 형식화. 예: "method $m_2$의 caller $m_1$이 $k$보다 깊은 호출 체인에서 도달 가능하고, $m_1$의 context가 $m_2$의 분석에 필수적이면, $m_1$에서 $m_2$로의 tunneling이 정밀도를 높임"
- **Non-monotonicity 회피 조건**: 단순 규칙이 non-monotone 행동을 유발하지 않는 조건을 분석. 규칙이 "safe"한 부분 공간에만 tunneling을 적용하면 monotonicity가 복원될 수 있음

### (5) 구현 가이드라인

기존 분석기에 tunneling을 최소한의 노력으로 통합하기 위한 가이드라인을 제공한다.

- **분석 규칙 수정**: 원 논문 Figure 4의 규칙 변경을 일반화. Method invocation 규칙에 단일 조건문(`if shouldTunnel(m1, m2) then ctx' = pctx else ctx' = [pctx + e]`)을 추가하는 것으로 충분
- **`shouldTunnel` 함수의 구현**: 선택된 단순 규칙에 따라 10~30줄의 코드로 구현
- **Preprocessing**: 규칙에 필요한 정보(caller count, method body size 등)를 pre-analysis 단계에서 계산. Pre-analysis는 context-insensitive analysis와 동일 비용 또는 그 이하
- **Framework 독립성**: Datalog 기반(Doop, Soufflé), imperative(Soot, Wala, SPARTA), 함수형 등 임의의 분석 프레임워크에 통합 가능한 인터페이스 제시

## 4. 후보 벤치마크 (Candidate Benchmarks)

### DaCapo 스위트 (원 논문과의 직접 비교)
- **DaCapo 2006-10-MR2** [Blackburn et al., 2006]: luindex, lusearch, antlr, pmd (small), eclipse, xalan, fop, chart, bloat, jython (large)
- *원 논문 Table 2-3과 동일 설정에서 비교하여, 단순 규칙이 학습된 복잡한 heuristic에 얼마나 근접하는지 측정*

### 원 논문 외 Java 벤치마크
- **JPC**, **Checkstyle** — 원 논문 Table 4에서 사용된 추가 벤치마크
- **SPECjvm2008**
- **Dacapo-9.12-bach** (updated suite)

### 대규모 실세계 프로그램
- **OpenJDK**, **Spring Framework**, **Apache Tomcat**, **Apache Commons** — 확장성 평가
- **Guava**, **Jackson**, **Netty** — 중규모 라이브러리

### 다른 언어 (범용성 검증)
- **Python 프로그램**: Context-Tunneling-Python 연구와 연계. 단순 규칙이 언어 독립적으로 동작하는지 검증
- **JavaScript 프로그램**: TAJS [Jensen et al., SAS 2009] 벤치마크. 동적 언어에서의 범용성
- **C/C++ 프로그램**: SVF [Sui & Xue, CGO 2016] 벤치마크. Pointer analysis에서의 범용성

### 합성 벤치마크 (규칙의 강점/약점 분석)
- **Decorator chain** (다양한 깊이): Wrapper tunneling 규칙의 효과 isolation
- **Factory pattern**: Allocation fan-out 규칙의 효과 isolation
- **Deep inheritance hierarchy**: Type-hierarchy 규칙의 효과 isolation
- **Many-caller/single-caller 혼합**: Caller-count 규칙의 임계값 sensitivity 분석

## 5. 후보 베이스라인 (Candidate Baselines)

### 5.1 원 논문의 data-driven heuristic (핵심 비교 대상)
- **Context Tunneling heuristic** [Jeon, Jeong, Oh, *OOPSLA 2018*] — 학습된 $\Pi = \langle f_1, f_2 \rangle$. **본 연구의 핵심 질문: 53~137시간 학습된 복잡한 boolean formula가, 수 분만에 구현 가능한 단순 규칙에 비해 얼마나 더 나은가?**
- **Greedy variant** (원 논문 §5.2)
- **Approximate learning** (원 논문 Table 6): $\langle \textit{false}, f_2 \rangle$ 만 학습하여 비용을 절반으로 줄인 변형

### 5.2 Tunneling 없는 baseline
- **$k$-CFA** ($k$ = 1, 2): 4가지 flavor 모두
- **Context-insensitive analysis**
- *단순 규칙이 최소한 tunneling 없는 baseline을 유의미하게 outperform해야 함*

### 5.3 Context-sensitivity 선택 기법 (단순성 비교)
- **Zipper** [Li et al., OOPSLA 2018] — 원칙적(principled) context-sensitivity 선택. Precision-critical pattern(direct flow, wrapped flow, unwrapped flow)을 기반으로 메서드별 context-sensitivity 적용 여부를 정적으로 결정. **단순성·원칙성에서 본 연구와 가장 유사한 철학**
- **Scaler** [Li et al., OOPSLA 2018] — Scalability-guided. Object allocation graph의 구조적 성질 활용
- **Turner** [Jeon & Oh, PLDI 2022] — 자동 context-sensitivity 선택
- **BEAN** [Tan et al., ISSTA 2016] — Redundant node 식별로 object allocation graph에서 불필요한 context element 제거
- *이 기법들은 "어떤 메서드에 context-sensitivity를 적용할지"를 결정하며, tunneling과는 orthogonal. 두 기법을 조합했을 때의 시너지도 평가 대상*

### 5.4 Trivial tunneling 규칙 (하한 비교)
- **Random tunneling**: 각 pair $(m_1, m_2)$에 대해 확률 $p$로 tunneling 적용. 단순 규칙이 random보다 유의미하게 나은지 확인
- **All-tunnel**: $\mathcal{T} = \mathbb{M}_P \times \mathbb{M}_P$ (모든 메서드에 tunneling → context-insensitive)
- **No-tunnel**: $\mathcal{T} = \emptyset$ (conventional $k$-CFA)
- **Single-feature tunneling**: 원 논문의 atomic feature 중 단일 feature 하나만으로 tunneling (예: B1만으로 $f_1 = \text{B1}$). 원 논문 §5.2에서 best single feature는 B1("nested class 메서드")이었고, 9,694→7,218 alarm 감소를 달성. 단순 규칙이 이보다 나은지 비교

### 5.5 Optimal tunneling (상한 비교)
- **Optimal-Tunneling-Abstraction 연구의 결과** — program-specific optimal $\mathcal{T}^*$. 단순 규칙이 optimal에 얼마나 근접하는지 측정 (소규모 프로그램에서)
- *이를 통해 단순 규칙의 "정밀도 천장"을 확인*

### 평가 지표

**정밀도·비용** (원 논문과 동일):
- **May-fail casts** — 낮을수록 정밀
- **Analysis time** (seconds) — 낮을수록 확장적
- **Poly virtual calls**, **Reachable methods**, **Call-graph edges**

**단순성 지표** (본 연구 고유):
- **규칙의 서술 길이**: 자연어 또는 pseudo-code로 몇 줄/몇 단어로 기술 가능한가
- **구현 코드 줄 수**: 기존 분석기에 추가되는 LoC
- **파라미터 수**: 수동 설정이 필요한 파라미터(임계값 등)의 수. 0이 이상적
- **학습/preprocessing 비용**: Data-driven 접근의 53~137시간 vs. 단순 규칙의 preprocessing 시간
- **언어 이식 노력**: 새로운 언어로 이식할 때 필요한 변경량

**범용성 지표**:
- **Cross-flavor 성능**: 동일 규칙이 4가지 flavor 모두에서 효과적인가
- **Cross-language 성능**: Java 외 언어에서도 동작하는가
- **Cross-framework 성능**: Doop 외 프레임워크에서도 동작하는가

**비교 지표**:
- **Data-driven 대비 정밀도 비율**: $\frac{\text{may-fail casts (simple rule)}}{\text{may-fail casts (data-driven)}}$ — 1에 가까울수록 gap이 작음
- **Optimal 대비 정밀도 비율**: 소규모 프로그램에서 측정

---

## 연구 지형 요약 (Research Landscape Summary)

| 축 | 대표 연구 | 단순성 | 원칙성 | 범용성 | 효과성 | 비고 |
|---|---|---|---|---|---|---|
| Data-driven tunneling | Jeon et al. [OOPSLA 2018] | ❌ | ❌ | △ | ✅ | 학습 필요, 복잡한 formula |
| Principled ctx selection | Zipper [Li et al., 2018] | ✅ | ✅ | △ | ✅ | Tunneling이 아닌 selection |
| Scalability-guided | Scaler [Li et al., 2018] | ✅ | ✅ | △ | △ | 정밀도보다 확장성 우선 |
| Data-driven ctx depth | Jeong et al. [OOPSLA 2017] | ❌ | ❌ | △ | ✅ | Monotone 공간, 학습 필요 |
| Redundant node removal | BEAN [Tan et al., 2016] | ✅ | △ | △ | △ | OAG 구조에 의존 |
| **본 연구: Simple tunneling** | — | **✅** | **✅** | **✅** | **?** | **핵심 질문: 효과 유지 가능?** |

본 연구의 핵심 contribution은 **"complexity budget"의 재분배**이다. 원 논문은 복잡성을 **학습 알고리즘과 feature 설계**에 투자하여 높은 효과를 달성했다. 본 연구는 복잡성을 **이론적 분석과 원칙적 정의**에 투자하여, 결과물(tunneling 규칙)은 극도로 단순하지만 유사한 효과를 달성하는 것을 목표로 한다.

### 주요 Open Question
- **"Pareto frontier"는 어디에 있는가?** 단순성과 효과성의 trade-off 곡선에서, data-driven 대비 90%의 효과를 10%의 복잡성으로 달성하는 sweet spot이 존재하는가?
- **단일 규칙으로 충분한가?** 원 논문의 학습된 heuristic이 실질적으로 포착하는 패턴은 몇 가지인가? 1~2개의 핵심 패턴이 대부분의 이득을 설명한다면, 단순 규칙이 충분할 수 있음
- **Caller count는 좋은 proxy인가?** $|\text{callers}(m)|$이 "context element의 중요도"의 충분한 근사인지는 실험적·이론적으로 검증 필요
- **Zipper와의 통합**: Zipper의 precision-critical pattern + 본 연구의 tunneling 규칙을 결합하면 시너지가 있는가? Zipper는 "어디에 context-sensitivity를 적용할지", tunneling은 "어떤 context element를 유지할지"를 결정하므로 orthogonal한 개선이 가능할 수 있음
- **이론적 최적 단순 규칙**: 규칙의 "서술 복잡도"(예: 조건의 수)를 고정했을 때, 해당 복잡도 내에서 최적인 규칙을 특성화할 수 있는가? 이는 최적 tunneling 문제(Optimal-Tunneling-Abstraction)의 제약된 버전
