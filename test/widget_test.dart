// Testes básicos do app Banho & Tosa
//
// Para executar os testes:
// flutter test

import 'package:flutter_test/flutter_test.dart';
import 'package:banho_tosa/main.dart';

void main() {
  testWidgets('App inicia com tela de login', (WidgetTester tester) async {
    // Build do app
    await tester.pumpWidget(const BanhoTosaApp());

    // Verifica se a tela de login aparece
    expect(find.text('Banho & Tosa'), findsOneWidget);
    expect(find.text('Entrar'), findsWidgets);
  });
}
