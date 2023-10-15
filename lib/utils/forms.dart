import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../entities/autonomy_level.dart';
import 'formats.dart';

/// Widget for form title
class FormTitle extends StatelessWidget {
  /// Constructor
  const FormTitle({required this.title, super.key});

  /// Title to show
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Align(
        alignment: Alignment.center,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Text entry for a Form
class FormTextEntry extends StatelessWidget {
  /// Constructor
  const FormTextEntry({
    this.label,
    this.controller,
    this.text,
    this.prefixIcon,
    this.validator,
    this.onTap,
    this.hidden = false,
    this.enabled = true,
    this.formatters,
    super.key,
  });

  /// What is this form entry supposed to represent
  final String? label;

  /// Optional text controller
  final TextEditingController? controller;

  /// Optional initial text
  final String? text;

  /// Optional prefix icon
  final IconData? prefixIcon;

  /// Optional validator function
  final String? Function(String?)? validator;

  /// Optional on tap function
  final void Function()? onTap;

  /// Whether the written text should be hidden (like for a password)
  final bool hidden;

  /// Whether the text field is enabled or not
  final bool? enabled;

  /// Optional list of [TextInputFormatter]s
  final List<TextInputFormatter>? formatters;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        inputFormatters: formatters,
        enabled: enabled,
        initialValue: text,
        onTap: onTap,
        validator: validator,
        controller: controller,
        obscureText: hidden,
        decoration: InputDecoration(
          hintText: label,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}

/// Text that appears before a form text entry
class TextHeader extends StatelessWidget {
  /// Constructor
  const TextHeader({required this.label, super.key});

  /// What text to show on the header
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}

/// Wrapper for text for displaying entity info
class InfoText extends StatelessWidget {
  /// Constructor
  const InfoText(this.data, {super.key});

  /// Text to show
  final String data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Text(
        data,
        style: const TextStyle(
          fontSize: 25,
        ),
      ),
    );
  }
}

/// Button for submitting login attempt
class SubmitButton extends StatelessWidget {
  /// Constructor
  const SubmitButton({required this.label, this.onPressed, super.key});

  /// On button pressed
  final void Function()? onPressed;

  /// Button label
  final String label;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        child: Text(
          label,
          style: const TextStyle(fontSize: 25),
        ),
      ),
    );
  }
}

/// Widget for picking a date
class DatePicker extends StatelessWidget {
  /// Constructor
  const DatePicker({
    this.initialDate,
    this.firstDate,
    this.onDatePicked,
    this.hintText,
    super.key,
  });

  /// Initially picked date when date picker shows up
  final DateTime? initialDate;

  /// Optional first date
  final DateTime? firstDate;

  /// Optional input hint text
  final String? hintText;

  /// Optional callback for when a date is picked
  final void Function(DateTime)? onDatePicked;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        child: InputDecorator(
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Text(
            initialDate != null ? formatDate(initialDate!) : hintText ?? '',
          ),
        ),
        onTap: () async {
          final now = DateTime.now();

          final chosenDate = await showDatePicker(
            context: context,
            initialDate: initialDate ?? now,
            firstDate: firstDate ?? DateTime(1900),
            lastDate: now,
          );

          if (onDatePicked != null && chosenDate != null) {
            onDatePicked!(chosenDate);
          }
        },
      ),
    );
  }
}

/// Custom [DropdownButtonFormField] with [FutureBuilder]
class FutureDropdown<T> extends StatelessWidget {
  /// Constructor
  const FutureDropdown({
    required this.dropdownBuilder,
    required this.future,
    this.noData,
    this.onChanged,
    this.initialSelected,
    super.key,
  });

  /// Future to be used on [FutureBuilder]
  final Future<List<T>?>? future;

  /// Widget to show when no data is received
  final Widget? noData;

  /// Callback to build the [DropdownButtonFormField]
  final Widget Function(T) dropdownBuilder;

  /// Callback for [DropdownButtonFormField] onChanged
  final void Function(T?)? onChanged;

  /// Optional initial initialSelection value
  final T? initialSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          // Check for connection state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 12.0,
              ),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // Check if data is null
          if (snapshot.data == null) {
            if (noData != null) {
              return noData!;
            }

            return DropdownButtonFormField<T>(
              isExpanded: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              items: null,
              onChanged: onChanged,
            );
          }

          // Build dropdown items
          final dropdownItems = <DropdownMenuItem<T>>[];
          for (final item in snapshot.data!) {
            dropdownItems.add(DropdownMenuItem<T>(
              value: item,
              child: dropdownBuilder(item),
            ));
          }

          return DropdownButtonFormField<T>(
            value: initialSelected,
            isExpanded: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            items: dropdownItems,
            onChanged: onChanged,
          );
        },
      ),
    );
  }
}

/// Dropdown for [AutonomyLevel]s
class AutonomyLevelDropdown extends StatelessWidget {
  /// Constructor
  const AutonomyLevelDropdown({
    required this.items,
    this.controller,
    this.onSelected,
    this.initialSelection,
    this.enabled = true,
    super.key,
  });

  /// List of [AutonomyLevel]s
  final List<AutonomyLevel> items;

  /// Controller for text field
  final TextEditingController? controller;

  /// Current initialSelection item
  final AutonomyLevel? initialSelection;

  /// Whether the dropdown is enabled or not
  final bool enabled;

  /// Callback for when an item is initialSelection
  final void Function(AutonomyLevel?)? onSelected;

  @override
  Widget build(BuildContext context) {
    // Initialize entries
    final entries = <DropdownMenuEntry<AutonomyLevel>>[];
    for (final item in items) {
      entries.add(DropdownMenuEntry<AutonomyLevel>(
        value: item,
        label: item.label,
      ));
    }

    return DropdownMenu<AutonomyLevel>(
      enabled: enabled,
      enableFilter: true,
      enableSearch: true,
      width: MediaQuery.of(context).size.width - 16,
      onSelected: onSelected,
      initialSelection: initialSelection,
      controller: controller,
      dropdownMenuEntries: entries,
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}

/// [TextInputFormatter] for either CNPJ or name
class CnpjOrNameTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Empty text
    if (newValue.text == '') {
      return newValue;
    }

    // If first character is not a letter nor a digit, keep old value
    final letterDigitExp = RegExp(r'\w');
    if (!letterDigitExp.hasMatch(newValue.text[0])) {
      return oldValue;
    }

    // If first character is a letter, don't do any filtering
    final digitExp = RegExp(r'\d');
    if (!digitExp.hasMatch(newValue.text[0])) {
      return newValue;
    }

    // If erasing
    if (newValue.text.length < oldValue.text.length) {
      // Keep removing any trailing [./-] chars
      var newText = newValue.text;
      final exp = RegExp(r'[.\/-]');
      while (newText.isNotEmpty && exp.hasMatch(newText.characters.last)) {
        newText = newText.substring(0, newText.length - 1);
      }

      return TextEditingValue(text: newText);
    }

    // Remove non-digit chars from new text
    var newText = newValue.text;
    newText = newText.replaceAllMapped(
      RegExp(r'[.\/\-a-zA-Z]'),
      (match) => '',
    );

    // Check if surpassed 14 digits limit
    final newLength = newText.length;
    if (newLength > 14) {
      return oldValue;
    }

    // Format text based on new length
    if (newLength <= 2) {
      // Text remains the same
    } else if (newLength <= 5) {
      newText = '${newText.substring(0, 2)}'
          '.'
          '${newText.substring(2, newLength)}';
    } else if (newLength <= 8) {
      newText = '${newText.substring(0, 2)}'
          '.'
          '${newText.substring(2, 5)}'
          '.'
          '${newText.substring(5, newLength)}';
    } else if (newLength <= 12) {
      newText = '${newText.substring(0, 2)}'
          '.'
          '${newText.substring(2, 5)}'
          '.'
          '${newText.substring(5, 8)}'
          '/'
          '${newText.substring(8, newLength)}';
    } else {
      newText = '${newText.substring(0, 2)}'
          '.'
          '${newText.substring(2, 5)}'
          '.'
          '${newText.substring(5, 8)}'
          '/'
          '${newText.substring(8, 12)}'
          '-'
          '${newText.substring(12, newLength)}';
    }

    return TextEditingValue(text: newText);
  }
}
