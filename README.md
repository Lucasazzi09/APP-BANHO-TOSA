# 🐾 Banho & Tosa - Sistema de Gestão

Sistema completo de gestão para pet shops desenvolvido em Flutter + Firebase.

---

## 📁 Estrutura do Projeto

```
C:\App\
├── 📱 BanhoTosa/              # Código-fonte do aplicativo
├── 📚 Documentacao/           # Documentação técnica
├── 🔥 Configuracao_Firebase/  # Setup do Firebase
└── 🛠️ Instalacao_Flutter/     # Instalação do Flutter
```

---

## 🚀 Início Rápido

### 1. Executar o App
```bash
cd C:\App\BanhoTosa
flutter run -d chrome
```

### 2. Fazer Login
- **Usuário:** Seu nome de usuário cadastrado
- **Senha:** Sua senha

### 3. Explorar
- 🏠 **Home** - Dashboard com resumo
- 👥 **Clientes** - Cadastro de clientes
- 🐶 **Pets** - Cadastro de pets
- 📅 **Agendamentos** - Gestão de serviços
- 💰 **Relatórios** - Financeiro
- ⚙️ **Configurações** - Foto de perfil e conta

---

## 📚 Documentação

### 📖 Leia Primeiro
**[Documentacao/RESUMO_MELHORIAS.md](Documentacao/RESUMO_MELHORIAS.md)**
- O que foi implementado
- Como usar as funcionalidades
- Comparação antes/depois

### 🔒 Segurança
**[Documentacao/SECURITY.md](Documentacao/SECURITY.md)**
- Proteção de credenciais
- Conformidade LGPD
- Checklist de deploy

### 🧪 Testes
**[Documentacao/TESTES.md](Documentacao/TESTES.md)**
- Como testar cada funcionalidade
- Validação de recursos

---

## ✨ Funcionalidades

### 👤 Usuários
- ✅ Cadastro com nome, email e senha
- ✅ Login com username ou email
- ✅ Foto de perfil (Base64 - gratuito!)
- ✅ Recuperação de senha
- ✅ Excluir conta (LGPD)

### 🐾 Gestão
- ✅ Cadastro de clientes
- ✅ Cadastro de pets (com porte)
- ✅ Agendamentos de serviços
- ✅ Controle de produtos
- ✅ Alerta de estoque baixo
- ✅ Gestão de serviços e preços

### 💰 Financeiro
- ✅ Controle de pagamentos
- ✅ Relatórios de faturamento
- ✅ Histórico de vendas
- ✅ Múltiplas formas de pagamento

### 🔔 Notificações
- ✅ Lembrete 3h e 1h antes do agendamento
- ✅ Notificação na hora
- ✅ Alerta de Estoque Baixo (Navegador)
- ✅ WhatsApp integrado

---

## 🛠️ Tecnologias

- **Flutter** - Framework multiplataforma
- **Firebase Auth** - Autenticação
- **Firestore** - Banco de dados
- **SharedPreferences** - Cache local
- **Image Picker** - Seleção de fotos
- **Animate Do** - Animações

---

## 🔥 Firebase Setup

### Serviços Utilizados
- ✅ **Authentication** - Login/Cadastro
- ✅ **Firestore** - Banco de dados
- ❌ **Storage** - NÃO usado (Base64 no Firestore)

### Configurar
Leia: **[Configuracao_Firebase/FIREBASE_SETUP.md](Configuracao_Firebase/FIREBASE_SETUP.md)**

---

## 📊 Status do Projeto

### ✅ Completo
- Sistema de gestão funcional
- Autenticação segura
- Foto de perfil
- Documentação completa
- Conformidade LGPD (70%)

### 🔄 Melhorias Futuras
- [ ] Exportação de dados (LGPD)
- [ ] Backup automático
- [ ] App mobile (Android/iOS)
- [ ] Dashboard analytics
- [ ] Multi-usuário

---

## 📞 Suporte

### Problemas?
1. Verifique **[Documentacao/TESTES.md](Documentacao/TESTES.md)**
2. Leia **[Documentacao/SECURITY.md](Documentacao/SECURITY.md)**
3. Veja comentários no código

### Dúvidas sobre código?
- Todos os arquivos `.dart` estão documentados
- Leia os comentários em cada classe/método

---

## 📝 Licença

Projeto desenvolvido para uso pessoal/comercial.

---

## 🎉 Versão

**v1.0.0** - Sistema completo e funcional

**Última atualização:** 20/03/2024

---

**Desenvolvido com ❤️ usando Flutter + Firebase**
