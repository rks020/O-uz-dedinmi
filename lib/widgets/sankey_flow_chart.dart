import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SankeyFlowChart extends StatefulWidget {
  final double income;
  final double expenses;
  final List<CategoryVolume> incomeBreakdown;
  final List<CategoryVolume> expenseBreakdown;

  const SankeyFlowChart({
    super.key,
    required this.income,
    required this.expenses,
    required this.incomeBreakdown,
    required this.expenseBreakdown,
  });

  @override
  State<SankeyFlowChart> createState() => _SankeyFlowChartState();
}

class _SankeyFlowChartState extends State<SankeyFlowChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);
    _controller.forward();
  }

  @override
  void didUpdateWidget(SankeyFlowChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.income != widget.income || oldWidget.expenses != widget.expenses) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.income == 0 && widget.expenses == 0) {
      return const Center(
        child: Text(
          'Akış gösterilecek veri bulunamadı',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(double.infinity, 300),
          painter: FlowPainter(
            income: widget.income,
            expenses: widget.expenses,
            incomeBreakdown: widget.incomeBreakdown,
            expenseBreakdown: widget.expenseBreakdown,
            progress: _animation.value,
          ),
        );
      },
    );
  }
}

class CategoryVolume {
  final String name;
  final double amount;
  final Color color;

  CategoryVolume({required this.name, required this.amount, required this.color});
}

class FlowPainter extends CustomPainter {
  final double income;
  final double expenses;
  final List<CategoryVolume> incomeBreakdown;
  final List<CategoryVolume> expenseBreakdown;
  final double progress;

  FlowPainter({
    required this.income,
    required this.expenses,
    required this.incomeBreakdown,
    required this.expenseBreakdown,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 0);
    
    final double nodeWidth = 12.0;
    final double padding = 20.0;
    final double chartHeight = size.height;
    final double leftX = padding;
    final double midX = size.width / 2;
    final double rightX = size.width - padding - nodeWidth;

    // Use total income as the base for scale
    final double totalScale = income > 0 ? income : (expenses > 0 ? expenses : 100);
    final double heightScale = (chartHeight - 40) / totalScale;

    // --- LEFT NODES (Income Categories) ---
    double currentLeftY = 20.0;
    for (var inc in incomeBreakdown) {
      final double nodeHeight = inc.amount * heightScale;
      final Rect rect = Rect.fromLTWH(leftX, currentLeftY, nodeWidth, nodeHeight);
      
      // Draw Input Bar
      final paint = Paint()..color = inc.color;
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(2)), paint);

      // Draw Connection to Middle
      final path = Path();
      path.moveTo(leftX + nodeWidth, currentLeftY);
      path.cubicTo(
        leftX + (midX - leftX) / 2, currentLeftY,
        leftX + (midX - leftX) / 2, currentLeftY,
        midX, currentLeftY
      );
      path.lineTo(midX, currentLeftY + nodeHeight);
      path.cubicTo(
        leftX + (midX - leftX) / 2, currentLeftY + nodeHeight,
        leftX + (midX - leftX) / 2, currentLeftY + nodeHeight,
        leftX + nodeWidth, currentLeftY + nodeHeight
      );
      path.close();

      canvas.drawPath(
        path, 
        Paint()..color = inc.color.withOpacity(0.2 * progress)
      );

      // Label
      _drawLabel(canvas, inc.name, currencyFormat.format(inc.amount), Offset(leftX + 20, currentLeftY + nodeHeight / 2));
      
      currentLeftY += nodeHeight + 10;
    }

    // --- MIDDLE NODE (Total Income) ---
    final double midNodeHeight = income * heightScale;
    final Rect midRect = Rect.fromLTWH(midX, 20, nodeWidth, midNodeHeight);
    canvas.drawRRect(
      RRect.fromRectAndRadius(midRect, const Radius.circular(2)), 
      Paint()..color = const Color(0xFF0055D4)
    );
    _drawLabel(canvas, "Toplam Gelir", currencyFormat.format(income), Offset(midX + 20, 20 + midNodeHeight / 2));

    // --- CONNECTIONS MIDDLE TO RIGHT ---
    double currentRightY = 20.0;
    
    // 1. Expenses flows
    for (var exp in expenseBreakdown) {
      final double expHeight = exp.amount * heightScale;
      _drawFlow(canvas, midX + nodeWidth, 20 + (currentRightY - 20), rightX, currentRightY, nodeWidth, expHeight, exp.color.withOpacity(0.2 * progress));
      
      // Right Node Bar
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(rightX, currentRightY, nodeWidth, expHeight), const Radius.circular(2)),
        Paint()..color = Colors.grey[700]!
      );
      _drawLabel(canvas, exp.name, currencyFormat.format(exp.amount), Offset(rightX - 10, currentRightY + expHeight / 2), alignRight: true);
      
      currentRightY += expHeight + 10;
    }

    // 2. Savings flow (Remaining)
    final double savings = income - expenses;
    if (savings > 0) {
      final double savingsHeight = savings * heightScale;
      _drawFlow(canvas, midX + nodeWidth, 20 + (currentRightY - 20), rightX, currentRightY, nodeWidth, savingsHeight, const Color(0xFF10B981).withOpacity(0.2 * progress));
      
      // Right Node Bar
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(rightX, currentRightY, nodeWidth, savingsHeight), const Radius.circular(2)),
        Paint()..color = const Color(0xFF10B981)
      );
      _drawLabel(canvas, "Artan Gelir", currencyFormat.format(savings), Offset(rightX - 10, currentRightY + savingsHeight / 2), alignRight: true);
    }
  }

  void _drawFlow(Canvas canvas, double sx, double sy, double tx, double ty, double width, double height, Color color) {
    final path = Path();
    path.moveTo(sx, sy);
    path.cubicTo(sx + (tx - sx) / 2, sy, sx + (tx - sx) / 2, ty, tx, ty);
    path.lineTo(tx, ty + height);
    path.cubicTo(sx + (tx - sx) / 2, ty + height, sx + (tx - sx) / 2, sy + height, sx, sy + height);
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawLabel(Canvas canvas, String label, String value, Offset offset, {bool alignRight = false}) {
    final span = TextSpan(
      children: [
        TextSpan(text: '$label\n', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10)),
        TextSpan(text: value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
    final tp = TextPainter(
      text: span,
      textAlign: alignRight ? TextAlign.right : TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    
    final double rectWidth = tp.width + 16;
    final double rectHeight = tp.height + 8;
    
    final double rx = alignRight ? offset.dx - rectWidth : offset.dx;
    final double ry = offset.dy - rectHeight / 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(rx, ry, rectWidth, rectHeight), const Radius.circular(8)),
      Paint()..color = Colors.black.withOpacity(0.4)
    );

    tp.paint(canvas, Offset(rx + 8, ry + 4));
  }

  @override
  bool shouldRepaint(FlowPainter oldDelegate) => oldDelegate.progress != progress;
}
