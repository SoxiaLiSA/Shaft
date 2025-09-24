//
//  HomeView.swift
//  Shaft
//
//  Created by 杨鑫 on 2025/9/23.
//


import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var selectedTab: Tab = .discover

    enum Tab {
        case discover, ranking, following
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            
            // Discover 页面
            DiscoverView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Discover")
                }
                .tag(Tab.discover)
            
            // Ranking 页面
            RankingView()
                .tabItem {
                    Image(systemName: "star.fill")
                    Text("Ranking")
                }
                .tag(Tab.ranking)
            
            // Following 页面
            FollowingView()
                .tabItem {
                    Image(systemName: "person.2.fill")
                    Text("Following")
                }
                .tag(Tab.following)
        }
    }
}


struct RankingView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Ranking Page")
                .font(.title)
            Text("这里可以放 Ranking 内容")
        }
        .padding()
    }
}

struct FollowingView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Following Page")
                .font(.title)
            Text("这里可以放 Following 内容")
        }
        .padding()
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthManager())
}
