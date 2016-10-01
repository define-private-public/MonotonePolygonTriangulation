
library triangulate;

import 'dart:io';

// Test values
List<num> testValues = [-2, -5.3, 4, 7, 1, 0.1, 15, 11, -4];


// Does the merging part of merge sort
List<Comparable> merge(List<Comparable> left, List<Comparable> right) {
  List<Comparable> result = [];

  // Perform the sorting (and merging
  while ((left.length > 0) && (right.length > 0)) {
    if (left.first <= right.first) {
      result.add(left.first);
      left.removeAt(0);
    } else {
      result.add(right.first);
      right.removeAt(0);
    }
  }

  // Append the rest of the left/right to the result (could be none)
  result.addAll(left);
  result.addAll(right);

  // done!
  return result;
}


// Does a mergeSort on a list
List<Comparable> mergeSort(List<Comparable> values) {
  List<Comparable> left = [], right = [], result = [];

  // Base case
  if (values.length == 1)
    return values;
  else {
    // Split the values
    int middle = (values.length / 2).floor();
    left.addAll(values.getRange(0, middle));
    right.addAll(values.getRange(middle, values.length));

    // Split more
    left = mergeSort(left);
    right = mergeSort(right);

    // Join
    if (left.last <= right.first) {
      left.addAll(right);
      return left;
    }
    result = merge(left, right);

    return result;
  }
}


// Main execution
void main() {
  print(testValues);
  print(mergeSort(testValues));
}

