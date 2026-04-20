# 대규모 그래프를 위한 확장 가능한 PL4XGL (Scalable PL4XGL for Very Large Graphs)

## 1. 문제 (Problem)

PL4XGL [Jeon, Park, Oh, *PLDI 2024*]은 GDL(Graph Description Language)로 작성된 program들의 집합 $M \subseteq L \times P \times [0,1]$ 을 분류 모델로 사용하는 **symbolic, inherently interpretable** 그래프 학습 기법이다. 분류·설명의 **Fidelity = 0** 을 구조적으로 보장 (Theorem 6.1)하고, 설명 생성 비용이 0이며, 작은 데이터셋(MUTAG, BBBP, BACE, Tree-Cycles 등)에서 경쟁력 있는 정확도를 보인다.

그러나 **대규모 그래프 데이터**로 오면 심각한 확장성 문제가 드러난다. 실제 PL4XGL 논문의 Table 2가 이를 그대로 보여준다.

- **Training timeout**: HIV(41,127 분자) 데이터에서 2일의 training 예산 내에 학습을 끝내지 못함
- **Classification 병목**: Pubmed(19,717 노드)에서 분류 시간이 17분 — baseline GNN 대비 **170배** 느림
- **Training 비용 급증**: Pubmed에서 training 2,702.9분 (약 45시간), Citeseer 245.2분
- **프로그램 폭발 / 낭비**: 모델이 생성한 GDL program 중 실제 분류에 쓰이는 것은 **~5%에 불과** (§7.2) — 나머지 95%는 합성·저장·매칭 비용만 유발

구조적 원인은 다음과 같다.

1. **Per-instance greedy synthesis**: 각 training 데이터 $(\gamma_i, y_i)$ 마다 top-down 또는 bottom-up synthesis를 독립적으로 수행. 전체 비용이 $|T|$ 에 선형 이상으로 증가하며, 유사 패턴이 중복 합성됨
2. **Mutate$_k$ 의 지수적 탐색**: 깊이 $k$ 에서 mutated program 수가 지수적으로 증가. $k=3$이면 합성 질은 좋지만 대규모에서 불가
3. **매칭 비용**: GDL program을 그래프에 맞춰보는 것은 subgraph isomorphism + interval 검사. Subgraph isomorphism은 NP-complete이고, interval 제약으로 인해 후보 매칭 집합이 더 커질 수 있음
4. **Classification도 선형 탐색**: 분류 시 모든 candidate program을 입력 그래프에 매칭해 best-scored program을 찾음. 모델이 클수록(대규모 데이터일수록) 느려짐
5. **병렬화 부재**: 저자들이 언급했듯 synthesize 자체는 per-instance 독립이라 병렬화 가능하지만, 공식 구현은 순차적이며 대규모 분산 실행은 검증된 바 없음
6. **메모리 footprint**: feature 차원이 큰 데이터(Cora 1433, Citeseer 3703 dim)에서는 interval vector의 곱 공간이 폭발

이러한 한계 때문에 PL4XGL은 (a) 수만~수억 노드 규모의 OGB·SNAP 데이터, (b) 산업적 분자 라이브러리(ChEMBL, PubChem), (c) 대규모 프로그램 분석 그래프(전체 Linux kernel CPG 등) 등 **실제 의사결정이 일어나는 스케일**에서 활용되지 못한다.

## 2. 목표 (Goal)

PL4XGL의 **설명 가능성 보장(Fidelity = 0, 설명 비용 0, GDL의 해석성)** 을 유지하면서, **수십만~수억 노드 규모**의 그래프 데이터에 적용 가능한 확장 가능한 PL4XGL을 설계한다.

- **Training 확장성**: HIV(41K 분자), OGB-MolPCBA(~400K 분자), ogbn-arxiv(170K 노드), ogbn-products(2.4M 노드) 등에서 **합리적 시간**(e.g., 수시간 ~ 1일) 내 학습 완료
- **Classification 확장성**: 분류 cost가 그래프 크기와 모델 크기에 대해 준선형(near-linear)이어야 함. 이상적으로는 baseline GNN 대비 10× 이내
- **설명 품질 보존**: Fidelity = 0 구조적 보장 유지, Sparsity와 정확도 저하 ≤ 5%
- **메모리 효율**: 고차원 feature 데이터에서도 $O(|Q| \cdot d)$ 수준의 feature 공간 유지
- **분산/병렬 실행**: 멀티 노드, 멀티 GPU 환경에서 수평 확장

## 3. 기본 접근 방법 (Basic Approach)

확장성은 단일 기법이 아닌 **시스템 수준의 복합 최적화**로 달성된다. 다음 축을 조합한다.

### (1) Essential-only program synthesis
- PL4XGL이 합성한 program 중 ~5%만 분류에 기여한다는 관찰 → **처음부터 essential program만 합성**
- **Coverage-aware pruning**: 이미 covered된 training 인스턴스를 다시 covering하는 program 생성 억제 (ProgNet vocabulary construction 수식을 synthesis에 내장)
- **Subsumption-aware caching**: 새로 합성된 program $P$가 기존 모델의 어느 program $P'$에 subsumed($P' \sqsupseteq P$) 되는지 확인해 중복 저장 방지
- **Beam search + early termination**: top-down/bottom-up에서 beam $B$ 유지, quality gain이 $\epsilon$ 이하이면 중단
- **Mutate$_k$ 동적 깊이**: 인스턴스 복잡도에 따라 $k$를 조절 (작은 분자 → $k=3$, 대형 단일 그래프 → $k=1$)

### (2) Batched / vectorized matching
- GDL program 매칭을 **배치화**: 여러 그래프에 대해 동일 program을 동시에 검사 (GPU 친화)
- **Interval subsumption index**: interval vector를 R-tree / 차원별 B+tree로 인덱싱하여 candidate node 집합을 빠르게 필터
- **Canonical labeling + hash**: subgraph isomorphism 전에 canonical labeling으로 불일치 조기 컷오프
- **VF2 / RI / Glasgow subgraph solver**를 interval-aware로 확장

### (3) Parallel & distributed synthesis
- **Per-instance parallelism**: synthesis는 인스턴스 단위 독립이라는 점을 전면 활용 (MapReduce / Ray / Dask)
- **데이터 샤딩**: training set을 shard로 나누고 local model을 합성 후 **merge** (coverage-respecting union + subsumption elimination)
- **GPU kernel**: interval containment는 단순 비교라 SIMD/GPU 친화. subgraph isomorphism 부분만 CPU로 offload

### (4) Approximate synthesis with guarantees
- **$(\varepsilon, \delta)$-approximate PL4XGL**: Quality score 추정을 random sampling으로 대체 (ASAP / Arya 스타일)
  - Training 인스턴스의 부분집합에서 score 추정 → 오차 $\varepsilon$, 실패확률 $\delta$ 보장
- **Color-coding / neighborhood sampling**: subgraph isomorphism 매칭을 근사
- **점진적(progressive) 정밀화**: 먼저 빠른 근사로 후보군을 줄이고 선택된 program만 정확 매칭

### (5) Incremental / streaming PL4XGL
- 새 데이터가 들어올 때 전체 재합성 없이 **delta update** (추가 인스턴스에 대한 program만 추가/수정)
- 동적 그래프(GraphINC 스타일)에서 node/edge 삽입 시 affected program만 재검사

### (6) Program library pre-training
- 분야별(화학 / 생물 / 코드 / 금융) 일반적 GDL program 라이브러리를 미리 합성해 두고, 신규 task에서는 이 라이브러리로 **transfer** + 소수 task-specific program만 추가 합성
- 이를 통해 per-task synthesis 비용을 대폭 절감

### (7) 정확 classification path의 가속
- **Program trie / discrimination tree**: 활성화 가능한 program 후보를 tree로 조직, 입력 그래프에서 불필요한 매칭 방지
- **Label-wise 우선 탐색**: 각 label에서 quality score 상위 $K$개 program만 먼저 검사하여 조기 결정
- **Lazy matching**: best-scored program이 이미 확정되면 나머지 매칭 생략

## 4. 후보 벤치마크 (Candidate Benchmarks)

### PL4XGL이 이미 실패/고비용인 데이터 (직접 개선 타겟)
- **HIV** (41,127 분자) — PL4XGL training timeout (>2일)
- **Pubmed** (19,717 노드) — PL4XGL classification 170× 느림, training 45시간
- **Citeseer, Cora** — training 분 단위로 느림

### 대규모 분자 / 화학 정보
- **OGB-MolHIV, OGB-MolPCBA** [Hu et al., NeurIPS 2020] — 400K+ 분자
- **ChEMBL, PubChem** — 수백만~수천만 분자, 산업 규모
- **ZINC-250K, ZINC-full** — 대규모 약물 후보

### 대규모 노드 분류
- **ogbn-arxiv** (170K 노드, 1.2M 엣지)
- **ogbn-products** (2.4M 노드, 61M 엣지)
- **ogbn-papers100M** (111M 노드, 1.6B 엣지) — 초대형 스케일 스트레스 테스트
- **Reddit** (232K 노드), **Yelp** (716K 노드)

### 대규모 단일 그래프 / 산업 스케일
- **SNAP**: LiveJournal (4.8M 노드), Orkut (3M 노드), Friendster (65M 노드)
- **LDBC SNB SF100 / SF1000** — 그래프 DB 표준 스케일 팩터
- **Amazon, Alibaba, Pinterest** 공개 그래프

### 프로그램 분석 / 보안 (실 규모)
- **Big-Vul full** [Fan et al., MSR 2020], **Devign full** — 수십만 함수 규모 CPG
- **Android malware** 전체 마켓 스케일 call graph

### 합성 / 확장성 전용
- **GMark** [Bagan et al., TKDE 2016] — 임의 스케일 property graph 생성
- **RMAT** — 임의 크기 power-law graph

## 5. 후보 베이스라인 (Candidate Baselines)

### 5.1 원본 PL4XGL (절대 비교 기준)
- **PL4XGL** [Jeon, Park, Oh, *PLDI 2024*] — top-down / bottom-up greedy synthesis, per-instance 순차 실행
- **PL4XGL + Mutate$_k$ (k=1..8)** — 논문 Table 6에서 보인 tradeoff 확인

### 5.2 대규모 FSM / graph pattern mining 시스템 (systems 성능 비교)
- **Arabesque** [Teixeira et al., SOSP 2015]
- **Peregrine** [Jamshidi, Mahadasa, Vora, EuroSys 2020] — pattern-aware + symmetry breaking
- **AutoMine** [Mawhirter & Wu, SOSP 2019] — query-to-code compilation
- **Pangolin** [Chen et al., VLDB 2020] — CPU/GPU 공유 메모리
- **GraphZero / GraphPi** [Mawhirter et al., MICRO 2021; Shi et al., SC 2020]
- **Sandslash** [Chen, Prountzos et al., ICS 2021]
- **RStream** [Wang et al., OSDI 2018] — out-of-core

### 5.3 Approximate / sampling 기반 마이닝
- **ASAP** [Iyer et al., OSDI 2018] — neighborhood sampling, error-latency profile
- **Arya** [Arpaci-Dusseau et al., arXiv 2024] — 임의 패턴 $(\varepsilon, \delta)$ 보장
- **Motivo** [Bressan, Leucci, Panconesi, VLDB 2019] — billion-edge motif counting
- **MOSS-5** [Wang et al., TKDE 2018]

### 5.4 Scalable subgraph isomorphism solver
- **VF2++** [Jüttner & Madarasi, 2018]
- **RI / GraphQL** [Bonnici et al., BMC Bioinformatics 2013]
- **Glasgow Subgraph Solver** [McCreesh et al., 2018]
- **DAF** [Han et al., SIGMOD 2019]
- **CFL, CECI** — 대규모 subgraph matching

### 5.5 Scalable GNN (PL4XGL이 따라잡아야 할 성능 baseline)
- **GraphSAGE** [Hamilton, Ying, Leskovec, NeurIPS 2017] — neighbor sampling
- **ClusterGCN** [Chiang et al., KDD 2019] — graph partitioning
- **GraphSAINT** [Zeng et al., ICLR 2020] — subgraph sampling
- **ShaDow-GNN** [Zeng et al., NeurIPS 2021] — localized subgraph
- **GNN Autoscale / GNNAutoScale** [Fey et al., ICML 2021]
- **PinSAGE** [Ying et al., KDD 2018]

### 5.6 Incremental / streaming graph systems
- **GraphINC** [Hussein et al., SIGMOD 2023] — incremental pattern mining
- **Kineograph, Chronos** — temporal graph systems

### 5.7 Program synthesis 확장성 기법 (일반 PL 기법)
- **Conflict-driven learning** (CDCL in program synthesis)
- **Version space algebra** [Mitchell 1982; Lau et al. 2003] — generality lattice에서의 효율적 탐색
- **Anti-unification** [Plotkin 1970] — bottom-up generalization의 이론적 기반
- **EUSolver / Duet** — SyGuS 대규모 솔버

### 평가 지표
- **Training time** (분/시간)
- **Classification time per graph / per node** (ms)
- **Memory footprint** (GB)
- **Accuracy vs. 원본 PL4XGL** (허용 오차 ≤ 5%)
- **Fidelity** (원본은 구조적으로 0; 근사 모드에서는 실측)
- **Sparsity** (설명 크기 유지)
- **Scale ceiling**: 처리 가능한 최대 그래프 크기 (노드 수, 엣지 수)
- **Speedup**: baseline 대비 배수
- **Approximation error**: $(\varepsilon, \delta)$ 모드의 실측 오차

---

## 연구 지형 요약 (Research Landscape Summary)

| 축 | 대표 연구 | 본 연구와의 관계 |
|---|---|---|
| Symbolic graph learning | PL4XGL | **개선 대상** — 정확성·해석성은 유지 |
| Scalable FSM systems | Peregrine, GraphPi, AutoMine | synthesis/matching 시스템 기법 차용 |
| Approximate mining | ASAP, Arya, Motivo | $(\varepsilon, \delta)$ 보장 모드 설계 |
| Subgraph iso solver | VF2++, Glasgow, DAF | interval-aware 확장 필요 |
| Scalable GNN | GraphSAGE, ClusterGCN, GraphSAINT | 목표 성능 비교군 |
| Program synthesis | Version space, anti-unification | synthesis 알고리즘의 이론적 기반 |

**확장 가능한 PL4XGL**은 (a) program synthesis의 PL 기법, (b) graph pattern mining의 systems 기법, (c) subgraph isomorphism의 DB 기법, (d) approximate computing의 보장 기법을 **교차 활용**해야 한다. 특히 PL4XGL 저자들이 §7에서 직접 지적한 **"essential program만 retain하여 training/classification 비용을 대폭 절감"** 이라는 방향이 가장 명확한 출발점이며, 본 연구의 핵심 기여가 될 수 있다.
