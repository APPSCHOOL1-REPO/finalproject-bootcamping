//
//  DiaryCellView.swift
//  BootCamping
//
//  Created by 박성민 on 2023/01/18.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase

struct DiaryCellView: View {
    @EnvironmentObject var bookmarkStore: BookmarkStore
    @EnvironmentObject var diaryStore: DiaryStore
    @EnvironmentObject var wholeAuthStore: WholeAuthStore
    @EnvironmentObject var diaryLikeStore: DiaryLikeStore
    @EnvironmentObject var commentStore: CommentStore
    
    @StateObject var campingSpotStore: CampingSpotStore = CampingSpotStore()
    
    @State var isBookmarked: Bool = false
    
    //선택한 다이어리 정보 변수입니다.
    var item: Diary
    //삭제 알림
    @State private var isShowingDeleteAlert = false
    //유저 신고/ 차단 알림
    @State private var isShowingUserReportAlert = false
    @State private var isShowingUserBlockedAlert = false
    
    var body: some View {
        VStack(alignment: .leading) {
            diaryUserProfile
            diaryImage
            NavigationLink {
                DiaryDetailView(item: item)
            } label: {
                VStack(alignment: .leading) {
                    HStack(alignment: .center){
                        if item.uid == wholeAuthStore.currnetUserInfo!.id {
                            isPrivateImage
                        }
                        diaryTitle
                        Spacer()
                        bookmarkButton
                    }
                    diaryContent
                    if !campingSpotStore.campingSpotList.isEmpty {
                        diaryCampingLink
                    }
                    diaryDetailInfo
                    Divider().padding(.bottom, 3)
                    
                }
                .padding(.horizontal, UIScreen.screenWidth * 0.03)
            }
            .foregroundColor(.bcBlack)
        }
        
        .onAppear {
            isBookmarked = bookmarkStore.checkBookmarkedDiary(currentUser: wholeAuthStore.currentUser, userList: wholeAuthStore.userList, diaryId: item.id)
            commentStore.readCommentsCombine(diaryId: item.id)
            campingSpotStore.readCampingSpotListCombine(readDocument: ReadDocuments(campingSpotContenId: [item.diaryAddress]))
        }
    }
}

private extension DiaryCellView {
    //TODO: -유저 프로필 이미지 연결
//    var userProfileURL: String? {
//        for user in wholeAuthStore.userList {
//            if user.id == item.uid {
//                return user.profileImageURL
//            }
//        }
//        return ""
//    }
    
    
    //MARK: - 메인 이미지
    var diaryImage: some View {
        TabView{
            ForEach(item.diaryImageURLs, id: \.self) { url in
                WebImage(url: URL(string: url))
                    .resizable()
                    .placeholder {
                        Rectangle().foregroundColor(.gray)
                    }
                    .scaledToFill()
                    .frame(width: UIScreen.screenWidth, height: UIScreen.screenWidth)
                    .clipped()
            }
        }
        .frame(width: UIScreen.screenWidth, height: UIScreen.screenWidth)
        .tabViewStyle(PageTabViewStyle())
        // .never 로 하면 배경 안보이고 .always 로 하면 인디케이터 배경 보입니다.
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
        //        .padding(.vertical, 3)
    }
    
    //MARK: - 다이어리 작성자 프로필
    var diaryUserProfile: some View {
        HStack {
            //TODO: -다이어리 작성자 url 추가 (연산프로퍼티 작동 안됨)
            WebImage(url: URL(string: "https://firebasestorage.googleapis.com:443/v0/b/bootcamping-280fc.appspot.com/o/UserImages%2F6A6EB85C-6113-4FDA-BC23-62C1285762EF?alt=media&token=ed35fe2c-4f99-4293-99e5-5c35ca14b291"))
                .resizable()
                .placeholder {
                    Rectangle().foregroundColor(.gray)
                }
                .scaledToFill()
                .frame(width: 45)
                .clipShape(Circle())
            
            //유저 닉네임
            Text(item.diaryUserNickName)
                .font(.headline).fontWeight(.semibold)
            Spacer()
            //MARK: -...버튼 글 쓴 유저일때만 ...나타나도록
            if item.uid == Auth.auth().currentUser?.uid {
                alertMenu
                    .padding(.horizontal, UIScreen.screenWidth * 0.03)
                    .padding(.top, 5)
            }
            //TODO: -글 쓴 유저가 아닐때는 신고기능 넣기
            else {
                reportAlertMenu
                    .padding(.horizontal, UIScreen.screenWidth * 0.03)
                    .padding(.top, 5)
            }
            
        }
    }
    
    
    //MARK: - Alert Menu 버튼
    var alertMenu: some View {
        //MARK: - ... 버튼입니다.
        Menu {
            Button {
                //TODO: -수정기능 추가
            } label: {
                Text("수정하기")
            }
            
            Button {
                isShowingDeleteAlert = true
            } label: {
                Text("삭제하기")
            }
            
        } label: {
            Image(systemName: "ellipsis")
                .font(.title3)
        }
        //MARK: - 일기 삭제 알림
        .alert("일기를 삭제하시겠습니까?", isPresented: $isShowingDeleteAlert) {
            Button("취소", role: .cancel) {
                isShowingDeleteAlert = false
            }
            Button("삭제", role: .destructive) {
                diaryStore.deleteDiaryCombine(diary: item)
            }
        }
    }
    
    //MARK: - 유저 신고 / 차단 버튼
    var reportAlertMenu: some View {
        //MARK: - ... 버튼입니다.
        Menu {
            Button {
                isShowingUserReportAlert = true
            } label: {
                Text("신고하기")
            }
            
            Button {
                isShowingDeleteAlert = true
            } label: {
                Text("차단하기")
            }
            
        } label: {
            Image(systemName: "ellipsis")
                .font(.title3)
        }
        //MARK: - 유저 신고 알림
        .alert("유저를 신고하시겠습니까?", isPresented: $isShowingUserReportAlert) {
            Button("취소", role: .cancel) {
                isShowingUserReportAlert = false
            }
            Button("신고하기", role: .destructive) {
                ReportUserView(placeholder: "", options: [])
            }
        }
        .alert("유저를 차단하시겠습니까?", isPresented: $isShowingUserBlockedAlert) {
            Button("취소", role: .cancel) {
                isShowingUserBlockedAlert = false
            }
            Button("차단하기", role: .destructive) {
                //차단 컴바인..
            }
        }
    }
    
    //MARK: - 제목
    var diaryTitle: some View {
        Text(item.diaryTitle)
            .font(.system(.title3, weight: .semibold))
            .padding(.vertical, 5)
    }
    
    // MARK: - 다이어리 공개 여부를 나타내는 이미지
    private var isPrivateImage: some View {
        Image(systemName: (item.diaryIsPrivate ? "lock" : "lock.open"))
            .foregroundColor(Color.secondary)
    }
    
    // MARK: - 북마크 버튼
    private var bookmarkButton: some View {
        Button{
            isBookmarked.toggle()
            if isBookmarked{
                bookmarkStore.addBookmarkDiaryCombine(diaryId: item.id)
            } else {
                bookmarkStore.removeBookmarkDiaryCombine(diaryId: item.id)
            }
            wholeAuthStore.readUserListCombine()
        } label: {
            Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                .bold()
                .foregroundColor(Color.accentColor)
                .opacity((item.uid != wholeAuthStore.currnetUserInfo!.id ? 1 : 0))
        }
        .disabled(item.uid == wholeAuthStore.currnetUserInfo!.id)
    }
    
    //MARK: - 내용
    var diaryContent: some View {
        Text(item.diaryContent)
            .lineLimit(3)
            .multilineTextAlignment(.leading)
    }
    
    //MARK: - 캠핑장 이동
    var diaryCampingLink: some View {
        HStack {
            WebImage(url: URL(string: campingSpotStore.campingSpotList.first?.firstImageUrl ?? "")) //TODO: -캠핑장 사진 연동
                .resizable()
                .frame(width: 60, height: 60)
                .padding(.trailing, 5)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(campingSpotStore.campingSpotList.first?.facltNm ?? "")
                    .font(.headline)
                HStack {
                    Text(campingSpotStore.campingSpotList.first?.addr1 ?? "")
                    //TODO: 캠핑장 주소 -앞에 -시 -구 까지 짜르기
                        .font(.footnote)
                        .padding(.vertical, 2)
                    Spacer()
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            .foregroundColor(.bcBlack)
            
        }
        .padding(10)
        .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.bcDarkGray, lineWidth: 1)
                    .opacity(0.3)
            )
    }
    
    
    //MARK: - 좋아요, 댓글, 타임스탬프
    var diaryDetailInfo: some View {
        HStack {
            Button {
                //좋아요 버튼, 카운드
                if item.diaryLike.contains(Auth.auth().currentUser?.uid ?? "") {
                    diaryLikeStore.removeDiaryLikeCombine(diaryId: item.id)
                } else {
                    diaryLikeStore.addDiaryLikeCombine(diaryId: item.id)
                }
                diaryStore.readDiarysCombine()
            } label: {
                Image(systemName: item.diaryLike.contains(Auth.auth().currentUser?.uid ?? "") ? "flame.fill" : "flame")
                    .foregroundColor(item.diaryLike.contains(Auth.auth().currentUser?.uid ?? "") ? .red : .bcBlack)
            }
            Text("\(item.diaryLike.count)")
                .padding(.trailing, 7)
            
            //댓글 버튼
            Button {
                //"댓글 작성 버튼으로 이동"
            } label: {
                Image(systemName: "message")
            }
            Text("\(commentStore.commentList.count)")
                .font(.body)
                .padding(.horizontal, 3)
            
            Spacer()
            //작성 경과시간
            Text("\(TimestampToString.dateString(item.diaryCreatedDate)) 전")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .foregroundColor(.bcBlack)
        .font(.title3)
        .padding(.vertical, 5)
    }
}


struct DiaryCellView_Previews: PreviewProvider {
    static var previews: some View {
        DiaryCellView(item: Diary(id: "", uid: "", diaryUserNickName: "닉네임", diaryTitle: "안녕", diaryAddress: "주소", diaryContent: "내용", diaryImageNames: [""], diaryImageURLs: [
            "https://firebasestorage.googleapis.com:443/v0/b/bootcamping-280fc.appspot.com/o/DiaryImages%2F302EEA64-722A-4FE7-8129-3392EE578AE9?alt=media&token=1083ed77-f3cd-47db-81d3-471913f71c47"], diaryCreatedDate: Timestamp(), diaryVisitedDate: Date(), diaryLike: ["동훈"], diaryIsPrivate: true))
        .environmentObject(WholeAuthStore())
        .environmentObject(DiaryStore())
        .environmentObject(BookmarkStore())
        .environmentObject(DiaryLikeStore())
        .environmentObject(CommentStore())
        
    }
}


