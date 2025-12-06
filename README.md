# Desafio Técnico Mobile

## 📋 Sobre o Projeto

Aplicação que permite aos usuários pesquisar e visualizar detalhes de produtos utilizando as APIs públicas do Mercado Livre. O projeto implementa autenticação OAuth2, busca de produtos, listagem com paginação infinita e visualização de detalhes completos.

### Requisitos Atendidos

✅ **Três telas principais:**
- Campo de pesquisa com validação
- Lista de resultados com imagens e paginação infinita
- Detalhes completos do produto com galeria de imagens

✅ **Gestão de erros:**
  - Tratamento robusto de erros do ponto de vista do desenvolvedor (logs estruturados, estados de erro específicos)
- Feedback visual apropriado para o usuário (telas de erro com opção de retry)

✅ **Suporte a rotação de tela** 

## 🎯 Funcionalidades

### Autenticação
- Login automático via OAuth2 com refresh token
- Persistência segura de tokens no Keychain
- Renovação automática de token expirado

### Busca
- Campo de busca com validação (mínimo 3 caracteres)
- Feedback visual de validação em tempo real

### Lista de Produtos
- Grid responsivo (2 colunas no portrait, 4 no landscape)
- Paginação infinita com prefetching
- Cache de imagens para performance
- Estados de loading, erro e lista vazia

### Detalhes do Produto
- Galeria de imagens navegável com page control
- Informações (título, preço)
- Fetch da descrição
- Layout adaptativo para diferentes tamanhos de tela
- Estados de erro específicos para descrição

## 🏗️ Arquitetura

### Padrão MVVM + Coordinator
- **View**: UIKit com ViewCode (zero Storyboards/XIBs)
- **ViewModel**: Lógica de negócio e estados
- **Model**: Modelos de dados codificáveis

### Camadas do Projeto

```
challenge/
├── Core/                   # Infraestrutura base
│   ├── Environment/        # Ambientes (Production/Local)
│   ├── Storage/            # Keychain, Cache
│   └── Protocols/          # Protocolos compartilhados
├── Network/                # Camada de rede
│   ├── Core/               # APIClient, Requests
│   ├── Models/             # Request/Response
│   └── Factory/            # URL e Request builders
├── Modules/                # Features (MVVM)
│   ├── Login/
│   ├── Search/
│   ├── List/
│   └── Details/
├── DesignSystem/           # Tokens e componentes
│   ├── Tokens/             # Colors, Spacing, Typography
│   └── Components/         # Buttons, Labels, TextFields
├── Components/             # Componentes reutilizáveis
└── Extensions/             # Extensions úteis
```

### Destaques Técnicos

#### 1. **Design System**
- Sistema de tokens baseado em escala de 4pt (Apple HIG)
- Componentes reutilizáveis
- Suporte a Dynamic Type
- Tema com cores semânticas
- Light/Dark Mode

#### 2. **Gerenciamento de Estado**
- Estados específicos por feature (idle, loading, success, error)
- Fluxo unidirecional com callbacks
- Sincronização thread-safe com locks

#### 3. **Networking Robusto**
- Generic APIClient com suporte a múltiplos ambientes
- Parser de respostas com tratamento de erros tipado
- Suporte a diferentes tipos de serialização (JSON, Form URL Encoded, Query)
- Logs detalhados em debug

#### 4. **Paginação Inteligente**
- PaginationManager dedicado
- Prefetching para melhor UX
- Controle de estados de carregamento

#### 5. **Performance**
- Cache de imagens com NSCache
- Cancelamento automático de requisições
- Task management para operações assíncronas
- Debounce em buscas

#### 6. **Qualidade de Código**
- ViewCode protocol para setup consistente
- Dependency Injection
- Protocol-oriented programming
- Separation of concerns

## 🚀 Como Rodar o Projeto

### Pré-requisitos
- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

### Configuração

#### Target: **Local** (Mocks)
1. Selecione o scheme **challenge-Local**
2. Build e rode
3. ⚠️ **Limitações**: Paginação e busca não funcionam corretamente (mock estático)

#### Target: **Production** (API Real)

1. Selecione o scheme **challenge-production**
2. Primeira vez que o app Build e rode
   1. Se o refresh token do Base.xcconfig já fez refresh, precisa seguir **Configuraçao do Refresh Token** (veja seção abaixo)
   2. Build e rode

### ⚠️ Configuração do Refresh Token (IMPORTANTE)

O projeto está configurado com OAuth2 e utiliza refresh token para renovação automática. Por limitações de tempo, a autenticação completa não foi implementada in-app, sendo necessário configurar manualmente:

#### Refresh Token já configurado
O projeto vem com um refresh token pré-configurado no arquivo `Base.xcconfig`:
```
REFRESH_TOKEN = TG-692b2cb3525cbf000105110f-21820316
```

**Este token funcionará no primeiro login**, mas após o primeiro uso bem-sucedido, o token será renovado e armazenado no Keychain do simulador/dispositivo. A partir daí, apenas aquele simulador específico terá o token válido.

#### Como atualizar o Refresh Token

Se o token expirou ou você precisa rodar em um novo simulador/dispositivo:

**1. Obtenha o código de autorização:**
   
Acesse:
```
https://auth.mercadolivre.com.br/authorization?response_type=code&client_id=1440649797671384&redirect_uri=https://www.wagnersales.com.br
```

Credenciais:
- **Login**: `test_user_7747078902288141917@testuser.com`
- **Senha**: `s9EITIe2S5`

Após o login, você será redirecionado para uma URL contendo o código:
```
https://www.wagnersales.com.br/?code=TG-XXXXX
```

**2. Troque o código por um novo refresh token:**

```bash
curl -X POST \
  -H 'accept: application/json' \
  -H 'content-type: application/x-www-form-urlencoded' \
  'https://api.mercadolibre.com/oauth/token' \
  -d 'grant_type=authorization_code' \
  -d 'client_id=1440649797671384' \
  -d 'client_secret=1GL6Ul4btjXoup9kuYzo5xY4NPHbNR8F' \
  -d 'code=<<CODIGO_OBTIDO>>' \
  -d 'redirect_uri=https://www.wagnersales.com.br'
```

**3. Atualize o arquivo de configuração:**

No response, copie o valor de `refresh_token` e atualize em `challenge/Configs/Base.xcconfig`:
```
REFRESH_TOKEN = <NOVO_REFRESH_TOKEN>
```

**4. Limpe o Keychain (se necessário):**

Se você já rodou o app antes, pode ser necessário resetar o simulador ou deletar o app para limpar o Keychain.

## 🧪 Testes

### Estrutura de Testes
- Testes unitários seguindo padrão Given/When/Then
- Nomenclatura descritiva: `test_[unitOfWork]_when[state]_should[result]`
- Mocks para isolamento de dependências
- Cobertura de casos de sucesso, erro e edge cases

## 📱 Capturas de Tela

O aplicativo suporta:
- ✅ Portrait e Landscape
- ✅ iPhone e iPad
- ✅ Dark Mode
- ✅ Dynamic Type

## 🎨 Design Decisions

### Por que ViewCode?
- Melhor controle sobre layout
- Code review mais eficiente
- Merge conflicts minimizados

### Por que MVVM?
- Separação clara de responsabilidades
- Facilita testes unitários
- Binding natural com estados

### Por que sem bibliotecas terceiras?
- Menor overhead de dependências
- Maior controle sobre o código
- Melhor para avaliação técnica

## 🔧 Tecnologias e Frameworks

- **UIKit** - Interface
- **Swift Concurrency** - Async/await para operações assíncronas
- **URLSession** - Networking
- **Keychain** - Armazenamento seguro
- **NSCache** - Cache de imagens
- **XCTest** - Testes unitários

## 📈 Melhorias Futuras

Dado mais tempo, as seguintes melhorias seriam implementadas:

1. **Melhorar cobertura de testes**
1. **Autenticação completa in-app** com OAuth2 flow
5. **Analytics** e crash reporting
6. **CI/CD** pipeline
7. **Testes de UI** com XCUITest
8. **Snapshot tests** para componentes visuais
9. **Modularização** em frameworks

## 👨‍💻 Sobre o Desenvolvedor

**Wagner Sales**

Desenvolvedor iOS com experiência em desenvolvimento de aplicativos nativos, arquiteturas escaláveis e boas práticas de código.

- 🌐 [wagnersales.com.br](https://wagnersales.com.br)
- 💼 [LinkedIn](http://linkedin.com/in/salesawagner)
- 📧 [salesawagner@gmail.com](mailto:salesawagner@gmail.com)

---

## 📝 Licença
Este projeto foi desenvolvido como parte de um desafio técnico e é de uso exclusivo para avaliação.
---