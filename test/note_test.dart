import 'dart:io';

import 'package:gitjournal/core/note.dart';
import 'package:gitjournal/core/notes_folder_fs.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('Note', () {
    Directory tempDir;

    setUpAll(() async {
      tempDir = await Directory.systemTemp.createTemp('__notes_test__');
    });

    tearDownAll(() async {
      tempDir.deleteSync(recursive: true);
    });

    test('Should respect modified key as modified', () async {
      var content = """---
title: Foo
modified: 2017-02-15T22:41:19+01:00
---

Hello""";

      var notePath = p.join(tempDir.path, "note.md");
      await File(notePath).writeAsString(content);

      var parentFolder = NotesFolderFS(null, tempDir.path);
      var note = Note(parentFolder, notePath);
      await note.load();

      note.modified = DateTime.utc(2019, 12, 02, 4, 0, 0);

      await note.save();

      var expectedContent = """---
title: Foo
modified: 2019-12-02T04:00:00+00:00
---

Hello""";

      var actualContent = File(notePath).readAsStringSync();
      expect(actualContent, equals(expectedContent));
    });

    test('Should respect modified key as mod', () async {
      var content = """---
title: Foo
mod: 2017-02-15T22:41:19+01:00
---

Hello""";

      var notePath = p.join(tempDir.path, "note.md");
      await File(notePath).writeAsString(content);

      var parentFolder = NotesFolderFS(null, tempDir.path);
      var note = Note(parentFolder, notePath);
      await note.load();

      note.modified = DateTime.utc(2019, 12, 02, 4, 0, 0);

      await note.save();

      var expectedContent = """---
title: Foo
mod: 2019-12-02T04:00:00+00:00
---

Hello""";

      var actualContent = File(notePath).readAsStringSync();
      expect(actualContent, equals(expectedContent));
    });

    test('Should read and write tags', () async {
      var content = """---
title: Foo
tags: [A, B]
---

Hello""";

      var notePath = p.join(tempDir.path, "note5.md");
      await File(notePath).writeAsString(content);

      var parentFolder = NotesFolderFS(null, tempDir.path);
      var note = Note(parentFolder, notePath);
      await note.load();

      expect(note.tags.contains('A'), true);
      expect(note.tags.contains('B'), true);
      expect(note.tags.length, 2);

      note.tags = {...note.tags}..add('C');
      note.tags.add('D');
      note.tags.remove('B');

      await note.save();

      var expectedContent = """---
title: Foo
tags: [A, C, D]
---

Hello""";

      var actualContent = File(notePath).readAsStringSync();
      expect(actualContent, equals(expectedContent));
    });

    test('Should parse links', () async {
      var content = """---
title: Foo
---

[Hi](./foo.md)
[Hi2](./po/../food.md)
[Web](http://example.com)
""";

      var notePath = p.join(tempDir.path, "note6.md");
      await File(notePath).writeAsString(content);

      var parentFolder = NotesFolderFS(null, tempDir.path);
      var note = Note(parentFolder, notePath);
      await note.load();

      var links = await note.fetchLinks();
      expect(links[0].filePath, p.join(tempDir.path, "foo.md"));
      expect(links[0].term, "Hi");

      expect(links[1].filePath, p.join(tempDir.path, "food.md"));
      expect(links[1].term, "Hi2");

      expect(links.length, 2);
    });

    test('Should parse wiki style links', () async {
      var content = "[[GitJournal]] needs some [[Wild Fire]]";

      var notePath = p.join(tempDir.path, "note63.md");
      await File(notePath).writeAsString(content);

      var parentFolder = NotesFolderFS(null, tempDir.path);
      var note = Note(parentFolder, notePath);
      await note.load();

      var links = await note.fetchLinks();
      expect(links[0].filePath, null);
      expect(links[0].term, "GitJournal");

      expect(links[1].filePath, null);
      expect(links[1].term, "Wild Fire");

      expect(links.length, 2);
    });

    test('Should detect file format', () async {
      var content = """---
title: Foo
---

Gee
""";

      var notePath = p.join(tempDir.path, "note16.md");
      await File(notePath).writeAsString(content);

      var parentFolder = NotesFolderFS(null, tempDir.path);
      var note = Note(parentFolder, notePath);
      await note.load();

      expect(note.fileFormat, NoteFileFormat.Markdown);

      //
      // Txt files
      //
      var txtNotePath = p.join(tempDir.path, "note16.txt");
      await File(txtNotePath).writeAsString(content);

      var txtNote = Note(parentFolder, txtNotePath);
      await txtNote.load();

      expect(txtNote.fileFormat, NoteFileFormat.Txt);
      expect(txtNote.canHaveMetadata, false);
      expect(txtNote.title.isEmpty, true);
    });

    test('New Notes have a file extension', () async {
      var parentFolder = NotesFolderFS(null, tempDir.path);
      var note = Note.newNote(parentFolder);
      var path = note.filePath;
      expect(path.endsWith('.md'), true);
    });
  });
}
