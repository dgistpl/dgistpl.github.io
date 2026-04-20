# 트랜스덕티브 그래프 학습을 위한 PL4XGL (PL4XGL for Transductive Graph Learning)

## 1. 문제 (Problem)

**트랜스덕티브 그래프 학습(Transductive Graph Learning)** 은 단일 그래프 내에서 일부 노드의 label만 관측된 상태에서 나머지 노드의 label을 예측하는 문제이다. 학습 시 **unlabeled 노드의 feature와 그래프 구조 전체**를 활용할 수 있다는 점이 inductive learning과의 핵심 차이이다. Cora, Citeseer, Pubmed 등 citation network에서의 노드 분류가 대표적이며, GCN [Kipf & Welling, ICLR 2017], GAT [Veličković et al., ICLR 2018] 등 대부분의 GNN은 transductive 설정에서 설계·평가되었다. GNN의 message passing은 본질적으로 transductive이다 — labeled 노드의 정보가 edge를 따라 unlabeled 노드로 전파되므로, **전체 그래프 구조가 학습의 일부**가 된다.

PL4XGL [Jeon, Park, Oh, *PLDI 2024*]은 GDL(Graph Description Language) program으로 구성된 symbolic 분류기 $M \subseteq L \times P \times [0,1]$ 를 학습하는 **해석 가능한 그래프 학습** 기법이다. Fidelity = 0을 구조적으로 보장하고(Theorem 6.1), 설명이 분류의 직접적 근거와 일치하는 강한 해석 가능성을 가진다. 그러나 PL4XGL은 **본질적으로 inductive 방식**으로 설계되어 있으며, transductive 설정에서 심각한 한계를 드러낸다.

### PL4XGL의 transductive 학습 한계

1. **Per-instance 독립 합성**: PL4XGL의 program synthesis는 각 training 인스턴스 $(\gamma_i, y_i)$ 에 대해 독립적으로 수행된다. 노드 $v$의 program을 합성할 때 $v$의 **ego-subgraph** 만 참조하며, $v$와 연결된 unlabeled 노드들의 구조적·feature 정보를 활용하지 않는다. 즉 transductive learning의 핵심인 **"unlabeled 노드를 통한 정보 전파"** 가 원천적으로 차단된다.

2. **Homophily 미기술**: PL4XGL 저자들이 §7.1에서 직접 지적하였듯이, 현재 GDL은 **이웃 노드의 label 분포**를 기술하지 못한다. Citation network에서는 homophily — 연결된 노드들이 동일한 label을 가지는 경향 — 가 분류의 가장 강력한 단서이지만, GDL program은 이를 표현할 수 없다. 그 결과 Cora에서 accuracy 68.9% (GCN 81.5%), Citeseer에서 59.3% (GCN 70.3%), Pubmed에서 73.2% (GCN 79.0%)로, GNN 대비 **10~15%p 낮은 정확도**를 보인다 [PL4XGL Table 2].

3. **Label propagation 부재**: Label propagation [Zhu, Ghahramani & Lafferty, ICML 2003], label spreading [Zhou et al., NeurIPS 2003] 등 classical transductive 기법은 labeled 노드의 정보를 그래프 구조를 따라 확산시킨다. GNN의 message passing도 동일한 원리를 학습 가능한 형태로 구현한다. PL4XGL에는 이에 대응하는 메커니즘이 없다.

4. **Graph topology 활용 부재**: Transductive 설정에서는 **전체 그래프의 위상적 특성** (degree 분포, community 구조, spectral 속성 등)이 강력한 학습 신호이다. PL4XGL의 ego-subgraph 기반 합성은 $k$-hop 이내의 local 구조만 포착하며, global topology를 반영하지 못한다. 특히 long-range dependency가 중요한 heterophilic graph (Wisconsin, Texas, Cornell)에서 이 한계가 더 두드러진다.

5. **Semi-supervised 학습 미지원**: Transductive 노드 분류의 표준 프로토콜은 극소수(클래스당 20~140개)의 labeled 노드만 사용하는 semi-supervised 설정이다. PL4XGL의 per-instance synthesis는 각 labeled 인스턴스에서 독립적으로 program을 합성하므로, label이 적을 때 합성된 program의 **quality와 coverage가 급격히 저하**된다. GNN은 message passing을 통해 소수의 label 정보를 전체 그래프로 확산시키지만, PL4XGL에는 이러한 확산 경로가 없다.

6. **Training 비효율**: Pubmed(19,717 노드)에서 training 45시간, classification이 GNN 대비 170× 느림 [PL4XGL Table 2]. Transductive 설정의 대규모 단일 그래프에서는 이 비효율이 더욱 심화된다.

### 연구 공백

GNN 기반 transductive learning은 높은 정확도를 달성하지만 **black-box**이다. GNN 설명 기법(GNNExplainer, SubgraphX 등)은 post-hoc이며 faithfulness 보장이 없다. 반면 PL4XGL은 **Fidelity = 0의 구조적 보장**을 가지지만 transductive 설정에 적합하지 않다.

즉 **"transductive 그래프 학습에서 inherently interpretable하면서도 GNN 수준의 정확도를 달성하는 방법"** 은 현재 부재하다. PL4XGL의 해석 가능성 보장을 유지하면서 transductive learning의 핵심 원리 — unlabeled 데이터 활용, label propagation, global topology 반영 — 를 통합하는 것이 이 공백을 메우는 방향이다.

## 2. 목표 (Goal)

PL4XGL의 **해석 가능성 보장(Fidelity = 0, GDL의 human-readable 설명)** 을 유지하면서, **transductive 그래프 학습 설정**에서 GNN 수준의 정확도를 달성하는 프레임워크를 설계한다.

- **Transductive 정확도**: Cora, Citeseer, Pubmed 등 표준 citation network에서 GCN/GAT 수준의 accuracy 달성 (현재 PL4XGL 대비 10~15%p 향상)
- **해석 가능성 보존**: 예측의 근거가 GDL program으로 명시적으로 제시되어, Fidelity = 0 또는 이에 근접한 보장 유지
- **Unlabeled 노드 활용**: 전체 그래프 구조와 unlabeled 노드의 feature를 program synthesis 및 classification에 적극 활용
- **Homophily / heterophily 기술**: 이웃 label 분포, 이웃 feature 통계 등 관계적 속성을 GDL 언어 수준에서 표현 가능하도록 확장
- **Semi-supervised 효율성**: 클래스당 20개 수준의 극소수 label에서도 효과적인 program 합성
- **확장성**: 수만~수십만 노드의 단일 그래프에서 합리적 시간 내 학습·추론

## 3. 기본 접근 방법 (Basic Approach)

### (1) GDL 언어 확장: 관계적·집계 술어

PL4XGL §7.1이 지적한 표현력 한계를 해결하기 위해 GDL 언어를 확장한다.

- **Homophily 술어**: `homo(x, f, [lb, ub])` — 노드 $x$의 이웃 중 feature $f$가 $x$와 동일한 비율이 $[\text{lb}, \text{ub}]$ 구간에 속하는지 검사. Citation network에서 "같은 분야의 논문이 이웃의 70% 이상"과 같은 패턴 기술
- **Aggregate 술어**: `agg(x, f, op, [lb, ub])` — 노드 $x$의 이웃에 대해 feature $f$의 집계값($\text{op} \in \{\text{mean}, \text{sum}, \text{max}, \text{min}, \text{count}\}$)이 구간 $[\text{lb}, \text{ub}]$에 속하는지 검사. "이웃 degree의 평균이 5 이상", "oxygen 이웃 수 > chlorine 이웃 수" 등의 패턴
- **$k$-hop 확장**: `khop(x, k, f, op, [lb, ub])` — $k$-hop 이웃까지 확장한 aggregate. Long-range dependency 포착
- **Label distribution 술어 (transductive 전용)**: `ldist(x, c, [lb, ub])` — 노드 $x$의 이웃 중 label $c$를 가진 (labeled) 노드의 비율이 $[\text{lb}, \text{ub}]$인지 검사. **Transductive 설정에서만 의미** — unlabeled 노드의 이웃에 있는 labeled 노드 정보를 직접 활용

**표현력 보존**: 확장된 GDL은 기존 GDL을 subsume하며, 추가된 술어들은 기존 의미론과 일관되게 interval 기반으로 정의된다.

### (2) Transductive program synthesis

기존 PL4XGL의 per-instance 독립 합성을 transductive 설정에 맞게 재설계한다.

- **Graph-aware candidate generation**: Labeled 노드의 ego-subgraph뿐 아니라, **unlabeled 이웃 노드의 구조와 feature**도 program 합성 시 참조. 예를 들어 labeled 노드 $v$와 연결된 unlabeled 노드 $u$의 feature 패턴이 $v$의 classification에 기여하는 program으로 합성될 수 있음
- **Label-propagation-guided synthesis**: 먼저 classical label propagation으로 soft pseudo-label을 모든 노드에 할당한 뒤, 이를 **synthesis의 가이드**로 사용. Pseudo-label 분포가 유사한 노드 군집에서 공통 program을 합성하여 coverage를 극대화
- **Iterative synthesis-propagation loop**:
  1. 초기: labeled 노드에서 GDL program 합성
  2. 합성된 program으로 unlabeled 노드에 tentative label 부여
  3. 높은 confidence의 tentative label을 가진 노드를 추가 labeled set에 포함
  4. 확장된 labeled set에서 program 재합성
  5. 수렴 또는 budget 소진까지 반복
- **Co-training 스타일**: 서로 다른 view의 program 집합(예: topology 중심 vs. feature 중심)을 독립적으로 합성하고, 각 view가 높은 confidence로 예측한 unlabeled 노드를 상대 view의 training set에 추가

### (3) Graph structure-aware classification

분류 단계에서 그래프 구조를 활용한다.

- **Program activation propagation**: 노드 $v$에서 program $P$의 activation $e_P(v)$를 이웃으로 전파. $\hat{e}_P(v) = (1-\alpha) e_P(v) + \alpha \sum_{u \in \mathcal{N}(v)} \frac{e_P(u)}{|\mathcal{N}(u)|}$ — label propagation과 동일한 원리를 program activation 공간에서 수행
- **Smoothed scoring**: PL4XGL의 best-scored program lookup을 수정하여, 이웃 노드의 program score도 가중 반영. Homophily가 강한 그래프에서 이웃의 classification 근거가 자연스럽게 전파됨
- **Confidence-weighted propagation**: 높은 quality score의 program이 매칭되는 노드의 영향력을 더 크게 반영

### (4) Community-aware synthesis

그래프의 global 구조를 synthesis에 반영한다.

- **Graph partitioning**: Metis, Louvain 등으로 그래프를 community로 분할 → 각 community 내에서 공유되는 GDL program을 합성 (intra-community program)
- **Cross-community program**: community 경계에 걸친 패턴을 기술하는 program 합성 (inter-community program)
- **Hierarchical synthesis**: community → super-community → 전체 그래프의 계층적 program 합성. 다층적 구조를 포착하여 long-range dependency 표현

### (5) Positional / structural encoding의 GDL 통합

GNN에서 사용되는 positional encoding을 GDL 공간으로 가져온다.

- **Spectral position**: Laplacian eigenvector의 값을 노드 feature로 추가 → 기존 GDL의 interval 술어로 자연스럽게 기술 가능. "Fiedler vector 값이 $[0.1, 0.3]$인 노드"와 같은 global position 기반 패턴
- **Random walk structural encoding**: Random walk landing probability를 feature로 추가 → 구조적 역할(hub, bridge, peripheral)을 interval 패턴으로 포착
- **Distance encoding**: Labeled 노드까지의 shortest path distance를 feature로 추가 → transductive 학습에서 "가까운 labeled 노드의 영향" 을 직접 기술

### (6) Fidelity 보장의 확장

확장된 GDL과 transductive 메커니즘 하에서 Fidelity 보장을 재정립한다.

- **강한 보장 (Fidelity = 0)**: Program activation propagation 없이, 확장된 GDL program 자체만으로 분류가 수행되는 모드. PL4XGL의 원래 Theorem 6.1을 확장된 술어에 대해 재증명
- **약한 보장 (bounded Fidelity)**: Propagation을 포함한 모드에서, Fidelity의 상한을 이론적으로 bound. 예: propagation step 수 $T$와 graph conductance에 따른 Fidelity 상한
- **Controllable trade-off**: 사용자가 해석 가능성과 정확도 사이의 trade-off를 명시적으로 제어할 수 있는 knob 제공 (propagation depth, pseudo-label confidence threshold 등)

### (7) 학습 파이프라인

1. **Preprocessing**: Positional/structural encoding 계산 (Laplacian eigenvector, random walk), feature 확장
2. **Initial synthesis**: Labeled 노드에서 확장된 GDL program 합성 (homophily/aggregate 술어 포함)
3. **Label propagation**: Classical LP로 soft pseudo-label 생성
4. **Iterative refinement**: Synthesis-propagation loop (§3-(2))로 program set 확장
5. **Community-aware enrichment**: Community 구조를 반영한 추가 program 합성
6. **Classification**: Program activation + propagation 기반 분류
7. **Explanation**: 예측별 top-k program 제시, 관계적 술어 포함 설명

## 4. 후보 벤치마크 (Candidate Benchmarks)

### Homophilic citation network (PL4XGL이 직접 실패한 데이터 — 핵심 타겟)
- **Cora** (2,708 노드, 5,429 엣지, 7 클래스) — PL4XGL accuracy 68.9% vs. GCN 81.5%
- **Citeseer** (3,327 노드, 4,732 엣지, 6 클래스) — PL4XGL accuracy 59.3% vs. GCN 70.3%
- **Pubmed** (19,717 노드, 44,338 엣지, 3 클래스) — PL4XGL accuracy 73.2% vs. GCN 79.0%, training 45시간

### Heterophilic graph (long-range dependency, GDL 확장의 스트레스 테스트)
- **Wisconsin** (251 노드, 499 엣지, 5 클래스) — heterophily ratio ~0.21
- **Texas** (183 노드, 309 엣지, 5 클래스) — heterophily ratio ~0.11
- **Cornell** (183 노드, 295 엣지, 5 클래스) — heterophily ratio ~0.30
- **Actor** (7,600 노드, 33,544 엣지, 5 클래스) [Pei et al., ICLR 2020]
- **Squirrel, Chameleon** [Rozemberczki et al., 2021] — Wikipedia page graph, heterophilic

### 대규모 transductive 벤치마크 (확장성 평가)
- **ogbn-arxiv** (169,343 노드, 1,166,243 엣지, 40 클래스) [Hu et al., NeurIPS 2020]
- **ogbn-products** (2,449,029 노드, 61,859,140 엣지, 47 클래스) — 대규모 스트레스 테스트
- **Reddit** (232,965 노드, 57,307,946 엣지, 41 클래스) [Hamilton et al., NeurIPS 2017]
- **Flickr** (89,250 노드, 899,756 엣지, 7 클래스)
- **Yelp** (716,847 노드, 6,977,410 엣지, 100 클래스)

### 합성 데이터 (controlled evaluation)
- **BA-Shapes** [Ying et al., NeurIPS 2019] — PL4XGL이 degree 패턴을 precision 99%, recall 97%로 기술. Transductive 설정에서 propagation의 효과 분리 평가
- **Tree-Cycles, Tree-Grids** [Ying et al., NeurIPS 2019]
- **Synthetic homophily/heterophily graphs** — homophily ratio를 연속적으로 변화시키며 robustness 평가
- **CSBM (Contextual Stochastic Block Model)** [Deshpande et al., 2018] — 이론적 분석 가능한 합성 모델

### 프로그램 분석 / 보안 (실용적 transductive 적용)
- **Devign** [Zhou et al., NeurIPS 2019] — C 취약점 탐지 CPG. 동일 프로젝트 내 함수 간 transductive 관계 활용
- **Joern / CPG** [Yamaguchi et al., S&P 2014] — 소스 코드 그래프

### 사기 / 금융 (transductive 설정이 자연스러운 도메인)
- **Elliptic Bitcoin** [Weber et al., 2019] — 시간적 transductive: 과거 labeled 거래로 현재 거래 분류
- **DGraph-Fin** [Huang et al., NeurIPS 2022] — 금융 사기 탐지
- **YelpChi** [Rayana & Akoglu, KDD 2015] — 리뷰 사기 탐지

## 5. 후보 베이스라인 (Candidate Baselines)

### 5.1 원본 PL4XGL (절대 비교 기준)
- **PL4XGL** [Jeon, Park, Oh, *PLDI 2024*] — inductive GDL 합성. Cora 68.9%, Citeseer 59.3%, Pubmed 73.2%. **해석 가능성의 상한, 정확도의 하한** 역할
- **PL4XGL + Mutate$_k$** — mutation 깊이에 따른 성능 변화 확인

### 5.2 Transductive GNN (정확도 목표 기준)
- **GCN** [Kipf & Welling, ICLR 2017] — 가장 기본적인 transductive GNN. Cora 81.5%, Citeseer 70.3%, Pubmed 79.0%
- **GAT** [Veličković et al., ICLR 2018] — attention 기반 neighbor weighting
- **GraphSAGE** [Hamilton, Ying, Leskovec, NeurIPS 2017] — inductive/transductive 모두 지원
- **SGC** [Wu et al., ICML 2019] — simplified GCN, feature propagation만 수행
- **APPNP** [Klicpera, Bojchevski, Günnemann, ICLR 2019] — personalized PageRank 기반 propagation
- **GCNII** [Chen et al., ICML 2020] — deep GCN with initial residual + identity mapping

### 5.3 Classical transductive / semi-supervised 기법
- **Label Propagation (LP)** [Zhu, Ghahramani & Lafferty, ICML 2003] — graph-based semi-supervised learning의 고전
- **Label Spreading** [Zhou et al., NeurIPS 2003] — normalized Laplacian 기반 확산
- **ManiReg** [Belkin, Niyogi & Sindhwani, JMLR 2006] — manifold regularization
- **DeepWalk** [Perozzi, Al-Rfou, Skiena, KDD 2014] + classifier — random walk embedding
- **Node2Vec** [Grover & Leskovec, KDD 2016] + classifier

### 5.4 Heterophilic graph 전문 GNN
- **H2GCN** [Zhu et al., NeurIPS 2020] — ego/neighbor/higher-order 분리
- **GPRGNN** [Chien et al., ICLR 2021] — generalized PageRank
- **LINKX** [Lim et al., NeurIPS 2021] — large-scale heterophilic
- **GloGNN** [Li et al., ICML 2022] — global homophily 활용

### 5.5 Graph Transformer (최신 아키텍처)
- **Graphormer** [Ying et al., NeurIPS 2021]
- **NodeFormer** [Wu et al., NeurIPS 2022] — 대규모 노드 분류 전용
- **SGFormer** [Wu et al., NeurIPS 2023] — single-layer global attention

### 5.6 Interpretable / symbolic 기법 (해석 가능성 비교군)
- **ProgNet** [Anonymous, *KDD'26 under review*] — GDL vocabulary + GNN, graph classification 전용 (node classification 미지원이므로 graph-level task에서만 비교)
- **ProtGNN** [Zhang et al., AAAI 2022] — prototype 기반 해석 가능 GNN
- **SE-GNN** [Dai & Wang, IEEE TKDE 2022] — self-explaining GNN
- **Logic Explained Networks** [Ciravegna et al., AAAI 2023] — 논리 규칙 기반
- **Decision Tree on graph features** — positional/structural feature 위의 symbolic baseline

### 5.7 GNN + Post-hoc 설명 (accuracy-explainability 비교)
- **GCN + GNNExplainer** [Ying et al., NeurIPS 2019]
- **GCN + PGExplainer** [Luo et al., NeurIPS 2020]
- **GCN + SubgraphX** [Yuan et al., ICML 2021]
- **GAT + GSAT** [Miao et al., ICML 2022]
- *이들은 높은 정확도를 달성하지만, post-hoc 설명의 faithfulness (Fidelity)가 PL4XGL의 구조적 Fidelity = 0에 비해 열위*

### 평가 지표
- **Accuracy** (transductive node classification)
- **Fidelity(−) / Fidelity(+)** [Yuan et al., TPAMI 2022]: 설명의 faithfulness
- **Sparsity**: 설명 크기 (GDL program 수, interval 폭)
- **Stability**: 유사 노드에 대한 설명 일관성
- **Training time** (wall-clock), **Inference latency per node**
- **Label efficiency curve**: labeled 노드 비율에 따른 accuracy 변화 (semi-supervised 효율성)
- **Homophily robustness**: homophily ratio 변화에 따른 accuracy 변화
- **Scalability**: 노드 수 증가에 따른 training/inference 시간

---

## 연구 지형 요약 (Research Landscape Summary)

| 축 | 대표 연구 | 확장성 | 해석성 | Transductive | 비고 |
|---|---|---|---|---|---|
| Transductive GNN | GCN, GAT, APPNP, GCNII | ✅ | ❌ | ✅ | Black-box, post-hoc 설명 필요 |
| Classical semi-supervised | LP, Label Spreading | ✅ | △ | ✅ | 단순하지만 표현력 제한 |
| Heterophilic GNN | H2GCN, GPRGNN, LINKX | ✅ | ❌ | ✅ | Heterophily 전용, black-box |
| Symbolic graph learning | PL4XGL | ❌ | ✅ | ❌ | Fidelity = 0 보장, transductive 미지원 |
| Intrinsic interpretable GNN | ProtGNN, SE-GNN | △ | ✅ | △ | Subgraph 기반 설명, interval 불가 |
| GNN + post-hoc explainer | GCN + GNNExplainer/SubgraphX | ✅ | △ | ✅ | Faithfulness 보장 없음 |
| **본 연구: Transductive PL4XGL** | — | ✅ | ✅ | ✅ | **세 축 동시 달성 목표** |

**Transductive PL4XGL**은 (a) PL4XGL의 **Fidelity = 0 해석 가능성 보장**, (b) transductive learning의 **unlabeled 데이터 활용·label propagation**, (c) **확장된 GDL의 관계적 술어(homophily, aggregate)** 를 통합하여, 현재 문헌에서 뚜렷한 공백인 **"interpretable transductive graph learning"** 을 메운다.

### 주요 Open Question
- **GDL 확장의 표현력-복잡도 trade-off**: Homophily/aggregate 술어를 추가하면 program 매칭 비용이 어떻게 변하는가? 기존 PL4XGL의 NP-complete subgraph isomorphism에 aggregate 계산이 추가되는 비용을 관리할 수 있는가?
- **Fidelity 보장의 범위**: Program activation propagation을 포함하면 Fidelity = 0은 더 이상 성립하지 않는다. Propagation 하에서 Fidelity의 이론적 bound는 무엇인가?
- **Homophily 가정의 일반화**: Homophily 술어는 homophilic graph에서 효과적이지만, heterophilic graph에서는 다른 종류의 관계적 술어가 필요할 수 있다. 어떤 술어 집합이 homophily spectrum 전반을 커버하는가?
- **Iterative synthesis의 수렴**: Synthesis-propagation loop가 수렴하는가? 수렴 조건과 속도는?
- **Pseudo-label의 noise**: Label propagation 기반 pseudo-label에 noise가 있을 때, 합성된 program의 quality에 미치는 영향은? Error propagation을 어떻게 제어하는가?
- **Scalability ceiling**: 확장된 술어와 iterative synthesis를 포함하면 ogbn-products(2.4M 노드) 규모에서도 동작 가능한가?
