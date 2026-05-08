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
