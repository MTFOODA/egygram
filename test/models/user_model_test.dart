import 'package:flutter_application_3/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UsersModel.fromMap (Supabase row)', () {
    test('maps snake_case columns', () {
      final model = UsersModel.fromMap({
        'id': 'uuid-1',
        'user_name': 'amr',
        'user_token': 'tok',
        'bio': 'hi',
        'webpage': 'https://x.dev',
        'profile_image': 'media/avatars/a.jpg',
        'email': 'a@b.c',
        'phone': '010',
        'gender': 'male',
        'number_of_posts': 3,
        'number_of_followers': 10,
        'number_of_following': 7,
        'list_of_posts': ['p1', 'p2'],
        'list_of_reels': ['r1'],
        'list_of_tagged_for_me': [],
        'list_of_videos': ['v1'],
        'created_at': '2026-01-02T03:04:05.000Z',
      });

      expect(model.id, 'uuid-1');
      expect(model.userName, 'amr');
      expect(model.numberOfPosts, 3);
      expect(model.numberOfFollowers, 10);
      expect(model.numberOfFollowing, 7);
      expect(model.listOfPosts, ['p1', 'p2']);
      expect(model.listOfReels, ['r1']);
      expect(model.createdAt, isNotNull);
    });

    test('tolerates missing optional columns', () {
      final model = UsersModel.fromMap({'user_name': 'nour'});
      expect(model.userName, 'nour');
      expect(model.numberOfPosts, 0);
      expect(model.listOfPosts, isEmpty);
      expect(model.id, isNull);
      expect(model.createdAt, isNull);
    });

    test('round-trips through toMap', () {
      final original = UsersModel.fromMap({
        'id': 'uuid-2',
        'user_name': 'sara',
        'number_of_followers': 5,
        'list_of_reels': ['r9'],
      });
      final again = UsersModel.fromMap(original.toMap());

      expect(again.id, original.id);
      expect(again.userName, original.userName);
      expect(again.numberOfFollowers, original.numberOfFollowers);
      expect(again.listOfReels, original.listOfReels);
    });

    test('toMap omits id when null (insert path)', () {
      final map = UsersModel(userName: 'new').toMap();
      expect(map.containsKey('id'), isFalse);
      expect(map['user_name'], 'new');
      expect(map['number_of_posts'], 0);
    });
  });

  group('copyWith', () {
    test('replaces only the requested fields', () {
      final base = UsersModel(
        userName: 'amr',
        bio: 'old bio',
        numberOfFollowers: 4,
      );
      final updated = base.copyWith(bio: 'new bio');

      expect(updated.userName, 'amr');
      expect(updated.bio, 'new bio');
      expect(updated.numberOfFollowers, 4);
    });
  });
}
