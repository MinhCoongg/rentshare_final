import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? initialValue;
  final String? hint;
  final String? suffix;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String)? onChanged;
  final TextInputType? keyboardType;

  const CustomTextField({
    super.key, 
    required this.label,
    this.initialValue,
    this.hint,
    this.suffix,
    this.maxLines = 1,
    this.inputFormatters,
    this.onChanged,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, 
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          maxLines: maxLines,
          initialValue: initialValue,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint, 
            suffixText: suffix, 
            filled: true, 
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10), 
              borderSide: BorderSide(color: Colors.grey[300]!)
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10), 
              borderSide: const BorderSide(color: Color(0xFF1976D2))
            ),
          ),
        ),
      ],
    );
  }
}