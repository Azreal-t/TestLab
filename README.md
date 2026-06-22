# 🧪 TestLab

> **TestLab** é uma ferramenta Flutter para testar requisições HTTP de forma rápida e visual, similar ao Postman ou Insomnia — construída com [Dio](https://pub.dev/packages/dio) e arquitetura limpa.

---

## ✨ Funcionalidades

| Feature | Detalhe |
|---|---|
| **Métodos HTTP** | GET, POST, PUT, DELETE, PATCH |
| **Headers customizados** | Adicione/remova pares chave-valor livremente |
| **Body / JSON** | Editor raw com botão *Prettify JSON* integrado |
| **Importar cURL** | Cole qualquer comando `curl` (Linux, PowerShell, CMD) |
| **Exportar cURL** | Gera o comando curl nos 3 formatos de SO |
| **Resposta detalhada** | Body formatado, headers da resposta e metadados |
| **Histórico automático** | Últimas 20 requisições enviadas |
| **Salvar requisições** | Coleção persistida localmente via SharedPreferences |
| **Responsivo** | Layout adaptável para celular e desktop (Web) |

---

## 🏗️ Arquitetura

O projeto segue **Clean Architecture** com separação estrita de camadas, orientado pelos princípios **SOLID** e **Clean Code**.

```
lib/
├── core/
│   ├── theme.dart                 # Design system (cores, fontes, inputs)
│   └── utils/
│       ├── curl_converter.dart    # Parser e gerador de comandos cURL  (SRP)
│       └── json_prettifier.dart   # Formatação de JSON                  (SRP)
│
├── domain/
│   └── models/
│       └── saved_request.dart     # Entidade de domínio (pura, sem deps)
│
├── data/
│   └── services/
│       ├── http_service.dart      # Abstração + impl. Dio               (DIP/ISP)
│       └── storage_service.dart   # Abstração + impl. SharedPreferences  (DIP/ISP)
│
├── presentation/
│   ├── controllers/
│   │   └── test_lab_controller.dart  # Estado da UI (ChangeNotifier)    (SRP)
│   └── widgets/
│       ├── dialogs.dart           # Modais: Salvar, Exportar cURL, Importar cURL
│       ├── request_pane.dart      # Painel de configuração da requisição
│       ├── response_pane.dart     # Painel de exibição da resposta
│       └── sidebar_content.dart   # Histórico e coleções salvas
│
└── main.dart                      # Bootstrap + injeção de dependências
```

---

## 🧱 Princípios SOLID Aplicados

### S — Single Responsibility
Cada arquivo tem **uma única razão para mudar**:
- `curl_converter.dart` → lida apenas com parsing e geração de cURL
- `json_prettifier.dart` → responsável apenas por formatar JSON
- `http_service.dart` → responsável apenas por fazer chamadas de rede
- `test_lab_controller.dart` → gerencia apenas o estado da UI

### O — Open/Closed
- `CurlConverter` pode ser estendido para gerar scripts Python/fetch sem tocar nos widgets
- `StorageService` pode ter novas implementações (ex: SQLite, Hive) sem alterar o controller

### L — Liskov Substitution
- Qualquer implementação de `HttpService` ou `StorageService` pode substituir a concreta sem quebrar o `TestLabController` (útil para mocks em testes)

### I — Interface Segregation
- `HttpService` expõe apenas `request()`
- `StorageService` expõe apenas os métodos de CRUD de requisições — nenhuma interface "gorda"

### D — Dependency Inversion
- `TestLabController` **não instancia** Dio nem SharedPreferences diretamente
- As dependências são injetadas via construtor em `main.dart`, invertendo o controle

---

## 🛠️ Stack

| Tecnologia | Uso |
|---|---|
| [Flutter](https://flutter.dev) | Framework UI multiplataforma |
| [Dio ^5.9.2](https://pub.dev/packages/dio) | Cliente HTTP com interceptors |
| [shared_preferences ^2.5.5](https://pub.dev/packages/shared_preferences) | Persistência local key-value |

---

## 🚀 Como rodar

### Pré-requisitos
- Flutter SDK `^3.x`
- Android SDK (para Android) ou um browser moderno (para Web)

### Instalação

```bash
# 1. Clone o repositório
git clone <url-do-repo>
cd calm-hawking   # pasta do projeto

# 2. Instale as dependências
flutter pub get

# 3. Rode no Android (emulador ou dispositivo conectado)
flutter run

# 4. Rode na Web
flutter run -d chrome
```

---

## 🧪 Testes

```bash
flutter test
```

O smoke test verifica que o app inicializa corretamente e renderiza os elementos principais, com SharedPreferences mockado via `setMockInitialValues`.

---

## 📋 Boas Práticas de Código

- **Nenhum número mágico** — constantes nomeadas (`_kMaxHistorySize`)
- **Sem null-unsafe** — `SharedPreferences` declarado como `late final` e inicializado em `init()`
- **DRY** — lógica de construção de `SavedRequest` centralizada em `_buildSavedRequest()`
- **Comentários de intenção** — explicam o *porquê*, não o *o quê*
- **Widgets pequenos** — cada widget tem responsabilidade única e é extraído em arquivo próprio

---

## 📁 Configuração de Plataformas

| Plataforma | Status | Obs. |
|---|---|---|
| Android | ✅ | `INTERNET` permission declarada no manifest |
| Web | ✅ | Sujeito à política CORS do servidor de destino |
| Windows | ✅ | Compatível via Flutter Desktop |

---

## 📄 Licença

Distribuído sob a licença MIT. Veja `LICENSE` para mais informações.
