import 'dart:async';
import 'package:flutter/material.dart';
import '../models/fuel_entry.dart';

class SimpleSwipeCard extends StatefulWidget {
  const SimpleSwipeCard({
    super.key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
  });

  final FuelEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<SimpleSwipeCard> createState() => _SimpleSwipeCardState();
}

class _SimpleSwipeCardState extends State<SimpleSwipeCard> 
    with SingleTickerProviderStateMixin {
  bool _showButtons = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  Timer? _autoHideTimer;
  double _dragDistance = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _autoHideTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _showButtonsWithAnimation() {
    if (!_showButtons) {
      setState(() {
        _showButtons = true;
      });
      _animationController.forward();
      
      // Auto-hide after 3 seconds
      _autoHideTimer?.cancel();
      _autoHideTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          _hideButtonsWithAnimation();
        }
      });
    }
  }

  void _hideButtonsWithAnimation() {
    _autoHideTimer?.cancel();
    if (_showButtons) {
      _animationController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _showButtons = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: GestureDetector(
        onPanStart: (details) {
          _autoHideTimer?.cancel();
        },
        onPanUpdate: (details) {
          setState(() {
            _dragDistance += details.delta.dx;
            _dragDistance = _dragDistance.clamp(-120.0, 0.0);
          });
          
          // Trigger button reveal when dragged left enough
          if (_dragDistance <= -40 && !_showButtons) {
            _showButtonsWithAnimation();
          }
        },
        onPanEnd: (details) {
          final velocity = details.velocity.pixelsPerSecond.dx;
          
          // Apple-like gesture logic
          if (velocity > 500 || _dragDistance > -40) {
            // Swipe right or not far enough - hide buttons
            _hideButtonsWithAnimation();
          } else if (velocity < -500 || _dragDistance <= -80) {
            // Fast swipe left or dragged far - keep buttons
            _showButtonsWithAnimation();
          } else {
            // Moderate drag - show buttons briefly
            _showButtonsWithAnimation();
          }
          
          // Reset drag distance with animation
          setState(() {
            _dragDistance = 0;
          });
        },
        onTap: () {
          if (_showButtons) {
            _hideButtonsWithAnimation();
          }
        },
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.translate(
                offset: Offset(_dragDistance * 0.1, 0),
                child: _showButtons ? _buildCardWithButtons() : _buildNormalCard(),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNormalCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.08),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            spreadRadius: 0,
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_gas_station_outlined,
                    size: 18,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.entry.date.day}/${widget.entry.date.month}/${widget.entry.date.year}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 5.0,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      Theme.of(context).primaryColor.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  '${widget.entry.kilometerReading} km',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: Theme.of(context).primaryColor,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoColumn([
                  _InfoItem(Icons.payments_outlined, '${widget.entry.priceEGP.toStringAsFixed(0)} EGP', Colors.green),
                  _InfoItem(Icons.local_gas_station_outlined, '${widget.entry.liters.toStringAsFixed(1)} L', Colors.blue),
                  if (widget.entry.kilometersDriven > 0)
                    _InfoItem(Icons.speed_outlined, '${widget.entry.kilometersDriven} km', Colors.orange),
                ]),
              ),
              Expanded(
                child: _buildInfoColumn([
                  _InfoItem(Icons.attach_money_outlined, '${widget.entry.literPriceEGP.toStringAsFixed(1)} EGP/L', Colors.purple),
                  if (widget.entry.fuelConsumptionKmPerL > 0)
                    _InfoItem(Icons.eco_outlined, '${widget.entry.fuelConsumptionKmPerL.toStringAsFixed(1)} km/L', Colors.teal),
                  if (widget.entry.litersPer100Km > 0)
                    _InfoItem(Icons.analytics_outlined, '${widget.entry.litersPer100Km.toStringAsFixed(1)} L/100km', 
                      widget.entry.litersPer100Km > 8 ? Colors.red : Colors.green),
                ]),
              ),
            ],
          ),
          if (widget.entry.daysSinceLastRefill > 0)
            const SizedBox(height: 12),
          if (widget.entry.daysSinceLastRefill > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.schedule_outlined,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.entry.daysSinceLastRefill} days ago',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.swipe_left_outlined,
                size: 14,
                color: Colors.grey[400],
              ),
              const SizedBox(width: 4),
              Text(
                'Swipe left for options',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoColumn(List<_InfoItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Icon(
              item.icon,
              size: 16,
              color: item.color.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                item.text,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                  letterSpacing: -0.1,
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildCardWithButtons() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              border: Border.all(
                color: Colors.grey.withValues(alpha: 0.08),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  spreadRadius: 0,
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_gas_station_outlined,
                            size: 16,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '${widget.entry.date.day}/${widget.entry.date.month}/${widget.entry.date.year}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.entry.priceEGP.toStringAsFixed(0)} EGP • ${widget.entry.liters.toStringAsFixed(1)}L',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                if (widget.entry.litersPer100Km > 0)
                  Text(
                    '${widget.entry.litersPer100Km.toStringAsFixed(1)} L/100km',
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.entry.litersPer100Km > 8 ? Colors.red[600] : Colors.green[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ),
        // Apple-style action buttons
        Container(
          width: 70,
          height: 120,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF007AFF),
                Color(0xFF0056CC),
              ],
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              bottomLeft: Radius.circular(8),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onEdit,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.edit_outlined, color: Colors.white, size: 22),
                  SizedBox(height: 4),
                  Text(
                    'Edit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Container(
          width: 70,
          height: 120,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFF3B30),
                Color(0xFFD70015),
              ],
            ),
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onDelete,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_outline, color: Colors.white, size: 22),
                  SizedBox(height: 4),
                  Text(
                    'Delete',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String text;
  final Color color;
  
  _InfoItem(this.icon, this.text, this.color);
}