import 'package:auto_novel_reader_flutter/ui/components/settings/contributor.dart';
import 'package:auto_novel_reader_flutter/ui/components/universal/icon_option.dart';
import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';
import 'package:url_launcher/url_launcher.dart';

const myGithubUrl = 'https://github.com/Prixii';
const myAvatarUrl = 'https://avatars.githubusercontent.com/u/87805157?s=96&v=4';
const appRepo = 'https://github.com/Prixii/auto_novel_reader_flutter';
const autoNovelRepo = 'https://github.com/FishHawk/auto-novel';
const thanks = '''
感谢 Notsfsssf 的项目 Pixez-flutter 为我提供的帮助
感谢站长 Fishhawk 的开源项目 auto_novel''';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
        appBar: AppBar(
          shadowColor: theme.colorScheme.shadow,
          backgroundColor: theme.colorScheme.secondaryContainer,
          title: const Text('下载管理'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 8.0, bottom: 38),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Contributor(
                    name: 'Prixii',
                    contribution: '开发',
                    homePageUrl: myGithubUrl,
                    avatarUrl: myAvatarUrl),
              ),
              Divider(indent: 16, endIndent: 16, color: theme.dividerColor),
              IconOption(
                  icon: UniconsLine.github,
                  text: '本项目 GitHub 仓库',
                  onTap: () => launchUrl(Uri.parse(appRepo))),
              IconOption(
                  prefix: ClipRRect(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(12.0)),
                      child: Image.asset(
                        'assets/img/character.webp',
                        height: 24,
                        width: 24,
                      )),
                  text: '轻小说机翻机器人 GitHub 仓库',
                  onTap: () => launchUrl(Uri.parse(autoNovelRepo))),
              const IconOption(
                icon: UniconsLine.heart,
                text: '感谢',
                tip: thanks,
              ),
            ],
          ),
        ));
  }
}
