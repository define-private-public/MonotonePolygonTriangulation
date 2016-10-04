
library triangulate;

// A simple LIFO implementation
// Dart doesn't have one by default, and using Queue might be a little clunky
class Stack<T> {
  // Under the hood there is actually a list
  List<T> _list;

  
  // Constructs an empty Stack
  Stack() :
    _list = new List<T>();

  
  // Returns number of elements in the stack
  int size() =>
    _list.length;


  // Add an item to the stack
  void push(T x) =>
    _list.add(x);


  // Remove (and return) and item from the stack
  T pop() =>
    _list.removeLast();


  // Look at an item from the stack
  // Topmost element is at index 0, bottommost is at (n - 1)
  T peek(int index) =>
    _list[this.size() - index - 1];


  // Empty out the Stack
  void clear() =>
    _list.clear();
  

  // Return an iterator to go through the Stack
  Iterable<T> getIter() =>
    _list.reversed;


  // Create a copy of the Stack
  Stack<T> copy() {
    Stack<T> other = new Stack<T>();
    other._list = new List<T>.from(_list);
    return other;
  }

 
  // Get a string representation of the elements (topmost first)
  String toString() {
    if (size() == 0)
      return '[ ]';
    else {
      String str = '[ ';

      for (T x in getIter())
        str += x.toString() + ', ';

      // Trim out extra comma
      str = str.substring(0, str.length - 2);
      str += ' ]';

      return str;
    }
  }
}

