# 🤝 Guia de Contribuição

Obrigado pelo interesse em contribuir com o **Continhas**! Este guia vai te ajudar a entender como participar do projeto.

---

## 📋 Índice

- [Código de Conduta](#código-de-conduta)
- [Como Contribuir](#como-contribuir)
- [Reportando Bugs](#reportando-bugs)
- [Sugerindo Melhorias](#sugerindo-melhorias)
- [Pull Requests](#pull-requests)
- [Padrões de Código](#padrões-de-código)
- [Estrutura do Projeto](#estrutura-do-projeto)

---

## 📜 Código de Conduta

Este projeto segue um Código de Conduta. Ao participar, espera-se que você mantenha esse código. Por favor, seja respeitoso e construtivo em todas as interações.

### Nossos Princípios:
- 🤝 Seja respeitoso e inclusivo
- 💬 Críticas construtivas são bem-vindas
- 🎯 Foque no que é melhor para a comunidade
- ❤️ Mostre empatia com outros contribuidores

---

## 🚀 Como Contribuir

### 1. Fork o Repositório

Clique no botão "Fork" no canto superior direito da página do GitHub.

### 2. Clone seu Fork

```bash
git clone https://github.com/RafaSov/Continhas.git
cd Continhas
```

### 3. Crie uma Branch

```bash
git checkout -b feature/minha-nova-funcionalidade
```

**Convenção de nomes para branches:**
- `feature/` - Nova funcionalidade
- `fix/` - Correção de bug
- `docs/` - Documentação
- `refactor/` - Refatoração de código
- `test/` - Adição de testes

### 4. Faça suas Alterações

Desenvolva sua funcionalidade ou correção.

### 5. Commit suas Mudanças

```bash
git add .
git commit -m "feat: adiciona nova funcionalidade X"
```

**Convenção de commits:**
- `feat:` - Nova funcionalidade
- `fix:` - Correção de bug
- `docs:` - Documentação
- `style:` - Formatação (não altera código)
- `refactor:` - Refatoração
- `test:` - Testes
- `chore:` - Manutenção

### 6. Push para seu Fork

```bash
git push origin feature/minha-nova-funcionalidade
```

### 7. Abra um Pull Request

Vá até o repositório original e clique em "New Pull Request".

---

## 🐛 Reportando Bugs

Encontrou um bug? Abra uma [Issue](https://github.com/RafaSov/Continhas/issues) com:

### Template de Bug Report:

```markdown
## 🐛 Descrição do Bug
Uma descrição clara e concisa do bug.

## 📱 Ambiente
- **iOS Version:** 17.0
- **Device:** iPhone 15
- **App Version:** 1.0.0

## 🔄 Passos para Reproduzir
1. Vá para '...'
2. Clique em '....'
3. Role até '....'
4. Veja o erro

## ✅ Comportamento Esperado
O que deveria acontecer.

## ❌ Comportamento Atual
O que está acontecendo.

## 📸 Screenshots
Se aplicável, adicione screenshots.

## 📝 Informações Adicionais
Qualquer outro contexto sobre o problema.
```

---

## 💡 Sugerindo Melhorias

Tem uma ideia? Abra uma [Issue](https://github.com/RafaSov/Continhas/issues) com:

### Template de Feature Request:

```markdown
## 💡 Descrição da Funcionalidade
Uma descrição clara da funcionalidade sugerida.

## 🎯 Problema que Resolve
Qual problema essa funcionalidade resolveria?

## 📝 Solução Proposta
Como você imagina que isso funcionaria?

## 🔄 Alternativas Consideradas
Outras soluções que você considerou.

## 📸 Mockups/Exemplos
Se tiver, adicione mockups ou exemplos visuais.
```

---

## 🔀 Pull Requests

### Checklist antes de abrir um PR:

- [ ] Código segue os padrões do projeto
- [ ] Testei as alterações no simulador
- [ ] Não há warnings ou erros de compilação
- [ ] Atualizei a documentação (se necessário)
- [ ] Commit messages seguem a convenção
- [ ] Branch está atualizada com a `main`

### Template de Pull Request:

```markdown
## 📝 Descrição
Descreva as mudanças realizadas.

## 🔗 Issue Relacionada
Fixes #(número da issue)

## 🧪 Como Testar
1. Passo 1
2. Passo 2
3. Passo 3

## 📸 Screenshots
Antes | Depois
--- | ---
img | img

## ✅ Checklist
- [ ] Testei no simulador
- [ ] Sem warnings/erros
- [ ] Documentação atualizada
```

---

## 📐 Padrões de Código

### Swift Style Guide

Seguimos o [Swift Style Guide da Ray Wenderlich](https://github.com/raywenderlich/swift-style-guide).

### Principais Convenções:

#### Nomenclatura
```swift
// ✅ Correto
let maximumNumberOfItems = 10
func calculateTotalPrice() -> Double

// ❌ Errado
let max = 10
func calc() -> Double
```

#### Organização com MARK
```swift
// MARK: - Properties
// MARK: - Lifecycle
// MARK: - Public Methods
// MARK: - Private Methods
// MARK: - Actions
```

#### Views SwiftUI
```swift
struct MyView: View {
    // MARK: - Properties
    @State private var isLoading = false
    
    // MARK: - Body
    var body: some View {
        // ...
    }
    
    // MARK: - Subviews
    private var headerView: some View {
        // ...
    }
    
    // MARK: - Methods
    private func loadData() {
        // ...
    }
}
```

#### ViewModels
```swift
class MyViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var items: [Item] = []
    @Published var isLoading = false
    
    // MARK: - Private Properties
    private let service: MyService
    
    // MARK: - Init
    init(service: MyService = .shared) {
        self.service = service
    }
    
    // MARK: - Public Methods
    func loadItems() {
        // ...
    }
}
```

---

## 📁 Estrutura do Projeto

```
Continhas/
├── App/                    # Ponto de entrada
├── Models/                 # Modelos de dados
├── ViewModels/             # Lógica de negócio
├── Views/                  # Interface do usuário
│   ├── Components/         # Componentes reutilizáveis
│   ├── Resumo/             # Tela de resumo
│   ├── Mensal/             # Telas mensais
│   └── Config/             # Configurações
├── Services/               # Serviços (Storage, API, etc)
└── Extensions/             # Extensões Swift
```

### Onde adicionar novos arquivos:

| Tipo | Pasta |
|------|-------|
| Novo modelo de dados | `Models/` |
| Nova ViewModel | `ViewModels/` |
| Nova tela completa | `Views/NomeDaTela/` |
| Componente reutilizável | `Views/Components/` |
| Serviço (API, Storage) | `Services/` |
| Extensão de tipo | `Extensions/` |

---

## 🙏 Agradecimentos

Obrigado por contribuir! Cada contribuição, seja grande ou pequena, faz diferença. 💪

---

## ❓ Dúvidas?

Se tiver dúvidas, abra uma Issue com a tag `question` ou entre em contato:
- Email: rafael.olivsou@gmail.com
- Discord: raffinhaup
