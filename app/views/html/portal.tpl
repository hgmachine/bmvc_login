<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Portal</title>
</head>
<body>
    <h1>Login</h1>
    <form action="/portal" method="post">
        <label for="username">Nome:</label>
        <input id="username" name="username" type="text" required /><br>

        <label for="password">Senha:</label>
        <input id="password" name="password" type="password" required /><br>

        <input value="Login" type="submit" />
    </form>
    <form action="/logout" method="post">
        <button type="submit">Logout</button>
    </form>
</body>
</html>
