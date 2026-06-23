# Instructions: Projeto Scheffer (App de Agendamento SaaS)

## 📌 Visão Geral do Projeto
O BarberFlow é um aplicativo mobile multiperfil (Cliente, Barbeiro e Administrador/Dono) desenvolvido em **Flutter** com backend **Firebase (Auth e Firestore)**. O sistema foi projetado sob a ótica de SaaS (Software as a Service) escalável, onde toda a identidade visual, serviços, profissionais e regras de funcionamento são dinâmicos e consumidos do banco de dados, permitindo a adaptação para diferentes barbearias ou salões de beleza.

## 👥 Perfis de Usuário & Fluxos
1. **Cliente:** Solicita agendamentos de múltiplos serviços com profissionais específicos, visualiza histórico, gerencia o status de sua mensalidade, define lembretes de retorno e armazena fotos (locais) + comentários pós-corte.
2. **Barbeiro:** Gerencia sua agenda diária/semanal, aprova/recusa/conclui agendamentos, realiza anotações internas (ou compartilhadas) sobre clientes, controla o status de pagamento de mensalistas e realiza agendamentos manuais (para clientes sem o app).
3. **Dono/Administrador:** Possui todas as permissões do Barbeiro, além de cadastrar/remover profissionais e gerenciar o catálogo de serviços (preço e duração).

---

## 🛠️ Stack Tecnológica & Dependências Principais
- **Frontend:** Flutter (Foco inicial Android, preparado para iOS)
- **Gerenciamento de Estado:** Provider ou Bloc
- **Backend & Auth:** Firebase Auth & Cloud Firestore
- **Banco Local (Fotos):** `image_picker` (captura) & `path_provider` (armazenamento local do path)
- **Notificações:** Firebase Cloud Messaging (FCM) + Cloud Functions para gatilhos de tempo

---

## 🗄️ Arquitetura do Banco de Dados (Firestore)

### Coleção: `estabelecimentos`
```json
{
  "id": "string",
  "nome_comercial": "string",
  "logo_url": "string",
  "cores_tema": {
    "primary": "string (HEX)",
    "secondary": "string (HEX)"
  },
  "horario_funcionamento": {
    "dias_uteis": [1, 2, 3, 4, 5, 6],
    "abertura": "09:00",
    "fechamento": "19:00"
  }
}
## Coleção: `usuarios`
{
  "uid": "string",
  "nome": "string",
  "telefone": "string",
  "tipo": "cliente | barbeiro | dono",
  "id_estabelecimento": "string",
  "mensalista": {
    "is_mensalista": false,
    "pago": false,
    "dia_vencimento": 5
  }
}
## Coleção: `agendamentos`
{
  "id": "string",
  "id_estabelecimento": "string",
  "id_cliente": "string (ou 'manual')",
  "nome_cliente_manual": "string (opcional)",
  "id_barbeiro": "string",
  "servicos_ids": ["string"],
  "data_hora": "timestamp",
  "duracao_total_minutos": 60,
  "status": "pendente | confirmado | concluido | recusado"
}

🚀 Cronograma de Desenvolvimento (Sprints de 1-2h por dia)
Sprint 1: Setup, Arquitetura e Autenticação (Dias 1 a 7)
[ ] Criar o projeto Flutter limpando o código padrão (main.dart).

[ ] Configurar o console do Firebase, vincular o app Android e adicionar o google-services.json.

[ ] Configurar as dependências iniciais no pubspec.yaml (firebase_core, firebase_auth, cloud_firestore).

[ ] Estruturar as pastas do projeto por recursos (presentation/auth, presentation/client, presentation/manager).

[ ] Implementar a tela de Login e Cadastro (E-mail/Senha).

[ ] Criar a lógica do RootPage que lê o tipo do usuário no Firestore e decide se renderiza o Dashboard do Barbeiro ou a Home do Cliente.

Sprint 2: Catálogo Dinâmico e Cadastro do Estabelecimento (Dias 8 a 14)
[ ] Implementar tela para o Dono cadastrar os dados do estabelecimento (Horários de funcionamento).

[ ] Criar o CRUD de Serviços para o Dono (Adicionar Cabelo, Barba, Sobrancelha com preço e duração).

[ ] Criar o CRUD de Barbeiros (Vincular novos profissionais ao estabelecimento).

[ ] Garantir que os dados inseridos reflitam perfeitamente na interface de forma dinâmica (Tema e Cores vindo do Firestore).

Sprint 3: Fluxo de Agendamento do Cliente (Dias 15 a 22)
[ ] Criar a Home do Cliente listando os serviços disponíveis e profissionais.

[ ] Desenvolver a tela de seleção de Data e Horários (Calculando horários vagos e somando o tempo total dos serviços selecionados).

[ ] Implementar a lógica de envio do agendamento para o Firestore com status pendente.

[ ] Criar a tela de "Meus Agendamentos" para o cliente acompanhar o status.

Sprint 4: Painel do Barbeiro & Gestão de Agenda (Dias 23 a 30)
[ ] Criar o Dashboard do Barbeiro com a agenda do dia (Filtro por profissional logado).

[ ] Implementar os botões de ação para o Barbeiro: "Confirmar Agendamento" e "Recusar Agendamento".

[ ] Implementar a função de Agendamento Manual (Barbeiro agenda pelo cliente que ligou ou mandou WhatsApp).

[ ] Tratar visualmente os conflitos de horário na interface do barbeiro (Destaque para horários sobrepostos, deixando o gerenciamento visual para o profissional).

Sprint 5: Histórico, Fotos Locais e Comentários (Dias 31 a 38)
[ ] Implementar o botão "Concluir Atendimento" no painel do barbeiro.

[ ] Criar a tela de Histórico para o cliente.

[ ] Integrar image_picker e path_provider para o cliente tirar foto do corte pós-atendimento.

[ ] Salvar a imagem localmente no aparelho do usuário e persistir apenas o path local e o comentário no Firestore.

Sprint 6: Mensalistas e Lembretes (Dias 39 a 46)
[ ] Criar módulo de controle de mensalistas no painel do barbeiro (Marcar/Desmarcar como pago, alterar vencimento).

[ ] Criar visualização do status da mensalidade na tela do cliente.

[ ] Criar configuração de periodicidade para o cliente (Ex: "Avisar-me a cada 20 dias para cortar o cabelo") usando alarmes locais do sistema ou notificações programadas.

Sprint 7: Notificações Push e Polimento (Dias 47 a 54)
[ ] Configurar Firebase Cloud Messaging (FCM).

[ ] Criar trigger para notificar o barbeiro quando um novo agendamento for solicitado.

[ ] Estruturar a lógica (via Cloud Functions ou agendador local/n8n) para enviar notificação push ao cliente 30 minutos antes do horário marcado.

[ ] Polimento de UI, tratamento de estados de carregamento (Shimmer Effects) e tratamento de erros de conexão (Modo Offline/Cache do Firestore).

Sprint 8: Testes, Homologação e Deploy (Dias 55 a 60)
[ ] Realizar testes ponta a ponta simulando o uso simultâneo de 1 Barbeiro e 2 Clientes.

[ ] Validar a escala mudando o id_estabelecimento para garantir que um salão não veja os dados do outro.

[ ] Gerar o App Bundle (flutter build appbundle).

[ ] Configurar o painel do Google Play Console e enviar para testes fechados/produção.

🛑 Regras Críticas de Desenvolvimento
NÃO utilize valores fixos (hardcoded) para nomes de serviços, cores do app ou horários. Tudo deve vir do estado ou do Firestore para manter o conceito SaaS.

NÃO envie fotos pós-corte para o Firebase Storage. Elas devem ser salvas estritamente no armazenamento local do celular do cliente para evitar custos desnecessários com armazenamento em nuvem no MVP.

Mantenha a UI limpa e focada no barbeiro: O profissional usa o app com as mãos ocupadas; os botões de confirmação de agenda na tela do barbeiro devem ser grandes e exigir poucos cliques.

Gerenciamento de Erros: Todas as chamadas de banco de dados devem possuir blocos try-catch amigáveis, exibindo SnackBars informativas ao usuário em caso de falha.
