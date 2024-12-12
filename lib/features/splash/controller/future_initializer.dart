import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:new_ecommerce/bootstrap.dart';
import 'package:new_ecommerce/core/local_storage/app_storage_pod.dart';
import 'package:new_ecommerce/features/splash/controller/box_encryption_key_pod.dart';
import 'package:new_ecommerce/init.dart';
import 'package:platform_info/platform_info.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger.dart';

final futureInitializerPod = FutureProvider.autoDispose<ProviderContainer>((ref) async {
  ///Additional intial delay duration for app
  // await Future.delayed(const Duration(seconds: 1));
  await (init());
  await Hive.initFlutter();

  ///Replace `appBox` namw with any key you want

  final encryptionCipher = await Platform.I.when(
    mobile: () async {
      final encryptionKey = await ref.watch(boxEncryptionKeyPod.future);
      return HiveAesCipher(encryptionKey);
    },
  );

  ///TODO: Replace box name with your unique name
  final appBox = await Hive.openBox(
    'AppBox',
    encryptionCipher: encryptionCipher,
  );
  return ProviderContainer(
    overrides: [
      appBoxProvider.overrideWithValue(appBox),
    ],
    observers: [
      ///Added new talker riverpod observer
      ///
      /// If you want old behaviour
      /// Replace with
      ///
      ///  MyObserverLogger( talker: talker,)
      ///
      ///
      ///
      ///
      TalkerRiverpodObserver(
        talker: talker,
        settings: const TalkerRiverpodLoggerSettings(
          printProviderDisposed: true,
        ),
      ),
    ],
  );
});