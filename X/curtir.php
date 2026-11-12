<?php
$idPostagem = $_REQUEST["id"] ?? 0;
$email = $_REQUEST["email"] ?? "";

$dsn = 'mysql:dbname=x;host=127.0.0.1';
$user = 'root';
$password = '';

$dbh = new PDO($dsn, $user, $password);

$busca = "SELECT `id` FROM `curtidas` WHERE `id_postagem` = '$idPostagem' AND `email_usuario` = '$email' LIMIT 1";
$res = $dbh->query($busca);
$jaCurtiu = $res->fetch(PDO::FETCH_ASSOC);

if ($jaCurtiu) {
    $dbh->query("DELETE FROM `curtidas` WHERE `id_postagem` = '$idPostagem' AND `email_usuario` = '$email'");
} else {
    $dbh->query("INSERT INTO `curtidas` (`id`, `id_postagem`, `email_usuario`) VALUES (NULL, '$idPostagem', '$email')");
}

$totalRes = $dbh->query("SELECT COUNT(*) AS total FROM `curtidas` WHERE `id_postagem` = '$idPostagem'");
$totalLinha = $totalRes->fetch(PDO::FETCH_ASSOC);
$total = $totalLinha["total"] ?? 0;

$dbh->query("UPDATE `postagens` SET `curtidas` = '$total' WHERE `id` = '$idPostagem'");

echo "OK";
?>
