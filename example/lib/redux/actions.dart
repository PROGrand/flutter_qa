abstract class MatchingInplaceAction {
  final int matchingIndex;

  MatchingInplaceAction(this.matchingIndex);
}

class AddConnection extends MatchingInplaceAction {
  final int sourceIndex;
  final int destinationIndex;

  AddConnection(this.sourceIndex, this.destinationIndex, int matchingIndex) : super(matchingIndex);
}

class RemoveConnection extends MatchingInplaceAction {
  final int sourceIndex;

  RemoveConnection(this.sourceIndex, int matchingIndex) : super(matchingIndex);
}

class RemoveAllConnections extends MatchingInplaceAction {
  RemoveAllConnections(int matchingIndex) : super(matchingIndex);
}
