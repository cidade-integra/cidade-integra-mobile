import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../models/report.dart';
import '../providers/auth_provider.dart';
import '../services/geocoding_service.dart';
import '../services/report_service.dart';
import '../services/supabase_service.dart';
import '../utils/app_theme.dart';
import '../utils/input_sanitizer.dart';
import '../services/analytics_service.dart';
import '../utils/rate_limiter.dart';
import '../widgets/denuncia_form/image_upload.dart';

class NovaDenunciaScreen extends StatefulWidget {
  const NovaDenunciaScreen({super.key});

  @override
  State<NovaDenunciaScreen> createState() => _NovaDenunciaScreenState();
}

class _NovaDenunciaScreenState extends State<NovaDenunciaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _cepController = TextEditingController();
  final _enderecoController = TextEditingController();

  String? _categoriaSelecionada;
  bool _isAnonima = false;
  bool _loading = false;
  bool _buscandoCep = false;
  List<File> _selectedImages = [];

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _cepController.dispose();
    _enderecoController.dispose();
    super.dispose();
  }

  Future<void> _buscarCep() async {
    if (!InputSanitizer.isValidCep(_cepController.text)) return;
    final cep = _cepController.text.replaceAll(RegExp(r'\D'), '');

    setState(() => _buscandoCep = true);
    try {
      final response = await http.get(
        Uri.parse('https://viacep.com.br/ws/$cep/json/'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['erro'] != true && mounted) {
          _enderecoController.text =
              '${data['logradouro']}, ${data['bairro']} - ${data['localidade']}/${data['uf']}';
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _buscandoCep = false);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!await RateLimiter.canPerform('create_report', maxPerHour: 5)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Limite de denúncias por hora atingido. Tente mais tarde.'),
          ),
        );
      }
      return;
    }

    final title = InputSanitizer.sanitize(_tituloController.text);
    final description = InputSanitizer.sanitize(_descricaoController.text);
    final endereco = InputSanitizer.sanitize(_enderecoController.text);

    if (InputSanitizer.containsBlockedWords(title) ||
        InputSanitizer.containsBlockedWords(description)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O texto contém palavras inadequadas.')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final auth = context.read<AuthProvider>();
      final user = auth.user;

      List<String> imageUrls = [];
      for (final file in _selectedImages) {
        final url = await SupabaseService().uploadImage(file);
        imageUrls.add(url);
      }

      final coords = await GeocodingService().getCoordinates(endereco);

      final report = Report(
        id: '',
        title: title,
        description: description,
        category: ReportCategory.values.firstWhere(
          (c) => c.name == _categoriaSelecionada,
          orElse: () => ReportCategory.outros,
        ),
        isAnonymous: _isAnonima,
        userId: _isAnonima ? null : user?.uid,
        location: ReportLocation(
          address: endereco,
          postalCode: _cepController.text.replaceAll(RegExp(r'\D'), ''),
          latitude: coords?.lat,
          longitude: coords?.lng,
        ),
        imageUrls: imageUrls,
        status: ReportStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await ReportService().createReport(report);
      await AnalyticsService.logCreateReport(report.category.name);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Denúncia enviada com sucesso!')),
        );
        context.go('/denuncias');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar denúncia: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildForm(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.grey.shade50, Colors.white],
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.verde.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.add_circle_outline, size: 32, color: AppColors.verde),
          ),
          const SizedBox(height: 12),
          Text(
            'Nova Denúncia',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.azul,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Preencha os dados para registrar um problema urbano.',
            style: TextStyle(fontSize: 14, color: AppColors.textoSecundario),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _tituloController,
            textInputAction: TextInputAction.next,
            maxLength: 100,
            decoration: const InputDecoration(
              labelText: 'Título *',
              hintText: 'Ex: Buraco na calçada',
              prefixIcon: Icon(Icons.title),
              counterText: '',
            ),
            validator: (v) => InputSanitizer.validateText(v,
                fieldName: 'o título', min: 3, max: 100),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _descricaoController,
            maxLines: 4,
            maxLength: 2000,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Descrição *',
              hintText: 'Descreva o problema com detalhes...',
              prefixIcon: Icon(Icons.description_outlined),
              alignLabelWithHint: true,
            ),
            validator: (v) => InputSanitizer.validateText(v,
                fieldName: 'a descrição', min: 10, max: 2000),
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Categoria *',
              prefixIcon: Icon(Icons.category_outlined),
            ),
            value: _categoriaSelecionada,
            items: ReportCategory.values
                .map((c) => DropdownMenuItem(
                      value: c.name,
                      child: Text(c.label),
                    ))
                .toList(),
            validator: (v) => v == null ? 'Selecione uma categoria' : null,
            onChanged: (v) => setState(() => _categoriaSelecionada = v),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _cepController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            maxLength: 9,
            decoration: InputDecoration(
              labelText: 'CEP (opcional)',
              hintText: '00000-000',
              prefixIcon: const Icon(Icons.local_post_office_outlined),
              counterText: '',
              suffixIcon: _buscandoCep
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return null;
              if (!InputSanitizer.isValidCep(v)) return 'CEP inválido (00000-000)';
              return null;
            },
            onEditingComplete: _buscarCep,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _enderecoController,
            textInputAction: TextInputAction.done,
            maxLength: 200,
            decoration: const InputDecoration(
              labelText: 'Endereço *',
              hintText: 'Rua, bairro - cidade/UF',
              prefixIcon: Icon(Icons.location_on_outlined),
              counterText: '',
            ),
            validator: (v) => InputSanitizer.validateText(v,
                fieldName: 'o endereço', min: 5, max: 200),
          ),
          const SizedBox(height: 20),

          ImageUploadWidget(
            onImagesChanged: (imgs) => _selectedImages = imgs,
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Checkbox(
                value: _isAnonima,
                onChanged: (v) => setState(() => _isAnonima = v ?? false),
                activeColor: AppColors.verde,
                visualDensity: VisualDensity.compact,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isAnonima = !_isAnonima),
                  child: Text(
                    'Enviar como denúncia anônima',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textoSecundario,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _submit,
              icon: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send, size: 20),
              label: Text(_loading ? 'Enviando...' : 'Enviar Denúncia'),
            ),
          ),
        ],
      ),
    );
  }
}
