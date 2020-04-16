abstract class MatchingInplaceAction {
  MatchingInplaceAction(this.matchingIndex);

  final int matchingIndex;
}

class AddConnection extends MatchingInplaceAction {
  AddConnection(this.sourceIndex, this.destinationIndex, int matchingIndex)
      : super(matchingIndex);

  final int sourceIndex;
  final int destinationIndex;
}

class RemoveConnection extends MatchingInplaceAction {
  RemoveConnection(this.sourceIndex, int matchingIndex) : super(matchingIndex);
  final int sourceIndex;
}

class RemoveAllConnections extends MatchingInplaceAction {
  RemoveAllConnections(int matchingIndex) : super(matchingIndex);
}
