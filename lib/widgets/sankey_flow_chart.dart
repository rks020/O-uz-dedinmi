import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

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
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.linear);
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
          size: const Size(double.infinity, 350),
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
    
    final double nodeWidth = 14.0;
    final double padding = 20.0;
    final double chartHeight = size.height;
    final double leftX = padding;
    final double midX = size.width / 2;
    final double rightX = size.width - padding - nodeWidth;

    final double totalScale = income > 0 ? income : (expenses > 0 ? expenses : 100);
    final double heightScale = (chartHeight - 60) / totalScale;

    // Animation phases
    // 0.0 - 0.2: Left Bars appear
    // 0.2 - 0.5: Flow from Left to Middle
    // 0.5 - 0.6: Middle Bar appears
    // 0.6 - 0.9: Flow from Middle to Right
    // 0.9 - 1.0: Right Bars / Labels appear

    double leftBarsProgress = (progress / 0.2).clamp(0.0, 1.0);
    double leftToMidProgress = ((progress - 0.2) / 0.3).clamp(0.0, 1.0);
    double midBarProgress = ((progress - 0.5) / 0.1).clamp(0.0, 1.0);
    double midToRightProgress = ((progress - 0.6) / 0.3).clamp(0.0, 1.0);
    double rightBarsProgress = ((progress - 0.9) / 0.1).clamp(0.0, 1.0);

    // --- LEFT NODES (Income Categories) ---
    double currentLeftY = 30.0;
    double currentMidEntryY = 30.0;

    for (var inc in incomeBreakdown) {
      final double nodeHeight = inc.amount * heightScale;
      
      if (leftBarsProgress > 0) {
        final paint = Paint()..color = inc.color.withOpacity(leftBarsProgress);
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(leftX, currentLeftY, nodeWidth, nodeHeight * leftBarsProgress), const Radius.circular(4)),
          paint
        );
        _drawLabel(canvas, inc.name, currencyFormat.format(inc.amount), Offset(leftX + 20, currentLeftY + nodeHeight / 2), opacity: leftBarsProgress);
      }

      if (leftToMidProgress > 0) {
        _drawCurvedFlow(
          canvas, 
          leftX + nodeWidth, currentLeftY, 
          midX, currentMidEntryY, 
          nodeHeight, 
          inc.color.withOpacity(0.3), 
          leftToMidProgress
        );
      }

      currentLeftY += nodeHeight + 20;
      currentMidEntryY += nodeHeight; // Stack them in the middle
    }

    // --- MIDDLE NODE (Total Income) ---
    final double midNodeHeight = income * heightScale;
    if (midBarProgress > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(midX, 30, nodeWidth, midNodeHeight * midBarProgress), const Radius.circular(4)), 
        Paint()..color = const Color(0xFF0055D4).withOpacity(midBarProgress)
      );
      _drawLabel(canvas, "Toplam Gelir", currencyFormat.format(income), Offset(midX - 10, 30 + midNodeHeight / 2), alignRight: true, opacity: midBarProgress);
    }

    // --- CONNECTIONS MIDDLE TO RIGHT ---
    double currentRightY = 30.0;
    double currentMidExitY = 30.0;

    // 1. Expenses flows
    for (var exp in expenseBreakdown) {
      final double expHeight = exp.amount * heightScale;
      
      if (midToRightProgress > 0) {
        _drawCurvedFlow(
          canvas, 
          midX + nodeWidth, currentMidExitY, 
          rightX, currentRightY, 
          expHeight, 
          exp.color.withOpacity(0.3), 
          midToRightProgress
        );
      }

      if (rightBarsProgress > 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(rightX, currentRightY, nodeWidth, expHeight * rightBarsProgress), const Radius.circular(4)),
          Paint()..color = Colors.grey[700]!.withOpacity(rightBarsProgress)
        );
        _drawLabel(canvas, exp.name, currencyFormat.format(exp.amount), Offset(rightX - 10, currentRightY + expHeight / 2), alignRight: true, opacity: rightBarsProgress);
      }
      
      currentRightY += expHeight + 20;
      currentMidExitY += expHeight;
    }

    // 2. Savings flow (Remaining)
    final double savings = income - expenses;
    if (savings > 0) {
      final double savingsHeight = savings * heightScale;
      
      if (midToRightProgress > 0) {
        _drawCurvedFlow(
          canvas, 
          midX + nodeWidth, currentMidExitY, 
          rightX, currentRightY, 
          savingsHeight, 
          const Color(0xFF10B981).withOpacity(0.3), 
          midToRightProgress
        );
      }

      if (rightBarsProgress > 0) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(rightX, currentRightY, nodeWidth, savingsHeight * rightBarsProgress), const Radius.circular(4)),
          Paint()..color = const Color(0xFF10B981).withOpacity(rightBarsProgress)
        );
        _drawLabel(canvas, "Artan Gelir", currencyFormat.format(savings), Offset(rightX - 10, currentRightY + savingsHeight / 2), alignRight: true, opacity: rightBarsProgress);
      }
    }
  }

  void _drawCurvedFlow(Canvas canvas, double sx, double sy, double tx, double ty, double height, Color color, double flowProgress) {
    if (flowProgress <= 0) return;

    final Path path = Path();
    final double controlPointDistance = (tx - sx) * 0.5;

    // Top curve
    path.moveTo(sx, sy);
    path.cubicTo(
      sx + controlPointDistance, sy,
      tx - controlPointDistance, ty,
      tx, ty
    );

    // Right edge
    path.lineTo(tx, ty + height);

    // Bottom curve
    path.cubicTo(
      tx - controlPointDistance, ty + height,
      sx + controlPointDistance, sy + height,
      sx, sy + height
    );
    path.close();

    // Use a clipping rect or PathMeasure to animate the flow from left to right
    canvas.save();
    final double clipWidth = (tx - sx) * flowProgress;
    canvas.clipRect(Rect.fromLTWH(sx, 0, clipWidth, 1000));
    canvas.drawPath(path, Paint()..color = color);
    canvas.restore();
  }

  void _drawLabel(Canvas canvas, String label, String value, Offset offset, {bool alignRight = false, double opacity = 1.0}) {
    if (opacity <= 0) return;

    final span = TextSpan(
      children: [
        TextSpan(text: '$label\n', style: TextStyle(color: Colors.white.withOpacity(0.6 * opacity), fontSize: 10)),
        TextSpan(text: value, style: TextStyle(color: Colors.white.withOpacity(opacity), fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
    final tp = TextPainter(
      text: span,
      textAlign: alignRight ? TextAlign.right : TextAlign.left,
      textDirection: ui.TextDirection.ltr,
    );
    tp.layout();
    
    final double rectWidth = tp.width + 16;
    final double rectHeight = tp.height + 8;
    
    final double rx = alignRight ? offset.dx - rectWidth : offset.dx;
    final double ry = offset.dy - rectHeight / 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(rx, ry, rectWidth, rectHeight), const Radius.circular(8)),
      Paint()..color = Colors.black.withOpacity(0.4 * opacity)
    );

    tp.paint(canvas, Offset(rx + 8, ry + 4));
  }

  @override
  bool shouldRepaint(FlowPainter oldDelegate) => oldDelegate.progress != progress;
}
