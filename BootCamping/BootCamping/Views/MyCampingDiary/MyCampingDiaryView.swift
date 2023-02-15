//
//  MyCampingDiary.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/01/17.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import AlertToast


struct MyCampingDiaryView: View {
    @EnvironmentObject var diaryStore: DiaryStore
    @EnvironmentObject var faceId: FaceId
    
    @StateObject var diaryLikeStore: DiaryLikeStore = DiaryLikeStore()
    @StateObject var commentStore: CommentStore = CommentStore()
    
    @EnvironmentObject var tabSelection: TabSelector
    
    @AppStorage("faceId") var usingFaceId: Bool? //페이스id 설정 사용하는지
    //faceId.isLocked // 페이스 아이디가 잠겨있는지.
    
    var body: some View {
        ZStack {
            VStack {
                ScrollView(showsIndicators: false) {
                    LazyVStack {
                        ForEach(diaryStore.myDiaryUserInfoDiaryList, id: \.self) { userInfoDiary in
                            DiaryCellView(item: userInfoDiary)
                                .task {
                                    guard let index = diaryStore.myDiaryUserInfoDiaryList.firstIndex(where: { $0.diary.id == userInfoDiary.diary.id}) else { return }

                                    if (index + 1) % 5 == 0 {
                                        Task {
                                            diaryStore.nextGetMyDiaryCombine()
                                        }
                                    }
                                    
                                }
                        }
                    }
                    .refreshable {
                        diaryStore.firstGetMyDiaryCombine()
                        //탭틱
                        UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                    }
                    .padding(.bottom, 0.1)
                }
                .background(Color.bcWhite)
                .refreshable {
                    diaryStore.firstGetMyDiaryCombine()
                    //탭틱
                    UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
                }

                
            }
            //다이어리 비어있을때 추가 화면
            DiaryEmptyView().zIndex(-1)
            diaryStore.isProcessing ? Color.black.opacity(0.3) : Color.clear

            
        }
        .onChange(of: diaryStore.createFinshed) { _ in
            diaryStore.firstGetMyDiaryCombine()
            diaryStore.firstGetRealTimeDiaryCombine()
        }
        .toolbar{
            ToolbarItem(placement: .navigationBarLeading) {
                Text("My Camping Diary")
                    .font(.title2.bold())
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink (destination: DiaryAddView())
                {
                    Image(systemName: "plus")
                }
            }
        }
        .alert("다이어리 만들기에 실패했습니다.. 다시 시도해 주세요.", isPresented: $diaryStore.isError) {
            Button("확인", role: .cancel) {
                diaryStore.isError = false
            }
            
        }
        .toast(isPresenting: $diaryStore.isProcessing) {
            AlertToast(displayMode: .alert, type: .loading)
        }
    }
}
