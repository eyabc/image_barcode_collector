import 'package:flutter_bloc/flutter_bloc.dart';

class ImageState {

  final int imageCount;
  final int totalCount;

  ImageState(this.imageCount, this.totalCount);

}

class ImageCubit extends Cubit<ImageState> {
  ImageCubit() : super(ImageState(0, 0));

  setCount(int imageCount, int totalCount) {
    emit(ImageState(imageCount, totalCount));
  }

}