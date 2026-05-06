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
