<?php
$email = $_REQUEST["email"] ?? "";
$senha = $_REQUEST["senha"] ?? "";
$texto = $_REQUEST["txt"] ?? "";
$caminhoImagem = "";

$dsn = 'mysql:dbname=x;host=127.0.0.1';
$user = 'root';
$password = '';

$dbh = new PDO($dsn, $user, $password);

$buscaUsuario = "SELECT `id`, `nome` FROM `login` WHERE `email` = '$email' AND `senha` = '$senha' LIMIT 1";
$resUsuario = $dbh->query($buscaUsuario);
$usuario = $resUsuario->fetch(PDO::FETCH_ASSOC);

if (!$usuario) {
    echo "Apenas usuarios cadastrados podem postar!";
    exit;
}

if (isset($_FILES["imagem"]) && $_FILES["imagem"]["error"] == 0) {
    $temp = $_FILES["imagem"]["tmp_name"];
    $nome = time() . "_" . basename($_FILES["imagem"]["name"]);
    $destino = "fotos/" . $nome;

    if (copy($temp, $destino)) {
        $caminhoImagem = $destino;
    }
}

$idUsuario = $usuario["id"];
$nomeUsuario = $usuario["nome"];

if (trim($texto) == "" && $caminhoImagem == "") {
    echo "Digite um texto ou escolha uma foto para postar!";
    exit;
}

$comando = "INSERT INTO `postagens` (`id`, `id_usuario`, `nome_usuario`, `texto`, `imagem`) VALUES (NULL, '$idUsuario', '$nomeUsuario', '$texto', '$caminhoImagem')";
$resultado = $dbh->query($comando);

if($resultado) {
    echo "Postagem enviada com sucesso!";
} else {
    echo "Erro ao salvar postagem!";
}
?>
