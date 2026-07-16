import 'package:flutter/material.dart';
import '../models/module.dart';

class ModuleCard extends StatelessWidget {
  final CityModule module;
  final VoidCallback onTap;

  const ModuleCard({super.key, required this.module, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isMaintenance = module.key == 'solar' || module.key == 'garbage';

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Opacity(
        opacity: isMaintenance ? 0.6 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(module.icon, color: isMaintenance ? Colors.grey : module.accentColor, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      module.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                module.subtitle,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              if (isMaintenance)
                const Text(
                  '🛠️ Under Maintenance',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.orange),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              else
                Text(
                  module.stat,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: module.accentColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              const Spacer(),
              Container(
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: isMaintenance
                        ? [Colors.grey.shade100, Colors.grey.shade300]
                        : [module.bgColorStart, module.bgColorEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(
                    module.icon,
                    color: isMaintenance ? Colors.grey : module.accentColor.withOpacity(0.5),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
