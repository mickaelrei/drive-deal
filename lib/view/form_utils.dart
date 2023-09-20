import 'package:flutter/material.dart';

/// Widget for form title
class FormTitle extends StatelessWidget {
  /// Constructor
  const FormTitle({required this.title, super.key});

  /// Title to show
  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
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
    required this.label,
    this.controller,
    this.prefixIcon,
    this.validator,
    this.onTap,
    this.hidden = false,
    super.key,
  });

  /// What is this form entry supposed to represent
  final String label;

  /// Search text controller
  final TextEditingController? controller;

  /// Optional prefix icon
  final IconData? prefixIcon;

  /// Optional validator function
  final String? Function(String?)? validator;

  /// Optional on tap function
  final void Function()? onTap;

  /// Whether the written text should be hidden (like for a password)
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
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
class FormTextHeader extends StatelessWidget {
  /// Constructor
  const FormTextHeader({required this.label, super.key});

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
    super.key,
  });

  /// Initially picked date when date picker shows up
  final DateTime? initialDate;

  /// Optional first date
  final DateTime? firstDate;

  /// Optional callback for when a date is picked
  final void Function(DateTime)? onDatePicked;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        child: InputDecorator(
          decoration: InputDecoration(
            hintText: 'Purchase date',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Text(
            initialDate != null ? getDateString(initialDate!) : 'Purchase date',
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
    super.key,
  });

  /// Future to be used on [FutureBuilder]
  final Future<List<T>?> future;

  /// Widget to show when no data is received
  final Widget? noData;

  /// Callback to build the [DropdownButtonFormField]
  final Widget Function(T) dropdownBuilder;

  /// Callback for [DropdownButtonFormField] onChanged
  final void Function(T?)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          // Check for connection state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Check if data is null
          if (snapshot.data == null) {
            return noData ?? const _DefaultDropdownNoData();
          }

          // Build dropdown items
          final dropdownItems = <DropdownMenuItem<T>>[];
          for (final item in snapshot.data!) {
            dropdownItems.add(DropdownMenuItem(
              value: item,
              child: dropdownBuilder(item),
            ));
          }

          // Create dropdown
          return DropdownButtonFormField<T>(
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

/// Default [Widget] for when [FutureDropdown] gets no data
class _DefaultDropdownNoData extends StatelessWidget {
  const _DefaultDropdownNoData();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: InputDecorator(
        decoration: InputDecoration(
          hintText: 'Purchase date',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}

/// Method to get String form of date
String getDateString(DateTime date) {
  final day = date.day.toString();
  final month = date.month.toString();
  return '${day.padLeft(2, '0')}'
      '/'
      '${month.padLeft(2, '0')}'
      '/'
      '${date.year}';
}
