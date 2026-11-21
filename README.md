<p align="center">
    <img src="assets/logo/logo.svg" alt="Logo da Biblioteca Pessoal" width="120px">
</p>

<h1 align="center" style="font-weight: bold;">Biblioteca Pessoal</h1>

<p align="center">
 <a href="#tech">Tecnologias</a> •
 <a href="#architecture">Arquitetura</a> •
 <a href="#started">Primeiros passos</a> •
 <a href="#colab">Colaboradores</a> •
 <a href="#contribute">Contribuir</a>
</p>

<p align="center">
    <b>App Flutter para acompanhar o progresso de leitura: cadastre livros, atualize a página atual e veja suas estatísticas.</b>
</p>

<p align="center">
     <a href="https://github.com/DevDaleee/my-personal-lib">⚙️ Ver o back-end (microsserviços em Go)</a>
</p>

> **Status:** em desenvolvimento. O destino final é mobile (Android/iOS). A versão web existe para as entregas da disciplina e é servida pelo gateway do back-end.

<h2 id="layout">🎨 Layout</h2>

As capturas de tela entram aqui quando as primeiras telas estiverem prontas.

| Tela | O que faz |
|---|---|
| Entrar / Criar conta | login e cadastro |
| Minha biblioteca | lista de livros com filtro por status |
| Novo livro | cadastro de livro |
| Detalhe do livro | dados e atualização da página atual |
| Estatísticas | páginas por dia, livros concluídos por mês e sequência de dias de leitura |

<h2 id="tech">💻 Tecnologias</h2>

- Flutter e Dart (Material 3)
- [http](https://pub.dev/packages/http) para falar com a API REST
- [shared_preferences](https://pub.dev/packages/shared_preferences) para guardar o token de login
- Back-end: microsserviços em Go, NATS e gateway Nginx ([my-personal-lib](https://github.com/DevDaleee/my-personal-lib))

<h2 id="architecture">🧭 Arquitetura</h2>

```
App Flutter ──HTTP/JSON──▶ Gateway (Nginx) ──▶ /auth, /books → books-service
                                            └─▶ /stats       → stats-service
```

O app fala somente com o gateway. A URL da API não fica fixa no código: ela vem da variável `API_BASE_URL` do arquivo `.env` (lido com `flutter_dotenv`).

| Ambiente | `API_BASE_URL` |
|---|---|
| Desenvolvimento web | `http://localhost:8080` |
| Build servido pelo gateway | `/` (mesma origem) |
| Emulador Android | `http://10.0.2.2:8080` |

<h2 id="started">🚀 Primeiros passos</h2>

Como rodar o app localmente.

<h3>Pré-requisitos</h3>

- [Flutter](https://docs.flutter.dev/get-started/install) 3.47 ou superior
- [Git](https://git-scm.com)
- [Docker](https://docs.docker.com/get-docker/), para subir o back-end

<h3>Clonando</h3>

```bash
git clone https://github.com/DevDaleee/my-personal-lib-app.git
git clone https://github.com/DevDaleee/my-personal-lib.git
```

<h3>Iniciando</h3>

Suba o back-end:

```bash
cd my-personal-lib
docker compose up -d
```

Crie o `.env` a partir do exemplo e ajuste o `API_BASE_URL` (veja a tabela em [Arquitetura](#architecture)):

```bash
cd ../my-personal-lib-app
cp .env.example .env
```

Rode o app no Chrome (com `API_BASE_URL=http://localhost:8080` no `.env`):

```bash
flutter pub get
flutter run -d chrome
```

No emulador Android, troque o `.env` para `API_BASE_URL=http://10.0.2.2:8080` e rode:

```bash
flutter run
```

<h3>Build web</h3>

Com `API_BASE_URL=/` no `.env`:

```bash
flutter build web
```

O resultado fica em `build/web`, que o gateway do back-end serve em `/`.

> O `.env` vai junto no build e, na web, fica público. Não coloque nada secreto nele.

<h2 id="colab">🤝 Colaboradores</h2>

<table>
  <tr>
    <td align="center">
      <a href="https://github.com/DevDaleee">
        <img src="https://github.com/DevDaleee.png" width="100px;" alt="Foto de perfil de DevDaleee"/><br>
        <sub>
          <b>DevDaleee</b>
        </sub>
      </a>
    </td>
  </tr>
</table>

<h2 id="contribute">📫 Contribuir</h2>

1. `git clone https://github.com/DevDaleee/my-personal-lib-app.git`
2. `git checkout -b feature/NOME`
3. Siga o padrão de commits: português, imperativo, minúsculo (`feat(...)`, `fix(...)`)
4. Antes de commitar, rode `dart format .`, `flutter analyze` (sem avisos) e `flutter test`
5. Abra um Pull Request explicando o problema resolvido ou a funcionalidade criada. Se houver mudança visual, anexe capturas de tela.

<h3>Documentação útil</h3>

[📝 Como criar um Pull Request](https://www.atlassian.com/br/git/tutorials/making-a-pull-request)

[💾 Padrão de commits](https://gist.github.com/joshbuchea/6f47e86d2510bce28f8e7f42ae84c716)
