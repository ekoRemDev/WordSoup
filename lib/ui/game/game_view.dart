import 'package:bloc_provider/bloc_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:word_soup/blocs/words_bloc.dart';
import 'package:word_soup/models/board_data.dart';
import 'package:word_soup/ui/game/widgets/custom_fab_row.dart';
import 'package:word_soup/ui/game/widgets/letter_box.dart';
import 'package:word_soup/ui/game/widgets/letters_grid_view.dart';
import 'package:word_soup/ui/game/widgets/word_selection_box.dart';
import 'package:word_soup/utils/overlay_widgets/game_complete_dialog.dart';
import 'package:word_soup/utils/overlay_widgets/level_complete_dialog.dart';
import 'package:word_soup/utils/overlay_widgets/words_bottom_sheet.dart';
import 'package:word_soup/utils/base/selection_event.dart';
import 'package:word_soup/utils/custom_fabs_props_creator.dart';
import 'package:word_soup/utils/snackbar_util.dart';

class GameView extends StatefulWidget {

  final String sentence;
  final int tableSize;
  final int level;

  GameView({Key key, @required this.sentence, @required this.tableSize, @required this.level});

  @override
  _GameViewState createState() => _GameViewState();
}

class _GameViewState extends State<GameView> {

  var userSelection = '';
  WordsBloc wordsBloc;

  @override
  void initState() {
    super.initState();
    wordsBloc = BlocProvider.of(context);
    wordsBloc.userSelectionStream.listen((event) {
      if(event != null){
        checkEvent(event);
      }
    });
    print("Sentence: ${widget.sentence}");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        buildGridView(),
        WordSelectionBox(selection: userSelection),
        CustomFabRow(
            fabsProps: CustomFabsPropsCreator.getProps(
                [
                  () => wordsBloc.clearUserSelection(),
                  () => wordsBloc.checkUserSelection(),
                  () => showModalBottomSheet(context: context,
                    builder: (context) => WordsBottomSheet(words: wordsBloc.createSoupWordsWidget()),
                  )
                ]
            )
        ),
      ],
    );
  }

  Widget buildGridView(){
    final boardData = BoardData.BOARD_MAP[widget.tableSize];
    return Container(
      height: boardData.gridHeight,
      margin: EdgeInsets.all(20),
      child: LettersGridView(
          onSelectionEnd: _onSelectionEnd,
          onSelectionUpdate: _onSelectionUpdate,
          foundIndexes: wordsBloc.getUserFoundWordsIndices(),
          itemCount: widget.tableSize * widget.tableSize,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: 0.7,
            crossAxisCount: widget.tableSize,
            crossAxisSpacing: boardData.crossAxisSpacing,
            mainAxisSpacing: boardData.mainAxisSpacing,
          ),
          itemBuilder: (context, index, selected){
            return LetterBox(
              isSelected: selected,
              id: index,
              letter: widget.sentence[index],
            );
          }
      ),
    );
  }

  void _onSelectionEnd(List<int> selection){
    final userSelection = _createWordFromIndexes(selection);

    setState((){
      print("On selection end");
      if(wordsBloc.addedWords.contains(userSelection)){
        print("Word finded: $userSelection");
        if(wordsBloc.getUserFoundWords().contains(userSelection)){
          SnackBarUtil.createErrorSnack(context, 'You have already found $userSelection');
        }
        else{
          SnackBarUtil.createSuccessSnack(context, 'You found $userSelection!');
          wordsBloc.addUserFoundWord(userSelection, selection);
          if(wordsBloc.getUserFoundWords().length == wordsBloc.addedWords.length){
            if(widget.level != 6) createLevelCompletedDialog();
            else createGameCompleteDialog();
          }
          wordsBloc.clearUserSelection();
        }
      }
      else{
        SnackBarUtil.createErrorSnack(context, 'Ups! That did not match a soup word');
        wordsBloc.clearUserSelection();
      }
    });
  }

  void _onSelectionUpdate(List<int> selection) => setState(() => userSelection = _createWordFromIndexes(selection));

  String _createWordFromIndexes(List<int> selection){
    final buffer = StringBuffer();
    selection.forEach( (ind) => ind != -1 ? buffer.write(widget.sentence[ind]) : {});
    return buffer.toString();
  }

  void checkEvent(SelectionEvent event){
    if(event == SelectionEvent.ClearSelection) _onSelectionUpdate([]);
  }

  void createLevelCompletedDialog() async {
    final goNextLevel = await LevelCompleteDialog.showLevelCompleteDialog(context, widget.level);
    if(goNextLevel) wordsBloc.triggerLevelComplete();
  }

  void createGameCompleteDialog() async {
    await GameCompleteDialog.showGameCompleteDialog(context);
    Navigator.pop(context);
  }

}