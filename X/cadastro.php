<?php
$nome = $_REQUEST["nome"] ?? "";
$email = $_REQUEST["email"] ?? "";
$senha = $_REQUEST["senha"] ?? "";

$comando = "INSERT INTO `login` (`id`, `nome`, `email`, `senha`) VALUES (NULL, '$nome', '$email', '$senha')";

$dsn = 'mysql:dbname=x;host=127.0.0.1';
$user = 'root';
$password = '';

$dbh = new PDO($dsn, $user, $password);

$resultado = $dbh->query($comando);

if($resultado) {
    echo "Cadastrado com sucesso!";
} else {
    echo "Erro ao cadastrar!";
}
?>
