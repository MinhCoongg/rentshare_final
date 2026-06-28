import 'package:flutter/material.dart';
import 'package:rentshare_app/utils/format_utils.dart';

class PriceRangeFilter extends StatefulWidget {
  final double min, max;
  final Function(double, double) onApply;

  const PriceRangeFilter({super.key, required this.min, required this.max, required this.onApply});

  @override
  State<PriceRangeFilter> createState() => _PriceRangeFilterState();
}

class _PriceRangeFilterState extends State<PriceRangeFilter> {
  late RangeValues _currentRange;

  @override
  void initState() {
    super.initState();
    _currentRange = RangeValues(widget.min, widget.max);
  }

  @override
Widget build(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(child: Text("Chọn khoảng giá", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildPriceBadge("${_currentRange.start.toInt()}"),
            const Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
            _buildPriceBadge("${_currentRange.end.toInt()}"),
          ],
        ),
        
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF0056D2), 
            thumbColor: const Color(0xFF0056D2),
            trackHeight: 4,
          ),
          child: RangeSlider(
            values: _currentRange,
            min: 0, max: 1000000,
            onChanged: (values) => setState(() => _currentRange = values),
          ),
        ),
        
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0056D2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => widget.onApply(_currentRange.start, _currentRange.end),
            child: const Text("Áp dụng", style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        )
      ],
    ),
  );
}
  Widget _buildPriceBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
      child: Text('${FormatUtils.formatMoney(double.parse(text))}đ', style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}