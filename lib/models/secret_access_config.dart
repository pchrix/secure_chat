import 'dart:convert';

enum SecretAccessMethod {
  longPress,
  multiplePress,
  calculationSequence,
}

enum CalculatorButton {
  sqrt,
  clear,
  equals,
  zero,
  one,
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  nine,
  plus,
  minus,
  multiply,
  divide,
  decimal,
  pi,
  e,
  sin,
  cos,
  tan,
  log,
  ln,
  factorial,
  power,
}

class SecretAccessConfig {
  final SecretAccessMethod method;
  final CalculatorButton? triggerButton;
  final int? pressCount;
  final String? calculationSequence;
  final bool isEnabled;

  const SecretAccessConfig({
    required this.method,
    this.triggerButton,
    this.pressCount,
    this.calculationSequence,
    this.isEnabled = true,
  });

  // Default configuration (current behavior)
  static const SecretAccessConfig defaultConfig = SecretAccessConfig(
    method: SecretAccessMethod.longPress,
    triggerButton: CalculatorButton.sqrt,
    isEnabled: true,
  );

  // Alternative configurations
  static const SecretAccessConfig clearPressConfig = SecretAccessConfig(
    method: SecretAccessMethod.multiplePress,
    triggerButton: CalculatorButton.clear,
    pressCount: 4,
    isEnabled: true,
  );

  static const SecretAccessConfig calculationConfig = SecretAccessConfig(
    method: SecretAccessMethod.calculationSequence,
    calculationSequence: "7+4*5-3",
    isEnabled: true,
  );

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'method': method.index,
      'triggerButton': triggerButton?.index,
      'pressCount': pressCount,
      'calculationSequence': calculationSequence,
      'isEnabled': isEnabled,
    };
  }

  // Create from JSON
  factory SecretAccessConfig.fromJson(Map<String, dynamic> json) {
    return SecretAccessConfig(
      method: SecretAccessMethod.values[json['method'] ?? 0],
      triggerButton: json['triggerButton'] != null 
          ? CalculatorButton.values[json['triggerButton']] 
          : null,
      pressCount: json['pressCount'],
      calculationSequence: json['calculationSequence'],
      isEnabled: json['isEnabled'] ?? true,
    );
  }

  // Create from JSON string
  factory SecretAccessConfig.fromJsonString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return SecretAccessConfig.fromJson(json);
  }

  // Convert to JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }

  // Copy with modifications
  SecretAccessConfig copyWith({
    SecretAccessMethod? method,
    CalculatorButton? triggerButton,
    int? pressCount,
    String? calculationSequence,
    bool? isEnabled,
  }) {
    return SecretAccessConfig(
      method: method ?? this.method,
      triggerButton: triggerButton ?? this.triggerButton,
      pressCount: pressCount ?? this.pressCount,
      calculationSequence: calculationSequence ?? this.calculationSequence,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SecretAccessConfig &&
        other.method == method &&
        other.triggerButton == triggerButton &&
        other.pressCount == pressCount &&
        other.calculationSequence == calculationSequence &&
        other.isEnabled == isEnabled;
  }

  @override
  int get hashCode {
    return Object.hash(
      method,
      triggerButton,
      pressCount,
      calculationSequence,
      isEnabled,
    );
  }

  @override
  String toString() {
    return 'SecretAccessConfig(method: $method, triggerButton: $triggerButton, pressCount: $pressCount, calculationSequence: $calculationSequence, isEnabled: $isEnabled)';
  }
}

// Helper extensions for display names
extension SecretAccessMethodExtension on SecretAccessMethod {
  String get displayName {
    switch (this) {
      case SecretAccessMethod.longPress:
        return 'Appui long';
      case SecretAccessMethod.multiplePress:
        return 'Appuis multiples';
      case SecretAccessMethod.calculationSequence:
        return 'Séquence de calcul';
    }
  }

  String get description {
    switch (this) {
      case SecretAccessMethod.longPress:
        return 'Maintenir un bouton enfoncé';
      case SecretAccessMethod.multiplePress:
        return 'Appuyer plusieurs fois rapidement';
      case SecretAccessMethod.calculationSequence:
        return 'Effectuer un calcul spécifique';
    }
  }
}

extension CalculatorButtonExtension on CalculatorButton {
  String get displayName {
    switch (this) {
      case CalculatorButton.sqrt:
        return '√';
      case CalculatorButton.clear:
        return 'C';
      case CalculatorButton.equals:
        return '=';
      case CalculatorButton.zero:
        return '0';
      case CalculatorButton.one:
        return '1';
      case CalculatorButton.two:
        return '2';
      case CalculatorButton.three:
        return '3';
      case CalculatorButton.four:
        return '4';
      case CalculatorButton.five:
        return '5';
      case CalculatorButton.six:
        return '6';
      case CalculatorButton.seven:
        return '7';
      case CalculatorButton.eight:
        return '8';
      case CalculatorButton.nine:
        return '9';
      case CalculatorButton.plus:
        return '+';
      case CalculatorButton.minus:
        return '-';
      case CalculatorButton.multiply:
        return '×';
      case CalculatorButton.divide:
        return '÷';
      case CalculatorButton.decimal:
        return '.';
      case CalculatorButton.pi:
        return 'π';
      case CalculatorButton.e:
        return 'e';
      case CalculatorButton.sin:
        return 'sin';
      case CalculatorButton.cos:
        return 'cos';
      case CalculatorButton.tan:
        return 'tan';
      case CalculatorButton.log:
        return 'log';
      case CalculatorButton.ln:
        return 'ln';
      case CalculatorButton.factorial:
        return '!';
      case CalculatorButton.power:
        return '^';
    }
  }

  String get description {
    switch (this) {
      case CalculatorButton.sqrt:
        return 'Bouton racine carrée';
      case CalculatorButton.clear:
        return 'Bouton effacer';
      case CalculatorButton.equals:
        return 'Bouton égal';
      default:
        return 'Bouton $displayName';
    }
  }
}
