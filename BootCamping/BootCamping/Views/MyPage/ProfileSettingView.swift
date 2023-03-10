//
//  ProfileSettingView.swift
//  BootCamping
//
//  Created by 이민경 on 2023/01/18.
//

import SwiftUI
import PhotosUI
import FirebaseAuth
import SDWebImageSwiftUI

// MARK: - View: ProfileSettingView
/// 사용자의 프로필 사진과 닉네임을 변경할 수 있는 뷰
struct ProfileSettingView: View {
    
    //이미지 피커
    @State private var imagePickerPresented = false // 이미지 피커를 띄울 변수
    @State private var selectedImage: UIImage?      // 이미지 피커에서 선택한 이미지저장. UIImage 타입
    @State private var profileImage: Data?          // selectedImage를 Data 타입으로 저장
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var wholeAuthStore: WholeAuthStore
    @EnvironmentObject var diaryStore: DiaryStore
    
    
    @State private var updateNickname: String = ""
    
    @State private var isProfileImageReset: Bool = false    // 프로필 사진 기본이미지로 설정할 때 필요
    
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: UIScreen.screenHeight * 0.03){
                HStack{
                    Spacer()
                    imagePicker
                    Spacer()
                }
                updateUserNameTextField
                    .padding(.bottom)
                editButton
            }
        }
        .padding(.horizontal, UIScreen.screenWidth * 0.03)
        
    }
    
}

extension ProfileSettingView {
    
    // MARK: View: 이미지피커
    private var imagePicker: some View {
        VStack{
            Button(action: {
                imagePickerPresented.toggle()
            }, label: {
                if profileImage == nil {
                    // 프로필 사진을 안골랐을 때
                    if wholeAuthStore.currnetUserInfo!.profileImageURL != "" && isProfileImageReset == false {
                        // 기존 사용자 프로필 사진이 있고 기본 이미지를 선택하지 않은 경우 -> 기존 사용자의 프로필 이미지를 보여준다.
                        WebImage(url: URL(string: wholeAuthStore.currnetUserInfo!.profileImageURL))
                            .resizable()
                            .scaledToFill()
                            .clipped()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay{
                                ZStack{
                                    Image(systemName: "circlebadge.fill")
                                        .font(.largeTitle)
                                        .foregroundColor(.primary)
                                        .colorInvert()
                                        .offset(x: 40, y: 40)
                                    
                                    Image(systemName: "pencil.circle")
                                        .font(.title)
                                        .foregroundColor(.bcBlack)
                                        .offset(x: 40, y: 40)
                                }
                            }
                    } else if wholeAuthStore.currnetUserInfo!.profileImageURL == "" || isProfileImageReset == true{
                        // 기존 프로필 사진도 없거나, 기본 이미지를 선택한 경우 -> 기본 프로필 이미지(부트캠핑 로고) 를 보여준다
                        Image("defaultProfileImage")
                            .resizable()
                            .scaledToFill()
                            .clipped()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                            .overlay{
                                ZStack{
                                    Image(systemName: "circlebadge.fill")
                                        .font(.largeTitle)
                                        .foregroundColor(.primary)
                                        .colorInvert()
                                        .offset(x: 40, y: 40)
                                    
                                    Image(systemName: "pencil.circle")
                                        .font(.title)
                                        .foregroundColor(.bcBlack)
                                        .offset(x: 40, y: 40)
                                }
                            }
                    }
                } else {
                    // 프로필 사진을 골랐을 때
                    let image = UIImage(data: profileImage ?? Data()) == nil ? UIImage(contentsOfFile: "defaultProfileImage") : UIImage(data: profileImage ?? Data()) ?? UIImage(contentsOfFile: "defaultProfileImage")
                    Image(uiImage: ((image ?? UIImage(contentsOfFile: "defaultProfileImage"))!))
                        .resizable()
                        .scaledToFill()
                        .clipped()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay{
                            ZStack{
                                Image(systemName: "circlebadge.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(.primary)
                                    .colorInvert()
                                    .offset(x: 40, y: 40)
                                
                                Image(systemName: "pencil.circle")
                                    .font(.title)
                                    .foregroundColor(.bcBlack)
                                    .offset(x: 40, y: 40)
                            }
                        }
                    
                }
            })
            .sheet(isPresented: $imagePickerPresented,
                   onDismiss: { loadData() },
                   content: { ImagePicker(image: $selectedImage) })
            .padding(.bottom, 7)
            
            // 기본 이미지로 변경할 수 있는 버튼
            Button {
                profileImage = nil
                isProfileImageReset = true
            } label: {
                Text("기본 이미지로 변경")
                    .font(.caption2)
                    .padding(4)
                    .overlay{
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.bcDarkGray)
                            .opacity(0.3)
                    }
            }
        }
    }
    
    // selectedImage: UIImage 타입을 Data타입으로 저장하는 함수
    func loadData() {
        guard let selectedImage = selectedImage else { return }
        profileImage = selectedImage.jpegData(compressionQuality: 0.1)
    }
    
    
    // MARK: -View : updateUserNameTextField
    private var updateUserNameTextField : some View {
        VStack(alignment: .leading, spacing: 10){
            Text("닉네임")
                .font(.title3)
                .bold()
            TextField("닉네임", text: $updateNickname,prompt: Text("\(wholeAuthStore.currnetUserInfo!.nickName)"))
                .textFieldStyle(.roundedBorder)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.never)
        }
    }
    
    
    // MARK: -View : editButton
    private var editButton : some View {
        Button {
            // TODO: UserInfo 수정하기
            if updateNickname == "" {
                //닉네임 x 사진 기본으로
                if isProfileImageReset {
                    wholeAuthStore.updateUserCombine(image: nil, user: User(id: wholeAuthStore.currnetUserInfo!.id, profileImageName: wholeAuthStore.currnetUserInfo!.profileImageName, profileImageURL: wholeAuthStore.currnetUserInfo!.profileImageURL, nickName: wholeAuthStore.currnetUserInfo!.nickName, userEmail: "", bookMarkedDiaries: wholeAuthStore.currnetUserInfo!.bookMarkedDiaries, bookMarkedSpot: wholeAuthStore.currnetUserInfo!.bookMarkedSpot, blockedUser: wholeAuthStore.currnetUserInfo!.blockedUser))
                    
                } else {
                    // 닉네임 x 사진 변경
                    wholeAuthStore.updateUserCombine(image: profileImage, user: User(id: wholeAuthStore.currnetUserInfo!.id, profileImageName: wholeAuthStore.currnetUserInfo!.profileImageName, profileImageURL: wholeAuthStore.currnetUserInfo!.profileImageURL, nickName: wholeAuthStore.currnetUserInfo!.nickName, userEmail: wholeAuthStore.currnetUserInfo!.userEmail, bookMarkedDiaries: wholeAuthStore.currnetUserInfo!.bookMarkedDiaries, bookMarkedSpot: wholeAuthStore.currnetUserInfo!.bookMarkedSpot, blockedUser: wholeAuthStore.currnetUserInfo!.blockedUser))
                }
            } else {
                //닉네임 o 사진 기본으로
                if isProfileImageReset {
                    wholeAuthStore.updateUserCombine(image: nil, user: User(id: wholeAuthStore.currnetUserInfo!.id, profileImageName: wholeAuthStore.currnetUserInfo!.profileImageName, profileImageURL: wholeAuthStore.currnetUserInfo!.profileImageURL, nickName: updateNickname, userEmail: "", bookMarkedDiaries: wholeAuthStore.currnetUserInfo!.bookMarkedDiaries, bookMarkedSpot: wholeAuthStore.currnetUserInfo!.bookMarkedSpot, blockedUser: wholeAuthStore.currnetUserInfo!.blockedUser))
                    diaryStore.updateDiarysNickNameCombine(userUID: wholeAuthStore.currnetUserInfo!.id, nickName: updateNickname)
                } else {
                    //닉네임 o 사진 변경또는 그대로
                    wholeAuthStore.updateUserCombine(image: profileImage, user: User(id: wholeAuthStore.currnetUserInfo!.id, profileImageName: wholeAuthStore.currnetUserInfo!.profileImageName, profileImageURL: wholeAuthStore.currnetUserInfo!.profileImageURL, nickName: updateNickname, userEmail: wholeAuthStore.currnetUserInfo!.userEmail, bookMarkedDiaries: wholeAuthStore.currnetUserInfo!.bookMarkedDiaries, bookMarkedSpot: wholeAuthStore.currnetUserInfo!.bookMarkedSpot, blockedUser: wholeAuthStore.currnetUserInfo!.blockedUser))
                    diaryStore.updateDiarysNickNameCombine(userUID: wholeAuthStore.currnetUserInfo!.id, nickName: updateNickname)
                }
            }
            dismiss()
        } label: {
            Text("수정")
                .modifier(GreenButtonModifier())
        }
        .disabled(updateNickname == "" && selectedImage == nil && isProfileImageReset == false)
        // 닉네임, 프사 다 안바꾼 경우 버튼 비활성화
    }
    
}


//MARK: 이미지피커, 한 장 고르기
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var mode
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            guard let image = info[.originalImage] as? UIImage else { return }
            self.parent.image = image
            self.parent.mode.wrappedValue.dismiss()
        }
    }
}
