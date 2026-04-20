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

## 3. 기본 접근 방법 (Basic Approach)

기존의 subgraph 기반 패턴 마이닝을 **GDL program 공간으로 lift**하는 것이 핵심 아이디어이다. 다음과 같은 기술적 단계를 고려한다.

### (1) GDL 패턴 공간의 정의
- GDL program $P = (\overline{\delta_V}, \overline{\delta_E}, \tau)$: 노드/엣지 기술 + target symbol $\tau$ (node/edge/graph 세 종류)
- 그래프 $G$와 valuation $\nu: X \to V$가 program $P$를 만족하는 관계($(G, \nu) \models P$)를 subgraph isomorphism + interval 포함 검사로 정의
- 패턴의 **semantics**를 target에 따라 정의: $\llbracket P \rrbracket_{\texttt{graph}} = \{G \mid \exists \nu.\ (G,\nu) \models P\}$, $\llbracket P \rrbracket_{\texttt{node }x} = \{\nu(x) \mid (G,\nu) \models P\}$ 등. 기존 subgraph 언어가 GDL의 특수한 경우임을 명시 (subsumption lattice)
- **Generality order** $P_1 \sqsubseteq P_2 \iff \llbracket P_1 \rrbracket \subseteq \llbracket P_2 \rrbracket$ — PL4XGL의 합성 알고리즘이 이용하는 핵심 관계
- **Canonical form**: gSpan의 DFS code, FSG/FFSM의 canonical adjacency matrix를 interval-augmented 형태로 확장

### (2) GDL 패턴 마이닝 알고리즘
- **Candidate generation**:
  - **Top-down synthesis** [PL4XGL §5.2]: 가장 일반적인 program으로부터 시작 → AddNode / AddEdge / SpecializeNode / SpecializeEdge로 specializing. feature 값 발견에 강점
  - **Bottom-up synthesis** [PL4XGL §5.3]: 가장 구체적(인스턴스 그대로) program으로부터 시작 → RemoveNode / RemoveEdge / GeneralizeNode / GeneralizeEdge로 generalizing. 구조 패턴 포착에 강점
  - PL4XGL의 기존 구현을 직접 baseline으로 사용 가능 (greedy, 지역 최적해)
- **Interval generalization**: 서로 다른 feature 값을 가진 유사 패턴들을 하나의 interval 제약으로 일반화 (anti-unification, lattice climbing, numeric abstraction). PL4XGL의 `SpecializeItv` (median cut), `GeneralizeItv` (lower/upper bound 제거) 가 초기 설계
- **Pattern growth**: gSpan의 rightmost-extension, Peregrine의 pattern-aware matching order를 GDL 공간에 이식
- **Support / frequency 정의**: $\text{supp}(P) = |\llbracket P \rrbracket \cap \mathcal{G}|$로 일반화된 support 계산. minimum-image support(MNI) 등 단일 그래프 상 support 정의도 interval 공간으로 확장
- **Pruning**:
  - **Anti-monotonic pruning**: GDL 패턴 간의 subsumption 관계를 활용
  - **Closedness / maximality**: CloseGraph 스타일의 closed GDL pattern 개념 도입
  - **Symmetry breaking**: GraphZero 계열의 자동 동형성 제거 기법 적용
- **Essential-only mining**: PL4XGL의 관찰에 따르면 실제로 classification에 사용된 program은 전체 합성된 program의 **~5%** 에 불과하며, 이 때문에 training이 매우 비효율적이다 (MUTAG, Pubmed 등) [PL4XGL §7]. GDL mining은 처음부터 essential program만 효율적으로 찾는 방향이 주요 연구 과제

### (3) 패턴 품질 평가 및 선택
- **Coverage**: 데이터셋을 얼마나 설명하는가
- **Diversity**: 패턴 간 semantic overlap (예: pairwise Jaccard diversity)
- **Precision / Discriminativeness**: label이 있는 경우 특정 클래스에 대한 판별력
- **Interpretability**: 패턴 크기, interval 폭 등 사람이 읽기 쉬운 정도

### (4) 확장성
- Interval을 포함한 매칭은 순수 subgraph isomorphism보다 검사 공간이 커질 수 있음 → 효율적인 indexing, canonical form, 병렬화 기법 설계 필요
- **Approximate mode**: ASAP / Arya 계열의 color-coding + neighborhood sampling을 interval 패턴으로 확장하여 $(\varepsilon, \delta)$ 보장
- **Systems 수준 최적화**: AutoMine 스타일 query-to-code compilation, Pangolin 스타일 GPU 병렬화 고려

## 4. 후보 벤치마크 (Candidate Benchmarks)

### Graph-level 패턴 평가 (graph classification 데이터셋)
- **MUTAG, PTC (MR), NCI1, NCI109, Mutagenicity, BBBP, BACE, PROTEINS, DD, ENZYMES** — TUDataset의 대표 분자/단백질 그래프
- **OGB-MolHIV, OGB-MolPCBA, ZINC** — OGB[Hu et al., NeurIPS 2020] 대규모 분자 벤치마크
- **HIV** — PL4XGL이 training timeout으로 실패한 대규모 분자 데이터, 확장성 검증에 적합

### Node-level 패턴 평가 (node classification 데이터셋)
- **BA-Shapes, Tree-Cycles** [Ying et al., NeurIPS 2019] — 합성 데이터, 명시된 motif로 mining 정확성 평가. PL4XGL의 `[12, ∞]`-like degree 패턴이 실제로 발견되는지 검증
- **Wisconsin, Texas, Cornell** — 웹페이지 heterophilic 데이터
- **Cora, Citeseer, Pubmed** — citation network. PL4XGL이 **homophily를 기술하지 못해** 정확도가 낮았던 데이터 → 더 표현력 있는 GDL 확장의 평가 대상
- **BA-2Motifs** — motif가 명확히 정의되어 있어 mining 정확성 평가에 적합

### Frequent subgraph mining 전통 벤치마크
- **Mico, Patents, Youtube, CiteSeer, Yeast** — Arabesque / Peregrine / GraphPi 등에서 공통으로 사용되는 단일 대형 그래프
- **AIDS, DBLP, Cora** — classical FSM 논문들의 벤치마크
- **PubChem, ChEMBL** — 수백만~수천만 규모의 분자 그래프 집합, 확장성 검증용
- **LDBC Social Network Benchmark (SNB)** [Erling et al., SIGMOD 2015] — 그래프 DB/질의 표준 벤치마크
- **GMark** [Bagan et al., TKDE 2016] — schema-constrained 패턴 벤치마크
- **GraphChallenge** (MIT LL) — 시스템 성능 비교용 표준

### 소셜 / 웹 대규모 그래프 (확장성 평가)
- **SNAP**: LiveJournal, Orkut, Friendster, Pokec, Reddit
- **OGBN-Arxiv / Products / Papers100M**

### 프로그램 분석 / 보안
- **Devign** [Zhou et al., NeurIPS 2019] — C 취약점 탐지용 code property graph
- **Big-Vul** [Fan et al., MSR 2020], **Reveal** [Chakraborty et al., TSE 2022], **VulDeePecker** [Li et al., NDSS 2018]
- **Joern / CPG** [Yamaguchi et al., S&P 2014] — 소스 코드의 그래프 표현
- **Android malware call-graph datasets** — call graph 상의 악성 패턴
- *이 도메인은 토큰 수, 복잡도, 라인 수 등 수치형 feature가 풍부하여 GDL의 interval 술어가 특히 유용*

### 사기 / 금융
- **Elliptic Bitcoin** [Weber et al., KDD AML Workshop 2019]
- **YelpChi** [Rayana & Akoglu, KDD 2015], **Amazon Fraud**, **DGraph-Fin** [Huang et al., NeurIPS 2022]
- **AML synthetic** [Altman et al., NeurIPS 2023] — 거래 금액 구간 등 interval 기반 패턴이 자연스러움

## 5. 후보 베이스라인 (Candidate Baselines)

### 5.1 Classical Frequent Subgraph Mining
- **AGM** [Inokuchi, Washio & Motoda, PKDD 2000] — 최초의 Apriori 기반 induced subgraph mining
- **FSG** [Kuramochi & Karypis, ICDM 2001] — level-wise join, canonical adjacency matrix
- **gSpan** [Yan & Han, ICDM 2002] — DFS code + rightmost extension, candidate-generation-free의 고전
- **CloseGraph** [Yan & Han, KDD 2003] — closed frequent subgraph mining
- **FFSM** [Huan, Wang & Prins, ICDM 2003] — canonical adjacency matrix + join/extend
- **Gaston** [Nijssen & Kok, KDD 2004] — path → tree → cyclic graph 단계적 마이닝
- **MoFa** [Borgelt & Berthold, ICDM 2002] — 분자 그래프 특화 fragment mining

### 5.2 Scalable / Parallel / Distributed Systems
- **Arabesque** [Teixeira et al., SOSP 2015] — "think-like-an-embedding" 분산 마이닝 시스템의 효시
- **RStream** [Wang et al., OSDI 2018] — out-of-core relational-algebra 기반 마이닝
- **Fractal** [Dias et al., SIGMOD 2019] — DAG 기반 동적 load balancing
- **AutoMine** [Mawhirter & Wu, SOSP 2019] — pattern query를 set-intersection 코드로 컴파일
- **Peregrine** [Jamshidi, Mahadasa & Vora, EuroSys 2020] — pattern-aware symmetry breaking + matching order planning (**가장 중요한 modern baseline**)
- **Pangolin** [Chen et al., VLDB 2020] — CPU/GPU 공유 메모리 pattern mining
- **GraphZero** [Mawhirter et al., MICRO 2021] — 군론 기반 자동 symmetry breaking
- **GraphPi** [Shi et al., SC 2020] — matching-order 최적화 + 2-cycle redundancy 제거, 최고 속도
- **Sandslash** [Chen, Prountzos et al., ICS 2021] — FSM/motif/clique/k-truss를 통합하는 프로그래밍 프레임워크
- **GraphINC** [Hussein et al., SIGMOD 2023] — 동적/스트리밍 그래프에서의 incremental mining
- **GraphMini / G2Miner / SumPA** (2022–2023) — plan reuse, partial aggregation 기반 최신 시스템

### 5.3 Approximate & Sampling-Based Mining
- **ASAP** [Iyer et al., OSDI 2018] — neighborhood sampling + error-latency profile, approximate mining의 표준
- **Arya** [Arpaci-Dusseau, Iyer et al., arXiv 2405.03488, 2024] — 임의 패턴에 대한 $(\varepsilon, \delta)$ 보장 마이닝, ASAP의 일반화
- **Motivo** [Bressan, Leucci, Panconesi, VLDB 2019] — color-coding 기반 billion-edge 스케일 motif counting
- **MOSS-5** [Wang et al., IEEE TKDE 2018] — 5-node graphlet sampling
- **GUISE / MFinder** [Bhuiyan et al. 2012; Rahman et al. 2014] — uniform graphlet sampling 계열
- **Random-walk graphlet estimation** [Chen & Lui, 2016]

### 5.4 Motif / Graphlet Counting
- **Network motifs** [Milo et al., *Science* 2002] — motif 개념의 효시, 통계적 over-representation
- **ESU / FANMOD** [Wernicke, Bioinformatics 2006] — size-k subgraph를 중복 없이 열거하는 표준 exact motif 도구
- **ORCA** [Hočevar & Demšar, Bioinformatics 2014] — 4-/5-node graphlet orbit counting의 de facto 표준
- **PGD** [Ahmed, Neville, Rossi, Duffield, IEEE TKDE 2016] — 병렬 parameterized graphlet decomposition
- **ESCAPE** [Pinar, Seshadhri, Vishal, WWW 2017] — cut problem 환원 기반 5-node 정확 카운트

### 5.5 Neural / Learning-Based Pattern Mining
- **SPMiner** [Ying, Wang, You, Cannistraci, Leskovec, NeurIPS 2020] — order embedding space에서 subgraph를 임베딩하고 geometric containment로 support 추정 (**가장 중요한 neural baseline**)
- **NeuroMatch** [Ying et al., arXiv 2020] — neural subgraph matching
- **GNN-based subgraph counting** [Chen, Villar, Chen, Bruna, NeurIPS 2020] — "Can GNNs count substructures?", 표현력 한계 분석
- **GSN** [Bouritsas et al., IEEE TPAMI 2023] — substructure-aware GNN
- **ID-GNN** [You et al., AAAI 2021], **Labeling Trick** [Zhang et al.] — subgraph-aware GNN 표현

### 5.6 Pattern Languages Beyond Plain Subgraphs (**GDL과 가장 밀접**)
- **Cypher** [Francis et al., SIGMOD 2018] — property graph 질의 언어, `WHERE n.age > 30 AND n.age < 50`과 같은 범위 술어 지원. 산업 표준에 가장 근접한 analog
- **GQL** [ISO/IEC 39075:2024; SIGMOD 2022] — Cypher/PGQL/GSQL을 통합한 국제 표준 property graph 질의 언어
- **SPARQL 1.1** [W3C Recommendation 2013] — RDF graph에서 FILTER를 통한 값 범위 제약
- **RPQ / CRPQ** — regex on edges, DB 이론의 계보
- **PGQL** [van Rest et al., GRADES 2016] — Oracle property graph 질의 언어

### 5.7 Constraint-Based / Quantitative Mining (**GDL의 prior art**)
- **gPrune** [Zhu, Yan, Han, Yu, VLDB 2007] — 구조적/aggregate 제약을 FSM에 push (GDL의 직접적 선행 연구)
- **Cocain / Moser et al.** — weight/range 제약이 있는 패턴 마이닝
- **Weighted / Quantitative FSM** [Jiang, Coenen, Zito, 2013; Shelokar et al., 2014] — 수치 label을 다루지만 주로 discretize 기반
- **SUBDUE** [Holder & Cook, 1994–2009] — 변수를 포함하는 abstract 패턴의 역사적 선행 연구

### 5.8 GDL/Declarative 기반 (직접 비교 대상)
- **PL4XGL** [Jeon, Park, Oh, *PLDI 2024*] — GDL 언어의 원출처. top-down(specialization)과 bottom-up(generalization) **program synthesis** 알고리즘으로 candidate GDL program을 생성하고, $(label, program, score)$ 튜플 집합을 분류 모델로 사용. 관찰:
  - GDL은 subgraph보다 **엄격히 더 표현력이 강함** (§7.2, §8); `[12, ∞] — [-∞, ∞] — [12, ∞]`가 BA graph 노드를 precision 99%, recall 97%로 기술
  - 저자들이 "GDL can be employed in graph data mining" 을 직접 제안 (§8)
  - 그러나 mining이 **classification 목적으로 특화**되어 있고 (per-graph candidate만 생성), **일반 FSM/graph pattern mining의 frequency·support·closedness 개념은 없음**
  - 합성된 program의 ~5%만 실제 사용 → essential-only mining 관점에서 큰 비효율 (§7)
  - 본 연구는 이 공백을 채우는 것을 목표로 함

### 5.9 벤치마크·서베이 참고
- **TUDataset** [Morris et al., 2020]
- **OGB** [Hu et al., NeurIPS 2020]
- **Ribeiro et al., "A Survey on Subgraph Counting"** ACM CSUR 2021 — 40쪽 분량 taxonomy
- **Jamshidi et al., "A Survey of Parallel Graph Mining Systems"** arXiv 2022
- **Rehman et al., "Frequent Subgraph Mining Algorithms: A Survey"** JPDC 2021
- **Abdelhamid et al., "Graph Pattern Mining: A Survey of Issues and Approaches"** ACM CSUR 2017
- **Besta et al., "Graph Databases and Knowledge Graphs: A Survey"** ACM CSUR 2023

### 평가 지표
- **Coverage / Support**: 데이터셋의 몇 %를 설명하는가
- **Diversity (pairwise Jaccard)**: 중복 최소화 달성 여부
- **Compression ratio**: subgraph 대비 얼마나 적은 수의 패턴으로 같은 현상을 설명하는가
- **Downstream task accuracy**: 발견된 패턴을 feature로 사용한 classification 정확도
- **Runtime / Scalability**: 대규모 그래프에서의 실행 시간과 메모리 (Peregrine/GraphPi 비교)
- **Approximation error**: $(\varepsilon, \delta)$ 보장 모드의 실측 오차 (ASAP/Arya 비교)
- **Interpretability**: 도메인 전문가 평가 또는 패턴 크기·구간 폭 등의 proxy 지표

---

## 연구 지형 요약 (Research Landscape Summary)

선행 연구는 대체로 다음 세 축 중 하나에 속한다.

| 축 | 대표 연구 | 한계 |
|---|---|---|
| (a) 구조 중심 exact mining | gSpan, Peregrine, GraphPi, AutoMine | discrete label만, 값 범위 불가 |
| (b) 풍부한 술어 querying | Cypher, GQL, SPARQL | 자동 mining 부재 |
| (c) 제약 기반 mining | gPrune, weighted FSM | 연속 feature interval native 미지원 |
| (d) Approximate mining | ASAP, Arya, Motivo | 주로 counting, pattern language는 subgraph |
| (e) Neural mining | SPMiner, NeuroMatch | discrete label 중심, 해석성 제한 |
| (f) GDL symbolic classification | PL4XGL | classification 전용, 일반 mining(frequency/support/closedness) 개념 없음, 합성 비효율 |

**GDL 기반 mining은 (a)·(b)·(c)의 교집합**에 해당하는 영역을 겨냥한다: declarative한 interval 술어를 first-class로 다루면서 자동 패턴 발견을 수행하는 마이닝. 이는 현재 literature에서 뚜렷한 공백으로 남아 있으며 — PL4XGL 저자들이 직접 방향 제시 — 자연스러운 비교 기준은 **Peregrine/GraphPi (exact structural), Arya/ASAP (approximate), SPMiner (neural), PL4XGL (GDL symbolic)** 이다.

### GDL 확장 방향
PL4XGL §7의 한계는 그대로 GDL 기반 mining에도 확장 필요성을 시사한다.

- **Homophily / heterophily 기술**: citation network에서 PL4XGL이 정확도 하락을 보인 핵심 원인 — 현재 GDL은 "이웃 노드의 label 분포"와 같은 관계적 속성을 표현하지 못함
- **Aggregate 술어**: "oxygen 개수 > chlorine 개수", "이웃 degree 합 ≥ k" 등 집계 기반 패턴
- **Recursive / path 패턴**: regular path queries (RPQ) 스타일의 경로 술어
- **수치 비교**: 두 노드 변수 간 feature 값 비교 (`x.f ≤ y.f`)
