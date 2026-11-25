import 'package:flutter_test/flutter_test.dart';
import 'package:livebetter/services/update_service.dart';

void main() {
  group('版本比较', () {
    test('规范版本号补足三段并去掉 v 前缀', () {
      expect(normalizeVersion('v1.2'), '1.2.0');
      expect(normalizeVersion('V1.0.0'), '1.0.0');
      expect(normalizeVersion('1'), '1.0.0');
      expect(normalizeVersion('v1.0.0-beta'), isNull);
      expect(normalizeVersion('latest'), isNull);
    });

    test('按数字段比较大小', () {
      expect(compareVersions('1.0.0', '0.9.9'), 1);
      expect(compareVersions('1.0.0', '1.0.0'), 0);
      expect(compareVersions('1.0.0', '1.0.1'), -1);
      expect(compareVersions('1.10.0', '1.9.9'), 1);
      expect(compareVersions('2', '1.9.9'), 1);
    });
  });

  group('校验和解析', () {
    test('取首列 64 位摘要并转小写', () {
      final hash = 'A' * 64;
      expect(parseSha256('$hash  LiveBetter-v1.0.0-arm64.apk\n'),
          'a' * 64);
    });

    test('格式异常返回 null', () {
      expect(parseSha256('not-a-hash'), isNull);
      expect(parseSha256(''), isNull);
    });
  });

  group('Release 解析', () {
    Map<String, dynamic> release({
      String tag = 'v1.1.0',
      String apkName = 'LiveBetter-v1.1.0-arm64.apk',
      bool includeSha = true,
    }) {
      return {
        'tag_name': tag,
        'body': '修复若干问题',
        'assets': [
          {
            'name': apkName,
            'browser_download_url':
                'https://github.com/bohemoon/LiveBetter/releases/download/$tag/$apkName',
            'size': 25000000,
          },
          if (includeSha)
            {
              'name': '$apkName.sha256',
              'browser_download_url':
                  'https://github.com/bohemoon/LiveBetter/releases/download/$tag/$apkName.sha256',
              'size': 128,
            },
        ],
      };
    }

    test('远端更高版本返回更新信息', () {
      final info = parseRelease(release(), currentVersion: '1.0.0');
      expect(info, isNotNull);
      expect(info!.version, '1.1.0');
      expect(info.notes, '修复若干问题');
      expect(info.sizeBytes, 25000000);
      expect(info.apkUrl, endsWith('.apk'));
      expect(info.sha256Url, endsWith('.sha256'));
    });

    test('版本相同或更低不提示更新', () {
      expect(parseRelease(release(), currentVersion: '1.1.0'), isNull);
      expect(parseRelease(release(), currentVersion: '1.2.0'), isNull);
    });

    test('缺少校验和或非 arm64 包时忽略', () {
      expect(
        parseRelease(release(includeSha: false), currentVersion: '1.0.0'),
        isNull,
      );
      expect(
        parseRelease(
          release(apkName: 'LiveBetter-v1.1.0-x86_64.apk'),
          currentVersion: '1.0.0',
        ),
        isNull,
      );
    });

    test('非法 tag 返回 null', () {
      expect(
        parseRelease(release(tag: 'nightly'), currentVersion: '1.0.0'),
        isNull,
      );
    });
  });
}
