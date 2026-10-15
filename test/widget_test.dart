import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz/data/models/budget_model.dart';
import 'package:quiz/widgets/budget_card.dart';
import 'package:quiz/widgets/primary_button.dart';

void main() {
  testWidgets('PrimaryButton renders text and triggers onPressed', (
    WidgetTester tester,
  ) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrimaryButton(
            text: 'Simpan',
            onPressed: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Simpan'), findsOneWidget);
    await tester.tap(find.text('Simpan'));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('BudgetCard renders budget info correctly', (
    WidgetTester tester,
  ) async {
    final budget = BudgetModel(
      id: 'test-1',
      category: 'Makanan',
      name: 'Budget Makan',
      amount: 1000000,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: BudgetCard(budget: budget, spent: 250000)),
      ),
    );

    expect(find.text('Budget Makan'), findsOneWidget);
    expect(find.text('Makanan'), findsOneWidget);
  });

  testWidgets('BudgetCard triggers onTap callback when tapped', (
    WidgetTester tester,
  ) async {
    bool tapped = false;
    final budget = BudgetModel(
      id: 'test-2',
      category: 'Transportasi',
      name: 'Bensin',
      amount: 500000,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BudgetCard(
            budget: budget,
            spent: 100000,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Bensin'));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
