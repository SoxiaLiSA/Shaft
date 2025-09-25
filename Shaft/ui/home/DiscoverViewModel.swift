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
    @Published var isLoading = false
    @Published var nextUrl: String? = nil

    /// 初始加载
    func fetchData() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let recmd: RecmdIllust = try await Client.shared.getRecmdIllust()
            recmdIllusts = recmd.illusts
            nextUrl = recmd.next_url // ✅ 保存下一页地址
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// 加载更多
    func loadMore() async {
        guard !isLoading else { return }
        guard let url = nextUrl else { return } // ✅ 没有下一页就直接返回
        isLoading = true
        defer { isLoading = false }

        do {
            let data = try await Client.shared.generalGet(url: url)
            let more = try JSONDecoder().decode(RecmdIllust.self, from: data)
            recmdIllusts.append(contentsOf: more.illusts)
            nextUrl = more.next_url
        } catch {
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
    @State private var isLoading: Bool = true // 页面首次加载状态

    var body: some View {
        NavigationStack {
            ZStack {
                GeometryReader { geo in
                    ScrollView {
                        HStack(alignment: .top, spacing: columnSpacing) {
                            // 左列
                            LazyVStack(spacing: columnSpacing) {
                                ForEach(leftColumn) { illust in
                                    NavigationLink(destination: IllustDetailView(illust: illust)) {
                                        IllustCell(illust: illust)
                                            .frame(width: (geo.size.width - sideSpacing * 3) / 2)
                                    }
                                    .task {
                                        // 如果是最后一个插画，触发分页
                                        if illust.id == viewModel.recmdIllusts.last?.id {
                                            await viewModel.loadMore()
                                            distributeColumns(containerWidth: geo.size.width)
                                        }
                                    }
                                }
                            }
                            .padding(.leading, sideSpacing)

                            // 右列
                            LazyVStack(spacing: columnSpacing) {
                                ForEach(rightColumn) { illust in
                                    NavigationLink(destination: IllustDetailView(illust: illust)) {
                                        IllustCell(illust: illust)
                                            .frame(width: (geo.size.width - sideSpacing * 3) / 2)
                                    }
                                    .task {
                                        if illust.id == viewModel.recmdIllusts.last?.id {
                                            await viewModel.loadMore()
                                            distributeColumns(containerWidth: geo.size.width)
                                        }
                                    }
                                }
                            }
                            .padding(.trailing, sideSpacing)
                        }
                    }
                    .disabled(isLoading) // 首次加载中禁止滚动
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

                // 加载圆环
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .accentColor))
                        .scaleEffect(2)
                }
            }
            .navigationTitle("推荐插画")
        }
    }

    /// 分配插画到左右两列
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
