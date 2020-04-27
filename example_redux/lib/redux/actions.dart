
abstract class QAInplaceAction {
  QAInplaceAction(this.index);

  final int index;
}

class AddConnection extends QAInplaceAction {
  AddConnection(this.sourceIndex, this.destinationIndex, int index)
      : super(index);

  final int sourceIndex;
  final int destinationIndex;
}

class RemoveConnection extends QAInplaceAction {
  RemoveConnection(this.sourceIndex, int index) : super(index);

  final int sourceIndex;
}

class RemoveAllConnections extends QAInplaceAction {
  RemoveAllConnections(int index) : super(index);
}

class Order extends QAInplaceAction {
  Order(this.order, int index) : super(index);

  final List<int> order;
}
