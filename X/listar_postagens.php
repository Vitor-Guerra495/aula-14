<?php
header('Content-Type: application/json; charset=utf-8');

$email = $_REQUEST["email"] ?? "";

$dsn = 'mysql:dbname=x;host=127.0.0.1';
$user = 'root';
$password = '';

$dbh = new PDO($dsn, $user, $password);

$resUser = $dbh->query("SELECT `id` FROM `login` WHERE `email` = '$email' LIMIT 1");
$usuario = $resUser->fetch(PDO::FETCH_ASSOC);
$idMeu = $usuario["id"] ?? 0;

$comando = "SELECT `id`, `id_usuario`, `nome_usuario`, `texto`, `imagem` FROM `postagens` ORDER BY `id` DESC";
$resultado = $dbh->query($comando);
$linhas = $resultado->fetchAll(PDO::FETCH_ASSOC);

foreach ($linhas as &$linha) {
    $idPost = $linha["id"];
    $idAutor = $linha["id_usuario"];

    $resTotal = $dbh->query("SELECT COUNT(*) AS total FROM `curtidas` WHERE `id_postagem` = '$idPost'");
    $dadosTotal = $resTotal->fetch(PDO::FETCH_ASSOC);
    $linha["curtidas"] = (int)($dadosTotal["total"] ?? 0);

    $resCurtiu = $dbh->query("SELECT `id` FROM `curtidas` WHERE `id_postagem` = '$idPost' AND `email_usuario` = '$email' LIMIT 1");
    $linha["curtido"] = $resCurtiu->fetch(PDO::FETCH_ASSOC) ? true : false;

    if ($idMeu == $idAutor) {
        $linha["status_amizade"] = "proprio";
    } else {
        $buscaAmizade = "SELECT `status` FROM `amizades` WHERE (`id_solicitante` = '$idMeu' AND `id_destino` = '$idAutor') OR (`id_solicitante` = '$idAutor' AND `id_destino` = '$idMeu') LIMIT 1";
        $resAmizade = $dbh->query($buscaAmizade);
        $amizade = $resAmizade->fetch(PDO::FETCH_ASSOC);
        if ($amizade) {
            $linha["status_amizade"] = $amizade["status"];
        } else {
            $linha["status_amizade"] = "nenhum";
        }
    }

    $resCom = $dbh->query("SELECT `id`, `nome_usuario`, `texto` FROM `comentarios` WHERE `id_postagem` = '$idPost' ORDER BY `id` ASC");
    $linha["comentarios"] = $resCom->fetchAll(PDO::FETCH_ASSOC);
}

echo json_encode($linhas, JSON_UNESCAPED_UNICODE);
?>
