//
//  MyPage.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/01/17.
//

import SwiftUI

enum TapMypage : String, CaseIterable {
    case myCamping = "나의 캠핑 일정"
    case bookmarkedCampingSpot = "북마크한 캠핑장"
}

// MARK: - 마이페이지 첫 화면에 나타나는 뷰
struct MyPageView: View {
    @State private var nickname: String = "민콩"
    @State private var selectedPicker2: TapMypage = .myCamping
    
    @Namespace private var animation
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            userProfileSection
            animate()
            myPageTap
        }
        .padding(.horizontal, UIScreen.screenWidth * 0.1)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("마이페이지")
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    SettingView()
                } label: {
                    Image(systemName: "gearshape").foregroundColor(.black)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: -View : 유저 프로필이미지, 닉네임 표시
    private var userProfileSection : some View {
        HStack{
            Image(systemName: "person")
                .resizable()
                .clipShape(Circle())
                .frame(width: 60, height: 60)
            Text("\(nickname) 님")
            NavigationLink {
                ProfileSettingView()
            } label: {
                Image(systemName: "chevron.right")
                    .bold()
            }
            Spacer()
        }
    }
    
    // MARK: -ViewBuilder : 탭으로 일정, 북마크 표시
    @ViewBuilder
    private func animate() -> some View {
        HStack {
            ForEach(TapMypage.allCases, id: \.self) { item in
                VStack {
                    Text(item.rawValue)
                        .font(.callout)
                        .kerning(-1)
                        .foregroundColor(selectedPicker2 == item ? .black : .gray)
                    
                    if selectedPicker2 == item {
                        Capsule()
                            .foregroundColor(.black)
                            .frame(height: 2)
                            .matchedGeometryEffect(id: "info", in: animation)
                    } else if selectedPicker2 != item {
                        Capsule()
                            .foregroundColor(.white)
                            .frame(height: 2)
                    }
                }
                .frame(width: UIScreen.screenWidth * 0.4)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        self.selectedPicker2 = item
                    }
                }
            }
        }
    }
    
    // MARK: -View : 탭뷰에 따라 나의 캠핑 일정, 북마크한 캠핑장 표시
    private var myPageTap : some View {
        VStack {
            switch selectedPicker2 {
            case .myCamping:
                VStack(spacing: 30){
                    ForEach(0..<5) { _ in
                        MyPlanCellView()
                    }
                }
            case .bookmarkedCampingSpot:
                VStack(spacing: 20){
                    ForEach(0..<5) { _ in
                        BookmarkCellView()
                    }
                }
            }
        }
    }
}


struct MyPageView_Previews: PreviewProvider {
    static var previews: some View {
        MyPageView()
    }
}
