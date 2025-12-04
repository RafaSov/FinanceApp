# 💰 FinanceApp - Controle Financeiro Pessoal

<p align="center">
  <img src="Screenshots/app-icon.png" alt="FinanceApp Icon" width="120" height="120">
</p>

<p align="center">
  <strong>Controle suas finanças de forma simples e eficiente!</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/iOS-16.0+-blue.svg" alt="iOS 16.0+">
  <img src="https://img.shields.io/badge/Swift-5.9-orange.svg" alt="Swift 5.9">
  <img src="https://img.shields.io/badge/SwiftUI-4.0-purple.svg" alt="SwiftUI">
  <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License MIT">
  <img src="https://img.shields.io/badge/Architecture-MVVM-red.svg" alt="MVVM">
</p>

---

## 📱 Screenshots

<p align="center">
  <img src="Screenshots/splash.png" alt="Splash Screen" width="200">
  <img src="Screenshots/resumo.png" alt="Resumo" width="200">
  <img src="Screenshots/mensal.png" alt="Mensal" width="200">
  <img src="Screenshots/detalhes.png" alt="Detalhes" width="200">
</p>

---

## ✨ Funcionalidades

### 📊 Resumo Financeiro
- Visualização do mês atual com gráfico de pizza
- Cards de Entrada, Gastos e Saldo
- Gastos organizados por categoria com cores distintas

### 📅 Controle Mensal
- Lista de anos com meses expansíveis
- Criação automática do ano atual
- Histórico completo de todos os períodos

### 📝 Gestão de Contas
- Adicionar, editar e excluir contas
- Categorias: Lazer, Transporte, Educação, Investimento, Alimentação, Saúde, Moradia e Outros
- Status de pagamento: Pago, Pendente ou Atrasado
- **Copiar contas do mês anterior** com um toque

### ⚙️ Configurações
- **Exportar dados** para CSV (compatível com Excel)
- **Notificações** de vencimento personalizáveis
- Deletar todos os dados

### 🎨 Experiência do Usuário
- Splash screen animada
- Interface moderna e intuitiva
- Formatação automática de valores em moeda (R$)
- Suporte a modo claro e escuro

---

## 🏗️ Arquitetura

O projeto utiliza a arquitetura **MVVM (Model-View-ViewModel)** com SwiftUI:

```
FinanceApp/
├── 📁 App/
│   └── FinanceAppApp.swift          # Ponto de entrada + Splash Screen
├── 📁 Models/
│   └── Models.swift                  # Modelos de dados
├── 📁 ViewModels/
│   └── FinanceViewModel.swift        # Lógica de negócio
├── 📁 Views/
│   ├── ContentView.swift             # TabView principal
│   ├── 📁 Components/
│   │   ├── Components.swift          # Componentes reutilizáveis
│   │   └── PieChartView.swift        # Gráfico de pizza
│   ├── 📁 Resumo/
│   │   └── ResumoView.swift          # Tela Home
│   ├── 📁 Mensal/
│   │   ├── MensalView.swift          # Lista de anos/meses
│   │   ├── MonthDetailView.swift     # Detalhes do mês
│   │   └── ExpenseFormView.swift     # Formulário de despesa
│   └── 📁 Config/
│       ├── ConfigView.swift          # Configurações
│       └── NotificationSettingsView.swift
├── 📁 Services/
│   └── Services.swift                # Storage, Notificações, Export
└── 📁 Extensions/
    └── Extensions.swift              # Extensões úteis
```

---

## 🛠️ Tecnologias Utilizadas

| Tecnologia | Uso |
|------------|-----|
| **SwiftUI** | Interface do usuário |
| **Swift Charts** | Gráficos (iOS 17+) |
| **UserDefaults** | Persistência de dados |
| **UserNotifications** | Notificações locais |
| **Combine** | Gerenciamento de estado |
| **MVVM** | Arquitetura |

---

## 📋 Requisitos

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+

---

## 🚀 Instalação

### Clone o repositório

```bash
git clone https://github.com/RafaSov/FinanceApp.git
cd FinanceApp
```

### Abra no Xcode

```bash
open FinanceApp.xcodeproj
```

### Execute

1. Selecione um simulador (iPhone 15 recomendado)
2. Pressione `⌘ + R` ou clique em **Run**

---

## 📖 Como Usar

### 1️⃣ Tela de Resumo
A tela inicial mostra o resumo do mês atual:
- **Entrada**: Seu salário/renda
- **Gastos**: Soma de todas as contas
- **Saldo**: Entrada - Gastos
- **Gráfico**: Distribuição por categoria

### 2️⃣ Adicionar Entrada
1. Vá em **Mensal** → Selecione o mês
2. Toque no valor de **Entrada**
3. Digite o valor e salve

### 3️⃣ Adicionar Conta
1. Vá em **Mensal** → Selecione o mês
2. Toque no botão **+**
3. Preencha: Nome, Valor, Categoria e Status
4. Toque em **Salvar**

### 4️⃣ Copiar Contas do Mês Anterior
1. Vá em **Mensal** → Selecione o mês
2. Toque no ícone 📋 (ao lado do +)
3. Escolha copiar apenas contas ou contas + entrada

### 5️⃣ Exportar Dados
1. Vá em **Config** → **Exportar Dados**
2. Toque em **Gerar Arquivo CSV**
3. Compartilhe ou salve o arquivo

### 6️⃣ Configurar Notificações
1. Vá em **Config** → **Notificações**
2. Ative as notificações
3. Selecione o dia do mês para o lembrete
4. Toque em **Salvar**

---

## 🎨 Categorias de Despesas

| Categoria | Cor | Ícone |
|-----------|-----|-------|
| Lazer | 🟣 Roxo | 🎮 |
| Transporte | 🔵 Azul | 🚗 |
| Educação | 🟠 Laranja | 📚 |
| Investimento | 🟢 Verde | 📈 |
| Alimentação | 🔴 Vermelho | 🍴 |
| Saúde | 🩷 Rosa | ❤️ |
| Moradia | 🟤 Marrom | 🏠 |
| Outros | ⚫ Cinza | ⋯ |

---

## 📁 Estrutura de Dados

### Expense (Conta)
```swift
struct Expense: Identifiable, Codable {
    var id: UUID
    var name: String           // Nome da conta
    var value: Double          // Valor
    var category: ExpenseCategory  // Categoria
    var status: PaymentStatus  // Pago, Pendente, Atrasado
}
```

### MonthData (Dados do Mês)
```swift
struct MonthData: Identifiable, Codable {
    var id: UUID
    var month: Int             // 1-12
    var year: Int              // Ex: 2025
    var income: Double         // Entrada/Salário
    var expenses: [Expense]    // Lista de contas
}
```

---

## 🔔 Notificações

O app envia lembretes mensais no dia configurado:

```
💰 Lembrete de Contas
Suas contas estão vencendo! Verifique seus pagamentos no app.
```

**Configuração:**
- Dia do mês: 1 a 28
- Horário: 9:00 da manhã
- Repetição: Mensal

---

## 📤 Exportação CSV

O arquivo exportado contém:

```csv
Ano;Mês;Entrada;Total Gastos;Saldo;Conta;Valor;Categoria;Status
2025;Janeiro;5000,00;3500,00;1500,00;Aluguel;1500,00;Moradia;Pago
;;;;Internet;150,00;Outros;Pago
;;;;Academia;100,00;Saúde;Pendente
```

**Compatível com:**
- Microsoft Excel
- Google Sheets
- Apple Numbers
- LibreOffice Calc

---

## 🤝 Contribuindo

Contribuições são bem-vindas! Siga os passos:

1. Faça um **Fork** do projeto
2. Crie uma **branch** para sua feature:
   ```bash
   git checkout -b feature/nova-funcionalidade
   ```
3. Faça **commit** das alterações:
   ```bash
   git commit -m 'Adiciona nova funcionalidade'
   ```
4. Faça **push** para a branch:
   ```bash
   git push origin feature/nova-funcionalidade
   ```
5. Abra um **Pull Request**

---

## 📝 Roadmap

- [x] Tela de resumo com gráfico
- [x] Gestão de contas mensais
- [x] Copiar contas do mês anterior
- [x] Exportação CSV
- [x] Notificações de vencimento
- [x] Splash screen animada
- [ ] Backup no iCloud
- [ ] Widgets para Home Screen
- [ ] Apple Watch App
- [ ] Metas de economia
- [ ] Gráficos de evolução anual
- [ ] Múltiplas contas bancárias
- [ ] Temas personalizados

---

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

```
MIT License

Copyright (c) 2025 Rafael Dutra

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 👨‍💻 Autor

**Rafael Dutra**

- GitHub: [@RafaSov](https://github.com/RafaSov)
- LinkedIn: [Rafael Dutra](https://www.linkedin.com/in/olisouzarafael/)
- Email: rafael.olivsou@gmail.com

---

## ⭐ Apoie o Projeto

Se este projeto te ajudou, considere dar uma ⭐ no repositório!

---

<p align="center">
  Feito com SwiftUI
</p>
