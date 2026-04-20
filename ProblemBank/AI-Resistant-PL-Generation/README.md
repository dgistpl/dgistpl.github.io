# AI가 사용할 수 없고 인간만 사용할 수 있는 프로그래밍 언어를 생성하는 함수 (Generating Programming Languages Usable by Humans but Not by AI)

## 1. 문제 (Problem)

대규모 언어 모델(LLM)의 코드 생성 능력이 급격히 향상되면서, AI는 기존 프로그래밍 언어(Python, Java, C++ 등)로 작성된 코드를 이해하고, 생성하고, 변환하는 데 있어 인간에 근접하거나 이를 초월하는 성능을 보이고 있다 [Chen et al., *Codex*, 2021; Li et al., *StarCoder*, 2023; Rozière et al., *Code Llama*, 2023]. 이로 인해 다음과 같은 근본적 문제가 대두된다.

### AI 코드 능력의 위협

1. **자율 무기 및 악성 코드**: AI가 프로그래밍 언어를 자유롭게 사용할 수 있다면, 악의적 행위자가 AI를 이용하여 malware, exploit, 자율 공격 시스템을 대량으로 생성할 수 있다. 인간의 감독 없이 AI가 코드를 작성·실행·배포하는 시나리오는 심각한 안전 위협이다.

2. **Human-in-the-loop 보장**: Safety-critical 시스템(의료, 항공, 원자력, 금융)에서는 코드의 작성과 검증에 인간의 개입이 법적·윤리적으로 요구된다. 그러나 AI가 기존 프로그래밍 언어를 완벽히 사용할 수 있다면, "이 코드가 인간에 의해 작성·검증되었는가"를 확인할 기술적 수단이 없다.

3. **인간 프로그래머의 역할**: AI가 모든 프로그래밍 언어를 숙달하면, 인간 프로그래머의 고유한 역할과 가치가 무엇인지에 대한 본질적 질문이 제기된다. 인간만이 수행할 수 있는 프로그래밍 활동의 영역을 기술적으로 정의하고 보존하는 것은 사회적·기술적으로 중요하다.

4. **AI 능력 통제**: AI safety 연구의 핵심 과제 중 하나는 AI 시스템의 능력 범위를 의도적으로 제한(capability control)하는 것이다. 프로그래밍 능력은 AI의 가장 강력한 능력 중 하나이며, 이를 특정 영역에서 선택적으로 제한할 수 있다면 AI safety의 중요한 도구가 된다.

### 현재의 기술적 공백

현재 AI의 코드 능력을 제한하는 접근법은 대부분 **사후적(post-hoc)**이다:
- **코드 필터링**: AI가 생성한 코드를 사후적으로 검사하여 위험한 코드를 차단. 그러나 완벽한 필터링은 undecidable하며, 우회가 가능
- **모델 제한**: 학습 데이터에서 특정 코드 패턴을 제거하거나 RLHF로 거부 행동을 학습. 그러나 jailbreak에 취약하고, 모델이 업데이트될 때마다 재적용 필요
- **실행 환경 제한**: Sandbox, 권한 제어 등으로 AI가 실행할 수 있는 코드를 제한. 코드 작성 자체는 제한하지 못함

**사전적(proactive)**이고 **언어 수준(language-level)**에서의 접근 — 즉 **AI가 원천적으로 사용할 수 없는 프로그래밍 언어를 설계**하는 것 — 은 아직 연구되지 않았다.

### 핵심 연구 질문

**인간은 사용할 수 있지만 AI(특히 LLM)는 사용할 수 없는 프로그래밍 언어가 존재하는가? 존재한다면, 그러한 언어를 체계적으로 생성하는 함수를 구축할 수 있는가?**

이 질문은 다음과 같은 인지적·계산적 비대칭에 기반한다:

- **인간의 강점**: 시각·공간적 추론, 물리적 세계에 대한 직관, 유추(analogy)에 의한 학습, 소수의 예제로부터의 일반화, 사회적·문화적 맥락 이해, 감각 운동(sensorimotor) 통합
- **LLM의 약점**: 진정한 시각적 이해 부재(텍스트 토큰 기반), 새로운 형식 체계에 대한 few-shot 학습의 한계, 학습 분포 밖의 구문·의미론에 대한 취약성, 장거리 구조적 의존성의 불완전한 추적, 진정한 "이해" 없이 패턴 매칭에 의존

그러나 이 비대칭은 **고정적이지 않다** — AI의 능력은 빠르게 발전한다. 따라서 단일 언어를 설계하는 것이 아니라, AI의 현재 능력 수준에 맞추어 **지속적으로 새로운 AI-resistant 언어를 생성할 수 있는 함수(generator)**를 구축하는 것이 핵심이다.

## 2. 목표 (Goal)

**인간은 사용할 수 있지만 현재의 AI(LLM)는 사용할 수 없는 프로그래밍 언어를 체계적으로 생성하는 함수** $\mathcal{G}$를 개발한다.

$$\mathcal{G} : \text{AI}_{\text{capability}} \times \text{HumanCognition} \times \text{SecurityParam} \to \text{PL}$$

- **입력 1 — AI capability profile**: 대상 AI 시스템의 현재 능력 모델 (토큰화 방식, context window, 학습 데이터 분포, few-shot 학습 능력 등)
- **입력 2 — Human cognition model**: 인간 프로그래머가 활용할 수 있는 인지 능력 (시각적 추론, 공간적 사고, 유추, 문화적 지식 등)
- **입력 3 — Security parameter**: AI-resistance의 강도. 높을수록 AI가 사용하기 어렵지만 인간에게도 학습 비용이 증가
- **출력 — Programming Language**: 문법(syntax), 의미론(semantics), 타입 시스템, 도구(IDE, compiler) 등이 완전히 정의된 프로그래밍 언어

구체적 목표:
- **AI-resistance**: 생성된 언어로 작성된 프로그램을 AI(GPT-4, Claude, Code Llama 등)가 이해·생성·실행 추적할 수 없음 (정량적 측정: 코드 생성 정확도, 프로그램 이해 정확도 등이 random baseline 수준)
- **Human-usability**: 인간 프로그래머가 합리적 학습 시간(수 시간~수 일) 내에 해당 언어로 프로그래밍 가능 (정량적 측정: 학습 곡선, task completion rate, cognitive load)
- **Turing completeness**: 생성된 언어가 Turing-complete하여 임의의 계산을 표현 가능
- **실용성**: 생성된 언어가 단순한 esolang(esoteric language)이 아닌, 합리적 생산성으로 실제 프로그래밍 작업을 수행 가능
- **적응성(Adaptiveness)**: AI의 능력이 향상되면 $\mathcal{G}$의 입력을 업데이트하여 더 강한 AI-resistance를 가진 새 언어를 생성 가능
- **이론적 기반**: AI-resistance의 형식적 정의와, 특정 조건 하에서의 AI-resistance 보장에 대한 이론적 분석

## 3. 기본 접근 방법 (Basic Approach)

### (1) 인간-AI 인지 비대칭의 분류

AI-resistant 언어 설계의 기반이 되는 인간과 AI의 인지적 비대칭을 체계적으로 분류한다.

**축 1: 표현 양식(Modality)**
- **LLM의 한계**: 텍스트 토큰의 순차적 처리에 특화. 2D/3D 공간 구조, 연속적 시각 패턴, 촉각/운동감각(kinesthetic) 정보는 직접 처리 불가 (multimodal 모델에서도 시각적 "이해"는 superficial)
- **인간의 강점**: 시각적 패턴 인식, 공간적 추론, 다감각 통합
- **활용**: 2D/3D 공간적 구문, 시각적 프로그래밍 요소, 물리적 상호작용을 언어에 통합

**축 2: 분포 의존성(Distribution Dependence)**
- **LLM의 한계**: 학습 데이터 분포에 강하게 의존. 학습 분포 밖의 구문, 의미론, 프로그래밍 패러다임에 대해 급격히 성능 저하. Few-shot 학습은 개선하지만, genuinely novel한 형식 체계에는 한계
- **인간의 강점**: 유추(analogy), 추상적 원리 이해, 소수 예제로부터의 일반화
- **활용**: 기존 언어와 의도적으로 상이한 구문·의미론, 주기적으로 변경되는 언어 규칙

**축 3: 형식적 추론(Formal Reasoning)**
- **LLM의 한계**: 새로운 형식 체계(novel type system, novel evaluation rule)에 대한 엄밀한 추론이 약함. 학습된 패턴의 보간(interpolation)으로 추론을 흉내내지만, genuinely novel한 규칙에는 실패
- **인간의 강점**: 형식적 규칙을 읽고 이해하고 적용하는 능력 (수학, 논리학 교육을 통해)
- **활용**: 의미론이 novel한 형식적 규칙으로 정의된 언어

**축 4: 신체성 / 물리적 세계(Embodiment)**
- **LLM의 한계**: 물리적 세계와의 직접적 상호작용 부재. 물리적 직관에 기반한 추론이 약함
- **인간의 강점**: 물리적 세계에 대한 풍부한 직관, 공간적 조작 능력
- **활용**: 물리적 메타포에 기반한 의미론, 물리적 장치와의 상호작용을 포함하는 프로그래밍

**축 5: 사회적·문화적 지식(Social/Cultural Knowledge)**
- **LLM의 한계**: 학습 데이터에 포함된 문화적 지식은 재현하지만, implicit/tacit 지식, 로컬 문화, 개인적 경험에 기반한 추론은 불가
- **인간의 강점**: 공유된 문화적 맥락, 암묵적 지식, 사회적 관습에 대한 이해
- **활용**: 특정 공동체의 공유 지식을 전제로 하는 언어 요소

### (2) AI-Resistant 언어 특성의 설계 공간

각 비대칭 축에서 구체적인 언어 특성(language feature)을 도출한다.

**Feature A: 비순차적 구문(Non-sequential Syntax)**
- 프로그램이 1D 텍스트가 아닌 **2D 그리드, 그래프, 또는 다이어그램** 으로 작성
- 예: Befunge/Piet 계열이지만 실용적 수준으로 확장. 제어 흐름이 2D 공간에서의 방향·경로로 표현
- AI-resistance 근거: LLM의 토크나이저와 attention은 1D 순차 입력에 최적화. 2D 구조의 의미론적 해석은 학습 분포에 포함되지 않음
- Human-usability 근거: 인간은 flowchart, circuit diagram 등 2D 표현에 자연스럽게 추론

**Feature B: 동적 구문 변환(Dynamic Syntax Mutation)**
- 프로그램의 구문 규칙이 **실행 중에 변경**되거나, **프로그램 자체에 의해 재정의**됨
- 예: 특정 구문 블록 내에서 연산자의 의미나 키워드가 재정의되는 meta-syntactic facility
- AI-resistance 근거: LLM은 고정된 문법을 학습. 문법 자체가 동적이면 학습된 토크나이징·파싱 패턴이 무효화
- Human-usability 근거: 인간은 "이 맥락에서 + 는 문자열 결합을 의미한다"와 같은 context-dependent 재해석에 능숙

**Feature C: 비관습적 제어 흐름(Unconventional Control Flow)**
- 기존 언어의 if/while/for/recursion과 질적으로 다른 제어 흐름 메커니즘
- 예: 물리 시뮬레이션 기반 실행(프로그램이 물리 법칙에 따라 "흐른다"), 생태학적 모델(프로그램이 생태계 역학으로 진화), 음악적 구조(프로그램이 악보 구조로 실행)
- AI-resistance 근거: LLM이 학습한 제어 흐름은 기존 언어의 패턴. Novel 제어 흐름은 학습 분포 밖
- Human-usability 근거: 인간은 물리적·음악적·생태학적 직관을 프로그래밍에 전이 가능

**Feature D: 암호학적 구문 요소(Cryptographic Syntactic Elements)**
- 프로그램의 특정 부분이 암호학적 퍼즐을 풀어야 해석 가능
- 예: 프로그램의 키워드가 시각적 CAPTCHA 형태로 인코딩, 또는 프로그램 작성에 물리적 토큰(하드웨어 키)이 필요
- AI-resistance 근거: CAPTCHA solving은 AI의 약점 중 하나 (비록 향상 중). 물리적 토큰은 근본적으로 디지털 AI의 접근 불가
- Human-usability 근거: 인간은 시각적 CAPTCHA를 쉽게 해결, 물리적 장치 조작에 능숙

**Feature E: 의미론적 접지(Semantic Grounding)**
- 프로그램의 의미가 외부 세계의 상태나 물리적 속성에 의존
- 예: 변수의 값이 현재 날씨·위치·시간에 따라 결정되는 규칙, 물리적 측정(센서 값)이 프로그램 의미론의 일부
- AI-resistance 근거: LLM은 외부 세계와 직접 상호작용하지 못함
- Human-usability 근거: 인간은 물리적 세계에 내재(embedded)되어 있으며 환경과 자연스럽게 상호작용

**Feature F: 주기적 언어 진화(Periodic Language Evolution)**
- 언어의 구문·의미론이 **정기적으로 변경**되며, 변경 규칙은 이전 버전을 아는 인간에게는 자연스럽지만 AI에게는 학습 분포 이탈
- 예: 매월 키워드가 회전(rotate), 연산자의 우선순위가 특정 패턴으로 변경, 타입 규칙이 점진적으로 진화
- AI-resistance 근거: AI는 과거 데이터로 학습하므로 지속적 변경에 적응이 느림. 인간은 변경 규칙의 "원리"를 이해하면 빠르게 적응
- Human-usability 근거: 자연어도 지속적으로 변화하며 인간은 이에 적응

### (3) 생성 함수 $\mathcal{G}$의 설계

언어 생성 함수의 아키텍처를 설계한다.

**단계 1: AI capability probing**
- 대상 AI 시스템의 현재 능력을 체계적으로 측정
- Probing 벤치마크: novel 구문 학습 능력, 2D 구조 해석 능력, 새로운 형식 규칙 추론 능력, few-shot 프로그래밍 학습 능력
- 출력: AI capability profile $\mathcal{A} = (a_1, \ldots, a_n)$ — 각 축에서의 능력 수준

**단계 2: 인간-AI gap 식별**
- 각 비대칭 축에서 현재 AI 능력과 인간 능력의 gap을 측정
- Gap이 큰 축일수록 해당 축의 feature를 강하게 활용

**단계 3: Feature composition**
- 식별된 gap에 기반하여 language feature의 조합을 결정
- Security parameter에 따라 feature의 수와 강도를 조절
- Turing completeness를 보존하면서 feature를 결합하는 composition 규칙

**단계 4: 언어 생성**
- 선택된 feature 조합에 따라 concrete 언어 사양(구문, 의미론, 타입 시스템)을 생성
- BNF/EBNF 형태의 문법, operational semantics, 타입 규칙을 자동 생성
- 컴파일러/인터프리터 scaffold를 자동 생성

**단계 5: AI-resistance 검증**
- 생성된 언어에 대해 현재 AI 시스템의 사용 능력을 측정
- 목표 AI-resistance 수준에 도달하지 못하면 feature를 강화하여 재생성

**단계 6: Human-usability 검증**
- 인간 대상 사용성 평가(학습 시간, task completion, 인지 부하)
- Human-usability가 기준 이하이면 feature를 완화하여 재생성

### (4) 형식적 프레임워크

AI-resistance를 형식적으로 정의한다.

**정의: $(ε, δ)$-AI-resistance**
- 언어 $L$이 AI 시스템 $\mathcal{A}$에 대해 $(ε, δ)$-AI-resistant ⟺ $\mathcal{A}$가 $L$로 작성된 프로그래밍 작업을 수행할 때, 성공률이 random baseline + $ε$ 이하 (확률 $1 - δ$ 이상)
- $ε$이 작고 $δ$가 작을수록 강한 AI-resistance

**정의: Human-usability**
- 언어 $L$이 $(\tau, \rho)$-human-usable ⟺ 프로그래밍 경험이 있는 인간이 $\tau$ 시간 이내의 학습 후 표준 프로그래밍 작업을 $\rho$ 이상의 성공률로 수행 가능

**정의: AI-resistance margin**
- $\text{margin}(L, \mathcal{A}) = \text{HumanPerformance}(L) - \text{AIPerformance}(L, \mathcal{A})$
- Margin이 클수록 인간-AI 성능 차이가 크며, 이것이 $\mathcal{G}$가 최대화해야 할 목표

### (5) 이론적 한계 분석

- **존재성**: 인간은 사용할 수 있지만 AI는 사용할 수 없는 언어가 원리적으로 존재하는가? Computability theory와 cognitive science의 교차점에서 분석
- **AI 적응의 한계**: AI가 생성된 언어를 학습하여 AI-resistance를 무력화하는 데 필요한 데이터량과 계산량의 하한. PAC learning의 sample complexity와 관련
- **Arms race 역학**: AI가 적응하면 $\mathcal{G}$가 더 강한 언어를 생성하는 반복적 게임. 이 게임의 균형점(equilibrium)이 존재하는가?
- **Fundamental limit**: 인간의 인지 능력도 유한하므로, AI-resistance를 높이면 human-usability도 감소. 두 조건을 동시에 만족하는 **Pareto frontier**의 특성 분석

## 4. 후보 벤치마크 (Candidate Benchmarks)

### AI 코드 능력 평가 (AI-resistance 측정)
- **HumanEval** [Chen et al., 2021] — 164개 Python 프로그래밍 문제, Codex의 표준 벤치마크
- **MBPP** [Austin et al., 2021] — 974개 Python 프로그래밍 문제
- **APPS** [Hendrycks et al., NeurIPS 2021] — 경쟁 프로그래밍 문제
- **SWE-bench** [Jimenez et al., 2024] — 실세계 소프트웨어 엔지니어링 작업
- **CodeContests** [Li et al., 2022] — 프로그래밍 대회 문제
- *이 벤치마크들의 문제를 생성된 AI-resistant 언어로 번역하여 AI의 성능 저하를 측정*

### 인간 사용성 평가 (Human-usability 측정)
- **Cognitive load 측정**: NASA-TLX [Hart & Staveland, 1988]
- **학습 곡선**: 시간에 따른 task completion rate
- **프로그래밍 작업 스위트**: FizzBuzz, sorting, tree traversal, simple web server 등 표준 프로그래밍 과제를 AI-resistant 언어로 수행
- **비교 기준**: 동일 작업을 Python/JavaScript로 수행했을 때 대비 시간·정확도 비율

### Novel 언어 학습 능력 평가 (비대칭 측정)
- **BabyLM** [Warstadt et al., 2023] — 제한된 데이터로의 언어 학습 평가
- **ARC (Abstraction and Reasoning Corpus)** [Chollet, 2019] — AI의 추상적 추론 능력 평가. 시각적·공간적 패턴 인식
- **Novel language learning benchmark** (신규 구축): 완전히 새로운 형식 체계를 few-shot으로 학습하는 능력을 인간과 AI에서 비교
- **CAPTCHA 벤치마크**: 시각적 CAPTCHA 해결 능력의 인간-AI 비교

### Esolang 벤치마크 (기존 비관습적 언어에서의 AI 성능)
- **Befunge-93/98** — 2D 프로그래밍 언어
- **Piet** — 색상 기반 시각적 프로그래밍 언어
- **Malbolge** — 극도로 난해한 언어
- **Whitespace** — 공백 문자만 사용하는 언어
- **Chef, Shakespeare** — 자연어 모방 esolang
- *기존 esolang에 대한 AI의 성능을 baseline으로 측정 — esolang의 AI-resistance가 어디서 오는지 분석*

### AI 시스템 (AI-resistance 평가 대상)
- **GPT-4 / GPT-4o** [OpenAI, 2023]
- **Claude 3.5 Sonnet / Claude Opus** [Anthropic, 2024]
- **Code Llama** [Rozière et al., 2023] — open-source 코드 LLM
- **StarCoder 2** [Li et al., 2024]
- **DeepSeek-Coder** [Guo et al., 2024]
- **Gemini** [Google, 2024]
- *여러 AI 시스템에 대해 AI-resistance를 측정하여, 특정 모델에만 유효한 것이 아닌 범용적 AI-resistance 확인*

## 5. 후보 베이스라인 (Candidate Baselines)

### 5.1 기존 프로그래밍 언어 (AI-resistance 없음 — 하한)
- **Python, JavaScript, Java, C++** — AI가 높은 성능을 보이는 주류 언어. AI-resistance ≈ 0
- **Haskell, Prolog, APL, Forth** — 비주류 패러다임. AI 성능이 주류 대비 낮지만, 상당한 학습 데이터가 존재하여 AI-resistance는 제한적

### 5.2 Esolang (의도적 난해함 — 참고)
- **Brainfuck** — 최소 명령어 집합. AI가 학습 데이터에서 보았으므로 일부 사용 가능
- **Befunge** — 2D 언어. AI의 2D 추론 능력 테스트
- **Piet** — 시각적 언어. AI의 이미지 기반 코드 이해 테스트
- **Malbolge** — 극도의 난해함. 인간도 사용하기 어려움 → human-usability 실패의 반면교사
- *Esolang은 AI-resistance를 우연히 달성하지만, (a) 의도적 설계가 아니고, (b) human-usability도 낮으며, (c) 체계적 생성이 불가*

### 5.3 시각적/블록 기반 프로그래밍 언어 (대안적 모달리티)
- **Scratch** [Resnick et al., 2009] — 블록 기반 시각적 언어
- **LabVIEW** — 데이터 흐름 시각적 언어
- **Unreal Blueprints** — 노드 기반 시각적 스크립팅
- *시각적 언어는 LLM의 텍스트 처리에 자연스러운 장벽이 되지만, multimodal AI의 발전으로 장기적 AI-resistance는 불확실*

### 5.4 암호학적 난독화 (코드 보호 기법)
- **Code obfuscation** [Collberg et al., 1997] — 코드의 의미를 보존하면서 이해를 어렵게 함
- **Indistinguishability obfuscation** [Garg et al., FOCS 2013] — 이론적 최강 난독화
- **Homomorphic encryption** [Gentry, STOC 2009] — 암호화된 채로 계산
- *이들은 "코드 보호"이지 "언어 설계"가 아님. AI뿐 아니라 인간의 이해도 차단하므로 본 연구와 목적이 다름*

### 5.5 CAPTCHA / Human verification (인간-AI 구별)
- **reCAPTCHA** [von Ahn et al., 2008] — 시각적 인간 검증
- **PoW (Proof of Work)** — 계산적 검증
- *CAPTCHA는 "인간인지 AI인지를 검증"하는 것이고, 본 연구는 "인간만 사용 가능한 도구를 설계"하는 것. 관련되지만 목적이 다름*

### 5.6 AI Safety / Capability Control
- **AI sandboxing** [Armstrong et al., 2012]
- **Tool AI** [Drexler, 2019] — AI를 도구 수준으로 제한
- **Corrigibility** [Soares et al., 2015] — AI의 수정 가능성 보장
- *이들은 AI 능력 통제의 일반 이론. 본 연구는 프로그래밍 능력이라는 특정 축에서의 통제*

### 평가 지표

**AI-resistance**:
- **코드 생성 정확도**: HumanEval 스타일 task에서 pass@k (낮을수록 resistant)
- **코드 이해 정확도**: 생성된 언어의 코드에 대한 Q&A 정확도
- **프로그램 실행 추적**: AI가 생성된 언어의 프로그램 실행을 정확히 추적하는 비율
- **AI-resistance margin**: $\text{HumanPerformance} - \text{AIPerformance}$

**Human-usability**:
- **학습 시간**: 인간이 기본 작업을 수행할 수 있게 되기까지의 시간
- **Task completion rate**: 표준 프로그래밍 작업의 완료율
- **Cognitive load**: NASA-TLX 점수
- **프로그래밍 생산성**: 동일 작업을 Python으로 수행했을 때 대비 비율

**언어 품질**:
- **Turing completeness**: 증명 또는 시뮬레이션
- **표현력**: 다양한 프로그래밍 패러다임의 표현 가능성
- **도구 지원**: 컴파일러/인터프리터, 디버거, IDE 지원의 성숙도

**적응성**:
- **AI fine-tuning resistance**: AI가 생성된 언어의 예제를 fine-tuning한 후에도 AI-resistance가 유지되는가
- **진화 비용**: 언어를 다음 버전으로 업데이트하는 데 필요한 인간 학습 비용

---

## 연구 지형 요약 (Research Landscape Summary)

| 축 | 대표 연구 | AI-resistant | Human-usable | 체계적 생성 | 비고 |
|---|---|---|---|---|---|
| 주류 PL | Python, Java, C++ | ❌ | ✅ | N/A | AI가 완전 사용 가능 |
| Esolang | Brainfuck, Befunge, Piet | △ (우연) | ❌ | ❌ | 인간도 사용 어려움 |
| 시각적 PL | Scratch, LabVIEW | △ | ✅ | ❌ | Multimodal AI에 취약 |
| 코드 난독화 | Obfuscation, HE | ✅ | ❌ | △ | 인간도 이해 불가 |
| CAPTCHA | reCAPTCHA | ✅ (검증) | ✅ | ✅ | 프로그래밍 아닌 검증 |
| AI Safety | Sandboxing, corrigibility | △ | N/A | ❌ | 일반 통제, PL 무관 |
| **본 연구: AI-Resistant PL Generation** | — | **✅** | **✅** | **✅** | **새로운 연구 영역** |

본 연구는 **프로그래밍 언어 설계**, **AI 안전(safety)**, **인지 과학(cognitive science)**, **암호학(cryptography)** 의 교차점에 위치하는 새로운 연구 영역을 개척한다. 핵심 기여는 단일 AI-resistant 언어의 설계가 아니라, **AI의 능력 변화에 적응하여 지속적으로 새로운 AI-resistant 언어를 생성하는 함수** $\mathcal{G}$의 구축이다.

### 주요 Open Question
- **근본적 존재성**: Turing-complete이면서 인간은 실용적으로 사용 가능하지만 AI는 사용 불가능한 언어가 원리적으로 존재하는가? 아니면 충분한 학습 데이터와 계산 자원이 주어지면 AI는 임의의 형식 체계를 학습할 수 있는가?
- **Arms race의 결말**: AI가 생성된 언어를 학습하면 $\mathcal{G}$가 더 강한 언어를 생성하는 반복적 게임에서, 인간의 인지 능력이라는 상한 때문에 결국 AI가 승리하는가? 아니면 인간의 신체성(embodiment)이라는 근본적 장벽이 영구적 비대칭을 제공하는가?
- **Multimodal AI의 영향**: GPT-4V, Gemini 등 multimodal AI가 시각적 추론 능력을 획득하면, 축 1(표현 양식)에 기반한 AI-resistance가 무력화되는가?
- **실용성과 AI-resistance의 trade-off**: AI-resistance를 높이면 인간의 프로그래밍 생산성도 감소한다. 산업적으로 수용 가능한 생산성을 유지하면서 달성 가능한 최대 AI-resistance는?
- **법적·윤리적 함의**: AI-resistant 언어로만 작성되어야 하는 소프트웨어의 범위는? Safety-critical 시스템에 대한 규제 프레임워크와의 연결
- **인간의 적응 가능성**: 과연 인간이 비관습적 프로그래밍 언어를 "합리적 시간 내에" 배울 수 있는가? 인간의 프로그래밍 언어 학습 능력에 대한 인지 과학적 연구가 필요
