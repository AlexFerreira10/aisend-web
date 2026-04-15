import '../../models/lead_model.dart';

abstract final class MockDataSource {
  // ─── Instances ──────────────────────────────────────────────────────────────
  static const List<InstanceModel> instances = [
    InstanceModel(
      id: 'alex',
      label: 'Alex',
      phone: '(21) 97289-2504',
      isConnected: true,
    ),
    InstanceModel(
      id: 'davi',
      label: 'Davi',
      phone: '(21) 97289-2514',
      isConnected: true,
    ),
  ];

  // ─── KPIs ───────────────────────────────────────────────────────────────────
  static const int totalLeads = 2847;
  static const double responseRate = 0.23;
  static const int hotLeadsCount = 127;
  static const int broadcastsToday = 284;
  static const int convertedLeads = 67;

  // ─── Leads (20 mock records) ─────────────────────────────────────────────────
  static const List<LeadModel> leads = [
    LeadModel(
      id: '1',
      name: 'Dr. Carlos Silva',
      phone: '11987654321',
      lastMessage: 'Oi, pode me enviar mais informações sobre o preço?',
      status: LeadStatus.hot,
      time: '5 min atrás',
    ),
    LeadModel(
      id: '2',
      name: 'Dra. Ana Santos',
      phone: '11976543210',
      lastMessage: 'Obrigado pelo contato, vou avaliar.',
      status: LeadStatus.warm,
      time: '12 min atrás',
    ),
    LeadModel(
      id: '3',
      name: 'Dr. Roberto Lima',
      phone: '11965432109',
      lastMessage: 'Não estou interessado no momento.',
      status: LeadStatus.cold,
      time: '23 min atrás',
    ),
    LeadModel(
      id: '4',
      name: 'Dra. Maria Costa',
      phone: '11954321098',
      lastMessage: 'Sim, por favor envie o catálogo!',
      status: LeadStatus.hot,
      time: '34 min atrás',
    ),
    LeadModel(
      id: '5',
      name: 'Dr. Fernando Alves',
      phone: '21998765432',
      lastMessage: 'Qual o prazo de entrega?',
      status: LeadStatus.hot,
      time: '41 min atrás',
    ),
    LeadModel(
      id: '6',
      name: 'Dra. Juliana Ferreira',
      phone: '21987654321',
      lastMessage: 'Pode me ligar amanhã de manhã?',
      status: LeadStatus.warm,
      time: '55 min atrás',
    ),
    LeadModel(
      id: '7',
      name: 'Dr. Paulo Rodrigues',
      phone: '31976543210',
      lastMessage: 'Já tenho fornecedor, obrigado.',
      status: LeadStatus.cold,
      time: '1h atrás',
    ),
    LeadModel(
      id: '8',
      name: 'Dra. Camila Souza',
      phone: '31965432109',
      lastMessage: 'Estou interessado, me envie o preço.',
      status: LeadStatus.hot,
      time: '1h 15min atrás',
    ),
    LeadModel(
      id: '9',
      name: 'Dr. Marcelo Oliveira',
      phone: '41998765432',
      lastMessage: 'Vou pensar e retorno.',
      status: LeadStatus.warm,
      time: '1h 30min atrás',
    ),
    LeadModel(
      id: '10',
      name: 'Dra. Beatriz Mendes',
      phone: '41987654321',
      lastMessage: 'Não consigo agora, desculpa.',
      status: LeadStatus.cold,
      time: '2h atrás',
    ),
    LeadModel(
      id: '11',
      name: 'Dr. Ricardo Nascimento',
      phone: '51976543210',
      lastMessage: 'Qual a validade do produto?',
      status: LeadStatus.hot,
      time: '2h 10min atrás',
    ),
    LeadModel(
      id: '12',
      name: 'Dra. Luciana Carvalho',
      phone: '51965432109',
      lastMessage: 'Interessante! Quais as formas de pagamento?',
      status: LeadStatus.hot,
      time: '2h 30min atrás',
    ),
    LeadModel(
      id: '13',
      name: 'Dr. Eduardo Martins',
      phone: '85998765432',
      lastMessage: 'Por favor, me retire da lista.',
      status: LeadStatus.cold,
      time: '3h atrás',
    ),
    LeadModel(
      id: '14',
      name: 'Dra. Patrícia Ribeiro',
      phone: '85987654321',
      lastMessage: 'Envie mais detalhes para o meu e-mail.',
      status: LeadStatus.warm,
      time: '3h 20min atrás',
    ),
    LeadModel(
      id: '15',
      name: 'Dr. Thiago Gomes',
      phone: '71976543210',
      lastMessage: 'Ótimo, quero fazer um pedido!',
      status: LeadStatus.hot,
      time: '4h atrás',
    ),
    LeadModel(
      id: '16',
      name: 'Dra. Renata Barbosa',
      phone: '71965432109',
      lastMessage: 'Vou verificar com meu sócio.',
      status: LeadStatus.warm,
      time: '4h 30min atrás',
    ),
    LeadModel(
      id: '17',
      name: 'Dr. Sérgio Campos',
      phone: '62998765432',
      lastMessage: 'Agora não, obrigado.',
      status: LeadStatus.cold,
      time: '5h atrás',
    ),
    LeadModel(
      id: '18',
      name: 'Dra. Vanessa Teixeira',
      phone: '62987654321',
      lastMessage: 'Está disponível para entrega imediata?',
      status: LeadStatus.hot,
      time: '5h 30min atrás',
    ),
    LeadModel(
      id: '19',
      name: 'Dr. Bruno Azevedo',
      phone: '48976543210',
      lastMessage: 'Me conte mais sobre a Tirzepatida.',
      status: LeadStatus.warm,
      time: '6h atrás',
    ),
    LeadModel(
      id: '20',
      name: 'Dra. Larissa Pinto',
      phone: '48965432109',
      lastMessage: 'Preciso disso urgente, me ligue!',
      status: LeadStatus.hot,
      time: '6h 45min atrás',
    ),
  ];

  // ─── Convenience Getters ────────────────────────────────────────────────────
  static List<LeadModel> get recentLeads => leads.take(10).toList();

  static List<LeadModel> get coldLeads =>
      leads.where((l) => l.status == LeadStatus.cold).toList();

  static List<LeadModel> get hotLeads =>
      leads.where((l) => l.status == LeadStatus.hot).toList();
}
