# 2023iOS-Challenge-2nd

## 이미지 로드 관련 프로젝트.
해당 프로젝트는 iOS 챌린지 사전 과제 프로젝트.

특정 URL이 주어졌을 때, 이미지들을 로드하는 것이 주 기능.

현재 구현 방법
1. MVVM사용, Progress 처리
2. MVVM사용, Progress 미처리
3. MVVM미사용, Progress 미처리

## 1. MVVM 사용, Progress 처리
ViewController.swift의 isUsingVM 값을 true, ViewControllerViewModel.swift의 isUsingProgress 값을 true 처리.

이 경우 ViewController에서 SessionDelegate를 통해서 progress및 이미지 다운 처리하도록 되어있음.

## 2. MVVM 사용, Progress 미처리
ViewController.swift의 isUsingVM 값을 true, ViewControllerViewModel.swift의 isUsingProgress 값을 false 처리.

이 경우 Model에서 각자 이미지를 다운받아 처리하도록 구현되어있음.

## 3. MVVM 미사용, Progress 미처리
ViewController.swift의 isUsingVM 값을 false 처리.

이 경우 imageView안에서 각자 다운로드 하도록 구현되어있음.


