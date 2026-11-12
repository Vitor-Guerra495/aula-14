import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TelaAcesso(),
  ));
}

const String baseUrl = 'http://10.0.2.2/X';

class TelaAcesso extends StatefulWidget {
  const TelaAcesso({super.key});

  @override
  State<TelaAcesso> createState() => _TelaAcessoState();
}

class _TelaAcessoState extends State<TelaAcesso> {
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginSenhaController = TextEditingController();
  String _statusLogin = '';

  final TextEditingController _cadNomeController = TextEditingController();
  final TextEditingController _cadEmailController = TextEditingController();
  final TextEditingController _cadSenhaController = TextEditingController();
  String _statusCadastro = '';

  @override
  void initState() {
    super.initState();
    _verificarLoginSalvo();
  }

  Future<void> _verificarLoginSalvo() async {
    final prefs = await SharedPreferences.getInstance();
    final emailSalvo = prefs.getString('email') ?? '';
    final senhaSalva = prefs.getString('senha') ?? '';

    if (emailSalvo.isNotEmpty && senhaSalva.isNotEmpty) {
      _loginEmailController.text = emailSalvo;
      _loginSenhaController.text = senhaSalva;
      await _fazerLogin();
    }
  }

  Future<void> _fazerLogin() async {
    final url = Uri.parse('$baseUrl/login.php');
    final resposta = await http.post(url, body: {
      'email': _loginEmailController.text,
      'senha': _loginSenhaController.text,
    });

    final dados = jsonDecode(resposta.body);

    if (dados['id'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', _loginEmailController.text);
      await prefs.setString('senha', _loginSenhaController.text);
      await prefs.setString('nome', dados['nome'].toString());

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TelaApp(
            nome: dados['nome'].toString(),
            email: _loginEmailController.text,
          ),
        ),
      );
    } else {
      setState(() {
        _statusLogin = 'E-mail ou senha incorretos!';
      });
    }
  }

  Future<void> _cadastrar() async {
    final url = Uri.parse('$baseUrl/cadastro.php');
    final resposta = await http.post(url, body: {
      'nome': _cadNomeController.text,
      'email': _cadEmailController.text,
      'senha': _cadSenhaController.text,
    });

    if (resposta.body.contains('sucesso')) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', _cadEmailController.text);
      await prefs.setString('senha', _cadSenhaController.text);
      await prefs.setString('nome', _cadNomeController.text);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TelaApp(
            nome: _cadNomeController.text,
            email: _cadEmailController.text,
          ),
        ),
      );
    } else {
      setState(() {
        _statusCadastro = resposta.body;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Entrar'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Login'),
              Tab(text: 'Cadastro'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _loginEmailController,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _loginSenhaController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _fazerLogin,
                    child: const Text('Entrar'),
                  ),
                  const SizedBox(height: 12),
                  if (_statusLogin.isNotEmpty)
                    Text(
                      _statusLogin,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                ],
              ),
            ),
            SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _cadNomeController,
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _cadEmailController,
                    decoration: const InputDecoration(
                      labelText: 'E-mail',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _cadSenhaController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Senha',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _cadastrar,
                    child: const Text('Cadastrar'),
                  ),
                  const SizedBox(height: 12),
                  if (_statusCadastro.isNotEmpty)
                    Text(
                      _statusCadastro,
                      textAlign: TextAlign.center,
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

class TelaApp extends StatefulWidget {
  final String nome;
  final String email;

  const TelaApp({super.key, required this.nome, required this.email});

  @override
  State<TelaApp> createState() => _TelaAppState();
}

class _TelaAppState extends State<TelaApp> {
  final TextEditingController _textoController = TextEditingController();
  final TextEditingController _buscaController = TextEditingController();
  final Map<String, TextEditingController> _comentarioControllers = {};
  final ImagePicker _picker = ImagePicker();
  XFile? _foto;
  String _statusPostagem = '';
  String _termoBusca = '';
  List<dynamic> _postagens = [];
  bool _temNotificacao = false;

  @override
  void initState() {
    super.initState();
    _carregarPostagens();
  }

  Future<void> _carregarPostagens() async {
    final url = Uri.parse('$baseUrl/listar_postagens.php?email=${widget.email}');
    final resposta = await http.get(url);
    final dados = jsonDecode(resposta.body);

    final urlPedidos = Uri.parse('$baseUrl/listar_pedidos.php?email=${widget.email}');
    final resPedidos = await http.get(urlPedidos);
    final dadosPedidos = jsonDecode(resPedidos.body) as List<dynamic>;

    setState(() {
      _postagens = dados;
      _temNotificacao = dadosPedidos.isNotEmpty;
    });
  }

  Future<void> _curtirPostagem(String idPostagem) async {
    final url = Uri.parse('$baseUrl/curtir.php');
    await http.post(url, body: {
      'id': idPostagem,
      'email': widget.email,
    });

    await _carregarPostagens();
  }

  Future<void> _solicitarAmizade(String idDestino) async {
    final url = Uri.parse('$baseUrl/solicitar_amizade.php');
    await http.post(url, body: {
      'email': widget.email,
      'id_destino': idDestino,
    });

    await _carregarPostagens();
  }

  Future<void> _comentarPostagem(String idPostagem) async {
    final controller = _comentarioControllers[idPostagem];
    if (controller == null || controller.text.trim().isEmpty) return;

    final url = Uri.parse('$baseUrl/comentar.php');
    await http.post(url, body: {
      'email': widget.email,
      'id_postagem': idPostagem,
      'texto': controller.text,
    });

    controller.clear();
    await _carregarPostagens();
  }

  Future<void> _tirarFoto() async {
    final XFile? fotoTirada = await _picker.pickImage(source: ImageSource.camera);
    if (fotoTirada != null) {
      setState(() {
        _foto = fotoTirada;
      });
    }
  }

  Future<void> _escolherGaleria() async {
    final XFile? fotoEscolhida = await _picker.pickImage(source: ImageSource.gallery);
    if (fotoEscolhida != null) {
      setState(() {
        _foto = fotoEscolhida;
      });
    }
  }

  Future<void> _postar() async {
    if (_textoController.text.trim().isEmpty && _foto == null) {
      setState(() {
        _statusPostagem = 'Digite um texto ou escolha uma foto para postar!';
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final emailSalvo = prefs.getString('email') ?? '';
    final senhaSalva = prefs.getString('senha') ?? '';

    if (emailSalvo.isEmpty || senhaSalva.isEmpty) {
      setState(() {
        _statusPostagem = 'Você precisa estar logado para postar!';
      });
      return;
    }

    final url = Uri.parse('$baseUrl/salvar_postagem.php');
    final requisicao = http.MultipartRequest('POST', url);

    requisicao.fields['email'] = emailSalvo;
    requisicao.fields['senha'] = senhaSalva;
    requisicao.fields['txt'] = _textoController.text;

    if (_foto != null) {
      requisicao.files.add(
        await http.MultipartFile.fromPath('imagem', _foto!.path),
      );
    }

    final respostaStream = await requisicao.send();
    final resposta = await http.Response.fromStream(respostaStream);

    setState(() {
      _statusPostagem = resposta.body;
      _textoController.clear();
      _foto = null;
    });

    await _carregarPostagens();
  }

  Future<void> _sair(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TelaAcesso()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final postagensFiltradas = _postagens.where((item) {
      if (_termoBusca.isEmpty) return true;
      final autor = (item['nome_usuario'] ?? '').toString().toLowerCase();
      final texto = (item['texto'] ?? '').toString().toLowerCase();
      final busca = _termoBusca.toLowerCase();
      return autor.contains(busca) || texto.contains(busca);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Início'),
        actions: [
          SizedBox(
            width: 170,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: TextField(
                controller: _buscaController,
                onChanged: (valor) {
                  setState(() {
                    _termoBusca = valor;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Buscar...',
                  prefixIcon: Icon(Icons.search, size: 18),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TelaNotificacoes(email: widget.email),
                ),
              );
              await _carregarPostagens();
            },
            icon: Stack(
              children: [
                const Icon(Icons.notifications),
                if (_temNotificacao)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _sair(context),
            child: const Text('Sair'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Olá, ${widget.nome}!',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _textoController,
              decoration: const InputDecoration(
                labelText: 'O que está acontecendo?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _tirarFoto,
                  child: const Text('Câmera'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _escolherGaleria,
                  child: const Text('Galeria'),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _postar,
                  child: const Text('Postar'),
                ),
              ],
            ),
            if (_foto != null) ...[
              const SizedBox(height: 12),
              Image.file(
                File(_foto!.path),
                height: 180,
              ),
            ],
            if (_statusPostagem.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(_statusPostagem),
            ],
            const Divider(height: 32),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: postagensFiltradas.length,
              itemBuilder: (context, index) {
                final item = postagensFiltradas[index];
                final id = (item['id'] ?? '').toString();
                final idAutor = (item['id_usuario'] ?? '').toString();
                final autor = (item['nome_usuario'] ?? '').toString();
                final texto = (item['texto'] ?? '').toString();
                final imagem = (item['imagem'] ?? '').toString();
                final curtidas = (item['curtidas'] ?? '0').toString();
                final curtido = item['curtido'] == true;
                final statusAmizade = (item['status_amizade'] ?? 'nenhum').toString();
                final comentarios = (item['comentarios'] ?? []) as List<dynamic>;

                _comentarioControllers.putIfAbsent(id, () => TextEditingController());

                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              autor,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (statusAmizade == 'nenhum')
                              TextButton(
                                onPressed: () => _solicitarAmizade(idAutor),
                                child: const Text('Solicitar amizade'),
                              )
                            else if (statusAmizade == 'pendente')
                              const Text(
                                'Pedido pendente',
                                style: TextStyle(color: Colors.grey),
                              )
                            else if (statusAmizade == 'aceito')
                              const Text(
                                'Amigo',
                                style: TextStyle(color: Colors.green),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        if (texto.isNotEmpty)
                          Text(
                            texto,
                            style: const TextStyle(fontSize: 15),
                          ),
                        if (imagem.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Image.network(
                            '$baseUrl/$imagem',
                            height: 200,
                            fit: BoxFit.contain,
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => _curtirPostagem(id),
                              icon: Icon(
                                curtido ? Icons.favorite : Icons.favorite_border,
                                color: curtido ? Colors.red : Colors.grey,
                              ),
                            ),
                            Text(
                              curtidas,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        if (comentarios.isNotEmpty) ...[
                          const Divider(),
                          ...comentarios.map((c) {
                            final nomeCom = (c['nome_usuario'] ?? '').toString();
                            final textoCom = (c['texto'] ?? '').toString();
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                              child: Text('$nomeCom: $textoCom'),
                            );
                          }),
                        ],
                        if (statusAmizade == 'aceito' || statusAmizade == 'proprio') ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _comentarioControllers[id],
                                  decoration: const InputDecoration(
                                    hintText: 'Escrever comentário...',
                                    isDense: true,
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () => _comentarPostagem(id),
                                child: const Text('Comentar'),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TelaNotificacoes extends StatefulWidget {
  final String email;

  const TelaNotificacoes({super.key, required this.email});

  @override
  State<TelaNotificacoes> createState() => _TelaNotificacoesState();
}

class _TelaNotificacoesState extends State<TelaNotificacoes> {
  List<dynamic> _pedidos = [];

  @override
  void initState() {
    super.initState();
    _carregarPedidos();
  }

  Future<void> _carregarPedidos() async {
    final url = Uri.parse('$baseUrl/listar_pedidos.php?email=${widget.email}');
    final resposta = await http.get(url);
    final dados = jsonDecode(resposta.body);

    setState(() {
      _pedidos = dados;
    });
  }

  Future<void> _responder(String idPedido, String acao) async {
    final url = Uri.parse('$baseUrl/responder_amizade.php');
    await http.post(url, body: {
      'id': idPedido,
      'acao': acao,
    });

    await _carregarPedidos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
      ),
      body: _pedidos.isEmpty
          ? const Center(
              child: Text('Nenhum pedido de amizade pendente.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _pedidos.length,
              itemBuilder: (context, index) {
                final item = _pedidos[index];
                final idPedido = (item['id'] ?? '').toString();
                final nomeSolicitante = (item['nome_solicitante'] ?? '').toString();

                return Card(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$nomeSolicitante quer ser seu amigo',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _responder(idPedido, 'aceitar'),
                          child: const Text('Aceitar'),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () => _responder(idPedido, 'recusar'),
                          child: const Text('Recusar'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
