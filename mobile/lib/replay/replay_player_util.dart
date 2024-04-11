typedef VoidCallback = void Function();
typedef IntCallback = int Function();

// Replay control mechanisms
class ReplayControl {
  VoidCallback start;
  VoidCallback pause;
  VoidCallback resume;
  VoidCallback cancel;

  ReplayControl({
    required this.start,
    required this.pause,
    required this.resume,
    required this.cancel,
  });
}
