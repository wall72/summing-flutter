import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:summing_flutter/domain/summing_domain.dart';
import 'package:summing_flutter/infrastructure/persistence/game_save_store.dart';
import 'package:summing_flutter/infrastructure/persistence/persistence_keys.dart';
import 'package:summing_flutter/infrastructure/persistence/save_game_codec.dart';

// @MX:NOTE: [AUTO] schemaVersion 1 저장 형식 호환을 고정하는 fixture. 리팩토링 전 코덱이 만든 문자열이며, 코덱 파일은 diff를 비우기 위해 태그를 달지 않음
/// 리팩토링 전 `SaveGameCodec.encode`가 만든 저장 문자열 (AC-ARCH-03).
const _fixtureJson = '{"schemaVersion":1,"turnCount":17,'
    '"assigned":['
    'false,true,true,false,true,true,false,true,true,'
    'false,true,true,false,true,true,false,true,true,'
    'false,true,true,false,true,true,false,true,true,'
    'false,true,true,false,true,true,false,true,true,'
    'false,true,true,false,true,true,false,true,true,'
    'false,true,true,false,true,true,false,true,true,'
    'false,true,true,false,true,true,false,true,true,'
    'false,true,true,false,true,true,false,true,true,'
    'false,true,true,false,true,true,false,true,true'
    '],"values":['
    '0,7,4,0,8,5,0,9,6,0,0,7,0,1,8,0,2,9,0,3,0,0,4,1,0,5,2,'
    '0,6,3,0,7,4,0,8,5,0,9,6,0,0,7,0,1,8,0,2,9,0,3,0,0,4,1,'
    '0,5,2,0,6,3,0,7,4,0,8,5,0,9,6,0,0,7,0,1,8,0,2,9,0,3,0'
    '],"nextQueue":[3,1,4,1]}';

/// fixture를 만들 때 쓴 상태: i % 3 != 0 인 칸만 채우고 값은 (i * 7) % 10.
SummingCell _expectedCell(int i) =>
    i % 3 != 0 ? SummingCell.filled((i * 7) % 10) : SummingCell.empty;

GameState _fixtureState() => GameState(
      board: Board.fromCells(
        List<SummingCell>.generate(CellIndex.cellCount, _expectedCell),
      ),
      queue: NextQueue(const [3, 1, 4, 1]),
      turnCount: 17,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('fixture is exactly what the codec writes for the fixture state', () {
    expect(SaveGameCodec.encode(_fixtureState()), _fixtureJson);
  });

  test('game save store loads the schemaVersion 1 fixture unchanged', () async {
    SharedPreferences.setMockInitialValues({
      PersistenceKeys.saveGame: _fixtureJson,
    });
    final prefs = await SharedPreferences.getInstance();
    final GameSaveStore store = GameSaveStore(prefs);

    final loaded = store.load();

    expect(loaded, isNotNull);
    expect(loaded!.turnCount, 17);
    expect(loaded.board.cells, hasLength(81));
    for (var i = 0; i < CellIndex.cellCount; i++) {
      expect(loaded.board.cellAt(i), _expectedCell(i), reason: 'cell $i');
    }
    expect(loaded.queue.slots, hasLength(4));
    expect(loaded.queue.slots, [3, 1, 4, 1]);
  });
}
