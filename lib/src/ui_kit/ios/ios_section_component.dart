import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:work_timer/src/ui_kit/shared/context.dart';

class IOSSectionItem<T extends GetListenable> extends Equatable {
  const IOSSectionItem._internal(this.label, this.tooltip, this.icon, this.isActive, this.onPressed,
      this.additionalInformationObserver, this.additionalInformationCallback);

  factory IOSSectionItem.withSwitch(
      {required String label, required RxBool isActive, required ContextCallback onTap, String? tooltip}) {
    return IOSSectionItem._internal(label, tooltip ?? label, null, isActive, onTap, null, null);
  }

  factory IOSSectionItem.withIcon(
      {required String label, required IconData iconData, required ContextCallback onTap, String? tooltip}) {
    return IOSSectionItem._internal(label, tooltip ?? label, iconData, null, onTap, null, null);
  }

  factory IOSSectionItem.popUp(
          {required String label,
          String? tooltip,
          required ContextCallback onTap,
          IconData? iconData,
          required T informationObserver,
          required String Function(dynamic observer) informationParser}) =>
      IOSSectionItem<T>._internal(label, tooltip ?? label, null, null, onTap, informationObserver, informationParser);

  final String label;
  final String tooltip;
  final IconData? icon;
  final RxBool? isActive;
  final ContextCallback onPressed;
  final T? additionalInformationObserver;
  final String Function(dynamic observer)? additionalInformationCallback;

  @override
  List<Object?> get props => [
        label,
        tooltip,
        icon,
        isActive,
        onPressed,
        additionalInformationObserver,
        additionalInformationCallback,
      ];
}

class IOSSectionComponent extends StatelessWidget {
  const IOSSectionComponent({this.sectionTitle, required this.items, this.footnote, this.padding, super.key});

  final String? sectionTitle;
  final List<IOSSectionItem> items;
  final String? footnote;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(4),
      child: CupertinoListSection(
        backgroundColor: Colors.transparent,
        header: sectionTitle == null ? null : Text(sectionTitle!),
        footer: footnote == null ? null : Text(footnote!),
        margin: const EdgeInsets.all(8),
        children: items
            .map(
              (e) => Tooltip(
                message: e.tooltip,
                child: CupertinoListTile(
                  title: Text(e.label),
                  onTap: () => e.onPressed(context),
                  additionalInfo: e.additionalInformationObserver != null
                      ? Obx(() {
                          final additionalInformation =
                              e.additionalInformationCallback!.call(e.additionalInformationObserver!);
                          return Text(additionalInformation);
                        })
                      : null,
                  trailing: e.additionalInformationObserver != null
                      ? null
                      : e.isActive != null
                          ? Obx(() {
                              final isActive = e.isActive!.value;
                              return CupertinoSwitch(
                                value: isActive,
                                onChanged: (_) => e.onPressed(context),
                              );
                            })
                          : IconButton(
                              icon: Icon(e.icon),
                              tooltip: e.tooltip,
                              onPressed: () => e.onPressed(context),
                            ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
