---
layout: splash
author_profile: false
---

# Non-Linear Data Structures

Hierarchical and networked data representations.


### Trees: binary trees and BSTs

A **tree** is a hierarchical non-linear data structure consisting of nodes connected by edges. Unlike linear structures (arrays, linked lists), trees represent hierarchical relationships.

**Tree Terminology**:
- **Root**: The topmost node (no parent)
- **Parent**: A node with children
- **Child**: A node connected below another node
- **Leaf**: A node with no children
- **Edge**: Connection between two nodes
- **Path**: Sequence of nodes connected by edges
- **Height**: Length of longest path from root to leaf
- **Depth/Level**: Distance from root to a node
- **Subtree**: Tree formed by a node and its descendants

```
Example Tree:
        1 (root, height=2, depth=0)
       / \
      2   3 (depth=1)
     / \   \
    4   5   6 (leaves, depth=2)
```

**Binary Tree**:

A **binary tree** is a tree where each node has at most two children (left and right).

**Types of Binary Trees**:

1. **Full Binary Tree**: Every node has 0 or 2 children
```
     1
    / \
   2   3
  / \
 4   5
```

2. **Complete Binary Tree**: All levels filled except possibly the last, which fills left to right
```
     1
    / \
   2   3
  / \  /
 4  5 6
```

3. **Perfect Binary Tree**: All internal nodes have 2 children, all leaves at same level
```
     1
    / \
   2   3
  / \ / \
 4  5 6  7
```

4. **Degenerate/Skewed Tree**: Each node has only one child (essentially a linked list)
```
1
 \
  2
   \
    3
```

**Binary Tree Implementation**:
```python
class TreeNode:
    def __init__(self, value):
        self.value = value
        self.left = None
        self.right = None

class BinaryTree:
    def __init__(self):
        self.root = None

    def insert_left(self, parent, value):
        """Insert node as left child"""
        if parent is None:
            return None
        new_node = TreeNode(value)
        parent.left = new_node
        return new_node

    def insert_right(self, parent, value):
        """Insert node as right child"""
        if parent is None:
            return None
        new_node = TreeNode(value)
        parent.right = new_node
        return new_node

# Usage:
tree = BinaryTree()
tree.root = TreeNode(1)
left_child = tree.insert_left(tree.root, 2)
right_child = tree.insert_right(tree.root, 3)
tree.insert_left(left_child, 4)
tree.insert_right(left_child, 5)
```

**Binary Search Tree (BST)**:

A **BST** is a binary tree with an ordering property:
- **Left subtree** contains only nodes with values **less than** the parent
- **Right subtree** contains only nodes with values **greater than** the parent
- Both subtrees are also BSTs

```
Example BST:
        8
       / \
      3   10
     / \    \
    1   6    14
       / \   /
      4   7 13

Property: 1 < 3 < 4 < 6 < 7 < 8 < 10 < 13 < 14
```

**BST Operations**:

**1. Search** - O(h) where h is height:
```python
def search(root, target):
    """Search for a value in BST"""
    if root is None or root.value == target:
        return root

    if target < root.value:
        return search(root.left, target)  # Search left
    else:
        return search(root.right, target)  # Search right

# Iterative version:
def search_iterative(root, target):
    current = root
    while current is not None:
        if target == current.value:
            return current
        elif target < current.value:
            current = current.left
        else:
            current = current.right
    return None
```

**2. Insert** - O(h):
```python
def insert(root, value):
    """Insert value into BST"""
    if root is None:
        return TreeNode(value)

    if value < root.value:
        root.left = insert(root.left, value)
    elif value > root.value:
        root.right = insert(root.right, value)
    # If value == root.value, do nothing (no duplicates)

    return root

# Usage:
root = None
root = insert(root, 8)
root = insert(root, 3)
root = insert(root, 10)
root = insert(root, 1)
```

**3. Delete** - O(h):
```python
def delete(root, value):
    """Delete value from BST"""
    if root is None:
        return None

    # Find the node to delete
    if value < root.value:
        root.left = delete(root.left, value)
    elif value > root.value:
        root.right = delete(root.right, value)
    else:
        # Node found! Three cases:

        # Case 1: Leaf node (no children)
        if root.left is None and root.right is None:
            return None

        # Case 2: One child
        if root.left is None:
            return root.right
        if root.right is None:
            return root.left

        # Case 3: Two children
        # Find inorder successor (min value in right subtree)
        successor = find_min(root.right)
        root.value = successor.value
        root.right = delete(root.right, successor.value)

    return root

def find_min(root):
    """Find minimum value node"""
    while root.left is not None:
        root = root.left
    return root

def find_max(root):
    """Find maximum value node"""
    while root.right is not None:
        root = root.right
    return root
```

**4. Find Min/Max** - O(h):
```python
# Min: leftmost node
# Max: rightmost node
```

**BST Properties**:
- **Inorder traversal** gives sorted sequence
- **Average case**: O(log n) for search, insert, delete
- **Worst case**: O(n) when tree becomes skewed
- **Space**: O(n) for storing n nodes

**BST vs Array vs Linked List**:

| Operation | Sorted Array | Linked List | BST (balanced) |
|-----------|--------------|-------------|----------------|
| Search | O(log n) | O(n) | O(log n) |
| Insert | O(n) | O(1)* | O(log n) |
| Delete | O(n) | O(1)* | O(log n) |
| Min/Max | O(1) | O(n) | O(log n) |
| Sorted order | Built-in | No | Inorder traversal |

*assuming position is known

**Applications of BST**:
- **Databases**: Indexing for fast queries
- **File systems**: Directory structures
- **Expression trees**: Compiler design
- **Symbol tables**: Compiler implementation
- **Priority queues**: When dynamic updates needed

**Example: Building and Using a BST**:
```python
class BST:
    def __init__(self):
        self.root = None

    def insert(self, value):
        self.root = self._insert_recursive(self.root, value)

    def _insert_recursive(self, node, value):
        if node is None:
            return TreeNode(value)
        if value < node.value:
            node.left = self._insert_recursive(node.left, value)
        elif value > node.value:
            node.right = self._insert_recursive(node.right, value)
        return node

    def search(self, value):
        return self._search_recursive(self.root, value)

    def _search_recursive(self, node, value):
        if node is None or node.value == value:
            return node
        if value < node.value:
            return self._search_recursive(node.left, value)
        return self._search_recursive(node.right, value)

    def inorder(self):
        """Return sorted values"""
        result = []
        self._inorder_recursive(self.root, result)
        return result

    def _inorder_recursive(self, node, result):
        if node:
            self._inorder_recursive(node.left, result)
            result.append(node.value)
            self._inorder_recursive(node.right, result)

# Usage:
bst = BST()
values = [8, 3, 10, 1, 6, 14, 4, 7, 13]
for val in values:
    bst.insert(val)

print(bst.inorder())  # [1, 3, 4, 6, 7, 8, 10, 13, 14] - sorted!
print(bst.search(6) is not None)  # True
print(bst.search(5) is not None)  # False
```

**Common BST Problems**:
- Validate if a tree is a BST
- Find kth smallest/largest element
- Lowest common ancestor
- Convert sorted array to balanced BST
- Find range of values in BST

### Tree traversals: inorder/preorder/postorder

**Tree traversal** is the process of visiting all nodes in a tree in a specific order. There are two main categories: **Depth-First Search (DFS)** and **Breadth-First Search (BFS)**.

**Depth-First Traversals** (DFS):

Visit children before siblings. Three main types:

**1. Inorder Traversal** (Left → Root → Right):

Visit left subtree, then root, then right subtree.

```
Tree:     4
         / \
        2   6
       / \ / \
      1  3 5  7

Inorder: 1, 2, 3, 4, 5, 6, 7 (sorted for BST!)
```

```python
def inorder(root):
    """Inorder traversal: Left → Root → Right"""
    if root is None:
        return []

    result = []
    result.extend(inorder(root.left))    # Left
    result.append(root.value)            # Root
    result.extend(inorder(root.right))   # Right
    return result

# Iterative version using stack:
def inorder_iterative(root):
    result = []
    stack = []
    current = root

    while current or stack:
        # Go to leftmost node
        while current:
            stack.append(current)
            current = current.left

        # Process node
        current = stack.pop()
        result.append(current.value)

        # Visit right subtree
        current = current.right

    return result
```

**Use cases**:
- Get sorted values from BST
- Expression tree evaluation (infix notation)

**2. Preorder Traversal** (Root → Left → Right):

Visit root first, then left subtree, then right subtree.

```
Tree:     4
         / \
        2   6
       / \ / \
      1  3 5  7

Preorder: 4, 2, 1, 3, 6, 5, 7
```

```python
def preorder(root):
    """Preorder traversal: Root → Left → Right"""
    if root is None:
        return []

    result = []
    result.append(root.value)            # Root
    result.extend(preorder(root.left))   # Left
    result.extend(preorder(root.right))  # Right
    return result

# Iterative version:
def preorder_iterative(root):
    if root is None:
        return []

    result = []
    stack = [root]

    while stack:
        node = stack.pop()
        result.append(node.value)

        # Push right first (so left is processed first)
        if node.right:
            stack.append(node.right)
        if node.left:
            stack.append(node.left)

    return result
```

**Use cases**:
- Copy a tree
- Get prefix expression (prefix notation)
- Serialize/deserialize a tree

**3. Postorder Traversal** (Left → Right → Root):

Visit left subtree, then right subtree, then root.

```
Tree:     4
         / \
        2   6
       / \ / \
      1  3 5  7

Postorder: 1, 3, 2, 5, 7, 6, 4
```

```python
def postorder(root):
    """Postorder traversal: Left → Right → Root"""
    if root is None:
        return []

    result = []
    result.extend(postorder(root.left))   # Left
    result.extend(postorder(root.right))  # Right
    result.append(root.value)             # Root
    return result

# Iterative version (more complex):
def postorder_iterative(root):
    if root is None:
        return []

    result = []
    stack = []
    last_visited = None
    current = root

    while current or stack:
        # Go to leftmost node
        while current:
            stack.append(current)
            current = current.left

        peek_node = stack[-1]

        # If right child exists and not yet processed
        if peek_node.right and last_visited != peek_node.right:
            current = peek_node.right
        else:
            result.append(peek_node.value)
            last_visited = stack.pop()

    return result
```

**Use cases**:
- Delete a tree (delete children before parent)
- Get postfix expression (postfix notation)
- Calculate directory sizes

**Breadth-First Traversal** (BFS / Level-Order):

Visit nodes level by level, left to right.

```
Tree:     4
         / \
        2   6
       / \ / \
      1  3 5  7

Level-order: 4, 2, 6, 1, 3, 5, 7
```

```python
from collections import deque

def level_order(root):
    """Level-order traversal (BFS)"""
    if root is None:
        return []

    result = []
    queue = deque([root])

    while queue:
        node = queue.popleft()
        result.append(node.value)

        if node.left:
            queue.append(node.left)
        if node.right:
            queue.append(node.right)

    return result

# Level-by-level (grouped):
def level_order_grouped(root):
    """Return nodes grouped by level"""
    if root is None:
        return []

    result = []
    queue = deque([root])

    while queue:
        level_size = len(queue)
        current_level = []

        for _ in range(level_size):
            node = queue.popleft()
            current_level.append(node.value)

            if node.left:
                queue.append(node.left)
            if node.right:
                queue.append(node.right)

        result.append(current_level)

    return result

# Returns: [[4], [2, 6], [1, 3, 5, 7]]
```

**Use cases**:
- Find shortest path in unweighted tree
- Level-order processing
- Check if tree is complete
- Print tree level by level

**Traversal Comparison**:

| Traversal | Order | Use Case | Data Structure |
|-----------|-------|----------|----------------|
| Inorder | Left-Root-Right | Get sorted values (BST) | Stack (recursion) |
| Preorder | Root-Left-Right | Copy tree, serialize | Stack |
| Postorder | Left-Right-Root | Delete tree, calculate size | Stack |
| Level-order | Level by level | Shortest path, level processing | Queue |

**Visual Summary**:
```
Tree:     1
         / \
        2   3
       / \
      4   5

Preorder:  1 → 2 → 4 → 5 → 3 (DLR: Data-Left-Right)
Inorder:   4 → 2 → 5 → 1 → 3 (LDR: Left-Data-Right)
Postorder: 4 → 5 → 2 → 3 → 1 (LRD: Left-Right-Data)
Level:     1 → 2 → 3 → 4 → 5 (Top-to-bottom, left-to-right)
```

**Time and Space Complexity**:
- **Time**: O(n) - visit each node once
- **Space**:
  - Recursion: O(h) for call stack (h = height)
  - Iterative: O(h) for explicit stack/queue
  - Level-order: O(w) where w = max width

**Practical Example: Expression Tree**:
```python
"""
Expression: (3 + 5) * 2

Tree:       *
           / \
          +   2
         / \
        3   5

Inorder (infix):   3 + 5 * 2 (need parentheses)
Preorder (prefix): * + 3 5 2
Postorder (postfix): 3 5 + 2 *
"""

def evaluate_expression_tree(root):
    """Evaluate arithmetic expression tree"""
    if root is None:
        return 0

    # Leaf node (operand)
    if root.left is None and root.right is None:
        return int(root.value)

    # Evaluate subtrees
    left_val = evaluate_expression_tree(root.left)
    right_val = evaluate_expression_tree(root.right)

    # Apply operator (postorder: process children first!)
    if root.value == '+':
        return left_val + right_val
    elif root.value == '-':
        return left_val - right_val
    elif root.value == '*':
        return left_val * right_val
    elif root.value == '/':
        return left_val / right_val

# This uses postorder traversal internally!
```

### Heaps: min-heap and max-heap

A **heap** is a specialized tree-based data structure that satisfies the **heap property**. It's typically implemented as a **complete binary tree** stored in an array.

**Heap Property**:
- **Min-Heap**: Parent ≤ Children (smallest at root)
- **Max-Heap**: Parent ≥ Children (largest at root)

**Why Heaps?**
- Efficiently find min/max: O(1)
- Efficiently insert/delete: O(log n)
- Foundation for priority queues
- Used in heapsort algorithm

**Min-Heap Example**:
```
         1
        / \
       3   2
      / \ / \
     7  5 4  6

Array representation: [1, 3, 2, 7, 5, 4, 6]
Property: Parent ≤ Children at every node
```

**Max-Heap Example**:
```
         10
        /  \
       7    9
      / \  / \
     3  5 6  8

Array representation: [10, 7, 9, 3, 5, 6, 8]
Property: Parent ≥ Children at every node
```

**Array Implementation**:

For a node at index `i`:
- **Left child**: `2*i + 1`
- **Right child**: `2*i + 2`
- **Parent**: `(i - 1) // 2`

```python
class MinHeap:
    def __init__(self):
        self.heap = []

    def parent(self, i):
        return (i - 1) // 2

    def left_child(self, i):
        return 2 * i + 1

    def right_child(self, i):
        return 2 * i + 2

    def swap(self, i, j):
        self.heap[i], self.heap[j] = self.heap[j], self.heap[i]

    def insert(self, value):
        """Insert value - O(log n)"""
        # Add to end
        self.heap.append(value)

        # Bubble up to maintain heap property
        current = len(self.heap) - 1
        while current > 0:
            parent = self.parent(current)
            if self.heap[current] < self.heap[parent]:
                self.swap(current, parent)
                current = parent
            else:
                break

    def extract_min(self):
        """Remove and return minimum - O(log n)"""
        if len(self.heap) == 0:
            raise IndexError("Heap is empty")

        if len(self.heap) == 1:
            return self.heap.pop()

        # Store minimum
        min_value = self.heap[0]

        # Move last element to root
        self.heap[0] = self.heap.pop()

        # Bubble down to maintain heap property
        self._heapify_down(0)

        return min_value

    def _heapify_down(self, i):
        """Restore heap property by bubbling down"""
        size = len(self.heap)

        while True:
            smallest = i
            left = self.left_child(i)
            right = self.right_child(i)

            # Find smallest among node and its children
            if left < size and self.heap[left] < self.heap[smallest]:
                smallest = left
            if right < size and self.heap[right] < self.heap[smallest]:
                smallest = right

            # If node is in correct position, done
            if smallest == i:
                break

            # Swap and continue
            self.swap(i, smallest)
            i = smallest

    def peek(self):
        """Return minimum without removing - O(1)"""
        if len(self.heap) == 0:
            raise IndexError("Heap is empty")
        return self.heap[0]

    def size(self):
        return len(self.heap)

    def is_empty(self):
        return len(self.heap) == 0

# Usage:
min_heap = MinHeap()
min_heap.insert(5)
min_heap.insert(3)
min_heap.insert(7)
min_heap.insert(1)
print(min_heap.peek())        # 1 (minimum)
print(min_heap.extract_min()) # 1
print(min_heap.peek())        # 3 (new minimum)
```

**Max-Heap Implementation**:
```python
class MaxHeap:
    """Similar to MinHeap but with opposite comparisons"""

    def __init__(self):
        self.heap = []

    def parent(self, i):
        return (i - 1) // 2

    def left_child(self, i):
        return 2 * i + 1

    def right_child(self, i):
        return 2 * i + 2

    def swap(self, i, j):
        self.heap[i], self.heap[j] = self.heap[j], self.heap[i]

    def insert(self, value):
        """Insert value - O(log n)"""
        self.heap.append(value)
        current = len(self.heap) - 1

        # Bubble up (compare with > instead of <)
        while current > 0:
            parent = self.parent(current)
            if self.heap[current] > self.heap[parent]:
                self.swap(current, parent)
                current = parent
            else:
                break

    def extract_max(self):
        """Remove and return maximum - O(log n)"""
        if len(self.heap) == 0:
            raise IndexError("Heap is empty")

        if len(self.heap) == 1:
            return self.heap.pop()

        max_value = self.heap[0]
        self.heap[0] = self.heap.pop()
        self._heapify_down(0)
        return max_value

    def _heapify_down(self, i):
        """Restore heap property"""
        size = len(self.heap)

        while True:
            largest = i
            left = self.left_child(i)
            right = self.right_child(i)

            # Find largest among node and children
            if left < size and self.heap[left] > self.heap[largest]:
                largest = left
            if right < size and self.heap[right] > self.heap[largest]:
                largest = right

            if largest == i:
                break

            self.swap(i, largest)
            i = largest

    def peek(self):
        """Return maximum without removing - O(1)"""
        if len(self.heap) == 0:
            raise IndexError("Heap is empty")
        return self.heap[0]
```

**Building a Heap from Array** - O(n):
```python
def heapify(arr):
    """Build min-heap from array in O(n) time"""
    n = len(arr)

    # Start from last non-leaf node and heapify down
    for i in range(n // 2 - 1, -1, -1):
        _heapify_down(arr, n, i)

def _heapify_down(arr, n, i):
    """Helper to heapify subtree rooted at i"""
    smallest = i
    left = 2 * i + 1
    right = 2 * i + 2

    if left < n and arr[left] < arr[smallest]:
        smallest = left
    if right < n and arr[right] < arr[smallest]:
        smallest = right

    if smallest != i:
        arr[i], arr[smallest] = arr[smallest], arr[i]
        _heapify_down(arr, n, smallest)

# Usage:
arr = [5, 3, 7, 1, 9, 4]
heapify(arr)
print(arr)  # Valid min-heap structure
```

**Python's heapq Module**:
```python
import heapq

# Min-heap (default)
heap = []
heapq.heappush(heap, 5)
heapq.heappush(heap, 3)
heapq.heappush(heap, 7)
heapq.heappush(heap, 1)

print(heapq.heappop(heap))  # 1 (minimum)
print(heapq.heappop(heap))  # 3
print(heap[0])  # 5 (peek at minimum)

# Build heap from list
data = [5, 3, 7, 1, 9, 4]
heapq.heapify(data)  # Converts to min-heap in-place

# For max-heap, negate values:
max_heap = []
heapq.heappush(max_heap, -5)
heapq.heappush(max_heap, -3)
heapq.heappush(max_heap, -7)
max_val = -heapq.heappop(max_heap)  # 7
```

**Applications**:

**1. Priority Queue**:
```python
class PriorityQueue:
    """Task queue with priorities"""
    def __init__(self):
        self.heap = []
        self.counter = 0  # For tie-breaking

    def push(self, item, priority):
        heapq.heappush(self.heap, (priority, self.counter, item))
        self.counter += 1

    def pop(self):
        return heapq.heappop(self.heap)[2]  # Return item only

# Usage:
pq = PriorityQueue()
pq.push("task1", priority=3)
pq.push("task2", priority=1)  # Highest priority
pq.push("task3", priority=2)
print(pq.pop())  # "task2" (priority 1)
```

**2. Find K Largest/Smallest Elements**:
```python
def find_k_largest(arr, k):
    """Find k largest elements - O(n log k)"""
    # Use min-heap of size k
    heap = arr[:k]
    heapq.heapify(heap)

    for num in arr[k:]:
        if num > heap[0]:
            heapq.heapreplace(heap, num)

    return heap

def find_k_smallest(arr, k):
    """Find k smallest elements - O(n log k)"""
    return heapq.nsmallest(k, arr)  # Built-in

# Usage:
arr = [3, 1, 5, 12, 2, 11, 9, 8, 4]
print(find_k_largest(arr, 3))  # [9, 11, 12]
print(find_k_smallest(arr, 3)) # [1, 2, 3]
```

**3. Heapsort** - O(n log n):
```python
def heapsort(arr):
    """Sort array using heap"""
    # Build max-heap
    n = len(arr)
    for i in range(n // 2 - 1, -1, -1):
        _heapify_down_max(arr, n, i)

    # Extract elements one by one
    for i in range(n - 1, 0, -1):
        arr[0], arr[i] = arr[i], arr[0]  # Swap root with last
        _heapify_down_max(arr, i, 0)  # Heapify reduced heap

def _heapify_down_max(arr, n, i):
    largest = i
    left = 2 * i + 1
    right = 2 * i + 2

    if left < n and arr[left] > arr[largest]:
        largest = left
    if right < n and arr[right] > arr[largest]:
        largest = right

    if largest != i:
        arr[i], arr[largest] = arr[largest], arr[i]
        _heapify_down_max(arr, n, largest)

# Usage:
arr = [5, 3, 7, 1, 9, 4]
heapsort(arr)
print(arr)  # [1, 3, 4, 5, 7, 9]
```

**4. Merge K Sorted Lists**:
```python
def merge_k_sorted_lists(lists):
    """Merge k sorted lists using min-heap"""
    heap = []
    result = []

    # Add first element from each list
    for i, lst in enumerate(lists):
        if lst:
            heapq.heappush(heap, (lst[0], i, 0))  # (value, list_idx, elem_idx)

    while heap:
        val, list_idx, elem_idx = heapq.heappop(heap)
        result.append(val)

        # Add next element from same list
        if elem_idx + 1 < len(lists[list_idx]):
            next_val = lists[list_idx][elem_idx + 1]
            heapq.heappush(heap, (next_val, list_idx, elem_idx + 1))

    return result

# Usage:
lists = [[1, 4, 7], [2, 5, 8], [3, 6, 9]]
print(merge_k_sorted_lists(lists))  # [1, 2, 3, 4, 5, 6, 7, 8, 9]
```

**Heap Complexity**:

| Operation | Time Complexity |
|-----------|----------------|
| Insert | O(log n) |
| Extract Min/Max | O(log n) |
| Peek Min/Max | O(1) |
| Build Heap | O(n) |
| Heapsort | O(n log n) |
| Space | O(n) |

**Heap vs BST**:

| Feature | Heap | BST |
|---------|------|-----|
| Structure | Complete binary tree | Can be unbalanced |
| Order | Partial (heap property) | Full (left < root < right) |
| Find min/max | O(1) | O(h) |
| Search arbitrary | O(n) | O(h) |
| Insert | O(log n) | O(h) |
| Delete min/max | O(log n) | O(h) |
| Array representation | Yes (efficient) | No |

**When to use Heaps**:
- Need quick access to min/max only
- Implementing priority queues
- K largest/smallest problems
- Median maintenance
- Task scheduling
- Graph algorithms (Dijkstra's, Prim's)

### Balanced trees: AVL and Red-Black

**Balanced trees** are BSTs that automatically maintain a balanced structure to ensure O(log n) operations in the worst case.

**Why Balanced Trees?**

A regular BST can degenerate into a linked list:
```
Unbalanced (worst case: O(n)):
1
 \
  2
   \
    3
     \
      4

Balanced (O(log n)):
    2
   / \
  1   3
       \
        4
```

**AVL Tree (Adelson-Velsky and Landis)**:

An **AVL tree** is a self-balancing BST where the height difference between left and right subtrees (balance factor) is at most 1 for every node.

**Balance Factor**: `height(left subtree) - height(right subtree)`
- Must be in {-1, 0, 1}
- If |BF| > 1, rebalancing needed

**Example AVL Tree**:
```
      8 (BF=0)
     / \
    4   10 (BF=0)
   / \    \
  2   6   12
 BF  BF   BF
 0   0    0
```

**AVL Rotations**:

When balance factor violates AVL property, perform rotations:

**1. Right Rotation (LL case)**:
```
    y (BF=2)              x
   /                     / \
  x         →           z   y
 /
z

Code:
def right_rotate(y):
    x = y.left
    T = x.right

    x.right = y
    y.left = T

    # Update heights
    y.height = 1 + max(height(y.left), height(y.right))
    x.height = 1 + max(height(x.left), height(x.right))

    return x  # New root
```

**2. Left Rotation (RR case)**:
```
  x (BF=-2)                y
   \                      / \
    y         →          x   z
     \
      z

Code:
def left_rotate(x):
    y = x.right
    T = y.left

    y.left = x
    x.right = T

    # Update heights
    x.height = 1 + max(height(x.left), height(x.right))
    y.height = 1 + max(height(y.left), height(y.right))

    return y  # New root
```

**3. Left-Right Rotation (LR case)**:
```
    z (BF=2)              z                 y
   /                     /                 / \
  x          →          y        →        x   z
   \                   /
    y                 x

Solution: Left rotate x, then right rotate z
```

**4. Right-Left Rotation (RL case)**:
```
  x (BF=-2)            x                  y
   \                    \                / \
    z        →           y      →       x   z
   /                      \
  y                        z

Solution: Right rotate z, then left rotate x
```

**AVL Tree Implementation**:
```python
class AVLNode:
    def __init__(self, value):
        self.value = value
        self.left = None
        self.right = None
        self.height = 1

class AVLTree:
    def height(self, node):
        return node.height if node else 0

    def balance_factor(self, node):
        if not node:
            return 0
        return self.height(node.left) - self.height(node.right)

    def update_height(self, node):
        if node:
            node.height = 1 + max(self.height(node.left), self.height(node.right))

    def right_rotate(self, y):
        x = y.left
        T = x.right

        x.right = y
        y.left = T

        self.update_height(y)
        self.update_height(x)

        return x

    def left_rotate(self, x):
        y = x.right
        T = y.left

        y.left = x
        x.right = T

        self.update_height(x)
        self.update_height(y)

        return y

    def insert(self, root, value):
        # Standard BST insertion
        if not root:
            return AVLNode(value)

        if value < root.value:
            root.left = self.insert(root.left, value)
        elif value > root.value:
            root.right = self.insert(root.right, value)
        else:
            return root  # Duplicates not allowed

        # Update height
        self.update_height(root)

        # Get balance factor
        balance = self.balance_factor(root)

        # Rebalance if needed
        # Left-Left case
        if balance > 1 and value < root.left.value:
            return self.right_rotate(root)

        # Right-Right case
        if balance < -1 and value > root.right.value:
            return self.left_rotate(root)

        # Left-Right case
        if balance > 1 and value > root.left.value:
            root.left = self.left_rotate(root.left)
            return self.right_rotate(root)

        # Right-Left case
        if balance < -1 and value < root.right.value:
            root.right = self.right_rotate(root.right)
            return self.left_rotate(root)

        return root

# Usage:
avl = AVLTree()
root = None
values = [10, 20, 30, 40, 50, 25]
for val in values:
    root = avl.insert(root, val)
# Tree remains balanced after each insertion
```

**Red-Black Tree**:

A **Red-Black tree** is a self-balancing BST where each node has a color (red or black) with specific properties that ensure balance.

**Properties**:
1. Every node is either red or black
2. Root is always black
3. All leaves (NIL) are black
4. Red nodes cannot have red children (no two red nodes in a row)
5. Every path from root to leaf has the same number of black nodes (black-height)

**Example Red-Black Tree**:
```
      B:8
     /   \
   R:4   R:12
   / \   /  \
 B:2 B:6 B:10 B:14

B = Black, R = Red
```

**Red-Black Tree Operations**:

**Insertion** - O(log n):
1. Insert as in regular BST (node starts as red)
2. Fix violations:
   - Recolor nodes
   - Perform rotations if needed

**Recoloring and Rotation Cases**:
```python
class RBNode:
    def __init__(self, value):
        self.value = value
        self.left = None
        self.right = None
        self.parent = None
        self.color = "RED"  # New nodes are red

class RBTree:
    def __init__(self):
        self.NIL = RBNode(None)
        self.NIL.color = "BLACK"
        self.root = self.NIL

    def left_rotate(self, x):
        y = x.right
        x.right = y.left

        if y.left != self.NIL:
            y.left.parent = x

        y.parent = x.parent

        if x.parent is None:
            self.root = y
        elif x == x.parent.left:
            x.parent.left = y
        else:
            x.parent.right = y

        y.left = x
        x.parent = y

    def right_rotate(self, y):
        x = y.left
        y.left = x.right

        if x.right != self.NIL:
            x.right.parent = y

        x.parent = y.parent

        if y.parent is None:
            self.root = x
        elif y == y.parent.right:
            y.parent.right = x
        else:
            y.parent.left = x

        x.right = y
        y.parent = x

    def insert(self, value):
        # BST insertion
        node = RBNode(value)
        node.left = self.NIL
        node.right = self.NIL

        parent = None
        current = self.root

        while current != self.NIL:
            parent = current
            if node.value < current.value:
                current = current.left
            else:
                current = current.right

        node.parent = parent

        if parent is None:
            self.root = node
        elif node.value < parent.value:
            parent.left = node
        else:
            parent.right = node

        # Fix Red-Black properties
        self.fix_insert(node)

    def fix_insert(self, node):
        while node.parent and node.parent.color == "RED":
            if node.parent == node.parent.parent.left:
                uncle = node.parent.parent.right

                if uncle.color == "RED":
                    # Case 1: Uncle is red - recolor
                    node.parent.color = "BLACK"
                    uncle.color = "BLACK"
                    node.parent.parent.color = "RED"
                    node = node.parent.parent
                else:
                    if node == node.parent.right:
                        # Case 2: Node is right child - left rotate
                        node = node.parent
                        self.left_rotate(node)

                    # Case 3: Node is left child - right rotate and recolor
                    node.parent.color = "BLACK"
                    node.parent.parent.color = "RED"
                    self.right_rotate(node.parent.parent)
            else:
                # Mirror cases
                uncle = node.parent.parent.left

                if uncle.color == "RED":
                    node.parent.color = "BLACK"
                    uncle.color = "BLACK"
                    node.parent.parent.color = "RED"
                    node = node.parent.parent
                else:
                    if node == node.parent.left:
                        node = node.parent
                        self.right_rotate(node)

                    node.parent.color = "BLACK"
                    node.parent.parent.color = "RED"
                    self.left_rotate(node.parent.parent)

        self.root.color = "BLACK"  # Root is always black

# Usage:
rb_tree = RBTree()
values = [10, 20, 30, 40, 50, 25]
for val in values:
    rb_tree.insert(val)
```

**AVL vs Red-Black Comparison**:

| Feature | AVL Tree | Red-Black Tree |
|---------|----------|----------------|
| Balance | Strictly balanced | Loosely balanced |
| Height | ≤ 1.44 log n | ≤ 2 log n |
| Rotations on insert | Up to 2 | Up to 2 |
| Rotations on delete | O(log n) | Up to 3 |
| Search | Faster | Slightly slower |
| Insert/Delete | Slower (more rotations) | Faster |
| Use case | Search-heavy | Insert/delete-heavy |
| Memory | Less (only height) | More (color bit) |

**Practical Usage**:
- **AVL**: Database indexing, lookup-intensive applications
- **Red-Black**: Java TreeMap, C++ std::map, Linux kernel

**When to use Balanced Trees**:
- Need guaranteed O(log n) operations
- Can't tolerate worst-case O(n) of regular BST
- Frequent insertions/deletions (Red-Black)
- Mostly searches (AVL)
- Implementing ordered maps/sets

**Complexity Summary**:

| Operation | BST (worst) | AVL | Red-Black |
|-----------|-------------|-----|-----------|
| Search | O(n) | O(log n) | O(log n) |
| Insert | O(n) | O(log n) | O(log n) |
| Delete | O(n) | O(log n) | O(log n) |
| Space | O(n) | O(n) | O(n) |

### Graph representations: list vs matrix

A **graph** G = (V, E) consists of:
- **V**: Set of vertices (nodes)
- **E**: Set of edges (connections between vertices)

**Graph Types**:
1. **Undirected**: Edges have no direction (Facebook friendships)
2. **Directed (Digraph)**: Edges have direction (Twitter follows)
3. **Weighted**: Edges have values (road distances)
4. **Unweighted**: Edges have no values (social connections)

**Two Main Representations**:

**1. Adjacency Matrix**:

A 2D array where `matrix[i][j] = 1` if edge exists from vertex i to j.

**Undirected Graph Example**:
```
Graph:    0---1
          |   |
          2---3

Matrix:
     0  1  2  3
  0 [0, 1, 1, 0]
  1 [1, 0, 0, 1]
  2 [1, 0, 0, 1]
  3 [0, 1, 1, 0]

Note: Symmetric for undirected graphs
```

**Directed Graph Example**:
```
Graph:    0→1
          ↑ ↓
          2←3

Matrix:
     0  1  2  3
  0 [0, 1, 0, 0]
  1 [0, 0, 0, 1]
  2 [1, 0, 0, 0]
  3 [0, 0, 1, 0]

Note: Not symmetric for directed graphs
```

**Weighted Graph**:
```
Graph:    0--5--1
          |     |
          3     2
          |     |
          2--4--3

Matrix (∞ for no edge):
     0  1  2  3
  0 [0, 5, 3, ∞]
  1 [5, 0, ∞, 2]
  2 [3, ∞, 0, 4]
  3 [∞, 2, 4, 0]
```

**Implementation**:
```python
class GraphMatrix:
    def __init__(self, num_vertices, directed=False):
        self.num_vertices = num_vertices
        self.directed = directed
        # Initialize matrix with zeros
        self.matrix = [[0] * num_vertices for _ in range(num_vertices)]

    def add_edge(self, u, v, weight=1):
        """Add edge from u to v"""
        if 0 <= u < self.num_vertices and 0 <= v < self.num_vertices:
            self.matrix[u][v] = weight
            if not self.directed:
                self.matrix[v][u] = weight  # For undirected

    def remove_edge(self, u, v):
        """Remove edge from u to v"""
        if 0 <= u < self.num_vertices and 0 <= v < self.num_vertices:
            self.matrix[u][v] = 0
            if not self.directed:
                self.matrix[v][u] = 0

    def has_edge(self, u, v):
        """Check if edge exists"""
        return self.matrix[u][v] != 0

    def get_neighbors(self, u):
        """Get all neighbors of u"""
        neighbors = []
        for v in range(self.num_vertices):
            if self.matrix[u][v] != 0:
                neighbors.append(v)
        return neighbors

    def print_graph(self):
        for row in self.matrix:
            print(row)

# Usage:
g = GraphMatrix(4, directed=False)
g.add_edge(0, 1)
g.add_edge(0, 2)
g.add_edge(1, 3)
g.add_edge(2, 3)
g.print_graph()
```

**2. Adjacency List**:

An array of lists where `list[i]` contains all vertices adjacent to vertex i.

**Undirected Graph Example**:
```
Graph:    0---1
          |   |
          2---3

List:
0 → [1, 2]
1 → [0, 3]
2 → [0, 3]
3 → [1, 2]
```

**Directed Graph Example**:
```
Graph:    0→1
          ↑ ↓
          2←3

List:
0 → [1]
1 → [3]
2 → [0]
3 → [2]
```

**Weighted Graph**:
```
Graph:    0--5--1
          |     |
          3     2
          |     |
          2--4--3

List (vertex, weight):
0 → [(1, 5), (2, 3)]
1 → [(0, 5), (3, 2)]
2 → [(0, 3), (3, 4)]
3 → [(1, 2), (2, 4)]
```

**Implementation**:
```python
from collections import defaultdict

class GraphList:
    def __init__(self, directed=False):
        self.graph = defaultdict(list)
        self.directed = directed

    def add_edge(self, u, v, weight=None):
        """Add edge from u to v"""
        if weight is not None:
            self.graph[u].append((v, weight))
            if not self.directed:
                self.graph[v].append((u, weight))
        else:
            self.graph[u].append(v)
            if not self.directed:
                self.graph[v].append(u)

    def remove_edge(self, u, v):
        """Remove edge from u to v"""
        if v in self.graph[u]:
            self.graph[u].remove(v)
        if not self.directed and u in self.graph[v]:
            self.graph[v].remove(u)

    def has_edge(self, u, v):
        """Check if edge exists"""
        return v in self.graph[u]

    def get_neighbors(self, u):
        """Get all neighbors of u"""
        return self.graph[u]

    def get_vertices(self):
        """Get all vertices"""
        return list(self.graph.keys())

    def print_graph(self):
        for vertex in self.graph:
            print(f"{vertex} → {self.graph[vertex]}")

# Usage - Unweighted:
g = GraphList(directed=False)
g.add_edge(0, 1)
g.add_edge(0, 2)
g.add_edge(1, 3)
g.add_edge(2, 3)
g.print_graph()

# Usage - Weighted:
g_weighted = GraphList(directed=True)
g_weighted.add_edge(0, 1, weight=5)
g_weighted.add_edge(0, 2, weight=3)
g_weighted.add_edge(1, 3, weight=2)
g_weighted.print_graph()
```

**Comparison: Adjacency Matrix vs List**:

| Operation | Matrix | List |
|-----------|--------|------|
| Space | O(V²) | O(V + E) |
| Add edge | O(1) | O(1) |
| Remove edge | O(1) | O(V) |
| Check if edge exists | O(1) | O(V) |
| Find all neighbors | O(V) | O(degree) |
| Iterate all edges | O(V²) | O(V + E) |

**When to use Matrix**:
- Dense graphs (E ≈ V²)
- Need fast edge lookup (is there edge u→v?)
- Graph is small
- Implementing algorithms that check many edges (Floyd-Warshall)

**When to use List**:
- Sparse graphs (E << V²)
- Need to iterate over neighbors frequently
- Memory is a concern
- Most real-world graphs (social networks, web graphs)

**Space Comparison Example**:
```
Graph with 1000 vertices, 5000 edges:
- Matrix: 1000 × 1000 = 1,000,000 entries
- List: 1000 + 2×5000 = 11,000 entries (if undirected)
List is ~90x more space-efficient!
```

**Practical Usage**:
```python
# Dense graph (many edges) - use matrix
adj_matrix = [[0]*n for _ in range(n)]

# Sparse graph (few edges) - use list
adj_list = defaultdict(list)

# Most real-world scenarios: adjacency list
# Examples: social networks, web graphs, road networks
```

**Other Graph Representations** (less common):

**3. Edge List**:
```python
# Simple list of edges
edges = [(0, 1), (0, 2), (1, 3), (2, 3)]

# Weighted:
edges = [(0, 1, 5), (0, 2, 3), (1, 3, 2)]

# Good for: algorithms that process all edges (Kruskal's MST)
```

**4. Incidence Matrix**:
```python
# Rows = vertices, Columns = edges
# matrix[v][e] = 1 if vertex v is incident to edge e

# Rarely used, but useful for some theoretical proofs
```

### Graph traversals: BFS and DFS

**Graph traversal** is the process of visiting all vertices in a graph. Two fundamental approaches:

**1. Breadth-First Search (BFS)**:

Explore level by level: visit all neighbors before going deeper.

**Algorithm**:
1. Start at source vertex
2. Visit all unvisited neighbors
3. Then visit neighbors of those neighbors
4. Continue until all reachable vertices visited

**Uses Queue** (FIFO)

**Visual Example**:
```
Graph:    1 --- 2
          |  \  |
          |   \ |
          3 --- 4

BFS from 1:
Level 0: 1
Level 1: 2, 3, 4
Order: 1 → 2 → 3 → 4
```

**Implementation (Adjacency List)**:
```python
from collections import deque

def bfs(graph, start):
    """BFS traversal"""
    visited = set()
    queue = deque([start])
    visited.add(start)
    result = []

    while queue:
        vertex = queue.popleft()
        result.append(vertex)

        # Visit all unvisited neighbors
        for neighbor in graph[vertex]:
            if neighbor not in visited:
                visited.add(neighbor)
                queue.append(neighbor)

    return result

# Usage:
graph = {
    1: [2, 3, 4],
    2: [1, 4],
    3: [1, 4],
    4: [1, 2, 3]
}
print(bfs(graph, 1))  # [1, 2, 3, 4]
```

**BFS Level-by-Level**:
```python
def bfs_by_level(graph, start):
    """BFS with level tracking"""
    visited = set([start])
    queue = deque([(start, 0)])  # (vertex, level)
    levels = {}

    while queue:
        vertex, level = queue.popleft()
        levels[vertex] = level

        for neighbor in graph[vertex]:
            if neighbor not in visited:
                visited.add(neighbor)
                queue.append((neighbor, level + 1))

    return levels

# Returns: {1: 0, 2: 1, 3: 1, 4: 1}
```

**BFS Shortest Path** (unweighted):
```python
def bfs_shortest_path(graph, start, end):
    """Find shortest path using BFS"""
    if start == end:
        return [start]

    visited = set([start])
    queue = deque([(start, [start])])  # (vertex, path)

    while queue:
        vertex, path = queue.popleft()

        for neighbor in graph[vertex]:
            if neighbor not in visited:
                new_path = path + [neighbor]

                if neighbor == end:
                    return new_path

                visited.add(neighbor)
                queue.append((neighbor, new_path))

    return None  # No path found

# Usage:
path = bfs_shortest_path(graph, 1, 4)
print(path)  # [1, 4] (shortest path from 1 to 4)
```

**BFS Applications**:
- Find shortest path in unweighted graph
- Level-order processing
- Web crawling
- Social network analysis (degrees of separation)
- Broadcasting in networks
- GPS navigation (unweighted roads)

**2. Depth-First Search (DFS)**:

Explore as deep as possible before backtracking.

**Algorithm**:
1. Start at source vertex
2. Visit an unvisited neighbor
3. Recursively visit that neighbor's neighbors
4. Backtrack when no unvisited neighbors

**Uses Stack** (LIFO) - often via recursion

**Visual Example**:
```
Graph:    1 --- 2
          |  \  |
          |   \ |
          3 --- 4

DFS from 1:
Path: 1 → 2 → 4 → 3 (one possible order)
```

**Recursive Implementation**:
```python
def dfs_recursive(graph, start, visited=None):
    """DFS traversal (recursive)"""
    if visited is None:
        visited = set()

    visited.add(start)
    result = [start]

    for neighbor in graph[start]:
        if neighbor not in visited:
            result.extend(dfs_recursive(graph, neighbor, visited))

    return result

# Usage:
graph = {
    1: [2, 3, 4],
    2: [1, 4],
    3: [1, 4],
    4: [1, 2, 3]
}
print(dfs_recursive(graph, 1))  # [1, 2, 4, 3] (one possible order)
```

**Iterative Implementation** (explicit stack):
```python
def dfs_iterative(graph, start):
    """DFS traversal (iterative)"""
    visited = set()
    stack = [start]
    result = []

    while stack:
        vertex = stack.pop()

        if vertex not in visited:
            visited.add(vertex)
            result.append(vertex)

            # Add neighbors to stack (in reverse for consistent order)
            for neighbor in reversed(graph[vertex]):
                if neighbor not in visited:
                    stack.append(neighbor)

    return result

# Usage:
print(dfs_iterative(graph, 1))  # [1, 2, 4, 3]
```

**DFS with Path Tracking**:
```python
def dfs_all_paths(graph, start, end, path=None):
    """Find all paths from start to end"""
    if path is None:
        path = []

    path = path + [start]

    if start == end:
        return [path]

    paths = []
    for neighbor in graph[start]:
        if neighbor not in path:  # Avoid cycles
            new_paths = dfs_all_paths(graph, neighbor, end, path)
            paths.extend(new_paths)

    return paths

# Usage:
all_paths = dfs_all_paths(graph, 1, 4)
print(all_paths)  # [[1, 2, 4], [1, 4], [1, 3, 4]]
```

**DFS Cycle Detection**:
```python
def has_cycle_undirected(graph, start, visited=None, parent=None):
    """Detect cycle in undirected graph"""
    if visited is None:
        visited = set()

    visited.add(start)

    for neighbor in graph[start]:
        if neighbor not in visited:
            if has_cycle_undirected(graph, neighbor, visited, start):
                return True
        elif neighbor != parent:
            # Back edge found (not to parent) → cycle!
            return True

    return False

def has_cycle_directed(graph, vertex, visited, rec_stack):
    """Detect cycle in directed graph"""
    visited.add(vertex)
    rec_stack.add(vertex)

    for neighbor in graph[vertex]:
        if neighbor not in visited:
            if has_cycle_directed(graph, neighbor, visited, rec_stack):
                return True
        elif neighbor in rec_stack:
            # Back edge to ancestor → cycle!
            return True

    rec_stack.remove(vertex)
    return False
```

**DFS Applications**:
- Detect cycles
- Topological sorting
- Finding connected components
- Solving mazes and puzzles
- Backtracking problems
- Path finding (not necessarily shortest)

**BFS vs DFS Comparison**:

| Feature | BFS | DFS |
|---------|-----|-----|
| Data Structure | Queue | Stack/Recursion |
| Memory | O(V) - wider | O(h) - deeper |
| Shortest Path | ✅ Yes (unweighted) | ❌ No |
| Completeness | ✅ Yes | ✅ Yes (if checks visited) |
| Time | O(V + E) | O(V + E) |
| Use Case | Shortest path, level-order | Cycle detection, topological sort |

**Complete Graph Traversal**:

If graph has multiple connected components:

```python
def dfs_all_components(graph):
    """Visit all vertices in all components"""
    visited = set()
    components = []

    for vertex in graph:
        if vertex not in visited:
            component = []
            dfs_component(graph, vertex, visited, component)
            components.append(component)

    return components

def dfs_component(graph, vertex, visited, component):
    visited.add(vertex)
    component.append(vertex)

    for neighbor in graph[vertex]:
        if neighbor not in visited:
            dfs_component(graph, neighbor, visited, component)

# Example: graph with 2 components
graph = {
    1: [2], 2: [1],  # Component 1
    3: [4], 4: [3]   # Component 2
}
components = dfs_all_components(graph)
print(components)  # [[1, 2], [3, 4]]
```

**Practical Example: Social Network**:
```python
class SocialNetwork:
    def __init__(self):
        self.graph = defaultdict(list)

    def add_friendship(self, person1, person2):
        self.graph[person1].append(person2)
        self.graph[person2].append(person1)

    def degrees_of_separation(self, person1, person2):
        """Find shortest connection between two people (BFS)"""
        if person1 == person2:
            return 0

        visited = set([person1])
        queue = deque([(person1, 0)])

        while queue:
            person, distance = queue.popleft()

            for friend in self.graph[person]:
                if friend == person2:
                    return distance + 1

                if friend not in visited:
                    visited.add(friend)
                    queue.append((friend, distance + 1))

        return -1  # Not connected

    def find_all_friends_at_distance(self, person, distance):
        """Find all friends at exactly 'distance' hops away"""
        visited = set([person])
        queue = deque([(person, 0)])
        result = []

        while queue:
            current, dist = queue.popleft()

            if dist == distance:
                result.append(current)
                continue

            if dist < distance:
                for friend in self.graph[current]:
                    if friend not in visited:
                        visited.add(friend)
                        queue.append((friend, dist + 1))

        return result

# Usage:
network = SocialNetwork()
network.add_friendship("Alice", "Bob")
network.add_friendship("Bob", "Charlie")
network.add_friendship("Charlie", "David")

print(network.degrees_of_separation("Alice", "David"))  # 3
print(network.find_all_friends_at_distance("Alice", 2))  # ["Charlie"]
```

**Summary**:
- **BFS**: Use for shortest path, level-order, minimum hops
- **DFS**: Use for cycle detection, topological sort, exploring all paths
- Both: O(V + E) time, essential for graph algorithms

### Applications and modeling

Non-linear data structures (trees and graphs) model countless real-world systems and solve diverse problems.

**Tree Applications**:

**1. File Systems**:
```python
class FileNode:
    def __init__(self, name, is_file=False):
        self.name = name
        self.is_file = is_file
        self.children = [] if not is_file else None
        self.size = 0 if is_file else None

    def add_child(self, child):
        if not self.is_file:
            self.children.append(child)

    def calculate_size(self):
        """Calculate total size of directory tree"""
        if self.is_file:
            return self.size

        total = 0
        for child in self.children:
            total += child.calculate_size()
        return total

# Example:
root = FileNode("root")
docs = FileNode("Documents")
file1 = FileNode("report.pdf", is_file=True)
file1.size = 1024
docs.add_child(file1)
root.add_child(docs)

print(f"Total size: {root.calculate_size()} KB")
```

**2. HTML DOM**:
```
HTML Tree:
    html
     ├── head
     │   └── title
     └── body
         ├── h1
         ├── p
         └── div
             └── img

Each tag is a node in a tree structure
```

**3. Database Indexes** (B-Trees):
```
Used in:
- MySQL, PostgreSQL (B+ trees)
- Fast range queries
- Sorted traversal
- O(log n) search/insert/delete
```

**4. Decision Trees** (ML):
```
       Age > 30?
        /     \
      Yes      No
      /          \
 Approved    Income > 50k?
               /        \
             Yes         No
              |           |
          Approved    Rejected

Used for classification and regression
```

**5. Abstract Syntax Trees** (Compilers):
```python
"""
Expression: (3 + 5) * 2

AST:      *
         / \
        +   2
       / \
      3   5
"""

def evaluate_ast(node):
    if node.is_operand:
        return node.value

    left = evaluate_ast(node.left)
    right = evaluate_ast(node.right)

    if node.operator == '+':
        return left + right
    elif node.operator == '*':
        return left * right
```

**6. Huffman Coding** (Compression):
```python
"""
Build optimal prefix-free code tree
Characters with higher frequency get shorter codes
"""
import heapq

def huffman_encoding(text):
    # Build frequency table
    freq = {}
    for char in text:
        freq[char] = freq.get(char, 0) + 1

    # Build heap of (frequency, node)
    heap = [[weight, [char, ""]] for char, weight in freq.items()]
    heapq.heapify(heap)

    # Build Huffman tree
    while len(heap) > 1:
        lo = heapq.heappop(heap)
        hi = heapq.heappop(heap)

        for pair in lo[1:]:
            pair[1] = '0' + pair[1]
        for pair in hi[1:]:
            pair[1] = '1' + pair[1]

        heapq.heappush(heap, [lo[0] + hi[0]] + lo[1:] + hi[1:])

    return dict(heapq.heappop(heap)[1:])

# Usage:
codes = huffman_encoding("hello world")
print(codes)  # {'h': '000', 'e': '001', 'l': '01', ...}
```

**Graph Applications**:

**1. Social Networks**:
```python
"""
- Vertices: Users
- Edges: Friendships, Follows
"""

class SocialGraph:
    def __init__(self):
        self.graph = defaultdict(list)

    def add_follow(self, follower, followee):
        self.graph[follower].append(followee)

    def mutual_friends(self, user1, user2):
        """Find common connections"""
        friends1 = set(self.graph[user1])
        friends2 = set(self.graph[user2])
        return friends1 & friends2

    def suggest_friends(self, user):
        """Friend suggestions (friends of friends)"""
        suggestions = set()
        friends = set(self.graph[user])

        for friend in friends:
            for friend_of_friend in self.graph[friend]:
                if friend_of_friend != user and friend_of_friend not in friends:
                    suggestions.add(friend_of_friend)

        return suggestions
```

**2. Web Page Ranking** (PageRank):
```
- Vertices: Web pages
- Edges: Hyperlinks
- PageRank: Importance based on incoming links

Used by Google's original algorithm
```

**3. Maps and Navigation**:
```python
"""
- Vertices: Locations/Intersections
- Edges: Roads
- Weights: Distances, travel times
"""

class MapGraph:
    def __init__(self):
        self.graph = defaultdict(list)

    def add_road(self, loc1, loc2, distance):
        self.graph[loc1].append((loc2, distance))
        self.graph[loc2].append((loc1, distance))

    def dijkstra_shortest_path(self, start, end):
        """Find shortest path using Dijkstra's algorithm"""
        distances = {start: 0}
        pq = [(0, start)]
        visited = set()
        parent = {}

        while pq:
            curr_dist, curr = heapq.heappop(pq)

            if curr in visited:
                continue

            visited.add(curr)

            if curr == end:
                # Reconstruct path
                path = []
                while curr in parent:
                    path.append(curr)
                    curr = parent[curr]
                path.append(start)
                return path[::-1], distances[end]

            for neighbor, weight in self.graph[curr]:
                distance = curr_dist + weight

                if neighbor not in visited and (neighbor not in distances or distance < distances[neighbor]):
                    distances[neighbor] = distance
                    parent[neighbor] = curr
                    heapq.heappush(pq, (distance, neighbor))

        return None, float('inf')  # No path found

# Usage:
map_graph = MapGraph()
map_graph.add_road("A", "B", 5)
map_graph.add_road("A", "C", 3)
map_graph.add_road("B", "D", 2)
map_graph.add_road("C", "D", 4)
path, distance = map_graph.dijkstra_shortest_path("A", "D")
print(f"Path: {path}, Distance: {distance}")
```

**4. Course Prerequisites**:
```python
"""
- Vertices: Courses
- Edges: Prerequisites (directed)
- Topological sort: Valid course order
"""

def topological_sort(graph):
    """Find valid course order (DFS-based)"""
    visited = set()
    stack = []

    def dfs(course):
        visited.add(course)
        for prereq in graph[course]:
            if prereq not in visited:
                dfs(prereq)
        stack.append(course)

    for course in graph:
        if course not in visited:
            dfs(course)

    return stack[::-1]

# Example:
courses = {
    "CS101": [],
    "CS102": ["CS101"],
    "CS201": ["CS102"],
    "CS202": ["CS102"],
    "CS301": ["CS201", "CS202"]
}
order = topological_sort(courses)
print(order)  # Valid course order
```

**5. Network Flow**:
```
- Vertices: Routers, servers
- Edges: Network connections
- Weights: Bandwidth, capacity

Applications:
- Internet routing
- Traffic simulation
- Supply chain optimization
```

**6. Dependency Resolution** (Package Managers):
```python
"""
- Vertices: Software packages
- Edges: Dependencies
- Problem: Find installation order
"""

def resolve_dependencies(packages):
    """Resolve package dependencies (topological sort)"""
    # Build graph of dependencies
    graph = defaultdict(list)
    in_degree = defaultdict(int)

    for pkg, deps in packages.items():
        for dep in deps:
            graph[dep].append(pkg)
            in_degree[pkg] += 1
        if pkg not in in_degree:
            in_degree[pkg] = 0

    # Kahn's algorithm (BFS-based topological sort)
    queue = deque([pkg for pkg in in_degree if in_degree[pkg] == 0])
    order = []

    while queue:
        pkg = queue.popleft()
        order.append(pkg)

        for dependent in graph[pkg]:
            in_degree[dependent] -= 1
            if in_degree[dependent] == 0:
                queue.append(dependent)

    if len(order) != len(packages):
        return None  # Cycle detected - circular dependency!

    return order

# Usage:
packages = {
    "app": ["lib-a", "lib-b"],
    "lib-a": ["lib-c"],
    "lib-b": ["lib-c"],
    "lib-c": []
}
install_order = resolve_dependencies(packages)
print(install_order)  # ["lib-c", "lib-a", "lib-b", "app"]
```

**7. Recommendation Systems**:
```python
"""
- Bipartite graph: Users and Items
- Edges: Interactions (purchases, views, ratings)
"""

def recommend_items(user, user_item_graph, user_user_graph):
    """Recommend items based on similar users"""
    similar_users = user_user_graph[user]
    recommendations = set()

    for similar_user in similar_users:
        for item in user_item_graph[similar_user]:
            if item not in user_item_graph[user]:
                recommendations.add(item)

    return recommendations
```

**8. Circuit Design**:
```
- Vertices: Components
- Edges: Wires
- Applications: Layout optimization, signal routing
```

**Problem Modeling Checklist**:

**Use Trees When**:
- ✅ Hierarchical relationships
- ✅ One path between any two nodes
- ✅ Clear parent-child structure
- Examples: File systems, DOM, organizational charts

**Use Graphs When**:
- ✅ Many-to-many relationships
- ✅ Multiple paths between nodes
- ✅ Network-like structure
- Examples: Social networks, maps, dependencies

**Complexity Summary**:

| Problem Type | Structure | Key Algorithm |
|-------------|-----------|---------------|
| File system | Tree | Tree traversal |
| Shortest path | Graph | BFS/Dijkstra |
| Task scheduling | DAG | Topological sort |
| Social network | Graph | BFS/DFS |
| Compression | Tree | Huffman coding |
| Syntax parsing | Tree | Tree traversal |
| Network routing | Graph | Shortest path |

**Key Takeaway**: Most real-world systems are naturally represented as non-linear structures. Understanding trees and graphs is essential for modeling and solving complex problems efficiently.
