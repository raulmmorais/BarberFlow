# BarberFlow

Aplicativo mobile SaaS para gerenciamento de barbearias e salões de beleza. Multiperfil (**Cliente**, **Barbeiro** e **Dono/Administrador**), com identidade visual, serviços e regras de funcionamento dinâmicos via Firebase.

## Stack

| Camada | Tecnologia |
|--------|------------|
| Frontend | Flutter 3.x (Android prioritário, iOS preparado) |
| Estado | Provider |
| Auth | Firebase Auth (e-mail/senha + Google) |
| Banco | Cloud Firestore |
| Fotos locais | `image_picker` + `path_provider` |
| Notificações | Firebase Cloud Messaging (estrutura pronta) |

## Identificadores do app

| Plataforma | Valor |
|------------|-------|
| Android package / iOS bundle | `com.barberflow.barberflow` |
| Firebase project | `barberflow-4169a` |

## Arquitetura

```
lib/
├── core/           # Constantes, tema, erros, utils, widgets e serviços
├── domain/         # Entidades e enums
├── data/           # Models, datasources e repositories
└── presentation/   # UI por perfil (auth, client, manager, shared, routes)
```

Padrão em camadas: **presentation → data → domain**, com Firestore como fonte de verdade para dados do SaaS.

## Pré-requisitos

- Flutter SDK ^3.12.2
- Android Studio + emulador ou dispositivo físico
- Conta no [Firebase Console](https://console.firebase.google.com)
- Java (JDK do Android Studio) para builds Gradle

## Configuração local

1. Clone o repositório e instale dependências:

```bash
git clone https://github.com/raulmmorais/BarberFlow.git
cd BarberFlow
flutter pub get
```

2. **Firebase Android**
   - Baixe `google-services.json` no Firebase Console
   - Coloque em `android/app/google-services.json`
   - Registre o SHA-1 de debug no Firebase (necessário para Google Sign-In):

```powershell
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
cd android
.\gradlew signingReport
```

3. **Firestore** — crie ao menos um documento em `estabelecimentos` (o ID do documento é usado no cadastro):

```json
{
  "nome_comercial": "Barbearia Demo",
  "logo_url": "",
  "cores_tema": {
    "primary": "#1A1A2E",
    "secondary": "#E94560"
  },
  "horario_funcionamento": {
    "dias_uteis": [1, 2, 3, 4, 5, 6],
    "abertura": "09:00",
    "fechamento": "19:00"
  }
}
```

4. Execute no emulador ou dispositivo:

```bash
flutter run
```

## Coleções Firestore

| Coleção | Descrição |
|---------|-----------|
| `estabelecimentos` | Dados do salão, tema e horários |
| `usuarios` | Perfil, tipo e mensalidade |
| `agendamentos` | Reservas e status do atendimento |
| `estabelecimentos/{id}/servicos` | Catálogo de serviços (subcoleção) |

## Progresso das sprints

Detalhes completos em [`instructions.md`](instructions.md).

### Sprint 1 — Setup, arquitetura e autenticação *(em andamento)*

- [x] Projeto Flutter criado e código padrão removido
- [x] Firebase Console configurado (Auth + Firestore)
- [x] `google-services.json` vinculado ao Android
- [x] SHA-1 de debug registrado no Firebase
- [x] Dependências iniciais no `pubspec.yaml`
- [x] Estrutura de pastas por recurso (`auth`, `client`, `manager`)
- [x] Telas de Login e Cadastro (e-mail/senha)
- [x] Login com Google + tela de completar perfil
- [x] `RootPage` com roteamento por tipo de usuário (cliente / barbeiro / dono)
- [ ] Regras de segurança Firestore definitivas (MVP usa auth básico)
- [ ] Fluxo de cadastro para perfis barbeiro/dono via app

### Sprint 2 — Catálogo e estabelecimento

- [ ] Cadastro do estabelecimento (dono)
- [ ] CRUD de serviços
- [ ] CRUD de profissionais
- [ ] Tema dinâmico consumindo Firestore na UI

### Sprints 3–8

Agendamento do cliente, painel do barbeiro, histórico/fotos locais, mensalistas, FCM e deploy — ver [`instructions.md`](instructions.md).

## Scripts úteis

```bash
flutter analyze          # Análise estática
flutter test             # Testes unitários
flutter build apk --debug
flutter build appbundle  # Release (Play Store)
```

## Regras críticas (MVP)

- Sem valores fixos para serviços, cores ou horários — tudo vem do Firestore
- Fotos pós-corte **somente no armazenamento local** do dispositivo
- UI do barbeiro com botões grandes e poucos cliques
- Erros de rede/banco com feedback amigável (SnackBar)

## Licença

Ver [`LICENSE`](LICENSE).
