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
