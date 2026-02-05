import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/calculator/calculator_toggle_group_card.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/calculator/info_button_config.dart';
import 'package:gloomhaven_enhancement_calc/ui/widgets/ghc_divider.dart';

void main() {
  group('CalculatorToggleGroupCard', () {
    Widget buildWidget(List<ToggleGroupItem> items) {
      return MaterialApp(
        theme: ThemeData(
          dividerTheme: const DividerThemeData(color: Colors.grey),
        ),
        home: Scaffold(body: CalculatorToggleGroupCard(items: items)),
      );
    }

    testWidgets('renders correct number of toggle items', (tester) async {
      await tester.pumpWidget(
        buildWidget([
          const ToggleGroupItem(title: 'Item 1', value: false),
          const ToggleGroupItem(title: 'Item 2', value: true),
          const ToggleGroupItem(title: 'Item 3', value: false),
        ]),
      );

      expect(find.byType(Switch), findsNWidgets(3));
    });

    testWidgets('GHCDivider between items but not after last', (tester) async {
      await tester.pumpWidget(
        buildWidget([
          const ToggleGroupItem(title: 'Item 1', value: false),
          const ToggleGroupItem(title: 'Item 2', value: true),
          const ToggleGroupItem(title: 'Item 3', value: false),
        ]),
      );

      // 3 items → 2 dividers
      expect(find.byType(GHCDivider), findsNWidgets(2));
    });

    testWidgets('title text displayed for text-based items', (tester) async {
      await tester.pumpWidget(
        buildWidget([const ToggleGroupItem(title: 'My Toggle', value: false)]),
      );

      expect(find.text('My Toggle'), findsOneWidget);
    });

    testWidgets('titleWidget displayed for widget-based items', (tester) async {
      await tester.pumpWidget(
        buildWidget([
          ToggleGroupItem(titleWidget: const Icon(Icons.star), value: false),
        ]),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('subtitle displayed when provided', (tester) async {
      await tester.pumpWidget(
        buildWidget([
          const ToggleGroupItem(
            title: 'Title',
            subtitle: 'Subtitle text',
            value: false,
          ),
        ]),
      );

      expect(find.text('Subtitle text'), findsOneWidget);
    });

    testWidgets('switch reflects value state', (tester) async {
      await tester.pumpWidget(
        buildWidget([
          const ToggleGroupItem(title: 'Off', value: false),
          const ToggleGroupItem(title: 'On', value: true),
        ]),
      );

      final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
      expect(switches[0].value, isFalse);
      expect(switches[1].value, isTrue);
    });

    testWidgets('switch disabled when enabled = false', (tester) async {
      await tester.pumpWidget(
        buildWidget([
          const ToggleGroupItem(
            title: 'Disabled',
            value: false,
            enabled: false,
            onChanged: null,
          ),
        ]),
      );

      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.onChanged, isNull);
    });

    testWidgets('tapping switch calls onChanged with toggled value', (
      tester,
    ) async {
      bool receivedValue = false;

      await tester.pumpWidget(
        buildWidget([
          ToggleGroupItem(
            title: 'Toggle Me',
            value: false,
            onChanged: (value) => receivedValue = value,
          ),
        ]),
      );

      await tester.tap(find.byType(Switch));
      expect(receivedValue, isTrue);
    });

    testWidgets('tapping title area toggles switch', (tester) async {
      bool receivedValue = false;

      await tester.pumpWidget(
        buildWidget([
          ToggleGroupItem(
            title: 'Tap Title',
            value: false,
            onChanged: (value) => receivedValue = value,
          ),
        ]),
      );

      await tester.tap(find.text('Tap Title'));
      expect(receivedValue, isTrue);
    });

    testWidgets('custom trailingWidget replaces switch', (tester) async {
      await tester.pumpWidget(
        buildWidget([
          ToggleGroupItem(
            title: 'Custom Trailing',
            value: false,
            trailingWidget: const Icon(Icons.open_in_new),
          ),
        ]),
      );

      expect(find.byIcon(Icons.open_in_new), findsOneWidget);
      expect(find.byType(Switch), findsNothing);
    });

    testWidgets('onTap overrides toggle behavior on title tap', (tester) async {
      bool onTapCalled = false;
      bool onChangedCalled = false;

      await tester.pumpWidget(
        buildWidget([
          ToggleGroupItem(
            title: 'Custom Tap',
            value: false,
            onChanged: (value) => onChangedCalled = true,
            onTap: () => onTapCalled = true,
          ),
        ]),
      );

      // Tap on title area
      await tester.tap(find.text('Custom Tap'));

      expect(onTapCalled, isTrue);
      expect(onChangedCalled, isFalse);
    });

    testWidgets('info button shown when infoConfig provided', (tester) async {
      await tester.pumpWidget(
        buildWidget([
          ToggleGroupItem(
            infoConfig: InfoButtonConfig.titleMessage(
              title: 'Info Title',
              message: RichText(text: const TextSpan(text: 'Info message')),
            ),
            title: 'With Info',
            value: false,
          ),
        ]),
      );

      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
    });

    testWidgets('info button is enabled when infoConfig.enabled is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildWidget([
          ToggleGroupItem(
            infoConfig: InfoButtonConfig.titleMessage(
              title: 'Info Title',
              message: RichText(text: const TextSpan(text: 'Info message')),
              enabled: true,
            ),
            title: 'With Info',
            value: false,
          ),
        ]),
      );

      final infoButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(infoButton.onPressed, isNotNull);
    });

    testWidgets('info button is disabled when infoConfig.enabled is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildWidget([
          ToggleGroupItem(
            infoConfig: InfoButtonConfig.titleMessage(
              title: 'Info Title',
              message: RichText(text: const TextSpan(text: 'Info message')),
              enabled: false,
            ),
            title: 'With Info',
            value: false,
          ),
        ]),
      );

      final infoButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(infoButton.onPressed, isNull);
    });

    testWidgets('single item has no dividers', (tester) async {
      await tester.pumpWidget(
        buildWidget([const ToggleGroupItem(title: 'Only', value: false)]),
      );

      expect(find.byType(GHCDivider), findsNothing);
    });
  });
}
