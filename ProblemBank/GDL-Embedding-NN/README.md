# GDL Program 기반 임베딩과 신경망 (GDL-Based Embeddings for Neural Networks on Large Graphs)

## 1. 문제 (Problem)

대규모 그래프 학습은 다음 두 요구를 **동시에** 만족해야 한다.

1. **확장성**: 수백만~수억 노드 규모의 그래프에서 학습·추론이 가능해야 함
2. **해석성**: 예측의 근거가 사람이 이해할 수 있는 형태여야 함 (특히 신약 개발·의료·보안·금융 등 decision-critical 도메인)

현재 두 요구를 함께 만족하는 접근은 드물다.

- **Scalable GNN** (GraphSAGE, ClusterGCN, GraphSAINT, ShaDow-GNN, PinSAGE 등)은 수천만~수억 노드에 대응하지만 **black-box**이다. 설명을 얻으려면 별도의 post-hoc explainer (GNNExplainer, SubgraphX 등)가 필요하고, 이는 추가 비용과 설명 불일치(faithfulness gap)를 유발한다.
- **Symbolic / program 기반 방법** (PL4XGL, ProgNet)은 GDL(Graph Description Language)로 해석 가능한 근거를 제공하지만 **확장성이 부족**하다. PL4XGL은 HIV(41K 분자)에서 training timeout, Pubmed에서 분류 170× 느림. ProgNet도 program matching을 모든 인스턴스에 대해 수행해야 하므로 수백만 노드 규모에서는 비실용적이다.
- **Graph kernel / subgraph feature 기반 방법** (WL kernel, graphlet kernel, subgraph2vec, anonymous walks)은 구조적 feature를 벡터로 바꿔 scalable 학습을 가능하게 했지만, feature가 **추상적 구조 카운트**라서 "어떤 범위의 feature 값을 가진 어떤 패턴이 중요한가"와 같은 의미 있는 설명을 직접 제공하지 못한다.

최근 PL4XGL이 도입한 GDL은 subgraph보다 **엄격히 더 표현력이 강하고** [§7.2], feature 값에 대한 **interval 술어**를 first-class로 지원한다. 예를 들어 `[12, ∞] — [-∞, ∞] — [12, ∞]` 와 같은 GDL program은 Barabási–Albert 그래프의 노드를 precision 99%, recall 97%로 기술하며, 이는 subgraph로는 표현 불가능한 degree-range 패턴이다. PL4XGL 저자들은 §8에서 *"GDL can be employed in graph data mining and GNN explanation techniques"* 라 직접 제안하였다. 그러나 GDL을 **대규모 신경망 학습을 위한 embedding의 기반**으로 사용하는 연구는 아직 없다.

핵심 공백은 다음과 같다. **해석 가능한 GDL program들의 집합이 고정되어 있다면, 각 노드/그래프에 대한 program activation 벡터는 (i) 한 번만 계산하면 되고, (ii) NN의 입력으로 바로 사용 가능하며, (iii) 각 차원이 GDL program이라는 human-readable 단위에 대응한다.** 이는 scalable GNN의 속도와 symbolic 방법의 해석성을 결합할 수 있는 구조적 여지이다.

## 2. 목표 (Goal)

**GDL program을 feature 추출기로 사용해 해석 가능한 embedding을 생성하고, 이 embedding 위에서 표준 NN으로 대규모 그래프 학습을 수행**하는 프레임워크를 설계한다.

- **확장성**: 수백만~수억 노드 규모의 그래프(OGB-Papers100M, Friendster, 산업 규모 추천 그래프)에서 학습·추론 가능
- **해석 가능한 embedding**: 각 차원 $h_v[i]$가 구체적인 GDL program $P_i$ 의 활성화에 대응하여, NN의 입력 단계에서 이미 설명 단위 확보
- **GNN 수준의 정확도**: OGB 벤치마크에서 GraphSAGE, GIN, GAT 등 scalable GNN과 경쟁력 있는 성능
- **Downstream task 범용성**: 노드 분류, 그래프 분류, 링크 예측, 이상 탐지, 추천 등 다양한 task에 같은 embedding 재사용
- **Transfer learning**: 한 데이터셋에서 학습된 GDL 기반 embedding을 다른 (유사 도메인) 데이터셋으로 transfer
- **Post-hoc 설명**: 예측에 영향이 큰 차원 = 중요한 GDL program → 자연스러운 설명 제공

## 3. 기본 접근 방법 (Basic Approach)

### (1) GDL Program 기반 Embedding 함수
GDL program 집합 $\mathcal{Q} = \{P_1, \dots, P_k\}$ 가 주어졌을 때, 노드 $v$ 또는 그래프 $G$ 에 대한 embedding을 다음과 같이 정의한다.

**노드 embedding** (노드 분류, 링크 예측용):
$$
\mathbf{h}_v = \big[\phi_1(v), \phi_2(v), \dots, \phi_k(v)\big] \in \mathbb{R}^k
$$
여기서 $\phi_i(v)$ 는 $v$ 를 중심으로 한 **ego-subgraph** 에서 program $P_i$ 가 얼마나 활성화되는지를 측정하는 함수이다.

**그래프 embedding** (그래프 분류용):
$$
\mathbf{h}_G = \big[\phi_1(G), \phi_2(G), \dots, \phi_k(G)\big]
$$

### (2) Activation $\phi_i$ 의 설계 옵션
- **Binary**: $\phi_i(v) = e_{P_i}(v) \in \{0, 1\}$ — PL4XGL의 원래 의미론
- **Count**: $\phi_i(v) = |\{\nu : (G_v, \nu) \models P_i\}|$ — program이 매칭되는 valuation 수
- **Soft / continuous**: interval 제약에 대한 soft relaxation으로 $\phi_i(v) \in [0, 1]$ 를 출력 → 미분 가능
- **Weighted**: 매칭된 valuation의 feature distance 가중합
- **Hierarchical**: multi-hop ego-subgraph를 사용하여 k-hop receptive field 확보

### (3) 대규모 확장을 위한 핵심 기법
- **프로그램 매칭의 오프라인 사전계산**: $\mathcal{Q}$ 가 고정되면 $\phi_i$ 를 training 전에 한 번 계산해 저장 → 이후 NN 학습·추론은 $O(k)$ feature lookup
- **Sparse embedding**: 대부분의 program은 대다수 노드에서 활성화되지 않음 → sparse tensor 표현, CSR/CSC 저장
- **배치 매칭**: GPU 친화적 interval containment (dimension별 SIMD), subgraph isomorphism은 분산 VF2++/Glasgow 사용
- **Locality-sensitive hashing (LSH)**: interval vector를 해싱해 매칭 후보 빠르게 pruning
- **Hierarchical program tree**: subsumption 관계를 tree로 조직해 한 번의 트래버스로 여러 program 동시 평가
- **Streaming matching**: 그래프가 너무 커서 메모리에 안 들어가면 ego-subgraph 단위로 stream 처리

### (4) Vocabulary $\mathcal{Q}$ 의 구성 전략
- **Diversity-preserving greedy selection** (ProgNet 방식): coverage 최대화 + redundancy 최소화
- **Label-agnostic vocabulary**: 분류·예측 label 없이 구조적 다양성 기준으로 선택 → 여러 task에 재사용
- **Task-adaptive extension**: 공통 vocabulary + task-specific 소량 추가
- **Hierarchical vocabulary**: 저수준(local pattern) + 고수준(multi-hop pattern)의 다층 구성
- **Pre-trained library**: 화학·생물·코드·금융 도메인별 범용 GDL 라이브러리

### (5) 위 embedding 위의 NN 아키텍처
- **MLP**: 가장 단순한 downstream model, embedding이 이미 표현력이 높으므로 가능
- **Tabular NN** (TabNet, FT-Transformer): 각 program-dimension을 feature로 간주
- **GNN의 입력**: GNN의 초기 node feature를 GDL embedding으로 대체 → message passing은 그대로, 정확도·해석성 동시 향상
- **Mixture-of-Experts**: 각 expert가 특정 program 부분집합에 집중

### (6) 해석 / 설명
- **Feature importance**: 학습된 NN의 gradient, Integrated Gradients, SHAP을 GDL program 차원에 적용
- **Program-level attribution**: ProgNet 스타일의 signed contribution을 post-hoc으로 계산
- **Example-based grounding**: 중요한 program이 실제로 어떤 subgraph와 매칭되는지 concrete example 제공
- **Global explanation**: 데이터셋 전반에서 positive/negative 기여가 큰 program 집합 = 모델의 전역 규칙

### (7) 학습 파이프라인
1. **Vocabulary construction**: training 데이터의 일부에서 candidate GDL program 생성 → diversity-preserving selection으로 $\mathcal{Q}$ 결정
2. **Offline feature extraction**: 전체 데이터에 대해 $\phi_i$ 계산, sparse tensor로 저장
3. **NN training**: 표준 supervised learning (mini-batch, Adam 등)
4. **Inference**: lookup + NN forward — 매우 빠름
5. **Explanation**: 예측별 top-k program, 또는 데이터셋 수준 global program set

## 4. 후보 벤치마크 (Candidate Benchmarks)

### 대규모 노드 분류
- **ogbn-arxiv** (170K 노드)
- **ogbn-products** (2.4M 노드, 61M 엣지)
- **ogbn-papers100M** (111M 노드, 1.6B 엣지) — **초대형 테스트**
- **Reddit** (232K 노드), **Yelp** (716K 노드)
- **Flickr, Amazon2M** (GraphSAINT / ClusterGCN 표준)

### 대규모 그래프 분류 / 속성 예측
- **ogbg-molhiv, ogbg-molpcba** (400K+ 분자)
- **ogbg-code2** (소스 코드 AST 그래프)
- **ZINC-full, PCQM4Mv2** — 양자화학 대규모 회귀

### 링크 예측 / 추천
- **ogbl-collab, ogbl-citation2, ogbl-wikikg2, ogbl-ppa** [Hu et al., NeurIPS 2020]
- **Amazon Reviews, Alibaba User-Item** (산업 규모 추천 평가)

### 이상 탐지 / 사기
- **Elliptic Bitcoin**, **DGraph-Fin** [Huang et al., NeurIPS 2022]
- **YelpChi**, **Amazon Fraud**
- **AML synthetic** [Altman et al., NeurIPS 2023]

### Heterogeneous 그래프
- **OGB-MAG, DBLP, IMDB, ACM**
- **OAG (Open Academic Graph)** — 수억 노드

### 확장성 전용 합성
- **RMAT, Kronecker graph** — 임의 스케일 power-law
- **GMark** [Bagan et al., 2016]

### 해석성 평가 병행
- **MUTAG, BA-2Motifs, SpMotif** — 설명 품질 확인
- **GraphXAI** [Agarwal et al., NeurIPS 2022]

## 5. 후보 베이스라인 (Candidate Baselines)

### 5.1 Scalable GNN (속도·정확도 주 비교군)
- **GraphSAGE** [Hamilton, Ying, Leskovec, NeurIPS 2017] — neighbor sampling
- **PinSAGE** [Ying et al., KDD 2018] — 산업 규모 추천
- **ClusterGCN** [Chiang et al., KDD 2019] — partition-based batching
- **GraphSAINT** [Zeng et al., ICLR 2020] — subgraph sampling
- **ShaDow-GNN** [Zeng et al., NeurIPS 2021] — decoupled localized subgraph
- **GNNAutoScale** [Fey et al., ICML 2021] — historical embeddings
- **SIGN** [Rossi et al., 2020] — precomputed diffusion features
- **SGC** [Wu et al., ICML 2019] — simplified graph convolution
- **LightGCN** [He et al., SIGIR 2020]
- **GNS (Graph Network Shift)** / **GAS** — 초대형 GNN

### 5.2 Graph kernel / subgraph feature 기반 임베딩
- **WL kernel** [Shervashidze et al., JMLR 2011] — 색상 정제 기반
- **Graphlet kernel** [Shervashidze et al., AISTATS 2009]
- **subgraph2vec** [Narayanan et al., 2016]
- **graph2vec** [Narayanan et al., 2017]
- **Anonymous Walks** [Ivanov & Burnaev, ICML 2018]
- **NetMF / Node2Vec / DeepWalk** — random walk 기반 임베딩

### 5.3 Tabular / feature-based NN (embedding 위 NN 비교)
- **MLP** — 가장 단순
- **TabNet** [Arik & Pfister, AAAI 2021]
- **FT-Transformer** [Gorishniy et al., NeurIPS 2021]
- **DeepFM, xDeepFM** — feature interaction NN

### 5.4 Symbolic / program 기반 그래프 학습 (해석성 비교군)
- **PL4XGL** [Jeon, Park, Oh, *PLDI 2024*] — scalability 한계
- **ProgNet** [Anonymous, *KDD'26 under review*] — vocabulary + GNN decomposable architecture
- **Decision Tree on WL features** — symbolic baseline

### 5.5 Hybrid neural-symbolic 그래프 학습
- **Concept Bottleneck Models** [Koh et al., ICML 2020] — 사람 해석 가능 개념을 중간층으로
- **Prototype GNN / ProtGNN** [Zhang et al., AAAI 2022]
- **KerGNNs** [Feng et al., AAAI 2022] — graph kernel + NN
- **Logic Explained Networks** [Ciravegna et al., AAAI 2023]

### 5.6 Graph Transformer (비교 가능한 최신 아키텍처)
- **Graphormer** [Ying et al., NeurIPS 2021]
- **GPS** [Rampášek et al., NeurIPS 2022]
- **NodeFormer** [Wu et al., NeurIPS 2022] — large graph용

### 평가 지표
- **Accuracy / ROC-AUC / MRR / Hits@K** (task별 표준 metric)
- **Training time** (wall-clock), **Inference latency per query**
- **Memory footprint** (GB)
- **Scale ceiling**: 처리 가능한 최대 노드/엣지 수
- **Explainability**: Fidelity(−/+), Sparsity, Stability, Plausibility
- **Transferability**: 한 데이터에서 학습된 embedding의 다른 데이터 성능
- **Vocabulary size $k$ 에 대한 scaling** — $k$ 를 줄이면서 정확도 유지

---

## 연구 지형 요약 (Research Landscape Summary)

| 축 | 대표 연구 | 확장성 | 해석성 | 비고 |
|---|---|---|---|---|
| Scalable GNN | GraphSAGE, ClusterGCN, ShaDow-GNN | ✅ | ❌ | black-box, 설명은 post-hoc |
| Graph kernel + NN | WL, graphlet, subgraph2vec | ✅ | △ | 추상적 카운트, 구체 패턴 해석 X |
| Symbolic graph learning | PL4XGL, ProgNet | ❌ | ✅ | 해석성 최고, scale 못함 |
| Concept bottleneck / hybrid | ProtGNN, KerGNNs, LEN | △ | ✅ | 그래프 특화 확장 제한 |
| **본 연구: GDL embedding + NN** | — | ✅ | ✅ | **두 축 동시 달성 목표** |

**GDL embedding + NN** 접근은 (a) GDL의 **interval-aware 해석 가능 패턴 언어** 로부터 해석성을, (b) **offline feature extraction + 일반 NN** 구조로부터 scalability를 확보한다. 자연스러운 비교 기준은 scalability에서 **GraphSAGE / ClusterGCN / ShaDow-GNN**, 해석성에서 **PL4XGL / ProgNet / ProtGNN**, 추상 feature + NN에서 **WL + kernel SVM / TabNet on graphlet counts** 이다.

### 주요 Open Question
- **Vocabulary 크기 $k$ 와 표현력의 tradeoff**: 수천 개의 program으로 수억 노드 그래프를 충분히 구분할 수 있는가?
- **Soft activation의 이론적 보장**: binary matching을 relaxation할 때 Fidelity·sparsity가 어떻게 변하는가?
- **GDL 표현력 확장**: PL4XGL §7.1이 지적한 homophily·aggregate 술어 부재 → embedding에서는 어떻게 흡수할 것인가 (message-passing 층을 추가? GDL 언어를 확장?)
- **Transfer learning**: GDL vocabulary가 chemistry → biology, 또는 한 언어 CPG → 다른 언어 CPG 로 얼마나 전이되는가?
