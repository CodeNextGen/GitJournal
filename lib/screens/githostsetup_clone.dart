import 'package:flutter/material.dart';

import 'githostsetup_loading.dart';

class GitHostSetupGitClone extends StatelessWidget {
  final String errorMessage;

  GitHostSetupGitClone({
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (this.errorMessage == null || this.errorMessage.isEmpty) {
      return GitHostSetupLoadingPage("Cloning ...");
    }

    var children = <Widget>[
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          'Failed',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.display1,
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          this.errorMessage,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.display1,
        ),
      ),
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
}