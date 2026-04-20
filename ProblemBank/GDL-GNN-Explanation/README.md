# GDL 기반 GNN 설명 기법 (GDL-based GNN Explanation)

## 1. 문제 (Problem)

**GNN 설명(GNN Explanation)** 은 GNN이 특정 예측을 내린 **근거**를 사람이 이해할 수 있는 형태로 제시하는 문제이다. 신약 개발, 의료 진단, 프로그램 분석, 사기 탐지 등 의사결정이 중요한 도메인에서 GNN을 실제로 배치하기 위한 전제 조건이다.

지금까지 제안된 대부분의 GNN 설명 기법은 **subgraph(부분 그래프) 또는 subgraph 위의 가중치(edge/feature mask)** 를 설명의 단위로 사용한다.

- **Post-hoc 방법**: GNNExplainer, PGExplainer, SubgraphX, GraphMask, PGM-Explainer, CF-GNNExplainer, RCExplainer 등 — 예측된 그래프에서 중요한 edge/node/subgraph를 찾아 제시
- **Rationale 기반 intrinsic 방법**: GSAT, GIB-subgraph, DIR, ProtGNN 등 — 예측 과정에서 task-relevant subgraph를 직접 식별
- **Global explanation 방법**: XGNN, GNNInterpreter, GCFExplainer 등 — 모델 전체 행동을 설명하는 대표 그래프 생성

그러나 subgraph/edge mask를 설명 언어로 사용하는 접근법은 다음과 같은 **근본적 한계**를 가진다.

- **Instance-level isolation**: 각 인스턴스마다 독립적으로 subgraph가 생성되어, 데이터셋 전반에서 **공유되고 재사용 가능한 설명 단위**가 없다. 같은 현상을 설명하는 두 그래프에 대해 서로 다른 subgraph가 제시되는 **설명의 불안정성(instability)** 이 자주 관찰된다 [Agarwal et al., *NeurIPS 2022*; Amara et al., *GraphLearn 2022*].
- **표현력 부족**: Subgraph는 고정된 feature 값으로만 패턴을 기술한다. "탄소 개수가 3~5인 고리"와 같이 **feature 값 범위(range)** 로 표현되는 일반화된 설명은 subgraph로는 직접 표현 불가능하다.
- **Soft mask의 해석 어려움**: 많은 방법들은 edge/node에 [0, 1] 값을 부여하는데, 이를 사람이 이해 가능한 규칙으로 변환하는 데는 추가적 해석 단계(thresholding 등)가 필요하며 faithfulness가 저하된다.
- **Dataset-level 설명 부재**: 사용자는 종종 "이 모델은 전체적으로 어떤 종류의 패턴에 반응하는가?"를 알고 싶어 하지만, 대다수 기법은 **단일 인스턴스** 설명만 제공한다. XGNN 계열이 global explanation을 시도하지만 생성된 그래프가 실제 데이터 분포와 맞지 않는 경우가 많다.
- **Faithfulness와 accuracy의 trade-off**: ProgNet의 분석[KDD'26 under review]에서 드러나듯, 강한 GNN의 정확도를 유지하는 설명 기법(SubgraphX, GSAT)은 설명이 약하고 불안정한 반면, 본질적으로 해석 가능한 symbolic 방법(PL4XGL)은 정확도를 희생한다.

최근 PL4XGL [Jeon, Park, Oh, *PLDI 2024*]과 ProgNet [Anonymous, *KDD'26 under review*]이 **GDL(Graph Description Language)** 을 분류의 근거 언어로 도입하였다. GDL program은 `node x <φ>` / `edge (x,y) <φ>` / `target` 으로 구성되며 feature 값을 **interval(구간)** 로 기술하는 declarative 패턴 언어이고, subgraph보다 **엄격히 더 표현력이 강하다** [PL4XGL §7.2]. 특히 PL4XGL은 **구조적으로 Fidelity = 0 을 보장**한다 (Theorem 6.1): 분류가 program에 의해 직접 수행되므로, 그 program을 만족하는 subgraph로도 동일한 label 예측이 성립. 이는 post-hoc subgraph 설명이 도달하기 어려운 수준의 faithfulness이다.

그러나 두 연구 모두 GDL을 **특정 모델 구조에 내장**하여 사용한다. PL4XGL은 GNN을 아예 대체하는 symbolic 분류기 $M \subseteq L \times P \times [0,1]$ 이고, ProgNet은 GDL vocabulary를 GNN 인코더와 결합한 전용 아키텍처이다. 즉 **임의의 사전 학습된 GNN을 그대로 두고 GDL을 설명 언어로 덧씌우는 model-agnostic 프레임워크는 부재**하다. 한편 PL4XGL 저자들은 논문의 Related Work(§8)에서 *"GDL can be employed in ... GNN explanation techniques"* 라고 이 방향을 직접적으로 제안하였으나, 실제로 구현한 연구는 아직 없다. 추가로 PL4XGL은 **표현력 한계**도 지적한다 (§7.1): homophily, aggregate 술어("oxygen 수 > chlorine 수"), heterophilic citation network 등은 현재 GDL로는 기술되지 않으며, Cora/Citeseer/Pubmed에서 정확도가 떨어진다. 따라서 GDL 기반 GNN 설명은 이러한 한계를 보완할 **확장된 GDL**도 함께 연구될 필요가 있다.

## 2. 목표 (Goal)

**Subgraph 대신 GDL program을 설명의 단위로 사용하는 GNN explanation 프레임워크**를 개발한다. 구체적으로 다음 목표를 동시에 달성한다.

- **Interval-aware 설명**: 설명이 "이러이러한 feature 범위를 만족하는 패턴이 존재할 때 예측이 y가 된다"의 형태로 자연스럽게 기술됨
- **Dataset-level 재사용성**: 동일 또는 유사한 현상을 설명하는 GDL program이 여러 인스턴스에 걸쳐 공유되어, 설명의 일관성(consistency)과 안정성(stability) 확보
- **모델 독립성(model-agnostic)**: 임의의 GCN/GIN/GAT/Graph Transformer 등에 사후적으로 적용 가능한 post-hoc 버전과, 학습 시 내재화된 intrinsic 버전을 모두 지원
- **Faithfulness 보장**: 생성된 GDL 기반 설명으로부터 subgraph를 instance-grounding하여, Fidelity(−) / Fidelity(+) 등 표준 지표에서 기존 방법보다 우수
- **인간 친화적 표현**: 도메인 전문가가 GDL program을 읽고 수정할 수 있는 수준의 간결성과 표현력

## 3. 기본 접근 방법 (Basic Approach)

### (1) 설명 언어로서의 GDL
- GDL program $P = (\overline{\delta_V}, \overline{\delta_E}, \tau)$: 노드/엣지 기술 + target symbol $\tau \in \{\texttt{node }x, \texttt{edge }(x,y), \texttt{graph}\}$ — **node / edge / graph 분류 설명을 모두 지원**
- Interval `<φ>`은 open bound 포함 (`[-∞, 0.3]`, `[5, ∞]`)
- 의미론 $\llbracket P \rrbracket$: target 종류에 따라 그래프/노드/엣지의 집합으로 정의됨. 기존 subgraph 설명은 interval 폭이 0인 특수 케이스
- 설명은 단일 GDL program 또는 **program들의 집합(vocabulary)** 로 구성되어, 인스턴스-레벨부터 데이터셋-레벨까지 다층적 설명을 가능하게 함
- PL4XGL의 원래 설계 철학인 **"설명이 곧 분류 경로"** (Theorem 6.1 Fidelity = 0)를 post-hoc 환경에서도 최대한 근사

### (2) Post-hoc GDL Explainer
사전 학습된 임의의 GNN $f$와 입력 그래프 $G$가 주어졌을 때:

1. **Candidate program 생성**: $G$를 기반으로 후보 GDL program 집합 $\mathcal{P}_G$ 생성. PL4XGL의 top-down(specialize) / bottom-up(generalize) **program synthesis**를 재사용 — 특히 bottom-up은 구체적 인스턴스에서 출발해 generalize하므로 post-hoc 설명과 자연스럽게 부합
2. **Program scoring**: 각 program $P$에 대해 GNN 예측 기여도 $s(P)$ 계산 — GNNExplainer 스타일의 mutual information, PGExplainer 스타일의 parameterized scorer, 또는 SubgraphX 스타일의 Shapley value를 GDL 공간으로 확장
3. **Program selection**: $f(G)$의 예측을 유지하는 최소의 program 집합을 선택 (e.g., Fidelity(−) 최소화). PL4XGL의 Theorem 6.1과 유사하게 "program을 만족하는 임의 subgraph도 같은 예측" 이라는 구조적 성질을 최대한 근사하는 것이 목표
4. **Instance grounding**: 선택된 program들을 만족시키는 concrete subgraph $G' \subseteq G$를 iterative refinement로 추출 (ProgNet의 Algorithm 2 참고)

### (3) Intrinsic GDL Rationale
학습 과정에 GDL 기반 rationale을 내재화하는 방법:

- **GDL-aware attention**: GSAT의 stochastic attention을 GDL program activation으로 대체 — program $P$의 activation indicator $e_P(G) \in \{0,1\}$와 학습 가능한 program embedding을 결합
- **Information bottleneck on GDL**: $I(\mathcal{P}; Y) - \beta I(\mathcal{P}; G)$를 최적화하여 task-relevant한 최소 GDL program 집합 학습
- **Prototype-based**: ProtGNN의 prototype을 GDL program으로 대체하여 prototype을 사람이 읽을 수 있게 만듦

### (4) Global Explanation via GDL Vocabulary
데이터셋 전반에 걸친 설명:

- 학습 데이터에서 추출된 GDL program 중 coverage와 diversity가 높은 부분집합 $\mathcal{Q}$를 선택 (ProgNet의 vocabulary construction)
- 각 클래스 $c$에 대해 positive/negative attribution이 큰 program들을 식별하여 **"모델이 클래스 $c$를 어떻게 인식하는가"** 에 대한 전역 설명 제공
- XGNN/GNNInterpreter가 graph 생성으로 global explanation을 시도한 것에 비해, GDL은 실제 데이터에서 유래한 **grounded global explanation** 을 제공

### (5) Counterfactual GDL Explanation
- "어떤 program의 활성화가 사라지면 예측이 바뀌는가?" — CF-GNNExplainer / RCExplainer의 counterfactual 개념을 GDL 공간으로 확장
- 최소 program 수정 $\Delta P$로 예측이 $\hat{y} \to y'$ 로 변하는 counterfactual 설명 제공

### (6) 평가 프로토콜
- **Fidelity(−) / Fidelity(+)**: 설명만 남겼을 때 / 설명을 제거했을 때 예측 일치도
- **Sparsity**: 설명의 크기 (GDL program 수, 또는 grounding된 subgraph 크기)
- **Stability / Consistency**: 유사한 입력에 대해 유사한 설명이 나오는가 [Agarwal et al., NeurIPS 2022]
- **Plausibility**: 도메인 ground truth motif(예: MUTAG의 NO₂, BA-2Motifs의 house motif)와의 일치도
- **Human evaluation**: 전문가의 가독성·유용성 평가

## 4. 후보 벤치마크 (Candidate Benchmarks)

### 실세계 분자 그래프 (설명 품질이 도메인 의미와 직접 연결)
- **MUTAG** — NO₂, aromatic ring이 known ground-truth motif
- **Mutagenicity**, **BBBP**, **BACE**, **NCI1**, **PTC (MR)**, **PROTEINS**
- **OGB-MolHIV, OGB-MolPCBA** [Hu et al., NeurIPS 2020] — 대규모 평가용
- **ClinTox, Tox21, SIDER** — 독성/부작용 예측

### 합성 벤치마크 (ground-truth motif가 명시된 설명 전용)
- **BA-2Motifs** [Luo et al., NeurIPS 2020] — house-shape vs. 5-cycle motif
- **BA-Shapes, BA-Community, Tree-Cycles, Tree-Grids** [Ying et al., NeurIPS 2019] — GNNExplainer의 표준 설명 평가 데이터. PL4XGL에서 `[12, ∞] — [-∞, ∞] — [12, ∞]` 같은 degree-range 패턴이 precision 99%, recall 97%로 작동하는 것을 보였으므로, GDL 기반 설명의 강점을 검증하기에 적합
- **SpMotif** [Wu et al., ICLR 2022] — spurious correlation이 통제된 설명 평가
- **MNIST-75sp, Graph-SST2/SST5** [Yuan et al., 2022] — 이미지·텍스트 파생 그래프 벤치마크

### Heterophilic / 표현력 한계 스트레스 테스트
- **Cora, Citeseer, Pubmed** — homophilic citation network. PL4XGL이 homophily 미기술로 정확도 하락 → 확장된 GDL의 설명력 평가
- **Wisconsin, Texas, Cornell** [Pei et al., ICLR 2020] — heterophilic web graph

### 프로그램 분석 / 보안 (interval 술어가 자연스러운 도메인)
- **Devign** [Zhou et al., NeurIPS 2019], **Big-Vul** [Fan et al., MSR 2020], **Reveal** [Chakraborty et al., TSE 2022] — C 취약점 탐지 code property graph
- **Joern / CPG** [Yamaguchi et al., S&P 2014]
- *토큰 수, 복잡도, 라인 수 등 수치형 feature → GDL interval 술어의 강점 영역*

### 사기 / 금융 (수치 feature 중심)
- **Elliptic Bitcoin** [Weber et al., 2019]
- **YelpChi** [Rayana & Akoglu, KDD 2015]
- **DGraph-Fin** [Huang et al., NeurIPS 2022]

### Explanation 평가 전용 벤치마크 스위트
- **GraphXAI** [Agarwal et al., NeurIPS 2022] — ground-truth 설명이 제공되는 통합 벤치마크
- **SHAPEGGen** [Agarwal et al., 2023] — 합성 설명 벤치마크 생성기
- **TUDataset** [Morris et al., 2020]

## 5. 후보 베이스라인 (Candidate Baselines)

### 5.1 Post-hoc: Mask / Perturbation 기반
- **GNNExplainer** [Ying et al., NeurIPS 2019] — edge/feature에 soft mask를 학습, 가장 널리 쓰이는 baseline
- **PGExplainer** [Luo et al., NeurIPS 2020] — amortized parameterized explainer, 여러 인스턴스에서 공유되는 설명 모델
- **GraphMask** [Schlichtkrull et al., ICLR 2021] — layer-wise edge masking
- **GNN-LRP / Excitation BP** [Schnake et al., IEEE TPAMI 2022] — layer-wise relevance propagation
- **DEGREE** [Feng et al., ICLR 2022] — decomposition 기반 설명

### 5.2 Post-hoc: Search / Game-Theoretic 기반
- **SubgraphX** [Yuan et al., ICML 2021] — MCTS + Shapley value로 중요한 subgraph 탐색 (state-of-the-art post-hoc baseline)
- **SAME** [Ye et al., NeurIPS 2023] — structure-aware Monte Carlo search
- **GStarX** [Zhang et al., NeurIPS 2022] — Hamiache-Navarro value 기반 설명

### 5.3 Post-hoc: Surrogate / Probabilistic 기반
- **GraphLIME** [Huang et al., IEEE TKDE 2022] — HSIC Lasso 기반 local linear surrogate
- **PGM-Explainer** [Vu & Thai, NeurIPS 2020] — Bayesian network surrogate
- **GraphChef** [Müller et al., ICML IMLH 2023] — decision tree surrogate

### 5.4 Post-hoc: Generative / RL 기반
- **GEM (Gem)** [Lin, Lan, Li, ICML 2021] — auto-encoder 기반 generative explainer
- **RG-Explainer** [Shan et al., NeurIPS 2021] — reinforcement learning 기반
- **OrphicX** [Lin, Lan, Li, Chen, CVPR 2022] — causally informed explanation

### 5.5 Counterfactual Explanation
- **CF-GNNExplainer** [Lucic et al., AISTATS 2022] — 최소한의 edge 제거로 예측을 뒤집는 counterfactual
- **RCExplainer** [Bajaj et al., NeurIPS 2021] — robust counterfactual, decision boundary 기반
- **CLEAR** [Ma et al., NeurIPS 2022] — variational causal counterfactual
- **GCFExplainer** [Huang et al., WSDM 2023] — global counterfactual

### 5.6 Intrinsic / Rationale-Based
- **GSAT** [Miao, Liu, Li, ICML 2022] — stochastic attention + information bottleneck, rationale 기반 표준 baseline
- **GIB / IB-subgraph** [Yu et al., NeurIPS 2022; Wu et al., ICLR 2022] — information bottleneck으로 task-relevant subgraph 학습
- **DIR** [Wu et al., ICLR 2022] — discovering invariant rationales, causal 관점
- **ProtGNN** [Zhang et al., AAAI 2022] — prototype 기반 intrinsic interpretability
- **SE-GNN** [Dai & Wang, IEEE TKDE 2022] — self-explaining GNN
- **KerGNNs** [Feng et al., AAAI 2022] — graph kernel 기반 interpretable GNN

### 5.7 Global Explanation
- **XGNN** [Yuan et al., KDD 2020] — RL로 클래스를 대표하는 graph 생성
- **GNNInterpreter** [Wang & Shen, ICLR 2023] — continuous relaxation 기반 global explanation
- **GLGExplainer** [Azzolin et al., ICLR 2023] — global logical explanation via concept 추출
- **D4Explainer** [Chen et al., NeurIPS 2023] — diffusion 기반 global/local 설명

### 5.8 Concept-Based
- **GCExplainer** [Magister et al., 2021] — k-means concept clustering
- **GCI** [Xuanyuan et al., *ICML 2023*] — GNN concept interpretation
- **GraphLIME-Concept** 계열

### 5.9 Symbolic / Program-Based (**GDL과 가장 밀접**)
- **PL4XGL** [Jeon, Park, Oh, *PLDI 2024*] — GDL 언어의 원출처. 모델은 $M \subseteq L \times P \times [0,1]$ 형태의 symbolic 분류기(best-scored program lookup)로, GNN을 **대체**한다. Learning은 top-down/bottom-up **program synthesis**. 장점: (i) 설명이 분류의 실제 근거와 일치하여 **Fidelity = 0 보장** (Theorem 6.1), (ii) 설명 생성 비용 0 (classification이 곧 explanation), (iii) subgraph보다 엄격히 더 표현력이 강한 GDL. 한계: (i) **neural GNN에 적용 불가** — 모델 자체가 GNN이 아님, (ii) homophily / aggregate 술어 미기술 (§7.1), (iii) training 비효율 (합성된 program의 ~5%만 사용). 저자들이 §8에서 GDL을 GNN 설명에 직접 활용할 것을 제안 — 본 연구의 핵심 motivation
- **ProgNet** [Anonymous, *KDD'26 under review*] — GDL vocabulary를 GNN 인코더와 결합한 intrinsic 설명. diversity-preserving vocabulary construction + decomposable evidence composition으로 program-level signed attribution 제공. *임의 GNN에 post-hoc 적용이 아니라 전용 아키텍처 필요*
- **Logic Explained Networks (LEN)** [Ciravegna et al., *AAAI 2023*] — 논리 규칙 추출, 그래프 도메인 확장 연구 있음

### 5.10 평가 프로토콜 관련 (기법 아닌 benchmark/metric)
- **GraphXAI** [Agarwal et al., NeurIPS 2022] — explanation 평가 표준 suite
- **Amara et al., GraphLearn 2022** — "GraphFramEx: Towards Systematic Evaluation of Explainability Methods for GNNs"
- **Faber et al., KDD 2021** — explanation evaluation 비판적 분석
- **ROAR / RemOve-And-Retrain** 스타일 faithfulness 평가

### 5.11 Survey
- **Yuan, Yu, Gui, Ji**, *Explainability in GNNs: A Taxonomic Survey*, IEEE TPAMI 2022 — Fidelity 지표의 출처
- **Kakkad, Jannu, Sharma, Aggarwal, Medya**, *A Survey on Explainability of GNNs*, arXiv 2023
- **Li, Zhou, Lin, Liu, Du, Zhu**, *Explainability in Graph Neural Networks: An Experimental Survey*, arXiv 2022
- **Longa et al.**, *Explaining the Explainers in Graph Neural Networks: a Comparative Study*, ACM CSUR 2024

### 평가 지표
- **Fidelity(−)** / **Fidelity(+)** [Yuan et al., TPAMI 2022]
- **Sparsity**: 설명 크기
- **Accuracy on ground-truth motifs**: 합성 데이터에서 motif recall/precision
- **Stability**: 입력 섭동 하 설명 일관성
- **Consistency**: 유사 입력에 대한 설명 유사도
- **Contrastivity / Contrast**: 클래스 간 설명의 구별도
- **Plausibility**: 도메인 지식 일치도
- **Human evaluation**: 전문가 가독성·유용성

---

## 연구 지형 요약 (Research Landscape Summary)

| 축 | 대표 연구 | 한계 |
|---|---|---|
| Post-hoc subgraph/mask | GNNExplainer, PGExplainer, SubgraphX, GraphMask | instance-level, interval 불가, 불안정 |
| Intrinsic rationale | GSAT, GIB, DIR, ProtGNN | subgraph/edge 기반, dataset-level 재사용 어려움 |
| Global explanation | XGNN, GNNInterpreter, GCFExplainer | 생성된 graph가 데이터 분포와 분리됨 |
| Counterfactual | CF-GNNExplainer, RCExplainer, CLEAR | 여전히 edge-level, interval 설명 부재 |
| Symbolic / program-based | PL4XGL, ProgNet | model-agnostic post-hoc 프레임워크 부재 |

**GDL 기반 GNN explanation**은 interval-aware 설명 언어의 표현력과 dataset-level 재사용성을 모두 확보하면서도, **임의의 사전 학습 GNN에 적용 가능한 post-hoc 프레임워크** 영역을 메운다. 이 방향은 PL4XGL 저자들이 §8에서 직접 제안한 것이기도 하다. 자연스러운 3대 비교 기준은 **GNNExplainer/PGExplainer (mask 기반), SubgraphX (search 기반), GSAT (intrinsic rationale)** 이며, symbolic 계열에서는 **PL4XGL, ProgNet** 과 직접 비교한다.

### GDL 확장 방향 (Open Problems)
PL4XGL §7.1의 표현력 한계는 GDL 기반 설명에도 그대로 영향을 미치며, 다음을 해결하면 더 완전한 설명 언어가 된다.

- **Homophily / heterophily**: 이웃 label 분포 기술 (citation network 설명 실패의 원인)
- **Aggregate 술어**: "oxygen > chlorine 개수", "이웃 degree 평균 ≥ k"
- **Recursive / path 제약**: RPQ 스타일 경로 술어로 message-passing 깊이 표현
- **변수 간 비교**: `x.f ≤ y.f` 같은 symbolic 비교
- **Soft activation**: 현재 $e_P(G) \in \{0, 1\}$ 의 이진 activation을 확률적으로 완화하여 미분 가능한 post-hoc 최적화 지원
