# 주어진 프로그램과 k에 대한 최적 터널링 추상화 알고리즘 (Optimal Tunneling Abstraction for a Given Program and k)

## 1. 문제 (Problem)

Context tunneling [Jeon, Jeong, Oh, *OOPSLA 2018*]은 $k$-limited context-sensitive points-to analysis에서 중요한 context element만을 선택적으로 유지하여 정밀도와 확장성을 동시에 향상시키는 기법이다. 핵심은 **tunneling relation** $\mathcal{T} \subseteq \mathbb{M} \times \mathbb{M}$ — 어떤 메서드 쌍 $(m_1, m_2)$에 대해 child method $m_2$가 parent method $m_1$의 context를 그대로 상속할지를 결정하는 이진 관계 — 을 적절히 선택하는 것이다.

### 현재 접근법의 한계

원 논문은 tunneling relation을 **data-driven heuristic**으로 학습한다. 구체적으로:

1. **Parameterized heuristic**: Atomic feature의 boolean formula $\Pi = \langle f_1, f_2 \rangle$로 tunneling relation을 생성. $f_1$은 context를 child에 전달하는 메서드, $f_2$는 parent로부터 context를 상속하는 메서드를 특성화 (§4.2, Equation 1)
2. **Non-greedy 학습 알고리즘**: Seed feature 선택 → 정제(refinement) → 평가의 반복으로 boolean formula를 탐색 (Algorithm 1-3)
3. **Training set에서 학습, test set에서 평가**: DaCapo의 4개 소규모 프로그램(luindex, lusearch, antlr, pmd)에서 학습하고 6개 대규모 프로그램에서 평가

이 접근법에는 다음과 같은 근본적 한계가 있다.

**1. Heuristic의 간접성(Indirection)**: 학습 알고리즘은 **주어진 프로그램에 대한 최적 $\mathcal{T}$를 직접 찾는 것이 아니라**, atomic feature의 boolean formula를 통해 $\mathcal{T}$를 간접적으로 생성한다. Boolean formula로 표현 가능한 tunneling relation은 전체 $\mathcal{T} \in \wp(\mathbb{M} \times \mathbb{M})$ 공간의 극히 일부이다. 즉 formula로 표현 불가능하지만 분석 정밀도를 크게 높이는 $\mathcal{T}$가 존재할 수 있다.

**2. 최적성 보장 부재**: Non-greedy 알고리즘은 greedy보다 나은 결과를 내지만(Figure 5), 여전히 **global optimum을 보장하지 않는다**. 알고리즘은 seed feature를 선택하고 conjunctive refinement를 수행하는 local search이며, 공간의 non-monotonicity(§4.1)로 인해 local optimum에 빠질 수 있다.

**3. Non-monotonicity의 미해결**: 원 논문의 핵심 관찰은 분석이 tunneling relation에 대해 **non-monotone**하다는 것이다 — $\mathcal{T} \subseteq \mathcal{T}'$이라 해서 $\text{proved}(F_P(\mathcal{T})) \subseteq \text{proved}(F_P(\mathcal{T}'))$가 성립하지 않음. 이 non-monotonicity 때문에 기존의 monotone parameter learning 알고리즘 [Jeong et al., OOPSLA 2017; Liang et al., 2011]을 직접 사용할 수 없었고, 원 논문은 heuristic으로 우회하였다. **Non-monotonic 공간에서 최적해를 효율적으로 찾는 알고리즘적 문제 자체는 미해결**이다.

**4. Program-specific vs. general heuristic의 gap**: 원 논문의 heuristic은 여러 프로그램에 걸쳐 일반화되는 것을 목표로 하므로, **특정 프로그램 $P$와 특정 $k$에 대한 최적 $\mathcal{T}$와는 gap**이 있다. Table 2-3의 결과에서도 일부 프로그램에서는 tunneling이 baseline 대비 개선이 적은 경우가 있으며, 이는 general heuristic이 program-specific optimum에 도달하지 못함을 시사한다.

### 문제의 형식화

주어진 프로그램 $P$와 context depth $k$에 대해 다음 최적화 문제를 정의한다.

$$\mathcal{T}^* = \arg\max_{\mathcal{T} \in \wp(\mathbb{M}_P \times \mathbb{M}_P)} |\text{proved}(F_P(\mathcal{T}))| \quad \text{s.t.} \quad \text{cost}(F_P(\mathcal{T})) \leq \text{cost}(F_P(\emptyset))$$

여기서:
- $\mathbb{M}_P$는 프로그램 $P$의 메서드 집합
- $F_P(\mathcal{T})$는 tunneling relation $\mathcal{T}$를 사용한 분석 결과
- $\text{proved}(F_P(\mathcal{T}))$는 증명된 assertion(예: may-fail cast가 아닌 것으로 판명된 query)의 집합
- $\text{cost}(F_P(\mathcal{T}))$는 분석 비용 (analysis time 또는 call-graph edge 수)
- $F_P(\emptyset)$는 tunneling 없는 conventional $k$-context-sensitive analysis

이 문제의 난이도:
- **공간 크기**: $|\wp(\mathbb{M}_P \times \mathbb{M}_P)| = 2^{|\mathbb{M}_P|^2}$. DaCapo 프로그램에서 reachable methods가 수천~수만 개이므로, 공간 크기는 $2^{10^6}$ 이상
- **Non-monotonicity**: 목적 함수가 $\mathcal{T}$에 대해 non-monotone하여 branch-and-bound, lattice search 등 표준 기법이 직접 적용 불가
- **평가 비용**: 단일 $\mathcal{T}$에 대한 $F_P(\mathcal{T})$ 계산이 전체 points-to analysis 실행을 요구 — 수 초~수 분

현재 이 최적화 문제를 효율적으로 풀거나, 최적성에 대한 이론적 보장을 제공하는 알고리즘은 존재하지 않는다.

## 2. 목표 (Goal)

주어진 프로그램 $P$와 context depth $k$에 대해, **최적 또는 근-최적(near-optimal)의 tunneling relation $\mathcal{T}^*$를 효율적으로 찾는 알고리즘**을 개발한다.

- **최적성**: 찾은 $\mathcal{T}$가 전체 공간에서 $|\text{proved}|$를 최대화하거나, 최적해 대비 근사 비율(approximation ratio)을 보장
- **효율성**: 전체 $2^{|\mathbb{M}_P|^2}$ 공간을 열거하지 않고, 합리적 시간(예: 분석 자체의 수~수십 배 이내) 내에 해를 찾음
- **비용 제약 준수**: 찾은 $\mathcal{T}$가 baseline 대비 분석 비용을 증가시키지 않음
- **이론적 분석**: Non-monotonic 공간에서의 최적화 문제의 계산 복잡도 분석 (NP-hardness 증명 또는 polynomial-time 알고리즘)
- **실험적 검증**: 원 논문의 data-driven heuristic 대비 정밀도 향상 정도 측정 — program-specific optimal과 general heuristic의 gap 정량화

## 3. 기본 접근 방법 (Basic Approach)

### (1) 문제의 구조 분석

최적 $\mathcal{T}$ 탐색을 효율적으로 만들기 위해 문제의 구조적 성질을 먼저 분석한다.

**Non-monotonicity의 원인 규명**:
- Non-monotonicity는 tunneling이 call graph의 구조 자체를 변경하기 때문에 발생한다. $\mathcal{T}$에 새로운 pair $(m_1, m_2)$를 추가하면 $m_2$의 context가 변경되고, 이로 인해 $m_2$가 호출하는 메서드들의 context도 연쇄적으로 변경되어 예측 불가능한 정밀도 변화가 발생
- **Local non-monotonicity vs. global structure**: Non-monotonicity가 특정 메서드 pair에 국한되는지, 아니면 전체적으로 얽혀 있는지를 프로그램별로 실험적·이론적으로 분석
- **Near-monotone 부분 공간 식별**: $\wp(\mathbb{M}_P \times \mathbb{M}_P)$의 부분 공간에서 monotonicity가 근사적으로 성립하는 영역을 식별하면, 해당 영역에서는 효율적 탐색이 가능

**계산 복잡도 분석**:
- 최적 tunneling 문제를 결정 문제로 형식화하고 NP-hardness를 증명 (또는 polynomial-time 알고리즘이 존재함을 보임)
- Points-to analysis의 복잡도 결과 [Van Horn & Mairson, ICFP 2008; Rehof & Fähndrich, SAS 2001]와의 관계 분석
- **Inapproximability**: 근사 비율에 대한 hardness 결과 — 최적의 $c$-근사가 가능한 최선의 $c$는?

### (2) Exact 알고리즘

소규모~중규모 프로그램에서 최적 $\mathcal{T}^*$를 정확히 찾는 알고리즘을 설계한다. 이 알고리즘의 주 목적은 (a) heuristic과 최적해의 gap을 정량화하고, (b) 근사 알고리즘의 품질을 평가하는 oracle 역할이다.

- **Constraint-based formulation**: $\mathcal{T}$의 각 원소 $(m_i, m_j)$를 boolean 변수 $x_{ij}$로 인코딩하고, 분석 결과를 constraint로 표현. MaxSAT / ILP로 풀기
  - 난점: 분석 결과 자체가 fixpoint이므로 constraint가 비선형·재귀적
  - 가능성: 분석을 Datalog으로 표현한 경우, Datalog 프로그램의 구조를 활용한 인코딩
- **CEGAR (Counterexample-Guided Abstraction Refinement) 스타일**:
  1. 초기: $\mathcal{T} = \emptyset$ (conventional analysis)
  2. 분석 실행 → 증명 실패한 query $q$ 식별
  3. $q$를 증명할 수 있는 tunneling pair $(m_i, m_j)$ 탐색 (targeted refinement)
  4. $(m_i, m_j)$를 $\mathcal{T}$에 추가하되, 비용 제약과 다른 query에 대한 부작용을 검사
  5. 수렴까지 반복
- **Branch-and-bound with non-monotone pruning**:
  - 표준 branch-and-bound는 monotonicity에 의존하여 가지를 쳐내지만, non-monotone 공간에서는 다른 pruning 규칙이 필요
  - **Impact-based pruning**: 메서드 pair $(m_i, m_j)$의 "impact" — 이 pair의 tunneling 여부가 다른 분석 결과에 미치는 영향의 범위 — 를 pre-computation하여, impact가 작은 pair는 일찍 결정
  - **Symmetry breaking**: Call graph의 구조적 대칭성을 활용하여 동치인 $\mathcal{T}$를 중복 탐색하지 않음

### (3) 근사 알고리즘

대규모 프로그램에서 실용적 시간 내에 근-최적 $\mathcal{T}$를 찾는 알고리즘을 설계한다.

**Greedy 변형 with lookahead**:
- 원 논문의 non-greedy 전략을 일반화: 각 step에서 $\ell$-step lookahead로 tunneling pair의 조합 효과를 평가
- $\ell = 1$이면 greedy, $\ell = |\mathbb{M}_P|^2$이면 exact. 적절한 $\ell$에서 정밀도-비용 trade-off

**Local search / metaheuristic**:
- **Simulated annealing**: $\mathcal{T}$ 공간에서 neighbor는 단일 pair의 추가/제거. 온도 스케줄링으로 local optimum 탈출
- **Genetic algorithm**: $\mathcal{T}$를 bit vector로 인코딩, crossover는 두 $\mathcal{T}$의 합집합/교집합, mutation은 random pair flip
- **Tabu search**: 최근 변경한 pair를 tabu list에 넣어 cycling 방지

**Decomposition 기반 접근**:
- **SCC(Strongly Connected Component) decomposition**: Call graph의 SCC 단위로 tunneling 문제를 분해. 각 SCC 내에서 독립적으로 최적 $\mathcal{T}_{\text{SCC}}$를 찾고 합성
- **Hierarchical decomposition**: 큰 프로그램을 모듈/패키지 단위로 분해하고 각 단위의 최적 $\mathcal{T}$를 계층적으로 합성
- **Independent pair identification**: $(m_i, m_j)$의 tunneling이 다른 pair의 효과에 영향을 미치지 않는 "독립" pair를 식별하여, 독립 pair들은 개별 최적화 후 결합

**Bayesian optimization**:
- $\mathcal{T}$를 고차원 boolean vector로 표현하고, $|\text{proved}(F_P(\mathcal{T}))|$를 black-box objective로 Bayesian optimization
- Gaussian process surrogate model로 비용이 큰 $F_P(\mathcal{T})$ 평가 횟수를 최소화
- **Acquisition function**: Expected improvement, 비용 제약을 penalty로 통합

**Reinforcement learning**:
- State: 현재 $\mathcal{T}$, Action: pair 추가/제거, Reward: $\Delta|\text{proved}|$ (비용 제약 위반 시 penalty)
- Policy gradient 또는 DQN으로 메서드 pair 선택 정책을 학습
- Program-specific 학습: 단일 프로그램에 대해 RL agent를 훈련하여 해당 프로그램의 최적 $\mathcal{T}$에 수렴

### (4) 공간 축소 기법

$2^{|\mathbb{M}_P|^2}$의 탐색 공간을 사전에 줄이는 기법을 설계한다.

- **Irrelevant pair pruning**: Query와 무관한 메서드 pair — 즉 tunneling 여부가 어떤 query의 결과에도 영향을 미치지 않는 pair — 를 정적 분석으로 식별하여 제거
- **Must-tunnel / must-not-tunnel pair identification**: 특정 pair의 tunneling이 항상 이득(또는 항상 손해)임을 정적으로 증명할 수 있는 경우, 해당 pair를 고정
- **Sensitivity-guided reduction**: 각 pair $(m_i, m_j)$의 tunneling이 분석 결과에 미치는 영향(sensitivity)을 빠르게 추정하고, sensitivity가 임계값 이하인 pair는 don't-care로 처리
- **Call graph structure-based filtering**: Call graph에서 호출 깊이가 $k$ 이하인 메서드는 tunneling의 영향이 없으므로 제외. 재귀가 없는 단순 체인도 tunneling이 불필요한 경우가 많음
- **Dominance-based pruning**: Pair $(m_i, m_j)$가 pair $(m_i', m_j')$를 dominate하는 경우 — 즉 $(m_i, m_j)$를 tunnel하면 $(m_i', m_j')$의 tunneling 효과가 자동으로 달성되는 경우 — dominated pair를 제거

### (5) 분석 비용 절감

각 $\mathcal{T}$ 후보의 평가 비용($F_P(\mathcal{T})$ 실행)을 줄이는 기법을 설계한다.

- **Incremental analysis**: $\mathcal{T}$에서 $\mathcal{T} \cup \{(m_i, m_j)\}$로 변경 시, 전체 분석을 재실행하지 않고 영향받는 부분만 재계산. Datalog 기반 분석에서 incremental evaluation(semi-naive evaluation의 확장) 활용
- **Abstract evaluation**: 전체 points-to analysis 대신, 분석 결과를 근사하는 가벼운 abstract evaluation으로 $\mathcal{T}$의 품질을 빠르게 추정. 유망한 후보에 대해서만 정확한 분석 실행
- **Caching and reuse**: 이전에 계산한 $F_P(\mathcal{T}')$의 결과를 캐싱하고, $\mathcal{T}$와 $\mathcal{T}'$의 차이가 작을 때 결과를 재사용
- **Parallel evaluation**: 여러 후보 $\mathcal{T}_1, \mathcal{T}_2, \ldots$를 병렬로 평가

### (6) 이론적 분석

- **Complexity**: 최적 tunneling 문제의 NP-hardness (또는 polynomial solvability) 증명
- **Approximation**: 다항 시간 근사 알고리즘의 존재 여부와 근사 비율
- **Structure of non-monotonicity**: Non-monotonicity의 정도를 정량화하는 지표(예: 얼마나 많은 pair에서 non-monotone 현상이 관찰되는가)와, non-monotonicity가 약할 때의 알고리즘 성능 보장
- **Submodularity / supermodularity**: $|\text{proved}(F_P(\mathcal{T}))|$가 (약한) submodular 또는 supermodular 성질을 가지는 부분 공간이 있는지 분석. Submodularity가 성립하면 greedy가 $(1 - 1/e)$-근사를 보장

## 4. 후보 벤치마크 (Candidate Benchmarks)

### DaCapo 스위트 (원 논문과의 직접 비교)
- **Training set**: luindex, lusearch, antlr, pmd — 소규모, exact 알고리즘으로 $\mathcal{T}^*$ 계산 가능
- **Test set**: eclipse, xalan, fop, chart, bloat, jython — 중규모~대규모
- *원 논문의 heuristic이 학습한 $\mathcal{T}_{\text{heuristic}}$과 exact $\mathcal{T}^*$의 gap을 DaCapo에서 직접 측정*

### 원 논문 외 Java 벤치마크
- **JPC** (jpc.sourceforge.net) — 원 논문 Table 4에서 추가 평가에 사용
- **Checkstyle** (checkstyle.sourceforge.net) — 원 논문 Table 4에서 추가 평가에 사용
- **Soot test suite** — 정적 분석 프레임워크의 테스트 프로그램
- **SPECjvm2008** — Java 성능 벤치마크

### 소규모 합성 프로그램 (exact 알고리즘 검증용)
- **원 논문 Figure 1, 2의 예제** — call-site-sensitivity, object-sensitivity 동기 부여 예제. 최적 $\mathcal{T}$를 수동으로 계산 가능
- **Synthetic call graph benchmarks** — 제어된 크기와 구조(chain, tree, DAG, SCC 포함)의 합성 프로그램으로 exact 알고리즘의 정확성 검증 및 scalability 측정
- **Non-monotonicity stress test** — Non-monotone 현상이 극대화되도록 설계된 프로그램 (예: 다중 경로를 통해 동일 메서드에 도달하는 패턴)

### 대규모 확장성 테스트
- **OpenJDK** — Java 표준 라이브러리
- **Spring Framework** — 대규모 Java 프레임워크
- **Apache Commons** — 중규모 유틸리티 라이브러리
- *대규모에서는 exact가 불가능하므로 근사 알고리즘의 품질과 확장성을 평가*

## 5. 후보 베이스라인 (Candidate Baselines)

### 5.1 원 논문의 data-driven heuristic (핵심 비교 대상)
- **Context Tunneling heuristic** [Jeon, Jeong, Oh, *OOPSLA 2018*] — Boolean formula $\Pi = \langle f_1, f_2 \rangle$로 학습된 tunneling relation. Algorithm 1-3의 non-greedy 탐색. **본 연구의 핵심 비교 대상**: program-specific optimal $\mathcal{T}^*$ 대비 얼마나 gap이 있는지 정량화
- **Greedy variant** (원 논문 §5.2) — 원 논문에서 non-greedy의 우월성을 보이기 위해 비교한 greedy 버전. 본 연구의 하한 비교

### 5.2 Tunneling 없는 baseline (하한 기준)
- **$k$-CFA** ($k$ = 1, 2): Conventional $k$-call-site-sensitive analysis without tunneling
- **$k$-object-sensitivity** ($k$ = 1, 2): Conventional $k$-object-sensitive analysis without tunneling
- **$k$-type-sensitivity** ($k$ = 1, 2)
- **$k$-hybrid context-sensitivity** ($k$ = 1, 2)
- **Context-insensitive analysis**: $\mathcal{T} = \mathbb{M}_P \times \mathbb{M}_P$ (모든 메서드에 tunneling 적용 → 모든 메서드가 동일 context → context-insensitive와 동치)

### 5.3 Data-driven program analysis의 학습 알고리즘 (알고리즘 비교)
- **Jeong et al. [OOPSLA 2017]** — Disjunctive model for context depth 학습. Monotone 공간에서 동작, non-monotone에 부적합 (원 논문에서 직접 언급)
- **Liang et al. [POPL 2011]** — Minimal abstraction learning. Monotonicity 가정 하의 알고리즘
- **Oh et al. [OOPSLA 2015]** — Linear combination of features for analysis heuristic
- **Chae et al. [OOPSLA 2017]** — Automatic feature generation for program analysis
- *이들은 모두 monotone parameter space를 가정하거나 heuristic이며, non-monotone 공간에서의 최적성 보장이 없음*

### 5.4 Context-sensitivity 선택 기법 (관련 최적화)
- **Zipper** [Li et al., OOPSLA 2018] — Precision-preserving context-sensitivity 선택. 어떤 메서드에 context-sensitivity를 적용할지를 정적으로 결정
- **Scaler** [Li et al., OOPSLA 2018] — Scalability-guided context-sensitivity
- **Turner** [Jeon & Oh, PLDI 2022] — Context-sensitivity 자동 선택
- **BEAN** [Tan et al., ISSTA 2016] — Redundant context element 식별
- **Selective context-sensitivity** [Jeong et al., OOPSLA 2017; Oh et al., PLDI 2014] — 메서드별 $k$ 값 선택
- *이들은 "어떤 메서드에 context-sensitivity를 적용할지"를 결정하며, tunneling의 "어떤 context element를 유지할지"와는 orthogonal하지만 관련된 최적화 문제*

### 5.5 비단조적(non-monotone) 최적화 기법 (알고리즘적 비교)
- **Non-monotone submodular maximization** [Buchbinder et al., FOCS 2012] — $(1/2 - \epsilon)$-근사 알고리즘
- **Black-box combinatorial optimization** — Bayesian optimization, evolutionary strategy, random search
- **MaxSAT solvers** — RC2, Open-WBO, MaxHS — constraint-based formulation의 solver
- **ILP solvers** — Gurobi, CPLEX — 정수 계획법 기반 formulation의 solver
- *이들과의 비교를 통해 tunneling 문제의 특수 구조를 활용한 알고리즘이 범용 optimizer보다 우수한지를 평가*

### 평가 지표

**최적성 관련**:
- **Optimality gap**: $|\text{proved}(F_P(\mathcal{T}^*))| - |\text{proved}(F_P(\mathcal{T}_{\text{alg}}))|$ — exact 해 대비 근사 해의 gap
- **Optimality ratio**: $\frac{|\text{proved}(F_P(\mathcal{T}_{\text{alg}}))|}{|\text{proved}(F_P(\mathcal{T}^*))|}$
- **Heuristic gap**: $|\text{proved}(F_P(\mathcal{T}^*))| - |\text{proved}(F_P(\mathcal{T}_{\text{heuristic}}))|$ — 원 논문 heuristic과 optimal의 gap

**비용 관련**:
- **알고리즘 실행 시간**: $\mathcal{T}$를 찾는 데 걸리는 총 시간
- **분석 평가 횟수**: $F_P(\mathcal{T})$를 실행한 횟수 — 알고리즘의 sample efficiency
- **비용 제약 준수 여부**: $\text{cost}(F_P(\mathcal{T})) \leq \text{cost}(F_P(\emptyset))$

**분석 결과**:
- **May-fail casts**, **analysis time**, **call-graph edges**, **reachable methods** — 원 논문과 동일한 지표
- **Tunneling relation 크기**: $|\mathcal{T}^*|$ — 최적 해의 sparsity
- **Non-monotonicity 지표**: 공간에서 non-monotone pair의 비율

---

## 연구 지형 요약 (Research Landscape Summary)

| 축 | 대표 연구 | 최적성 보장 | Non-monotone 대응 | Program-specific | 비고 |
|---|---|---|---|---|---|
| Data-driven tunneling heuristic | Jeon et al. [OOPSLA 2018] | ❌ | △ (non-greedy) | ❌ (general) | 원 논문, 본 연구의 개선 대상 |
| Monotone parameter learning | Jeong et al. [OOPSLA 2017], Liang et al. [2011] | △ (monotone 공간) | ❌ | ❌ | Non-monotone에 부적합 |
| Context-sensitivity 선택 | Zipper, Scaler, Turner | ❌ | △ | △ | Orthogonal한 최적화 |
| Non-monotone submodular opt | Buchbinder et al. [FOCS 2012] | ✅ (이론적) | ✅ | ✅ | 범용, 구조 미활용 |
| **본 연구: Optimal tunneling** | — | **✅** | **✅** | **✅** | **문제 특수 구조 활용** |

**최적 tunneling abstraction 알고리즘**은 (a) 원 논문이 heuristic으로 우회한 **non-monotonic 최적화 문제를 정면으로 해결**하고, (b) **program-specific optimal과 general heuristic의 gap을 최초로 정량화**하며, (c) 분석의 non-monotonicity라는 현상에 대한 **이론적 이해**(계산 복잡도, 근사 가능성, 구조적 성질)를 제공한다.

### 주요 Open Question
- **최적 tunneling 문제는 NP-hard인가?** Points-to analysis 자체의 복잡도(EXPTIME-complete for $k$-CFA [Van Horn & Mairson, ICFP 2008])와 최적 tunneling의 복잡도는 어떤 관계인가?
- **Non-monotonicity는 실제로 얼마나 심각한가?** 실제 프로그램에서 non-monotone pair의 비율과, non-monotonicity가 local optimum의 수에 미치는 영향은?
- **Program-specific optimal과 general heuristic의 gap은 얼마나 큰가?** Gap이 크다면 program-specific 최적화의 실용적 가치가 높고, 작다면 general heuristic의 품질이 이미 충분함을 의미
- **Exact 알고리즘이 실용적 크기의 프로그램에서 동작 가능한가?** 공간 축소 + incremental evaluation으로 DaCapo training 프로그램(수천 메서드)에서 exact solution을 계산할 수 있는가?
- **Incremental evaluation은 얼마나 효과적인가?** $\mathcal{T} \to \mathcal{T} \cup \{(m_i, m_j)\}$ 변경 시 분석 결과의 변화량은 전형적으로 얼마나 큰가? 작다면 incremental evaluation이 극적인 속도 향상을 제공
- **최적 $\mathcal{T}^*$의 구조적 패턴은?** 최적 $\mathcal{T}^*$에 포함되는 pair들의 공통 특성이 있는가? 이 패턴이 새로운 atomic feature 또는 더 나은 heuristic 설계를 guide할 수 있는가?
