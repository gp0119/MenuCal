//
//  GeneralSettingsView.swift
//  MenuCal
//
//  Created by gp on 2026/6/8.
//

import ServiceManagement
import SwiftUI

struct GeneralSettingsView: View {
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var store: SettingsStore
    @State private var loginItemStatus = SMAppService.mainApp.status
    @State private var errorMessage: String?

    var body: some View {
        Form {
            Section {
                Toggle("登录时自动启动", isOn: launchAtLoginBinding)
            } footer: {
                if loginItemStatus == .requiresApproval {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("需要在系统设置中允许 MenuCal 登录时启动。")
                        Button("打开登录项设置") {
                            SMAppService.openSystemSettingsLoginItems()
                        }
                    }
                }
            }

            Section {
                Toggle("使用 24 小时制", isOn: $store.uses24HourTime)
                Toggle("显示上午/下午", isOn: $store.showsAMPM)
                    .disabled(store.uses24HourTime)
            }
        }
        .formStyle(.grouped)
        .onAppear(perform: refreshLoginItemStatus)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                refreshLoginItemStatus()
            }
        }
        .alert("无法更新开机启动设置", isPresented: errorAlertBinding) {
            Button("确定", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private var launchAtLoginBinding: Binding<Bool> {
        Binding(
            get: {
                loginItemStatus == .enabled || loginItemStatus == .requiresApproval
            },
            set: updateLaunchAtLogin
        )
    }

    private var errorAlertBinding: Binding<Bool> {
        Binding(
            get: { errorMessage != nil },
            set: { isPresented in
                if !isPresented {
                    errorMessage = nil
                }
            }
        )
    }

    private func updateLaunchAtLogin(_ isEnabled: Bool) {
        do {
            if isEnabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        refreshLoginItemStatus()
    }

    private func refreshLoginItemStatus() {
        loginItemStatus = SMAppService.mainApp.status
    }
}
