import 'package:flutter/material.dart';

/// Text entry for a Form
class FormTextEntry extends StatelessWidget {
  /// Constructor
  const FormTextEntry({
    required this.label,
    required this.controller,
    this.prefixIcon,
    this.validator,
    this.hidden = false,
    super.key,
  });

  /// What is this form entry supposed to represent
  final String label;

  /// Search text controller
  final TextEditingController controller;

  /// Optional prefix icon
  final IconData? prefixIcon;

  /// Optional validator function
  final String? Function(String?)? validator;

  /// Whether the written text should be hidden (like for a password)
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
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
