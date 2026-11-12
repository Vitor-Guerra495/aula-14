<?php
header('Content-Type: application/json; charset=utf-8');

$email = $_REQUEST["email"] ?? "";

$dsn = 'mysql:dbname=x;host=127.0.0.1';
$user = 'root';
$password = '';

$dbh = new PDO($dsn, $user, $password);

$resUser = $dbh->query("SELECT `id` FROM `login` WHERE `email` = '$email' LIMIT 1");
$usuario = $resUser->fetch(PDO::FETCH_ASSOC);

if (!$usuario) {
    echo "[]";
    exit;
}

$idMeu = $usuario["id"];

$comando = "SELECT `id`, `id_solicitante`, `nome_solicitante`, `status` FROM `amizades` WHERE `id_destino` = '$idMeu' AND `status` = 'pendente' ORDER BY `id` DESC";
$resultado = $dbh->query($comando);
$linhas = $resultado->fetchAll(PDO::FETCH_ASSOC);

echo json_encode($linhas, JSON_UNESCAPED_UNICODE);
?>
