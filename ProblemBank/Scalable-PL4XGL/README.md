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
