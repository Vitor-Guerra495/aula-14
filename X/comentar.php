<?php
$email = $_REQUEST["email"] ?? "";
$idPostagem = $_REQUEST["id_postagem"] ?? 0;
$texto = $_REQUEST["texto"] ?? "";

if (trim($texto) == "") {
    echo "Digite um comentario!";
    exit;
}

$dsn = 'mysql:dbname=x;host=127.0.0.1';
$user = 'root';
$password = '';

$dbh = new PDO($dsn, $user, $password);

$resUser = $dbh->query("SELECT `id`, `nome` FROM `login` WHERE `email` = '$email' LIMIT 1");
$usuario = $resUser->fetch(PDO::FETCH_ASSOC);

if (!$usuario) {
    echo "Usuario nao encontrado!";
    exit;
}

$idMeu = $usuario["id"];
$nomeMeu = $usuario["nome"];

$resPost = $dbh->query("SELECT `id_usuario` FROM `postagens` WHERE `id` = '$idPostagem' LIMIT 1");
$postagem = $resPost->fetch(PDO::FETCH_ASSOC);

if (!$postagem) {
    echo "Postagem nao encontrada!";
    exit;
}

$idAutor = $postagem["id_usuario"];

if ($idMeu != $idAutor) {
    $buscaAmizade = "SELECT `id` FROM `amizades` WHERE ((`id_solicitante` = '$idMeu' AND `id_destino` = '$idAutor') OR (`id_solicitante` = '$idAutor' AND `id_destino` = '$idMeu')) AND `status` = 'aceito' LIMIT 1";
    $resAmizade = $dbh->query($buscaAmizade);
    if (!$resAmizade->fetch(PDO::FETCH_ASSOC)) {
        echo "Apenas amigos podem comentar!";
        exit;
    }
}

$comando = "INSERT INTO `comentarios` (`id`, `id_postagem`, `id_usuario`, `nome_usuario`, `texto`) VALUES (NULL, '$idPostagem', '$idMeu', '$nomeMeu', '$texto')";
$dbh->query($comando);

echo "Comentario salvo!";
?>
