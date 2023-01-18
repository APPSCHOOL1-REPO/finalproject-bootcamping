//
//  Diary.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/01/18.
//

import Foundation
import Firebase

struct Diary {
    let id: String //글
    let uid: String //유저
    let diaryTitle: String //다이어리 제목
    let diaryAddress: String //장소
    let diaryContent: String //다이어리 내용
    let diaryImageURL: [String] //사진
    let diaryCreatedDate: Timestamp //작성날짜
    let diaryVisitedDate: Date //방문날짜 (피커로..?)
    let diaryLike: String //다이어리 좋아요
}