import 'package:flutter_bloc/flutter_bloc.dart';

class ImageState {

  final int imageCount;

  static const int lastCount = 1000;

  ImageState(this.imageCount);

}

class ImageCubit extends Cubit<ImageState> {
  ImageCubit() : super(ImageState(0));

  setTotalLoadingCount(int count) {
    emit(ImageState(count));
  }

}