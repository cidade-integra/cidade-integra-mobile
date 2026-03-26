import 'package:flutter/material.dart';
import '../data/faq_data.dart';
import '../utils/app_theme.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: faqData.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final category = faqData[_tabController.index];

    return Column(
      children: [
        _FaqHeader(),

        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColors.verde,
            unselectedLabelColor: AppColors.textoSecundario,
            indicatorColor: AppColors.verde,
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            tabs: faqData.map((cat) => Tab(text: cat.label)).toList(),
          ),
        ),

        const SizedBox(height: 8),
        ...category.items.map((item) => _FaqTile(item: item)),
        const SizedBox(height: 16),
        const _ContactSection(),
      ],
    );
  }
}

class _FaqHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey.shade50,
            Colors.white,
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.verde.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.help_outline, size: 32, color: AppColors.verde),
          ),
          const SizedBox(height: 16),
          Text(
            'Dúvidas Frequentes',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.azul,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Encontre respostas para as perguntas mais comuns sobre a plataforma.',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textoSecundario,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final FaqItem item;
  const _FaqTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: AppColors.bordas),
        ),
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          iconColor: AppColors.verde,
          collapsedIconColor: AppColors.textoSecundario,
          title: Text(
            item.question,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.azul,
            ),
          ),
          children: [
            Text(
              item.answer,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textoSecundario,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.verde.withValues(alpha: 0.1),
                    AppColors.verde.withValues(alpha: 0.04),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.verde,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('?',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ainda tem dúvidas?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.azul,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Entre em contato com nossa equipe.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textoSecundario,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Conteúdo
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Se você não encontrou a resposta para sua dúvida, entre em contato conosco:',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textoSecundario,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Email
                  _ContactCard(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    info: 'suporte@cidadeintegra.com',
                    buttonLabel: 'Enviar email',
                    onTap: () {
                      // TODO: abrir mailto: com url_launcher
                    },
                  ),
                  const SizedBox(height: 12),

                  // Telefone
                  _ContactCard(
                    icon: Icons.phone_outlined,
                    title: 'Telefone',
                    info: '(99) 9999-9999',
                    buttonLabel: 'Ligar agora',
                    onTap: () {
                      // TODO: abrir tel: com url_launcher
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String info;
  final String buttonLabel;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.info,
    required this.buttonLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.bordas),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.verde.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: AppColors.verde),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.azul)),
                  const SizedBox(height: 2),
                  Text(info,
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textoSecundario)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(icon, size: 16),
              label: Text(buttonLabel),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.verde,
                side: BorderSide(color: AppColors.verde),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
