

abstract class MatchingInplaceAction {
	int matchingIndex;
}

class AddConnection extends MatchingInplaceAction {
	int queryIndex;
	int answerIndex;
}

class RemoveConnection extends MatchingInplaceAction {
	int queryIndex;
	int answerIndex;
}

class RemoveAllConnections extends MatchingInplaceAction {
}