
* 引数がDLL.MRB_ARGS_OPT(4)固定になってるのを修正
- 継承が動いていないのを修正
* ConverterをConverter,Utilに分割
* module,classをリストアップして、先に作るようにする
* Fiberのテスト
* bindingが対応する型を増やす
* Send()がエラーを返した時の処理をちゃんとする
* スタックトレースをだせるようにする（デバッグビルド？）
* Value classがmrbを持つように（いちいち、mrbを渡さなくて済むように）
