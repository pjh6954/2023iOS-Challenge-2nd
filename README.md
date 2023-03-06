# 2023iOS-Challenge-2nd

## 이미지 로드 관련 프로젝트.
해당 프로젝트는 원티드 프리온보딩 iOS 챌린지 2023년 3월 사전 프로젝트.

특정 URL이 주어졌을 때, 이미지들을 로드하는 것이 주 기능.

현재 구현 방법
1. MVVM사용, Progress 처리
2. MVVM사용, Progress 미처리
3. MVVM미사용, Progress 미처리

## 1. MVVM 사용, Progress 처리
ViewController.swift의 isUsingVM 값을 true, ViewControllerViewModel.swift의 isUsingProgress 값을 true 처리.

이 경우 ViewController에서 SessionDelegate를 통해서 progress및 이미지 다운 처리하도록 되어있음.

![MVVM Progress](https://user-images.githubusercontent.com/37360920/223026265-0ef3f09e-05a9-4781-86b6-b76674523e7a.gif)

## 2. MVVM 사용, Progress 미처리
ViewController.swift의 isUsingVM 값을 true, ViewControllerViewModel.swift의 isUsingProgress 값을 false 처리.

이 경우 Model에서 각자 이미지를 다운받아 처리하도록 구현되어있음.

![MVVM Non-Progress](https://user-images.githubusercontent.com/37360920/223026133-cbe867a6-a654-4552-af79-9866f1aabf86.gif)

## 3. MVVM 미사용, Progress 미처리
ViewController.swift의 isUsingVM 값을 false 처리.

이 경우 imageView안에서 각자 다운로드 하도록 구현되어있음.

![Non-MVVM](https://user-images.githubusercontent.com/37360920/223026309-dcd39270-1302-499a-90fb-55b454f4fab2.gif)



