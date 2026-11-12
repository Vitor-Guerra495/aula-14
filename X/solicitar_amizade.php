<?php
$email = $_REQUEST["email"] ?? "";
$idDestino = $_REQUEST["id_destino"] ?? 0;

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

$idSolicitante = $usuario["id"];
$nomeSolicitante = $usuario["nome"];

if ($idSolicitante == $idDestino) {
    echo "Voce nao pode adicionar a si mesmo!";
    exit;
}

$busca = "SELECT `id` FROM `amizades` WHERE (`id_solicitante` = '$idSolicitante' AND `id_destino` = '$idDestino') OR (`id_solicitante` = '$idDestino' AND `id_destino` = '$idSolicitante') LIMIT 1";
$resBusca = $dbh->query($busca);

if ($resBusca->fetch(PDO::FETCH_ASSOC)) {
    echo "Pedido ja existe!";
    exit;
}

$comando = "INSERT INTO `amizades` (`id`, `id_solicitante`, `nome_solicitante`, `id_destino`, `status`) VALUES (NULL, '$idSolicitante', '$nomeSolicitante', '$idDestino', 'pendente')";
$dbh->query($comando);

echo "Pedido enviado!";
?>
