# GDL 기반 그래프 데이터마이닝 (Graph Data Mining with GDL)

## 1. 문제 (Problem)

**그래프 데이터마이닝(Graph Data Mining)**, 특히 **그래프 패턴 마이닝(Graph Pattern Mining)** 은 대규모 그래프 데이터셋에서 빈번하게 등장하거나 의미 있는 **구조적 패턴**을 자동으로 발견하는 문제이다. 신약 개발, 소셜 네트워크 분석, 프로그램 분석, 사기 탐지 등 다양한 도메인에서 핵심 기법으로 활용된다.

기존의 그래프 패턴 마이닝은 대부분 **subgraph(부분 그래프)** 를 패턴의 표현 언어로 사용해 왔다. 예를 들어 frequent subgraph mining (gSpan, FSG, Gaston, CloseGraph 등), motif discovery (ESU/FANMOD), graphlet counting (ORCA, ESCAPE) 등은 모두 subgraph를 기본 단위로 한다. 최근의 대규모·분산 시스템들 (Arabesque, Peregrine, AutoMine, GraphPi, Pangolin, Sandslash) 또한 subgraph 표현 위에서 속도와 확장성을 개선해 왔다.

그러나 subgraph를 패턴 언어로 사용하는 접근법은 다음과 같은 **표현력의 한계**를 가진다.

- **Rigid 값 일치 요구**: Subgraph는 노드·엣지의 feature 값을 "동일한 값"으로만 매칭한다. 예를 들어 분자 그래프에서 "탄소 개수가 3~5개인 고리 구조"처럼 **범위(range)** 로 정의되는 의미 있는 패턴은 subgraph로 직접 표현할 수 없다.
- **폭발적인 패턴 수**: 값이 다른 유사 패턴들이 모두 서로 다른 subgraph로 구분되어 집계된다. 그 결과 중복되거나 의미상 유사한 패턴이 방대하게 쏟아져 나오고, 실제 "일반화된" 구조적 규칙은 포착되지 않는다.
- **실세계 패턴 누락**: 최근 연구[PL4XGL, PLDI 2024]는 subgraph 기반 표현이 실세계 데이터셋의 핵심 패턴을 포착하지 못함을 지적하였다. 의미 있는 패턴은 종종 feature 값의 **범위**와 **위상(topology)** 의 조합으로 기술되기 때문이다.

한편 다른 방향에서는 풍부한 제약을 가진 **질의 언어(query language)** 들이 발전해 왔다. Cypher [Francis et al., SIGMOD 2018], GQL [ISO/IEC 39075:2024], SPARQL, PGQL 등은 property(속성) 값에 대한 비교·범위 술어를 지원한다. 그러나 이들은 사용자가 **수동으로 패턴을 지정하는 질의** 목적이지, 데이터에서 **자동으로 의미 있는 패턴을 발견하는 mining** 목적이 아니다. 제약 기반 마이닝 연구(gPrune [Zhu et al., VLDB 2007], 가중치 FSM) 또한 구조적·카테고리형 제약 중심이며, 연속형 feature에 대한 **interval 술어**를 native하게 다루는 마이닝 알고리즘은 부재하다.

최근 PL4XGL[Jeon, Park, Oh, *PLDI 2024*]이 제안한 **GDL(Graph Description Language)** 은 feature 값을 **interval(구간)** 로 기술할 수 있고, 위상 구조도 함께 표현할 수 있는 declarative 그래프 패턴 기술 언어이다. GDL program은 노드 기술 `node x <φ>`, 엣지 기술 `edge (x,y) <φ>`, 그리고 **target symbol** $\tau \in \{\texttt{node }x, \texttt{edge }(x,y), \texttt{graph}\}$ 로 구성되어, **노드·엣지·그래프 수준의 패턴**을 모두 기술할 수 있다. Interval은 `[lb, ub]` / `[-∞, ub]` / `[lb, ∞]`와 같은 open bound를 포함한다. 이는 subgraph가 가질 수 없는 "degree $\geq 12$인 노드"와 같은 패턴을 자연스럽게 표현 가능하게 한다. 예를 들어 BA-Shapes 데이터셋에서 GDL program `[12, ∞] — [-∞, ∞] — [12, ∞]`는 Barabási–Albert 그래프의 노드를 precision 99%, recall 97%로 기술하는데, 이러한 degree-range 패턴은 subgraph 표현으로는 불가능하다 [PL4XGL §8].

GDL은 **classification 전용 evidence로만 활용**되었을 뿐, 일반적인 그래프 데이터마이닝의 패턴 언어로서는 아직 탐구되지 않았다. 흥미롭게도 PL4XGL 저자들 본인이 논문의 Related Work (§8)에서 *"GDL is strictly more expressive than subgraphs; GDL can be employed in graph data mining"* 이라고 명시적으로 제안하였다. 그러나 이 가능성을 실제로 구현한 연구는 아직 없다. 즉 다음 삼각의 교차점에 해당하는 연구 지형이 비어 있다:

- *(a) 구조 중심 mining* (gSpan, Peregrine, GraphPi) — discrete label만
- *(b) 풍부한 술어의 querying* (Cypher, GQL, SPARQL) — 자동 mining 부재
- *(c) 제약 기반 mining* (gPrune, weighted FSM) — 연속 feature interval 미지원

## 2. 목표 (Goal)

Subgraph 대신 **GDL을 패턴 언어로 사용하는 그래프 데이터마이닝 프레임워크**를 개발한다. 구체적으로 다음을 달성한다.

- **표현력 향상**: feature 값의 구간 제약을 포함한 풍부한 패턴을 발견
- **일반화된 패턴 발견**: 값의 미세한 차이로 파편화되던 유사 패턴을 하나의 일반화된 GDL program으로 통합
- **Compact한 패턴 집합**: subgraph 기반에서 발생하는 중복·폭발 문제를 완화하여, 해석 가능한 소수의 의미 있는 패턴을 추출
- **확장성 확보**: 대규모 그래프 데이터셋에서 실용적으로 동작하는 마이닝 알고리즘 설계 (Peregrine/GraphPi/AutoMine 수준의 systems 성능 목표)
- **근사 보장**: 대규모에서는 ASAP/Arya 계열처럼 $(\varepsilon, \delta)$-근사 지원 모드도 제공
