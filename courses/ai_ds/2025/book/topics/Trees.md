---
layout: splash
author_profile: false
---

# Trees

Hierarchical structures with parent-child relationships.


### 1. Binary trees and properties
Understanding the fundamental tree structure:

#### **Definition**:
- **Tree**: Hierarchical data structure with nodes connected by edges
- **Binary Tree**: Each node has at most two children (left and right)
- **Root**: Top node with no parent
- **Leaf**: Node with no children
- **Height**: Longest path from root to leaf
- **Depth**: Distance from root to node

**Node structure**:
```python
class TreeNode:
    def __init__(self, val=0):
        self.val = val
        self.left = None
        self.right = None
```

#### **Types of binary trees**:

**1. Full Binary Tree**:
- Every node has 0 or 2 children
```
       1
      / \
     2   3
    / \
   4   5
```

**2. Complete Binary Tree**:
- All levels filled except possibly last, which is filled left to right
```
       1
      / \
     2   3
    / \  /
   4  5 6
```

**3. Perfect Binary Tree**:
- All internal nodes have 2 children, all leaves at same level
```
       1
      / \
     2   3
    / \ / \
   4  5 6  7
```

**4. Balanced Binary Tree**:
- Height difference between left and right subtrees ≤ 1 for all nodes
```
       1
      / \
     2   3
    /
   4
Height difference: |2 - 1| = 1 ✓
```

**5. Degenerate (Skewed) Tree**:
- Each node has only one child (essentially a linked list)
```
1
 \
  2
   \
    3
     \
      4
```

#### **Properties**:
```python
# Maximum nodes at level i: 2^i
# Maximum nodes in tree of height h: 2^(h+1) - 1
# Minimum height for n nodes: log₂(n+1) - 1

def max_nodes_at_level(level):
    return 2 ** level

def max_nodes_in_tree(height):
    return 2 ** (height + 1) - 1

def min_height(n):
    import math
    return math.ceil(math.log2(n + 1)) - 1

# Example: n=7 nodes
# Min height = 2 (perfect tree)
# Max height = 6 (skewed tree)
```

#### **Basic operations**:
```python
def height(node):
    """Calculate height of tree"""
    if not node:
        return -1
    return 1 + max(height(node.left), height(node.right))

def size(node):
    """Count total nodes"""
    if not node:
        return 0
    return 1 + size(node.left) + size(node.right)

def is_balanced(node):
    """Check if tree is balanced"""
    if not node:
        return True
    
    left_height = height(node.left)
    right_height = height(node.right)
    
    if abs(left_height - right_height) > 1:
        return False
    
    return is_balanced(node.left) and is_balanced(node.right)
```

### 2. Binary Search Trees (BSTs)
Ordered binary trees for efficient searching:

#### **BST Property**:
- **Left subtree**: All values < node value
- **Right subtree**: All values > node value
- **Recursive**: Property holds for all subtrees

**Example**:
```
       8
      / \
     3   10
    / \    \
   1   6   14
      / \  /
     4  7 13
```

#### **Operations**:

**Search**:
```python
def search(root, target):
    """Search for value in BST - O(h)"""
    if not root or root.val == target:
        return root
    
    if target < root.val:
        return search(root.left, target)
    else:
        return search(root.right, target)

# Iterative version
def search_iterative(root, target):
    while root and root.val != target:
        if target < root.val:
            root = root.left
        else:
            root = root.right
    return root
```

**Insert**:
```python
def insert(root, val):
    """Insert value into BST - O(h)"""
    if not root:
        return TreeNode(val)
    
    if val < root.val:
        root.left = insert(root.left, val)
    else:
        root.right = insert(root.right, val)
    
    return root
```

**Delete**:
```python
def delete(root, val):
    """Delete value from BST - O(h)"""
    if not root:
        return None
    
    if val < root.val:
        root.left = delete(root.left, val)
    elif val > root.val:
        root.right = delete(root.right, val)
    else:
        # Node to delete found
        
        # Case 1: No children (leaf)
        if not root.left and not root.right:
            return None
        
        # Case 2: One child
        if not root.left:
            return root.right
        if not root.right:
            return root.left
        
        # Case 3: Two children
        # Find inorder successor (smallest in right subtree)
        successor = find_min(root.right)
        root.val = successor.val
        root.right = delete(root.right, successor.val)
    
    return root

def find_min(node):
    """Find minimum value node"""
    while node.left:
        node = node.left
    return node
```

**Find min/max**:
```python
def find_minimum(root):
    """Find minimum value - O(h)"""
    if not root:
        return None
    while root.left:
        root = root.left
    return root.val

def find_maximum(root):
    """Find maximum value - O(h)"""
    if not root:
        return None
    while root.right:
        root = root.right
    return root.val
```

**Validate BST**:
```python
def is_valid_bst(root, min_val=float('-inf'), max_val=float('inf')):
    """Check if tree is valid BST"""
    if not root:
        return True
    
    if root.val <= min_val or root.val >= max_val:
        return False
    
    return (is_valid_bst(root.left, min_val, root.val) and
            is_valid_bst(root.right, root.val, max_val))
```

### 3. Traversals: inorder, preorder, postorder
Different ways to visit all nodes:

#### **Inorder (Left-Root-Right)**:
- **Result**: Sorted order for BST
- **Use**: Get sorted elements, validate BST

```python
def inorder(root):
    """Inorder traversal - recursive"""
    if not root:
        return []
    
    result = []
    result.extend(inorder(root.left))
    result.append(root.val)
    result.extend(inorder(root.right))
    return result

# Iterative with stack
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
        result.append(current.val)
        
        # Go to right subtree
        current = current.right
    
    return result
```

**Example**:
```
Tree:    4
        / \
       2   6
      / \ / \
     1  3 5  7

Inorder: [1, 2, 3, 4, 5, 6, 7]
```

#### **Preorder (Root-Left-Right)**:
- **Result**: Root before children
- **Use**: Copy tree, prefix expressions

```python
def preorder(root):
    """Preorder traversal - recursive"""
    if not root:
        return []
    
    result = [root.val]
    result.extend(preorder(root.left))
    result.extend(preorder(root.right))
    return result

# Iterative
def preorder_iterative(root):
    if not root:
        return []
    
    result = []
    stack = [root]
    
    while stack:
        node = stack.pop()
        result.append(node.val)
        
        # Push right first (so left is processed first)
        if node.right:
            stack.append(node.right)
        if node.left:
            stack.append(node.left)
    
    return result
```

**Example**:
```
Tree:    4
        / \
       2   6
      / \ / \
     1  3 5  7

Preorder: [4, 2, 1, 3, 6, 5, 7]
```

#### **Postorder (Left-Right-Root)**:
- **Result**: Children before root
- **Use**: Delete tree, postfix expressions

```python
def postorder(root):
    """Postorder traversal - recursive"""
    if not root:
        return []
    
    result = []
    result.extend(postorder(root.left))
    result.extend(postorder(root.right))
    result.append(root.val)
    return result

# Iterative (two stacks)
def postorder_iterative(root):
    if not root:
        return []
    
    stack1 = [root]
    stack2 = []
    
    while stack1:
        node = stack1.pop()
        stack2.append(node)
        
        if node.left:
            stack1.append(node.left)
        if node.right:
            stack1.append(node.right)
    
    result = []
    while stack2:
        result.append(stack2.pop().val)
    
    return result
```

**Example**:
```
Tree:    4
        / \
       2   6
      / \ / \
     1  3 5  7

Postorder: [1, 3, 2, 5, 7, 6, 4]
```

#### **Level-order (BFS)**:
- **Result**: Level by level
- **Use**: Find level, shortest path

```python
from collections import deque

def level_order(root):
    """Level-order traversal (BFS)"""
    if not root:
        return []
    
    result = []
    queue = deque([root])
    
    while queue:
        node = queue.popleft()
        result.append(node.val)
        
        if node.left:
            queue.append(node.left)
        if node.right:
            queue.append(node.right)
    
    return result

# By levels
def level_order_by_levels(root):
    """Return list of lists, one per level"""
    if not root:
        return []
    
    result = []
    queue = deque([root])
    
    while queue:
        level_size = len(queue)
        level = []
        
        for _ in range(level_size):
            node = queue.popleft()
            level.append(node.val)
            
            if node.left:
                queue.append(node.left)
            if node.right:
                queue.append(node.right)
        
        result.append(level)
    
    return result
```

**Example**:
```
Tree:    4
        / \
       2   6
      / \ / \
     1  3 5  7

Level-order: [4, 2, 6, 1, 3, 5, 7]
By levels: [[4], [2, 6], [1, 3, 5, 7]]
```

### 4. Heaps: structure and heap operations
Binary trees with heap property:

#### **Heap Property**:
- **Max Heap**: Parent ≥ children
- **Min Heap**: Parent ≤ children
- **Complete Binary Tree**: All levels filled except last

**Array representation**:
```python
# For node at index i:
# Left child: 2*i + 1
# Right child: 2*i + 2
# Parent: (i - 1) // 2

class MinHeap:
    def __init__(self):
        self.heap = []
    
    def parent(self, i):
        return (i - 1) // 2
    
    def left_child(self, i):
        return 2 * i + 1
    
    def right_child(self, i):
        return 2 * i + 2
```

**Heapify operations**:
```python
def heapify_up(self, i):
    """Bubble up element at index i"""
    while i > 0:
        parent_idx = self.parent(i)
        if self.heap[i] < self.heap[parent_idx]:
            self.heap[i], self.heap[parent_idx] = \
                self.heap[parent_idx], self.heap[i]
            i = parent_idx
        else:
            break

def heapify_down(self, i):
    """Bubble down element at index i"""
    n = len(self.heap)
    
    while True:
        smallest = i
        left = self.left_child(i)
        right = self.right_child(i)
        
        if left < n and self.heap[left] < self.heap[smallest]:
            smallest = left
        
        if right < n and self.heap[right] < self.heap[smallest]:
            smallest = right
        
        if smallest != i:
            self.heap[i], self.heap[smallest] = \
                self.heap[smallest], self.heap[i]
            i = smallest
        else:
            break
```

**Heap operations**:
```python
def insert(self, val):
    """Insert value - O(log n)"""
    self.heap.append(val)
    self.heapify_up(len(self.heap) - 1)

def extract_min(self):
    """Remove and return minimum - O(log n)"""
    if not self.heap:
        return None
    
    if len(self.heap) == 1:
        return self.heap.pop()
    
    min_val = self.heap[0]
    self.heap[0] = self.heap.pop()
    self.heapify_down(0)
    
    return min_val

def peek(self):
    """Get minimum without removing - O(1)"""
    return self.heap[0] if self.heap else None

def build_heap(self, arr):
    """Build heap from array - O(n)"""
    self.heap = arr[:]
    # Start from last non-leaf node
    for i in range(len(self.heap) // 2 - 1, -1, -1):
        self.heapify_down(i)
```

**Using Python's heapq**:
```python
import heapq

# Min heap
heap = []
heapq.heappush(heap, 3)
heapq.heappush(heap, 1)
heapq.heappush(heap, 4)

min_val = heapq.heappop(heap)  # Returns 1

# Build heap from list
arr = [3, 1, 4, 1, 5, 9, 2, 6]
heapq.heapify(arr)  # O(n)

# Max heap (negate values)
max_heap = []
heapq.heappush(max_heap, -3)
heapq.heappush(max_heap, -1)
max_val = -heapq.heappop(max_heap)  # Returns 3
```

### 5. Balanced trees: AVL, Red-Black
Self-balancing BSTs for guaranteed O(log n) operations:

#### **AVL Trees**:
- **Balance Factor**: height(left) - height(right) ∈ {-1, 0, 1}
- **Rebalancing**: Rotations after insert/delete
- **Stricter**: More balanced than Red-Black

**Rotations**:
```python
class AVLNode:
    def __init__(self, val):
        self.val = val
        self.left = None
        self.right = None
        self.height = 1

def get_height(node):
    return node.height if node else 0

def get_balance(node):
    return get_height(node.left) - get_height(node.right) if node else 0

def update_height(node):
    node.height = 1 + max(get_height(node.left), get_height(node.right))

# Right rotation
def rotate_right(y):
    """
        y                x
       / \              / \
      x   C    -->     A   y
     / \                  / \
    A   B                B   C
    """
    x = y.left
    B = x.right
    
    x.right = y
    y.left = B
    
    update_height(y)
    update_height(x)
    
    return x

# Left rotation
def rotate_left(x):
    """
      x                  y
     / \                / \
    A   y      -->     x   C
       / \            / \
      B   C          A   B
    """
    y = x.right
    B = y.left
    
    y.left = x
    x.right = B
    
    update_height(x)
    update_height(y)
    
    return y
```

**AVL Insert**:
```python
def avl_insert(root, val):
    """Insert with rebalancing"""
    # Standard BST insert
    if not root:
        return AVLNode(val)
    
    if val < root.val:
        root.left = avl_insert(root.left, val)
    else:
        root.right = avl_insert(root.right, val)
    
    # Update height
    update_height(root)
    
    # Get balance factor
    balance = get_balance(root)
    
    # Left-Left case
    if balance > 1 and val < root.left.val:
        return rotate_right(root)
    
    # Right-Right case
    if balance < -1 and val > root.right.val:
        return rotate_left(root)
    
    # Left-Right case
    if balance > 1 and val > root.left.val:
        root.left = rotate_left(root.left)
        return rotate_right(root)
    
    # Right-Left case
    if balance < -1 and val < root.right.val:
        root.right = rotate_right(root.right)
        return rotate_left(root)
    
    return root
```

#### **Red-Black Trees**:
- **Properties**:
  1. Every node is red or black
  2. Root is black
  3. Leaves (NULL) are black
  4. Red node has black children
  5. All paths from node to leaves have same number of black nodes

**Advantages over AVL**:
- Fewer rotations on insert/delete
- Faster for frequent modifications
- Used in many standard libraries (C++ std::map, Java TreeMap)

#### **Comparison**:

| Feature | AVL | Red-Black |
|---------|-----|-----------|
| Balance | Stricter | Looser |
| Height | ≤ 1.44 log n | ≤ 2 log n |
| Rotations (insert) | ≤ 2 | ≤ 2 |
| Rotations (delete) | O(log n) | ≤ 3 |
| Search | Faster | Slightly slower |
| Insert/Delete | Slower | Faster |
| Use case | Read-heavy | Write-heavy |

### 6. Use cases: indexes, parsers, hierarchies
Real-world applications of trees:

#### **Database Indexes**:
```python
# B-Tree index for database
class BTreeIndex:
    """
    Used in: MySQL, PostgreSQL, SQLite
    Why: Optimized for disk I/O, high fanout
    """
    def search(self, key):
        # O(log n) disk reads
        pass
    
    def range_query(self, start, end):
        # Efficient range scans
        pass
```

#### **Expression Parsing**:
```python
# Parse arithmetic expression into tree
def parse_expression(expr):
    """
    Expression: 3 + 4 * 2
    Tree:
           +
          / \
         3   *
            / \
           4   2
    """
    pass

def evaluate(root):
    """Evaluate expression tree"""
    if not root:
        return 0
    
    # Leaf node (operand)
    if not root.left and not root.right:
        return root.val
    
    # Evaluate subtrees
    left_val = evaluate(root.left)
    right_val = evaluate(root.right)
    
    # Apply operator
    if root.val == '+':
        return left_val + right_val
    elif root.val == '-':
        return left_val - right_val
    elif root.val == '*':
        return left_val * right_val
    elif root.val == '/':
        return left_val / right_val
```

#### **File System Hierarchy**:
```python
class FileNode:
    def __init__(self, name, is_file=True):
        self.name = name
        self.is_file = is_file
        self.children = [] if not is_file else None
    
    def add_child(self, child):
        if not self.is_file:
            self.children.append(child)

# Directory structure
root = FileNode("/", is_file=False)
home = FileNode("home", is_file=False)
user = FileNode("user", is_file=False)
doc = FileNode("document.txt", is_file=True)

root.add_child(home)
home.add_child(user)
user.add_child(doc)
```

#### **Decision Trees (ML)**:
```python
class DecisionNode:
    def __init__(self, feature=None, threshold=None, 
                 left=None, right=None, value=None):
        self.feature = feature
        self.threshold = threshold
        self.left = left
        self.right = right
        self.value = value  # For leaf nodes

def predict(node, sample):
    """Traverse tree to make prediction"""
    if node.value is not None:
        return node.value
    
    if sample[node.feature] <= node.threshold:
        return predict(node.left, sample)
    else:
        return predict(node.right, sample)
```

#### **Huffman Coding (Compression)**:
```python
# Build Huffman tree for data compression
import heapq

def build_huffman_tree(freq):
    """Build tree from character frequencies"""
    heap = [[weight, [char, ""]] for char, weight in freq.items()]
    heapq.heapify(heap)
    
    while len(heap) > 1:
        lo = heapq.heappop(heap)
        hi = heapq.heappop(heap)
        
        for pair in lo[1:]:
            pair[1] = '0' + pair[1]
        for pair in hi[1:]:
            pair[1] = '1' + pair[1]
        
        heapq.heappush(heap, [lo[0] + hi[0]] + lo[1:] + hi[1:])
    
    return sorted(heapq.heappop(heap)[1:], key=lambda p: (len(p[-1]), p))
```

### 7. Complexity of operations
Performance characteristics of tree operations:

#### **Binary Search Tree (unbalanced)**:

| Operation | Average | Worst Case |
|-----------|---------|------------|
| Search | O(log n) | O(n) |
| Insert | O(log n) | O(n) |
| Delete | O(log n) | O(n) |
| Min/Max | O(log n) | O(n) |
| Traversal | O(n) | O(n) |

#### **Balanced BST (AVL, Red-Black)**:

| Operation | Time | Notes |
|-----------|------|-------|
| Search | O(log n) | Guaranteed |
| Insert | O(log n) | With rebalancing |
| Delete | O(log n) | With rebalancing |
| Min/Max | O(log n) | Guaranteed |

#### **Heap**:

| Operation | Time | Notes |
|-----------|------|-------|
| Insert | O(log n) | Heapify up |
| Extract Min/Max | O(log n) | Heapify down |
| Peek Min/Max | O(1) | Root element |
| Build Heap | O(n) | From array |
| Heapify | O(log n) | Single element |

#### **Space complexity**:
- **Tree storage**: O(n) for n nodes
- **Recursive traversal**: O(h) stack space where h = height
- **Iterative traversal**: O(h) for stack/queue

#### **Height analysis**:
```python
# Best case (balanced): h = log₂ n
# Worst case (skewed): h = n

# Example: n = 1000 nodes
# Balanced: h ≈ 10 (very fast)
# Skewed: h = 1000 (slow as linked list)

def operations_comparison(n=1000):
    """Compare operations for different tree types"""
    import math
    
    balanced_height = math.ceil(math.log2(n))
    skewed_height = n
    
    print(f"Nodes: {n}")
    print(f"Balanced tree height: {balanced_height}")
    print(f"Skewed tree height: {skewed_height}")
    print(f"Search operations:")
    print(f"  Balanced: ~{balanced_height} comparisons")
    print(f"  Skewed: ~{skewed_height//2} comparisons (average)")

# Output:
# Nodes: 1000
# Balanced tree height: 10
# Skewed tree height: 1000
# Search operations:
#   Balanced: ~10 comparisons
#   Skewed: ~500 comparisons (average)
```

#### **Practical considerations**:
- **Use balanced trees** when: Frequent insertions/deletions, need guaranteed O(log n)
- **Use unbalanced BST** when: Data arrives sorted, simple implementation sufficient
- **Use heap** when: Need min/max quickly, priority queue operations
- **Use hash table** when: Only need search/insert/delete, no ordering required
