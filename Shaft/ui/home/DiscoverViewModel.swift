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

    var body: some View {
        ScrollView {
            HStack(alignment: .top, spacing: columnSpacing) {
                LazyVStack(spacing: columnSpacing) {
                    ForEach(leftColumn, id: \.id) { illust in
                        IllustCell(illust: illust)
                    }
                }
                .padding(.leading, sideSpacing)

                LazyVStack(spacing: columnSpacing) {
                    ForEach(rightColumn, id: \.id) { illust in
                        IllustCell(illust: illust)
                    }
                }
                .padding(.trailing, sideSpacing)
            }
        }

        .task {
            await viewModel.fetchData()
            distributeColumns()
        }
    }
    
    func distributeColumns() {
        leftColumn = []
        rightColumn = []
        var leftHeight: CGFloat = 0
        var rightHeight: CGFloat = 0
        
        let totalWidth = UIScreen.main.bounds.width
        let columnWidth = (totalWidth - sideSpacing * 3) / 2 // 左 8 + 中间 8 + 右 8

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
