abstract class RequestEvent {}

class InputEvent extends RequestEvent {
  String input;
  InputEvent({this.input});
}

class SendCancelEvent extends RequestEvent {}

class SendEvent extends RequestEvent {
  String text;
  SendEvent({this.text});
}
