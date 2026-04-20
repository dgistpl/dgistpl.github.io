# 해석 가능한 그래프 분류 (Interpretable Graph Classification)

## 1. 문제 (Problem)

그래프는 분자 구조, 소셜 네트워크, 프로그램 실행 추적, 지식 베이스 등 다양한 실세계 데이터를 자연스럽게 표현하는 기본 자료구조이다. 특히 신약 개발과 같이 의사결정이 중요한 도메인에서는 **정확한 예측**뿐만 아니라 **명확한 설명**이 함께 요구된다.

현재 그래프 분류의 주류 방법인 **GNN(Graph Neural Network)** 은 높은 정확도를 보여주지만 블랙박스로 동작한다. 예측의 근거가 연속적인(continuous) 임베딩에 얽혀 있어서, 어떤 구조적 패턴이 예측을 이끌었는지 명시적으로 식별하기 어렵다.

이를 해결하기 위해 다양한 explainable/interpretable GNN 기법들이 제안되었으나 다음과 같은 한계가 있다.

- **정확도 vs. 설명 품질 trade-off**: 강한 GNN 인코더의 정확도를 유지하는 방법(예: SubgraphX, GSAT)은 약하거나 불안정한 설명을 제공하는 반면, 본질적으로 해석 가능한 방법(예: PL4XGL)은 예측 정확도를 희생한다.
- **Instance-level isolation**: 설명 구조가 인스턴스별로 독립적으로 생성되어, 데이터셋 전체에서 공유·재사용 가능한 구조적 vocabulary를 학습하지 못한다. 이로 인해 태스크의 일반화된 로직을 포착하지 못하고 설명이 불안정해진다.

즉, **"설명 구조가 예측 메커니즘의 first-class, 재사용 가능한 구성요소"로 다뤄지지 않는 것**이 공통된 한계이다.

## 2. 목표 (Goal)

다음을 동시에 만족하는 interpretable graph classification framework를 설계한다.

- **높은 예측 정확도**: 최신 GNN 수준의 분류 성능
- **Faithful한 설명**: 예측 logit이 인간이 이해할 수 있는 구조적 증거 단위로 명시적으로 분해되어야 함
- **Dataset-level 재사용성**: 인스턴스별 독립적 설명이 아닌, 데이터셋 전반에서 공유되고 재사용 가능한 구조적 vocabulary 기반 설명 제공

## 3. 기본 접근 방법 (Basic Approach)

**ProgNet**은 neural representation learning과 명시적인 program-level evidence space를 통합하는 프레임워크이다. 세 가지 핵심 아이디어로 구성된다.

### (1) Declarative program 기반 evidence interface
- 각 그래프를 **GDL(Graph Description Language)** 로 작성된 human-interpretable program들의 shared vocabulary로 표현
- GDL program $P = (\overline{\delta_V}, \overline{\delta_E}, \tau)$ = 노드 기술(`node x <φ>`), 엣지 기술(`edge (x,y) <φ>`), 그리고 **target symbol** $\tau \in \{\texttt{node }x, \texttt{edge }(x,y), \texttt{graph}\}$ 로 구성 [PL4XGL, PLDI 2024]
- Feature value constraint `<φ>`는 $d$차원 interval vector이며 `[-∞, ub]` / `[lb, ∞]`와 같은 open bound 지원 (예: `<[3.0, 4.0]>`, `<[12, ∞]>`)
- 단순 subgraph는 GDL의 특수 케이스 (interval 폭이 0인 경우)이며, GDL은 subgraph보다 **엄격히 더 표현력이 강함** (증명: [PL4XGL §7.2])
- 그래프 $G$가 program $P$를 만족하는지 여부(activation $e_P(G) \in \{0,1\}$)가 evidence 단위가 됨
- ProgNet은 graph classification에 집중하므로 $\tau = \texttt{graph}$에 해당하는 program들만 사용 (GDL 자체는 node/edge 분류 target도 지원)

### (2) Diversity-preserving vocabulary 구축
- 학습 그래프에서 candidate program들을 추출한 뒤, greedy selection으로 compact하면서도 representative한 vocabulary $\mathcal{Q}$를 구성
- 선택 기준: **uncovered data에 대한 marginal precision** 최대화

$$\arg\max_{P \in \mathcal{P}} \frac{|(\llbracket P \rrbracket \cap \mathcal{G}_{tr}) \setminus \mathcal{C}(\mathcal{Q}) \cap \mathcal{G}_{l(P)}|}{|\mathcal{G}_{tr} \cap \llbracket P \rrbracket|}$$

- 이를 통해 coverage는 최대화하고 redundancy는 최소화하는 vocabulary 생성

### (3) Decomposable evidence composition network
- 그래프 임베딩 $\mathbf{h}_G$, program 임베딩 $\mathbf{h}_P$, 클래스 프로토타입 $\mathbf{v}_c$ 사이의 삼자 상호작용을 모델링
- 클래스 $c$에 대한 logit:

$$f_c(G) = \sum_{P \in \mathcal{Q}} e_P(G) \cdot \underbrace{(\mathbf{v}_c^\top \mathbf{h}_P)}_{\text{Class Alignment}} \cdot \underbrace{(\mathbf{h}_G^\top \mathbf{W} \mathbf{h}_P)}_{\text{Instance Context}}$$

- **Decomposability**: logit이 program별 기여도의 합으로 자연스럽게 분해됨 → faithful attribution 가능
- **Contextuality**: 동일 program의 중요도가 그래프별로 adaptive하게 가중됨
- **Consistency**: 공유된 program embedding으로 데이터셋 전반의 재사용·비교 가능성 확보

### 설명 생성
- **Program-level attribution**: $\alpha(G, \hat{c}, P) = e_P(G) \cdot (\mathbf{v}_{\hat{c}}^\top \mathbf{h}_P) \cdot (\mathbf{h}_G^\top \mathbf{W} \mathbf{h}_P)$
- **Evidence subgraph 추출**: attribution이 높은 program들을 모두 만족시키는 최소 subgraph $G' \subseteq G$를 iterative refinement로 추출

## 4. 후보 벤치마크 (Candidate Benchmarks)

8개의 대표적인 graph classification 벤치마크에서 실험한다.

### 분자(Molecular) 데이터셋 — 신약 개발과 연결, 정확도·설명성 모두 중요
| 데이터셋 | # Graphs | # Avg nodes | # Labels | 비고 |
|---|---|---|---|---|
| **NCI1** | 4,110 | 29.8 | 2 | 항암 활성 |
| **PTC (MR)** | 344 | 14.2 | 2 | 독성 |
| **MUTAG** | 188 | 17.9 | 2 | 돌연변이 유발성 |
| **PROTEINS** | 1,113 | 39.0 | 2 | 효소/비효소 |
| **BBBP** | 2,039 | 24.0 | 2 | 혈액-뇌 장벽 투과 |
| **BACE** | 1,513 | 34.0 | 2 | BACE-1 저해제 |
| **Mutagenicity** | 4,337 | 30.3 | 2 | 돌연변이 유발성 |

### 합성(Synthetic) 데이터셋 — 설명 품질 평가 전용
| 데이터셋 | # Graphs | # Avg nodes | # Labels | 비고 |
|---|---|---|---|---|
| **BA-2Motifs** | 1,000 | 25.0 | 2 | House-shaped motif 포함 여부 |

## 5. 후보 베이스라인 (Candidate Baselines)

세 가지 유형의 기존 접근법을 대표하는 방법들과 비교한다.

### (1) Traditional GNN + Post-hoc explainer
- **GCN** [Kipf & Welling, 2017]: first-order spectral graph convolution
- **GIN** [Xu et al., 2019]: sum aggregation + MLP
- **GAT** [Veličković et al., 2018]: attention 기반 neighbor weighting
- **SubgraphX** [Yuan et al., 2021]: 예측 이후 responsible subgraph를 생성하는 state-of-the-art post-hoc 설명 방법

### (2) Rationale-based (intrinsic)
- **GSAT** [Miao et al., 2022]: stochastic attention과 information bottleneck 원리를 이용하여 task-relevant subgraph를 rationale로 식별

### (3) Symbolic / inherently interpretable
- **PL4XGL** [Jeon, Park, Oh, *PLDI 2024*]: GDL program들의 집합 $M \subseteq L \times P \times [0,1]$ 로 구성된 symbolic 모델. 입력 그래프에 대해 best-scored program을 선택하여 label과 함께 그 program을 explanation으로 제공. **Fidelity가 구조적으로 0 보장** (Theorem 6.1) — classification이 program에 의해 수행되었으므로 program을 만족하는 subgraph로도 같은 label 예측. Learning은 top-down(가장 일반 → 특수)과 bottom-up(가장 구체 → 일반) **program synthesis**로 수행. 그러나 (i) 신경망을 사용하지 않아 표현력 한계 (homophily, aggregate 속성 기술 불가), (ii) HIV 같은 대형 데이터셋에서 training timeout, (iii) citation network (Cora/Citeseer/Pubmed)에서 정확도 하락 — 이러한 한계를 ProgNet은 GNN과 결합으로 극복

### 평가 지표
- **Accuracy** (높을수록 좋음)
- **Fidelity** [Yuan et al., 2022] (낮을수록 좋음): 설명 subgraph만 모델에 입력했을 때 원래 예측이 유지되는 정도로 설명의 faithfulness를 측정
- **Vocabulary Coverage / Diversity** (pairwise Jaccard diversity): vocabulary 구축 전략의 적절성 평가

## 6. 참고 논문 리스트 (References)

### GNN 기초 모델
- **GCN** — Kipf & Welling. *Semi-Supervised Classification with Graph Convolutional Networks.* ICLR 2017.
- **GIN** — Xu, Hu, Leskovec, Jegelka. *How Powerful are Graph Neural Networks?* ICLR 2019.
- **GAT** — Veličković et al. *Graph Attention Networks.* ICLR 2018.
- **GraphSAGE** — Hamilton, Ying, Leskovec. *Inductive Representation Learning on Large Graphs.* NeurIPS 2017.
- **Spectral GCN** — Defferrard, Bresson, Vandergheynst. *Convolutional Neural Networks on Graphs with Fast Localized Spectral Filtering.* NeurIPS 2016.
- **Deformable GCN** — Park et al. *Deformable Graph Convolutional Networks.* AAAI 2022.
- **Graph Pooling** — Grattarola, Zambon, Bianchi, Alippi. *Understanding Pooling in Graph Neural Networks.* IEEE TNNLS 2024.

### Explainable / Interpretable Graph Learning
- **SubgraphX** — Yuan, Yu, Wang, Li, Ji. *On Explainability of Graph Neural Networks via Subgraph Explorations.* ICML 2021. *(post-hoc)*
- **GNNExplainer** — Ying, Bourgeois, You, Zitnik, Leskovec. *GNNExplainer: Generating Explanations for Graph Neural Networks.* NeurIPS 2019. *(post-hoc)*
- **PGExplainer** — Luo et al. *Parameterized Explainer for Graph Neural Network.* NeurIPS 2020. *(post-hoc)*
- **GraphLIME** — Huang et al. *GraphLIME: Local Interpretable Model Explanations for Graph Neural Networks.* IEEE TKDE 2022. *(surrogate)*
- **GraphChef** — Müller, Faber, Martinkus, Wattenhofer. *GraphChef: Learning the Recipe of Your Dataset.* ICML IMLH Workshop 2023. *(surrogate)*
- **GSAT** — Miao, Liu, Li. *Interpretable and Generalizable Graph Learning via Stochastic Attention Mechanism.* ICML 2022. *(rationale)*
- **Rationalizing Neural Predictions** — Lei, Barzilay, Jaakkola. CoRR 2016. *(rationale의 원류)*
- **VGIB** — Yu, Cao, He. *Improving Subgraph Recognition with Variational Graph Information Bottleneck.* arXiv 2022.
- **PL4XGL** — Jeon, Park, Oh. *PL4XGL: A Programming Language Approach to Explainable Graph Learning.* PLDI 2024. *(symbolic, GDL 기반)*

### Graph Pattern Description Languages
- **Cypher** — Francis et al. *Cypher: An Evolving Query Language for Property Graphs.* SIGMOD 2018.
- **Graphiti** — He, Fang, Dillig, Wang. *Graphiti: Bridging Graph and Relational Database Queries.* PLDI 2025.
- **GraphQ IR** — Nie et al. *GraphQ IR: Unifying the Semantic Parsing of Graph Query Languages with One Intermediate Representation.* arXiv 2022.
- **Object Graph Programming** — Thimmaiah, Lampropoulos, Rossbach, Gligoric. ICSE 2024.
- **Graph-cutting** — Mang, Ba, He, Rigger. *Finding Logic Bugs in Graph-processing Systems via Graph-cutting.* SIGMOD 2025.

### Graph Pattern Mining
- **Approximate Graph Pattern Mining** — Arpaci-Dusseau, Zhou, Chen. arXiv 2024.
- **GraphINC** — Hussein et al. *GraphINC: Graph Pattern Mining at Network Speed.* SIGMOD 2023.

### 응용: 신약 개발 / 분자 특성 예측
- Li et al. *An adaptive graph learning method for automated molecular interactions and properties predictions.* Nature Machine Intelligence 2022.
- Liu et al. *Interpretable Chirality-Aware Graph Neural Network for Quantitative Structure Activity Relationship Modeling in Drug Discovery.* bioRxiv 2022.
- Sun et al. *Graph convolutional networks for computational drug development and discovery.* Briefings in Bioinformatics 2019.
- Xiong et al. *Graph neural networks for automated de novo drug design.* Drug Discovery Today 2021.

### MUTAG 데이터셋 도메인 근거
- Debnath et al. *Structure-activity relationship of mutagenic aromatic and heteroaromatic nitro compounds.* Journal of Medicinal Chemistry 1991. *(carbon ring / NO₂ group과 mutagenicity의 관계)*

### Survey
- Kakkad, Jannu, Sharma, Aggarwal, Medya. *A Survey on Explainability of Graph Neural Networks.* arXiv 2023.
- Yuan, Yu, Gui, Ji. *Explainability in Graph Neural Networks: A Taxonomic Survey.* IEEE TPAMI 2022. *(Fidelity 지표의 출처)*
- Wu, Pan, Chen, Long, Zhang, Yu. *A Comprehensive Survey on Graph Neural Networks.* IEEE TNNLS 2021.
- Zhou, Cui, Zhang, Yang, Liu, Sun. *Graph Neural Networks: A Review of Methods and Applications.* CoRR 2018.
