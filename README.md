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

### Sprint 1 — Setup, arquitetura e autenticação ✅

- [x] Projeto Flutter criado e código padrão removido
- [x] Firebase Console configurado (Auth + Firestore)
- [x] `google-services.json` vinculado ao Android
- [x] SHA-1 de debug registrado no Firebase
- [x] Dependências iniciais no `pubspec.yaml`
- [x] Estrutura de pastas por recurso (`auth`, `client`, `manager`)
- [x] Telas de Login e Cadastro (e-mail/senha)
- [x] Login com Google + tela de completar perfil
- [x] `RootPage` com roteamento por tipo de usuário (cliente / barbeiro / dono)
- [x] Regras de segurança Firestore (MVP)
- [x] Fluxo de cadastro para perfis barbeiro/dono com código de convite

### Sprint 2 — Catálogo e estabelecimento ✅

- [x] Cadastro do estabelecimento — nome, cores, dias e horário de funcionamento (`OwnerEstablishmentScreen`)
- [x] CRUD de serviços — add/editar/excluir com nome, preço e duração (`ServicesCrudScreen`)
- [x] CRUD de profissionais — promover/demover usuários por UID (`BarbersCrudScreen`)
- [x] Tema dinâmico consumindo Firestore na UI (`DynamicTheme` + `EstabelecimentoProvider`)

### Sprint 3 — Fluxo de agendamento do cliente ✅

- [x] Home do cliente com lista de serviços e profissionais em tempo real
- [x] Fluxo de agendamento em 4 passos: serviços → profissional → data → horário
- [x] Cálculo de slots disponíveis com base nos horários do estabelecimento e agenda do barbeiro
- [x] Envio do agendamento ao Firestore com `status = pendente`
- [x] Tela "Meus agendamentos" com status colorido

> **Firestore:** índices compostos necessários em `agendamentos` — `(id_cliente, data_hora DESC)` e `(id_barbeiro, data_hora ASC)`.

### Sprint 4 — Painel do barbeiro e gestão de agenda *(próxima)*

- [ ] Dashboard do barbeiro com agenda do dia filtrada por profissional
- [ ] Confirmar / Recusar agendamentos
- [ ] Agendamento manual (cliente sem app)
- [ ] Destaque visual para conflitos de horário

### Sprints 5–8

Histórico/fotos locais, mensalistas, FCM e deploy — ver [`instructions.md`](instructions.md).

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
