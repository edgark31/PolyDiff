typedef VoidCallback = void Function();
typedef IntCallback = int Function();
typedef BoolCallback = bool Function();

// Replay control mechanisms for the replay functionality.
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
