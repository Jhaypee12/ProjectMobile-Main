import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme.dart';
import 'common.dart';

// ---------------------------------------------------------------------------
// Layout helpers
// ---------------------------------------------------------------------------

class PageList extends StatelessWidget {
  const PageList({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: children,
      );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.actionLabel, this.onAction});
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 22, bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(title,
                style: GoogleFonts.bricolageGrotesque(
                    fontSize: 19, fontWeight: FontWeight.w700)),
          ),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

/// Plain white card: information only, not tappable.
class AppCard extends StatelessWidget {
  const AppCard(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(16)});
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.line),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

/// Tinted card with a chevron: tappable.
class NavTile extends StatelessWidget {
  const NavTile({
    super.key,
    this.icon,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.accent = AppColors.purple,
  });

  final IconData? icon;
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.iceSoft,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.ice),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                leading ??
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon ?? Icons.circle_outlined,
                          color: accent, size: 22),
                    ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              height: 1.25)),
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(subtitle!,
                              style: const TextStyle(
                                  color: AppColors.muted, fontSize: 13)),
                        ),
                    ],
                  ),
                ),
                if (trailing != null)
                  Padding(
                      padding: const EdgeInsets.only(left: 8), child: trailing),
                const SizedBox(width: 2),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.purple),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum PillTone { soft, solid, done, alert }

class Pill extends StatelessWidget {
  const Pill(this.text, {super.key, this.tone = PillTone.soft});
  final String text;
  final PillTone tone;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      PillTone.soft => (AppColors.ice, AppColors.purple),
      PillTone.solid => (AppColors.blue, Colors.white),
      PillTone.done => (AppColors.purpleTint, AppColors.purple),
      PillTone.alert => (AppColors.alertTint, AppColors.alert),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(text,
          style:
              TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}

class AppProgress extends StatelessWidget {
  const AppProgress({super.key, required this.value, this.color});
  final double value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 8,
        color: color ?? AppColors.purple,
        backgroundColor: AppColors.ice,
      ),
    );
  }
}

class AppAvatar extends StatelessWidget {
  const AppAvatar(this.initials,
      {super.key, this.size = 44, this.color = AppColors.purple});
  final String initials;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: color,
      child: Text(initials,
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: size * 0.34)),
    );
  }
}

/// Big purple card at the top of a dashboard.
class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.caption,
    this.progress,
  });

  final String title, value, caption;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        color: AppColors.purple,
        child: Stack(
          children: [
            Positioned(
              right: -40,
              top: -50,
              child: Container(
                width: 140,
                height: 140,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: AppColors.blue),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: AppColors.iceDeep, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(value,
                      style: GoogleFonts.bricolageGrotesque(
                          fontSize: 46,
                          height: 1.1,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(caption,
                      style:
                          const TextStyle(color: AppColors.ice, fontSize: 14)),
                  if (progress != null) ...[
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        color: Colors.white,
                        backgroundColor: const Color(0x33FFFFFF),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatTile extends StatelessWidget {
  const StatTile(
      {super.key, required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value, label;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
                color: AppColors.ice, borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, size: 19, color: AppColors.purple),
          ),
          const SizedBox(height: 10),
          Text(value,
              style: GoogleFonts.bricolageGrotesque(
                  fontSize: 22, fontWeight: FontWeight.w800)),
          Text(label,
              style: const TextStyle(color: AppColors.muted, fontSize: 12.5)),
        ],
      ),
    );
  }
}

class FilterChips extends StatelessWidget {
  const FilterChips(
      {super.key,
      required this.labels,
      required this.selected,
      required this.onSelected});
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 14),
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: labels.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final on = i == selected;
            return ChoiceChip(
              label: Text(labels[i]),
              selected: on,
              showCheckmark: false,
              selectedColor: AppColors.purple,
              backgroundColor: AppColors.ice,
              side: BorderSide.none,
              shape: const StadiumBorder(),
              labelStyle: TextStyle(
                fontWeight: FontWeight.w700,
                color: on ? Colors.white : AppColors.purple,
              ),
              onSelected: (_) => onSelected(i),
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Modal building blocks
// ---------------------------------------------------------------------------

class ModalHeader extends StatelessWidget {
  const ModalHeader(
      {super.key, required this.icon, required this.title, this.subtitle});
  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
              color: AppColors.ice, borderRadius: BorderRadius.circular(16)),
          child: Icon(icon, color: AppColors.purple, size: 26),
        ),
        const SizedBox(height: 14),
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!,
              style: const TextStyle(color: AppColors.muted, height: 1.4)),
        ],
      ],
    );
  }
}

class KeyValueList extends StatelessWidget {
  const KeyValueList(this.rows, {super.key});
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
          color: AppColors.iceSoft, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.ice),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 13),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(rows[i].$1,
                      style: const TextStyle(
                          color: AppColors.muted, fontSize: 14)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(rows[i].$2,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class UploadBox extends StatelessWidget {
  const UploadBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.iceSoft,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.iceDeep, width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => showToast(context, 'File picker comes later'),
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(Icons.upload_file_rounded, color: AppColors.purple, size: 30),
              SizedBox(height: 8),
              Text('Tap to attach a file',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              SizedBox(height: 2),
              Text('PDF, DOCX or ZIP, up to 20 MB',
                  style: TextStyle(color: AppColors.muted, fontSize: 12.5)),
            ],
          ),
        ),
      ),
    );
  }
}

class PreviewBox extends StatelessWidget {
  const PreviewBox(this.icon, {super.key});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
          color: AppColors.ice, borderRadius: BorderRadius.circular(16)),
      child: Icon(icon, size: 56, color: AppColors.purple),
    );
  }
}

class FieldSpec {
  const FieldSpec(this.label, this.icon,
      {this.hint, this.password = false, this.lines = 1});
  final String label;
  final IconData icon;
  final String? hint;
  final bool password;
  final int lines;
}

/// Read-only detail sheet. Optional primary action closes the sheet first.
Future<void> showDetails(
  BuildContext context, {
  required IconData icon,
  required String title,
  String? subtitle,
  String? body,
  List<(String, String)> rows = const [],
  Widget? extra,
  String? primaryLabel,
  VoidCallback? onPrimary,
  String closeLabel = 'Close',
}) {
  return showAppModal(
    context,
    (ctx) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ModalHeader(icon: icon, title: title, subtitle: subtitle),
        if (body != null) ...[
          const SizedBox(height: 14),
          Text(body, style: const TextStyle(height: 1.5)),
        ],
        if (extra != null) ...[const SizedBox(height: 18), extra],
        if (rows.isNotEmpty) ...[
          const SizedBox(height: 18),
          KeyValueList(rows),
        ],
        const SizedBox(height: 24),
        if (primaryLabel != null) ...[
          PrimaryButton(
            label: primaryLabel,
            onPressed: () {
              Navigator.of(ctx).pop();
              onPrimary?.call();
            },
          ),
          const SizedBox(height: 10),
        ],
        GhostButton(label: closeLabel, onPressed: () => Navigator.of(ctx).pop()),
      ],
    ),
  );
}

/// Sheet with text fields and a submit button.
Future<void> showFormModal(
  BuildContext context, {
  required IconData icon,
  required String title,
  String? subtitle,
  required List<FieldSpec> fields,
  Widget? extra,
  required String submitLabel,
  String? toast,
  VoidCallback? onDone,
}) {
  return showAppModal(
    context,
    (ctx) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ModalHeader(icon: icon, title: title, subtitle: subtitle),
        const SizedBox(height: 20),
        if (extra != null) ...[extra, const SizedBox(height: 14)],
        for (final f in fields) ...[
          AppTextField(
            label: f.label,
            hint: f.hint,
            icon: f.icon,
            isPassword: f.password,
            maxLines: f.lines,
          ),
          const SizedBox(height: 14),
        ],
        const SizedBox(height: 10),
        PrimaryButton(
          label: submitLabel,
          onPressed: () {
            Navigator.of(ctx).pop();
            if (onDone != null) {
              onDone();
            } else if (toast != null) {
              showToast(context, toast);
            }
          },
        ),
        const SizedBox(height: 10),
        GhostButton(label: 'Cancel', onPressed: () => Navigator.of(ctx).pop()),
      ],
    ),
  );
}

/// Yes/no sheet, or a single "Done" button when [single] is true.
Future<void> showConfirmModal(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String? toast,
  bool single = false,
  VoidCallback? onConfirm,
}) {
  return showAppModal(
    context,
    (ctx) {
      void confirm() {
        Navigator.of(ctx).pop();
        onConfirm?.call();
        if (toast != null) showToast(context, toast);
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ModalHeader(icon: icon, title: title, subtitle: message),
          const SizedBox(height: 24),
          if (single)
            PrimaryButton(label: confirmLabel, onPressed: confirm)
          else
            Row(
              children: [
                Expanded(
                  child: GhostButton(
                      label: 'Cancel', onPressed: () => Navigator.of(ctx).pop()),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: PrimaryButton(label: confirmLabel, onPressed: confirm)),
              ],
            ),
        ],
      );
    },
  );
}