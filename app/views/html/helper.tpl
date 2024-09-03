<!DOCTYPE html>

<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>.::Bem-vindo ao BMVC::.</title>
    <link rel="stylesheet" type="text/css" href="static/css/helper.css">
    <script src="../../static/js/helper.js"></script>
</head>

<body>

    <div class= "object_centered">
      <h1>Seja bem-vindo ao BMVC! (Bottle Powered)</h1>
      <h4>Estrutura desenvolvida para oferecer suporte ao desenvolvimento FullStack da disciplina de Orientação a Objetos.</h4>
      <img src="{{'static/img/BottleLogo.png'}}" alt="Descrição da Imagem"
          width="300" height="300" onclick="displayText()">
      <h4>H.G.M.</h4>
    </div>

    <div class="object_centered">
         <h3>Para inserir uma página (HTML ou TPL):</h3>
         <h4 class="justify-text">Defina uma rota (HTTP: GET) no arquivo route.py, tal como indicado a seguir:</h4>
         <pre class="code-block"><code>

@app.route('/pagina', methods=['GET'])
def action_pagina():
    return ctl.render('pagina')

         </code></pre>

         <h4 class="justify-text">Escreva o arquivo 'pagina.tpl' ou 'pagina.html' e o coloque na pasta 'app/views/html/'. Em seguida, insira os arquivos estáticos necessários nas pastas correpondentes (/css,/js,/img), existentes na pasta "app/static".
           Carregue-os na página em questão, inserindo linhas semelhantes às mostradas a seguir.</h4>
         <pre class="code-block"><code>

&lt;!DOCTYPE html&gt;
&lt;html lang="pt-BR"&gt;
&lt;head&gt;
   &lt;meta charset="UTF-8"&gt;
   &lt;meta name="viewport" content="width=device-width, initial-scale=1.0"&gt;
   &lt;title&gt;Minha primeira página com o BMVC&lt;/title&gt;
   &lt;link rel=&quot;stylesheet&quot; type=&quot;text/css&quot; href=&quot;/static/css/pagina.css&quot;&gt;
   &lt;script src=&quot;/static/js/pagina.js&quot;&gt;&lt;/script&gt;

&lt;/head&gt;
&lt;body&gt;

   &lt;h1&gt;Olá! Esta é a minha primeira página com o BMVC :)&lt;/h1&gt;

&lt;/body&gt;
&lt;/html&gt;

        </code></pre>

        <h4 class="justify-text">Edite o controlador Application (arquivo: application.py) para conter um método de administração
          dpara o conteúdo apresentado em '/pagina'.</h4>
          <pre class="code-block"><code>

def pagina(self):
    # seu código complementar aqui
    return template('app/views/html/pagina')

          </code></pre>

          <h4 class="justify-text">Não deixe de editar o dicionário 'self.pages' com a nova alternativa para a rota inserida.</h4>
          <pre class="code-block"><code>
(...)

self.pages = {
    'pagina': self.pagina
}
(...)
          </code></pre>

     </div>

     <div class="object_centered">
          <h3>Para inserir um modelo e acessá-lo em uma das página:</h3>
          <h4 class="justify-text">Todos os modelos deverão ser alocados na pasta 'app/models', em arquivos separados, com extensão '.py' - neste exemplo: 'user_account.py'. O modelo utilizado, neste exemplo, se encontra a seguir:
          </h4>
          <pre class="code-block"><code>

class UserAccount():
    def __init__(self, username, password):
        self.username= username
        self.password= password

          </code></pre>
          <h4 class="justify-text">Defina uma infraestrutura para armazenar seu(s) modelo em um disco (banco de dados). Esta infraestrutura deve ser organziada
            dentro da pasta 'app/controllers/db'. Talvez seja interessante que você defina uma 'classe administradora' para o seu banco de dados, para que você possa acessar
            seus modelos com praticidade e segurança. Veja o exemplo a seguir da classe administradora 'DataRecord':
          </h4>
          <pre class="code-block"><code>

from app.models.user_account import UserAccount
import json

class DataRecord():
    """Banco de dados JSON para o recurso Usuários"""

    def __init__(self):
        self.user_accounts= [] # banco (json)
        try:
            with open("app/controllers/db/user_accounts.json", "r") as arquivo_json:
                user_data = json.load(arquivo_json)
                self.user_accounts = [UserAccount(**data) for data in user_data]
                self.limit = len(self.user_accounts) - 1  # Definindo o limite com base no número de contas de usuário
        except FileNotFoundError:
            self.user_accounts.append(UserAccount('Guest', '000000'))
            self.limit = len(self.user_accounts) - 1  # Definindo o limite como 0 no caso de nenhum arquivo encontrado


    def work_with_parameter(self, parameter):
        try:
            index = int(parameter)  # Convertendo o parâmetro para inteiro
            if index <= self.limit:
                return self.user_accounts[index]
        except (ValueError, IndexError):
            return None  # Tratamento de erro se o índice for inválido

          </code></pre>
          <h4 class="justify-text">A classe 'DataRecord' deve ser colocada na pasta 'app/controllers/', no arquivo 'datarecord.py'. Como se pode ver,
            a classe DataRecord executa, em seu construtor, a leitura de um arquivo JSON: user_accounts. Este arquivo, está convenientemente alocado na pasta 'app/controllers/db'.
            Temos um conteúdo básico para este arquivo, a seguir.
          </h4>
          <pre class="code-block"><code>

[{"username": "Henrique", "password": "123456"},{"username": "Moura", "password": "456789"}]

          </code></pre>
          <h4 class="justify-text">Em seguida, realize uma composição de um objeto DataRecord dentro da Application (Application -> Datarecord), no ato de sua construção - este objeto/atributo
            será tratado por: 'self.models'. Ainda dentro da classe Application, insira seu processamento de dados (tratamento do modelo) na action desejada e transmita as informações através
            da função template, tal como indicado a seguir:
          </h4>
          <pre class="code-block"><code>
(...)

class Application():

    def __init__(self):

        self.pages = {
        'pagina': self.pagina
        }

        self.models= DataRecord()

(...)

    def render(self,page,parameter=None):
        content = self.pages.get(page, self.helper)
        if not parameter:
            return content()
        else:
            return content(parameter)

(...)

    def pagina(self,parameter=None):
        if not parameter:
            return template('app/views/html/pagina',transfered= False)
        else:
            info = self.models.work_with_parameter(parameter)
            if not info:
               redirect('/pagina')
            else:
               return template('app/views/html/pagina',transfered= True, data=info)

          </code></pre>

          <h4 class="justify-text">No código acima, o parametro passado para action deve ser transmitido pela rota ou action específica. Com este parâmetro, o objeto 'self.models' poderá
            manipular os modelos e entregar as informações requeridas para a pagina, através da variável data. Lembre-se de importa a classe DataRecord no seu arquivo 'application.py'. Manipule a variável 'data' no arquivo TPL em forma de código comum, estabelecido
            tal como no exemplo a seguir:
          </h4>
          <pre class="code-block"><code>

&lt;!DOCTYPE html&gt;
&lt;html lang="pt-BR"&gt;
&lt;head&gt;
    &lt;meta charset="UTF-8"&gt;
    &lt;meta name="viewport" content="width=device-width, initial-scale=1.0"&gt;
    &lt;title&gt;Minha segunda página com o BMVC&lt;/title&gt;
&lt;/head&gt;
&lt;body&gt;

    &lt;h1&gt;Minha página com interação de modelos :)&lt;/h1&gt;

    simbolo-% if transfered:
        &lt;div&gt;
            &lt;h2&gt;Dados do Usuário:&lt;/h2&gt;
            &lt;p&gt;Username: chaves-duplas data.username chaves-duplas &lt;/p&gt;
            &lt;p&gt;Password: chaves-duplas data.password chaves-duplas &lt;/p&gt;
        &lt;/div&gt;
    simbolo-% else:
        &lt;h2&gt;Porém, desta vez não foram transferidas quaisquer informações ): &lt;/h2&gt;
    simbolo-% end

&lt;/body&gt;
&lt;/html&gt;

          </code></pre>
          <h4 class="justify-text">Para finalizar, a rota específica deverá ser inserida no arquivo 'route.py'. Nosso exemplo termina
            com o fragmento de código a seguir:
          </h4>
          <pre class="code-block"><code>

@app.route('/pagina', methods=['GET'])
@app.route('/pagina/&lt;parameter&gt;', methods=['GET'])
def action_pagina(parameter=None):
    if not parameter:
        return ctl.render('pagina')
    else:
        return ctl.render('pagina',parameter)

          </code></pre>
          <h4 class="justify-text">Observe que a rota pode ser 'pagina/0' ou 'pagina/1'. Note que o recurso '/pagina' também poderá ser acessado sem informações sobre os modelos.
          </h4>
      </div>

      <div class="object_centered">
           <h3>Para realizar o controle de acesso em páginas (contas de usuário): </h3>
           <h4 class="justify-text">Para realizar o controle de acesso em páginas precisaremos de um recurso de LOGIN de usuários.
           Para iniciarmos, podemos editar o arquivo route.py para modificarmos a action de acesso à rota '/pagina/&lt;unknown&gt;', além de criar a rota '/portal'.</h4>
           <pre class="code-block"><code>

(...)

@app.route('/pagina', methods=['GET'])
@app.route('/pagina/&lt;username&gt;', methods=['GET'])
def action_pagina(username=None):
    if not username:
        return ctl.render('pagina')
    else:
        return ctl.render('pagina',username)


@app.route('/portal', method='GET')
def login():
    return ctl.render('portal')


@app.route('/portal', method='POST')
def action_portal():
    username = request.forms.get('username')
    password = request.forms.get('password')
    session_id, username= ctl.authenticate_user(username, password)
    if session_id:
        response.set_cookie('session_id', session_id, httponly=True, \
        secure=True, max_age=3600)
        redirect(f'/pagina/{username}')
    else:
        return redirect('/portal')

(...)
           </code></pre>

           <h4 class="justify-text">Note que temos, no portal, uma action com o verbo GET e outra com o método POST.
             A primeira é responsável pela visualização da página 'portal.tpl', enquanto a segunda realizar
             a captura das informações de usuário, para autenticação. O procedimento para autenticação,
             aqui adotado, opera com a criação (por parte do controlador) de uma variável denominada
             "session_id", que será armazenada na memória local do seu navegador (cliente). Deste modo,
             cada cliente autenticado terá uma única "session_id" por vez, que indicará o usuário autenticado.
             A função responsável pelo armazenamento da variável "session_id" no navegador realiza o trabalho
             definindo um cookie de sessão com atributos de segurança. O parâmetro "httponly=True" impedem que
             esta variável secreta seja acessada via JavaScript, mitigando riscos de ataques XSS. O parâmetro
             "secure=True" garante que o cookie só seja enviado via conexões HTTPS, mitigando ataques do tipo
             "man-in-the-middle". Por fim, o parâmetro "max_age=3600" estabelece uma hora de duração para a
             variável armazenada (pode ser alterado para durar menos tempo). É preciso, também, criar uma
             action (verbo POST) para a realização do LOGOUT, que redirecionará o usuário para a rota '/helper'. </h4>
             <pre class="code-block"><code>

  (...)

  @app.route('/logout', method='POST')
  def logout():
      ctl.logout_user()
      response.delete_cookie('session_id')
      redirect('/helper')

  (...)
             </code></pre>

             <h4 class="justify-text">A rota '/pagina/&lt;unknown&gt;' indica um recurso: o nome do usuário conectado. Ainda vamos editar o controlador
             Application para manusear o username em lugar de um índice de usuário. Agora, a action_pagina irá verificar a autenticação antes de renderizar
             o arquivo pagina.tpl. Se o parâmetro passado não estiver relacionado com o cookie armazenado (procerdimento de autenticação), ocorrerá o direcionamento do
             usuário para a rota '/portal'. O código para a pagina de LOGIN está apresentado a seguir. </h4>
            <pre class="code-block"><code>

&lt;!DOCTYPE html&gt;
&lt;html lang=&quot;pt-BR&quot;&gt;
&lt;head&gt;
    &lt;meta charset=&quot;UTF-8&quot;&gt;
    &lt;meta name=&quot;viewport&quot; content=&quot;width=device-width, initial-scale=1.0&quot;&gt;
    &lt;title&gt;Portal&lt;/title&gt;
&lt;/head&gt;
&lt;body&gt;
    &lt;h1&gt;Login&lt;/h1&gt;
    &lt;form action=&quot;/portal&quot; method=&quot;post&quot;&gt;
        &lt;label for=&quot;username&quot;&gt;Nome:&lt;/label&gt;
        &lt;input id=&quot;username&quot; name=&quot;username&quot; type=&quot;text&quot; required /&gt;&lt;br&gt;

        &lt;label for=&quot;password&quot;&gt;Senha:&lt;/label&gt;
        &lt;input id=&quot;password&quot; name=&quot;password&quot; type=&quot;password&quot; required /&gt;&lt;br&gt;

        &lt;input value=&quot;Login&quot; type=&quot;submit&quot; /&gt;
    &lt;/form&gt;
    &lt;form action=&quot;/logout&quot; method=&quot;post&quot;&gt;
        &lt;button type=&quot;submit&quot;&gt;Logout&lt;/button&gt;
    &lt;/form&gt;
&lt;/body&gt;
&lt;/html&gt;

            </code></pre>
              <h4 class="justify-text">Na página 'portal.tpl' temos um formulário para o usuário introduzir suas credenciais, além de botões
                com função de navegação. Precisamos, agora, nos focar nos ajustes das classes Application e DataRecord. Começando
          pela classe Application, temos que atualizar alguns métodos. O código revisado está a seguir:</h4>
          <pre class="code-block"><code>

from app.controllers.datarecord import DataRecord
from bottle import template, redirect, request


class Application():

def __init__(self):

    self.pages = {
        'pagina': self.pagina,
        'portal': self.portal
    }

    self.__model= DataRecord()
    self.__current_loginusername= None


def render(self,page,parameter=None):
    content = self.pages.get(page, self.helper)
    if not parameter:
        return content()
    else:
        return content(parameter)


def get_session_id(self):
    return request.get_cookie('session_id')


def helper(self):
    return template('app/views/html/helper')


def portal(self):
    return template('app/views/html/portal')


def pagina(self,username=None):
    if self.is_authenticated(username):
        session_id = self.get_session_id()
        user = self.__model.getCurrentUser(session_id)
        return template('app/views/html/pagina', current_user=user)
    else:
        return template('app/views/html/pagina', current_user=None)


def is_authenticated(self, username):
    session_id = self.get_session_id()
    current_username = self.__model.getUserName(session_id)
    return username == current_username


def authenticate_user(self, username, password):
    session_id = self.__model.checkUser(username, password)
    if session_id:
        self.logout_user()
        self.__current_username= self.__model.getUserName(session_id)
        return session_id, username
    return None


def logout_user(self):
    self.__current_username= None
    session_id = self.get_session_id()
    if session_id:
        self.__model.logout(session_id)

          </code></pre>
          <h4 class="justify-text">Inicialmente, temos que atualizar as rotas para as páginas novas, na lista "self.pages".
          temos também a criação de um atributo novo, self.__current_username, que guardará o nome do usuário autenticado
          em cada navegador (cliente). O método "get_session_id" retornará o valor da variável "session_id" armazenada nos
          cookies do navegador. Veja, também, que temos as actions para as páginas novas, com algumas regras de acesso controlado.
          O controle de página se dá a partir da verificação de autenticação. Vamos nos focar, agora, no mecanismo de autenticação.
          O método "is_authenticated" pode verificar se o nome de usuário informado está autenticado. Para esta regra funcionar, o sistema
          não poderia permitir dois usuários com o mesmo nome! O método de autenticação é a porta de entrada para a autenticação de um
          usuário. Antes desta autenticação, o sistema o logout de um usuário que, possivelmente, já esteja logado. A geração do valor (único)
          da variável "session_id" é realizada pelo objeto "model" (DataRecord) através da função "checkUser". A função "authenticate_user"
          retorna os valores de "session_id" e "username", por conveniencia. Para finalizar esta explicação, temos o método "logout" que
          desconecta um usuário do sistema, apagando seu "session_id" dos cookies do navagador. Vamos passar agora para o arquivo "datarecord.py".
          </h4>
          <pre class="code-block"><code>

from app.models.user_account import UserAccount
import json
import uuid


class DataRecord():
"""Banco de dados JSON para o recurso Usuários"""

def __init__(self):

    self.__user_accounts= []
    self.__authenticated_users = {}
    self.read()


def read(self):
    try:
        with open("app/controllers/db/user_accounts.json", "r") as arquivo_json:
            user_data = json.load(arquivo_json)
            self.__user_accounts = [UserAccount(**data) for data in user_data]
    except FileNotFoundError:
        self.__user_accounts.append(UserAccount('Guest', '010101','101010'))


def book(self,username,password):

    new_user= UserAccount(username,password)
    self.__user_accounts.append(new_user)
    with open("app/controllers/db/user_accounts.json", "w") as arquivo_json:
        user_data = [vars(user_account) for user_account in \
        self.__user_accounts]
        json.dump(user_data, arquivo_json)


def getCurrentUser(self,session_id):
    if session_id in self.__authenticated_users:
        return self.__authenticated_users[session_id]
    else:
        return None


def getUserName(self,session_id):
    if session_id in self.__authenticated_users:
        return self.__authenticated_users[session_id].username
    else:
        return None


def getUserSessionId(self, username):
    for session_id in self.__authenticated_users:
        if username == self.__authenticated_users[session_id].username:
            return session_id
    return None  # Retorna None se o usuário não for encontrado


def checkUser(self, username, password):
    for user in self.__user_accounts:
        if user.username == username and user.password == password:
            session_id = str(uuid.uuid4())  # Gera um ID de sessão único
            self.__authenticated_users[session_id] = user
            return session_id  # Retorna o ID de sessão para o usuário
    return None


def logout(self, session_id):
    if session_id in self.__authenticated_users:
        del self.__authenticated_users[session_id] # Remove o usuário logado

          </code></pre>
          <h4 class="justify-text"> A classe DataRecord foi refatorada. Temos um novo atributo (dicionário) que armazena
          os usuários autenticados, além do antigo atributo "__user_accounts", que armazena a lista de usuários cadastrados.
          O método "getUserName(session_id)" é usado para resgatar o nome do usuário cadastrado, e isso só é possível através
          do dicionário "__authenticated_users", pois o mesmo armazena os números de sessão juntamente com os nomes de usuários.
          O método "getUserSessionId(username)" resgata o número de sessão a partir do nome do usuário e o método
          "checkUser(username, password)" continua exercendo sua função dentro do sistema, porém com a geração do número de sessão.
          O número de sessão é gerado pela função "uuid.uuid4()" do pacote UUID (uuid.uuid4())- esta função gera um código universal,
          aleatório e único. Este código é então armazenado com chave de acesso para o username (também único). Por fim, temos
          um método para LOGOUT de usuários, que remove um usuário a partir do seu "session_id".
       </div>
</body>
</html>
