import 'package:equatable/equatable.dart';

abstract class CameraEvent extends Equatable {
  @override
  List<Object> get props => [];
}



class DiscoverCameraEvent extends CameraEvent {}

class TakePictureEvent extends CameraEvent {}

class StartLiveViewEvent extends CameraEvent {}

class FetchLiveViewEvent extends CameraEvent {}

class StopLiveViewEvent extends CameraEvent {}

class FetchThumbnailsList extends CameraEvent {
    final int noOfPhotos;
    FetchThumbnailsList(this.noOfPhotos);
}

class SetISOEvent extends CameraEvent {
  final int value;

  SetISOEvent(this.value);
}

class SetWhiteBalanceEvent extends CameraEvent {
  final String value;

  SetWhiteBalanceEvent(this.value);
}


class UpdateUserIdEvent extends CameraEvent {
  final String userId;

  UpdateUserIdEvent(this.userId);
}
