import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width *
          0.75, // Ensuring width consistency
      margin:
          const EdgeInsets.symmetric(vertical: 12), // Spacing between elements
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B5998), // Dark blue color
          padding: const EdgeInsets.symmetric(vertical: 16), // Vertical padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6), // Slightly rounded edges
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 15, color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
