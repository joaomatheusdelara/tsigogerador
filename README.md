

TSIGO Gerador – Aplicativo Flutter
=======================

Resumo do Projeto

O aplicativo TSIGO Gerador foi desenvolvido para monitoramento, automação e manutenção de geradores de energia, integrando recursos avançados de telemetria, notificações em tempo real e futuramente checklist digital.
A solução conecta o usuário à plataforma TSIGO por meio de uma API REST, permitindo visualizar dados críticos como status, horímetro, tensão, comandos remotos e alertas, tudo em uma interface clean, intuitiva e responsiva.

O projeto foi idealizado para tornar o processo de gestão de geradores mais eficiente, reduzindo falhas operacionais e otimizando a manutenção preventiva e corretiva. A aplicação utiliza o Flutter (com visual Cupertino), Riverpod, Firebase e integra com a API da TSIGO para uma experiência robusta e segura.

Funcionalidades Principais
Dashboard: Visualização geral dos geradores (status, alertas, últimas notificações).

Monitoramento em Tempo Real: Telemetria (Status da rede, Status do Gerador, tensão, etc.).

Automação: Envio de comandos remotos para o gerador (ligar, desligar, reset, alterar horimetro, etc).


Notificações Push: Alertas automáticos e críticos para o usuário (via Firebase Cloud Messaging).

Suporte: Acesso direto a informações de suporte da empresa.

__________________________________________________________________________________________________________

Como Rodar o Projeto


Pré-requisitos
Flutter SDK (versão 3.6.1 ou superior)
Dart
Editor de código (recomendo VSCode ou Android Studio)

Android/iOS Emulator, ou um dispositivo físico

Passo a Passo

Clone o repositório:
git clone https://github.com/joaomatheusdelara/tsigogerador.git

Instale as dependências:

No terminal: flutter pub get

Configuração do Firebase(opcional):
Já incluso o arquivo firebase_options.dart.
Se quiser integrar com seu próprio projeto, siga a documentação FlutterFire.

Rode o projeto:
No emulador Android/iOS, ou plugue seu celular.

No terminal: flutter run


DÚVIDAS?
=======================
Para qualquer dúvida durante o teste, entre em contato:
João Matheus de Lara – joao@tsigo.com.br


