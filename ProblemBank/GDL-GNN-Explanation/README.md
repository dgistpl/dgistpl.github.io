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
