<?php
header('Content-Type: application/json; charset=utf-8');

$email = $_REQUEST["email"] ?? "";
$senha = $_REQUEST["senha"] ?? "";

$comando = "SELECT `id`, `nome`, `email` FROM `login` WHERE `email` = '$email' AND `senha` = '$senha' LIMIT 1";

$dsn = 'mysql:dbname=x;host=127.0.0.1';
$user = 'root';
$password = '';

$dbh = new PDO($dsn, $user, $password);

$resultado = $dbh->query($comando);
$linha = $resultado->fetch(PDO::FETCH_ASSOC);

if($linha) {
    echo json_encode($linha, JSON_UNESCAPED_UNICODE);
} else {
    echo "{}";
}
?>
