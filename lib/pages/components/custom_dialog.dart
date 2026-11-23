import 'package:material_ui/material_ui.dart';
import 'package:my_personal_lib_app/pages/helpers/sizes.dart';

class CustomDialog extends StatelessWidget {
  final String title;
  final String bodyMessage;
  final String textCancel;
  final String textConfirm;
  final bool? informativeDialog;
  const CustomDialog({
    super.key,
    required this.title,
    required this.bodyMessage,
    required this.textCancel,
    required this.textConfirm,
    this.informativeDialog = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(PaddingSizes.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: TextSizes.md, color: Theme.of(context).colorScheme.inverseSurface),
              ),
              SizedBox(height: PaddingSizes.md),
              Text(
                bodyMessage,
                style: TextStyle(fontSize: TextSizes.sm, color: Theme.of(context).colorScheme.inverseSurface),
              ),
              SizedBox(height: PaddingSizes.md),
              informativeDialog == false
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              textCancel,
                              style: TextStyle(fontSize: TextSizes.sm, color: Theme.of(context).colorScheme.inverseSurface),
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(
                              textConfirm,
                              style: TextStyle(fontSize: TextSizes.sm, color: Theme.of(context).colorScheme.inverseSurface.withValues(alpha: 0.7)),
                            ),
                          ),
                        ),
                      ],
                    )
                  : ElevatedButton(
                      onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
                      child: Text(
                        "Fazer login",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Theme.of(context).colorScheme.inverseSurface),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
