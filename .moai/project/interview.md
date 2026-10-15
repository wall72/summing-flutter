# Project Interview

## Stage A Round 1: Ownership, Purpose, and Goal
Question: 이 프로젝트의 앞으로 방향(목표)은 무엇에 가깝나요?
Answer: 웹 중심으로 완성도 높이기
Domain: puzzle-game (auto-populated from codebase analysis)
Goal: Web을 주 플랫폼으로 삼아 Summing 퍼즐 게임의 기능과 품질을 다듬는다 (Android/iOS 폴더는 유지하되 우선순위 낮음)

## Stage A Round 2: Constraints and Non-Goals
Question: 문서에 꼭 기록해둘 제약이나 '하지 않을 것'이 있나요?
Answer: 특별한 제약 없음
Constraints: none known

## Stage A Round 3: Scope, Boundaries, and Documentation Priority
Question: 이번 문서가 다루는 범위(할 것 / 하지 않을 것)는 어디까지로 잡을까요?
Answer: 현재 게임 기능 + 품질 개선
Scope: In scope — 현재 구현된 메뉴·게임·점수판·저장·오디오와 테스트·아키텍처 개선. Out of scope — 신규 게임 모드, 온라인 기능, 릴리스/배포 자동화.

## Stage B Round 4: Verification, Surfaces, and Sharing
Verification: flutter analyze && flutter test
UI surface: has-ui
External systems: none (로컬 shared_preferences만 사용)
Team sharing: solo
