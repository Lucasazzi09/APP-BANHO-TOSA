🐾 Banho & Tosa — Sistema de Gestão para Pet Shops

Sistema profissional de gestão para pet shops, focado em alta performance web e experiência "Offline-First" com sincronização em nuvem.

🚀 Como Executar
1. **Pré-requisitos**: Flutter SDK (Canal Stable) e conta no Firebase.
2. **Configuração**: Adicione suas credenciais no arquivo `lib/config/firebase_config.dart`.
3. **Instalação**: `flutter pub get`
4. **Execução**: `flutter run -d chrome`

✨ Funcionalidades
*   **Agenda Inteligente**: Gestão de horários com notificações nativas no navegador.
*   **Gestão de Estoque**: Alertas automáticos de nível crítico e geração de catálogo PDF.
*   **CRM Pet**: Histórico completo de clientes e animais com armazenamento Base64 (Zero custo de Storage).
*   **Financeiro**: Fluxo de caixa simplificado integrado aos serviços realizados.
*   **LGPD Ready**: Funções nativas para exclusão definitiva de dados do usuário e transparência no armazenamento local.

🛠️ Tecnologias
*   **Core**: Flutter Web
*   **State Management**: Provider
*   **Backend**: Firebase (Auth & Firestore NoSQL)
*   **Local Storage**: SharedPreferences (JSON Persistence)
*   **Relatórios**: PDF & Printing Library

📁 Estrutura de Pastas
* `/lib/models`: Entidades de dados.
* `/lib/screens`: Interfaces de usuário separadas por módulos.
* `/lib/services`: Lógica de negócio (Auth, Storage, Notificações).
* `/lib/config`: Configurações globais e constantes do Firebase.

🌐 Deploy (Firebase Hosting)
1. `flutter build web --release`
2. `firebase deploy --only hosting`

---
Desenvolvido com ❤️ para a comunidade Pet.
