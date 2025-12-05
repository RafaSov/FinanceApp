//  Continhas
//
//  Created by Rafael Souza Dutra on 02/12/25.
// ContinhasApp.swift
// Ponto de entrada do aplicativo com Splash Screen

import SwiftUI

@main
struct ContinhasApp: App {
    @StateObject private var continhasViewModel = ContinhasViewModel()
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environmentObject(continhasViewModel)
                
                if showSplash {
                    SplashScreenView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .preferredColorScheme(.light)
            .task {
                // Usando task em vez de onAppear + DispatchQueue
                try? await Task.sleep(nanoseconds: 2_500_000_000)
                withAnimation(.easeOut(duration: 0.4)) {
                    showSplash = false
                }
            }
        }
    }
}

// MARK: - Splash Screen View
struct SplashScreenView: View {
    @State private var isAnimating = false
    @State private var showLoadingText = false
    @State private var progress: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.4, blue: 0.9),
                    Color(red: 0.3, green: 0.2, blue: 0.8),
                    Color(red: 0.5, green: 0.1, blue: 0.7)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Círculos decorativos de fundo
            GeometryReader { geometry in
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 300, height: 300)
                    .offset(x: -100, y: -100)
                
                Circle()
                    .fill(Color.white.opacity(0.08))
                    .frame(width: 200, height: 200)
                    .offset(x: geometry.size.width - 100, y: geometry.size.height - 200)
            }
            
            // Conteúdo principal
            VStack(spacing: 0) {
                Spacer()
                
                // Ícone animado
                ZStack {
                    // Círculo externo pulsante
                    Circle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 3)
                        .frame(width: 140, height: 140)
                        .scaleEffect(isAnimating ? 1.2 : 1.0)
                        .opacity(isAnimating ? 0 : 0.5)
                    
                    // Círculo do meio
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 120, height: 120)
                    
                    // Ícone principal
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 70, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        .scaleEffect(isAnimating ? 1.0 : 0.8)
                }
                .padding(.bottom, 30)
                
                // Nome do app
                Text("Continhas")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
                
                // Subtítulo
                Text("Organize suas contas com facilidade")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.top, 8)
                
                Spacer()
                
                // Barra de loading
                VStack(spacing: 16) {
                    // Barra de progresso customizada
                    ZStack(alignment: .leading) {
                        // Fundo da barra
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.2))
                            .frame(width: 200, height: 6)
                        
                        // Progresso
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white)
                            .frame(width: 200 * progress, height: 6)
                    }
                    
                    // Texto de loading
                    if showLoadingText {
                        Text("Carregando seus dados...")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                            .transition(.opacity)
                    }
                }
                .padding(.bottom, 80)
            }
        }
        .onAppear {
            startAnimations()
        }
    }
    
    private func startAnimations() {
        // Animação do ícone
        withAnimation(.easeOut(duration: 0.6)) {
            isAnimating = true
        }
        
        // Animação de pulso contínuo
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            isAnimating = true
        }
        
        // Mostra texto de loading
        withAnimation(.easeIn(duration: 0.3).delay(0.3)) {
            showLoadingText = true
        }
        
        // Animação da barra de progresso
        withAnimation(.easeInOut(duration: 2.0)) {
            progress = 1.0
        }
    }
}

// MARK: - Preview
#Preview("Splash Screen") {
    SplashScreenView()
}

#Preview("App") {
    ContentView()
        .environmentObject(ContinhasViewModel())
}
