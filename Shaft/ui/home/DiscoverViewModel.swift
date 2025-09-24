//
//  DiscoverViewModel.swift
//  Shaft
//
//  Created by 杨鑫 on 2025/9/23.
//

import SwiftUI
import Combine // <- 必须导入
import Kingfisher




@MainActor
class DiscoverViewModel: ObservableObject {
    @Published var recmdIllusts: [Illust] = []
    @Published var errorMessage: String? = nil

    func fetchData() async {
        print("开始 fetchData")
        do {
            let recmd = try await Client.shared.getRecmdIllust()
            print("请求成功, illusts count:", recmd.illusts.count)
            recmdIllusts = recmd.illusts
        } catch {
            // 捕获所有错误并打印
            print("请求失败:", error)
            errorMessage = error.localizedDescription
        }
    }
}


struct DiscoverView: View {
    @StateObject private var viewModel = DiscoverViewModel()
    
    @State private var leftColumn: [Illust] = []
    @State private var rightColumn: [Illust] = []

    let sideSpacing: CGFloat = 8
    let columnSpacing: CGFloat = 8
    
    @State private var didLoadData = false
    @State private var isLoading: Bool = true // 🔹 加载状态
    
    var body: some View {
        NavigationStack {
            ZStack {
                GeometryReader { geo in
                    ScrollView {
                        HStack(alignment: .top, spacing: columnSpacing) {
                            LazyVStack(spacing: columnSpacing) {
                                ForEach(leftColumn) { illust in
                                    NavigationLink(destination: IllustDetailView(illust: illust)) {
                                        IllustCell(illust: illust)
                                            .frame(width: (geo.size.width - sideSpacing * 3) / 2)
                                    }
                                }
                            }
                            .padding(.leading, sideSpacing)

                            LazyVStack(spacing: columnSpacing) {
                                ForEach(rightColumn) { illust in
                                    NavigationLink(destination: IllustDetailView(illust: illust)) {
                                        IllustCell(illust: illust)
                                            .frame(width: (geo.size.width - sideSpacing * 3) / 2)
                                    }
                                }
                            }
                            .padding(.trailing, sideSpacing)
                        }
                    }
                    .disabled(isLoading) // 🔹 加载中禁止滚动
                    .onAppear {
                        if !didLoadData {
                            Task {
                                await viewModel.fetchData()
                                distributeColumns(containerWidth: geo.size.width)
                                isLoading = false
                                didLoadData = true
                            }
                        }
                    }
                }
                
                // 🔹 加载圆环
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                        .scaleEffect(2) // 放大圆环
                }
            }
            .navigationTitle("推荐插画")
        }
    }

    func distributeColumns(containerWidth: CGFloat) {
        leftColumn = []
        rightColumn = []
        var leftHeight: CGFloat = 0
        var rightHeight: CGFloat = 0

        let columnWidth = (containerWidth - sideSpacing * 3) / 2

        for illust in viewModel.recmdIllusts {
            let height = columnWidth / CGFloat(illust.width) * CGFloat(illust.height)

            if leftHeight <= rightHeight {
                leftColumn.append(illust)
                leftHeight += height + columnSpacing
            } else {
                rightColumn.append(illust)
                rightHeight += height + columnSpacing
            }
        }
    }
}
