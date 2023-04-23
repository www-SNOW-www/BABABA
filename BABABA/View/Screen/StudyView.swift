//
//  ChatView.swift
//  BABABA
//
//  Created by Snow on 2023/02/27.
//

import SwiftUI
import WebKit

struct StudyView: View {
    var body: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack {
                    VStack(alignment: .leading, spacing: 25) {
                        YouTubeWebView(videoID: "jgIlj8uPnlk")
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        YouTubeWebView(videoID: "mytmbKzwrGA")
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        YouTubeWebView(videoID: "LmI-Jt17tOc")
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        YouTubeWebView(videoID: "oaGaXUnm_pk")
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    }
                    .padding(.horizontal, 15)
                }
            }
            .navigationTitle("WHAT'S THE NEW VIDEO")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct YouTubeWebView: UIViewRepresentable {
    let videoID: String

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        guard let url = URL(string: "https://www.youtube.com/embed/\(videoID)") else { return }
        uiView.load(URLRequest(url: url))
    }
}

struct EducationView_Previews: PreviewProvider {
    static var previews: some View {
        StudyView()
    }
}
