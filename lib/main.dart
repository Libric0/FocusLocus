// Copyright (C) 2022 Fredrik Konrad <fredrik.konrad@posteo.net>
//
// This file is part of FocusLocus.
//
// FocusLocus is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
//
// FocusLocus is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with FocusLocus. If not, see <https://www.gnu.org/licenses/>.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:focuslocus/knowledge/statement.dart';

import 'package:focuslocus/test_utility.dart';
import 'package:focuslocus/widgets/screens/lrs_responses_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:focuslocus/local_storage/user_storage.dart';
import 'package:focuslocus/local_storage/adhd_type.dart';

import 'package:focuslocus/local_storage/course_metadata_storage.dart';
import 'package:focuslocus/local_storage/course_metadata_storage_model.dart';
import 'package:focuslocus/local_storage/deck_metadata_storage.dart';
import 'package:focuslocus/local_storage/deck_metadata_storage_model.dart';
import 'package:focuslocus/local_storage/knowledge_metadata_storage.dart';
import 'package:focuslocus/local_storage/knowledge_metadata_storage_model.dart';
import 'package:focuslocus/local_storage/learning_metadata_storage.dart';
import 'package:focuslocus/web_communication/lrs_sync.dart';
import 'package:focuslocus/local_storage/quiz_card_metadata_storage_model.dart';
import 'package:focuslocus/widgets/screens/help_screen.dart';
import 'package:focuslocus/widgets/main_app.dart';
import 'package:focuslocus/widgets/screens/stats_screen.dart';
import 'package:focuslocus/widgets/screens/user_screen.dart';

/// The file that initializes the local and remote storage and starts the application
void main() async {
  await initHive();
  await initLrs();
  await addLicenses();
  runApp(MaterialApp(
      title: 'FocusLocus',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
            color: Colors.white,
            foregroundColor: Colors.blue,
            shadowColor: Colors.blue),
        fontFamily: 'Sans Serif',
        textTheme: const TextTheme(
          bodyText1: TextStyle(fontSize: 18),
          button: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          headline6: TextStyle(
            //fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const MyApp()));
}

Future<void> addLicenses() async {
  LicenseRegistry.addLicense(() async* {
    yield const LicenseEntryWithLineBreaks([
      "OpenDyslexic"
    ], '''Copyright (c) 2019-07-29, Abbie Gonzalez (https://abbiecod.es|support@abbiecod.es),
with Reserved Font Name OpenDyslexic.
Copyright (c) 12/2012 - 2019
This Font Software is licensed under the SIL Open Font License, Version 1.1.
This license is copied below, and is also available with a FAQ at:
http://scripts.sil.org/OFL


-----------------------------------------------------------
SIL OPEN FONT LICENSE Version 1.1 - 26 February 2007
-----------------------------------------------------------

PREAMBLE
The goals of the Open Font License (OFL) are to stimulate worldwide
development of collaborative font projects, to support the font creation
efforts of academic and linguistic communities, and to provide a free and
open framework in which fonts may be shared and improved in partnership
with others.

The OFL allows the licensed fonts to be used, studied, modified and
redistributed freely as long as they are not sold by themselves. The
fonts, including any derivative works, can be bundled, embedded, 
redistributed and/or sold with any software provided that any reserved
names are not used by derivative works. The fonts and derivatives,
however, cannot be released under any other type of license. The
requirement for fonts to remain under this license does not apply
to any document created using the fonts or their derivatives.

DEFINITIONS
"Font Software" refers to the set of files released by the Copyright
Holder(s) under this license and clearly marked as such. This may
include source files, build scripts and documentation.

"Reserved Font Name" refers to any names specified as such after the
copyright statement(s).

"Original Version" refers to the collection of Font Software components as
distributed by the Copyright Holder(s).

"Modified Version" refers to any derivative made by adding to, deleting,
or substituting -- in part or in whole -- any of the components of the
Original Version, by changing formats or by porting the Font Software to a
new environment.

"Author" refers to any designer, engineer, programmer, technical
writer or other person who contributed to the Font Software.

PERMISSION & CONDITIONS
Permission is hereby granted, free of charge, to any person obtaining
a copy of the Font Software, to use, study, copy, merge, embed, modify,
redistribute, and sell modified and unmodified copies of the Font
Software, subject to the following conditions:

1) Neither the Font Software nor any of its individual components,
in Original or Modified Versions, may be sold by itself.

2) Original or Modified Versions of the Font Software may be bundled,
redistributed and/or sold with any software, provided that each copy
contains the above copyright notice and this license. These can be
included either as stand-alone text files, human-readable headers or
in the appropriate machine-readable metadata fields within text or
binary files as long as those fields can be easily viewed by the user.

3) No Modified Version of the Font Software may use the Reserved Font
Name(s) unless explicit written permission is granted by the corresponding
Copyright Holder. This restriction only applies to the primary font name as
presented to the users.

4) The name(s) of the Copyright Holder(s) or the Author(s) of the Font
Software shall not be used to promote, endorse or advertise any
Modified Version, except to acknowledge the contribution(s) of the
Copyright Holder(s) and the Author(s) or with their explicit written
permission.

5) The Font Software, modified or unmodified, in part or in whole,
must be distributed entirely under this license, and must not be
distributed under any other license. The requirement for fonts to
remain under this license does not apply to any document created
using the Font Software.

TERMINATION
This license becomes null and void if any of the above conditions are
not met.

DISCLAIMER
THE FONT SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT
OF COPYRIGHT, PATENT, TRADEMARK, OR OTHER RIGHT. IN NO EVENT SHALL THE
COPYRIGHT HOLDER BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
INCLUDING ANY GENERAL, SPECIAL, INDIRECT, INCIDENTAL, OR CONSEQUENTIAL
DAMAGES, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF THE USE OR INABILITY TO USE THE FONT SOFTWARE OR FROM
OTHER DEALINGS IN THE FONT SOFTWARE.''');
  });
}

Future<void> initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(QuizCardMetadataStorageModelAdapter());
  Hive.registerAdapter(CourseMetadataStorageModelAdapter());
  Hive.registerAdapter(DeckMetadataStorageModelAdapter());
  Hive.registerAdapter(KnowledgeMetadataStorageModelAdapter());
  Hive.registerAdapter(ADHDTypeAdapter());

  await LearningMetadataStorage.init();
  await DeckMetadataStorage.init();
  await CourseMetadataStorage.init();
  await KnowledgeMetadataStorage.init();
  await UserStorage.init();
}

Future<void> initLrs() async {
  await LrsSync.init();
}

class MyApp extends StatefulWidget {
  static MaterialColor themeColor = Colors.blue;
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool showAbout = false;
  // This widget is the root of your application.
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        drawer: Drawer(
          child: ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(AppLocalizations.of(context)!.user),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                  leading: const Icon(Icons.show_chart_rounded),
                  title: Text(AppLocalizations.of(context)!.stats),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StatsScreen(),
                        ));
                  }),
              ListTile(
                leading: const Icon(Icons.help),
                title: Text(AppLocalizations.of(context)!.help),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HelpScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: Text(AppLocalizations.of(context)!.about),
                onTap: () {
                  showAboutDialog(
                      context: context,
                      applicationIcon: SizedBox(
                        child: Image.asset("assets/icon/icon2.png",
                            isAntiAlias: true),
                        width: 100,
                        height: 100,
                      ));
                },
              ),
              if (TestConstants.testLRSSync)
                ListTile(
                  leading: const Icon(Icons.storage),
                  title: Text(AppLocalizations.of(context)!.lrsResponses),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LrsResponsesScreen()));
                  },
                )
            ],
          ),
        ),
        body: const MainApp(),
      ),
    );
  }
}
