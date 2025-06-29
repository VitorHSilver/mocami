import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Footer extends StatelessWidget {
  const Footer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(fontSize: 12, color: Colors.white70),
            children: [
              const TextSpan(text: 'created by '),
              WidgetSpan(
                child: GestureDetector(
                  onTap: () async {
                    try {
                      final Uri url = Uri.parse(
                        'https://github.com/VitorHSilver',
                      );

                      // Try to launch the URL
                      if (await canLaunchUrl(url)) {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        // Fallback: show a message
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Não foi possível abrir o link. Visite: https://github.com/VitorHSilver',
                              ),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      // Error handling
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Erro ao abrir link. Tente novamente.',
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text(
                    '@VitorHSilver',
                    style: TextStyle(
                      color: Colors.lightBlue,
                      fontSize: 12,
                    ),
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
