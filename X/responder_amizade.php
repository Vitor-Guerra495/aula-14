<?php
$idPedido = $_REQUEST["id"] ?? 0;
$acao = $_REQUEST["acao"] ?? "";

$dsn = 'mysql:dbname=x;host=127.0.0.1';
$user = 'root';
$password = '';

$dbh = new PDO($dsn, $user, $password);

if ($acao == "aceitar") {
    $dbh->query("UPDATE `amizades` SET `status` = 'aceito' WHERE `id` = '$idPedido'");
    echo "Amizade aceita!";
} else {
    $dbh->query("DELETE FROM `amizades` WHERE `id` = '$idPedido'");
    echo "Pedido recusado!";
}
?>
