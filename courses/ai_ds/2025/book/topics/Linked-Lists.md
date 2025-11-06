---
layout: splash
author_profile: false
---

# Linked Lists

Nodes connected via pointers for flexible insertions/deletions.


### 1. Singly, doubly, and circular lists
Three main variants of linked list structures:

#### **Singly Linked List**:
- **Structure**: Each node has data and pointer to next node
- **Traversal**: One direction only (forward)
- **Memory**: One pointer per node

**Implementation**:
```python
class Node:
    def __init__(self, data):
        self.data = data
        self.next = None

class SinglyLinkedList:
    def __init__(self):
        self.head = None
    
    def append(self, data):
        new_node = Node(data)
        if not self.head:
            self.head = new_node
            return
        
        current = self.head
        while current.next:
            current = current.next
        current.next = new_node
    
    def display(self):
        elements = []
        current = self.head
        while current:
            elements.append(current.data)
            current = current.next
        return elements
```

**Visual**:
```
head → [1|→] → [2|→] → [3|→] → [4|None]
```

**Advantages**:
- ✓ Simple implementation
- ✓ Less memory (one pointer per node)
- ✓ Efficient forward traversal

**Disadvantages**:
- ✗ Cannot traverse backward
- ✗ Deleting node requires previous node reference
- ✗ No direct access to tail

#### **Doubly Linked List**:
- **Structure**: Each node has data, next pointer, and previous pointer
- **Traversal**: Both directions (forward and backward)
- **Memory**: Two pointers per node

**Implementation**:
```python
class DNode:
    def __init__(self, data):
        self.data = data
        self.next = None
        self.prev = None

class DoublyLinkedList:
    def __init__(self):
        self.head = None
        self.tail = None
    
    def append(self, data):
        new_node = DNode(data)
        if not self.head:
            self.head = self.tail = new_node
            return
        
        new_node.prev = self.tail
        self.tail.next = new_node
        self.tail = new_node
    
    def delete(self, node):
        if node.prev:
            node.prev.next = node.next
        else:
            self.head = node.next
        
        if node.next:
            node.next.prev = node.prev
        else:
            self.tail = node.prev
```

**Visual**:
```
head → [None|1|→] ⇄ [←|2|→] ⇄ [←|3|→] ⇄ [←|4|None] ← tail
```

**Advantages**:
- ✓ Bidirectional traversal
- ✓ Easier deletion (no need for previous node)
- ✓ Can traverse from tail

**Disadvantages**:
- ✗ More memory (two pointers per node)
- ✗ More complex implementation
- ✗ Extra pointer maintenance

#### **Circular Linked List**:
- **Structure**: Last node points back to first node (forms a cycle)
- **Types**: Can be singly or doubly circular
- **Traversal**: Can start anywhere, no natural end

**Singly Circular**:
```python
class CircularLinkedList:
    def __init__(self):
        self.head = None
    
    def append(self, data):
        new_node = Node(data)
        if not self.head:
            self.head = new_node
            new_node.next = new_node  # Points to itself
            return
        
        current = self.head
        while current.next != self.head:
            current = current.next
        current.next = new_node
        new_node.next = self.head
    
    def display(self, max_iterations=100):
        if not self.head:
            return []
        
        elements = []
        current = self.head
        count = 0
        while count < max_iterations:
            elements.append(current.data)
            current = current.next
            if current == self.head:
                break
            count += 1
        return elements
```

**Visual**:
```
     ┌─────────────────────┐
     ↓                     |
head → [1|→] → [2|→] → [3|→] → [4|─]
```

**Advantages**:
- ✓ Can traverse entire list from any node
- ✓ Useful for round-robin scheduling
- ✓ No null pointers to check

**Disadvantages**:
- ✗ Risk of infinite loops if not careful
- ✗ More complex termination conditions
- ✗ Harder to detect end of list

#### **Comparison table**:

| Feature | Singly | Doubly | Circular |
|---------|--------|--------|----------|
| Memory per node | 1 pointer | 2 pointers | 1-2 pointers |
| Backward traversal | No | Yes | No (singly) |
| Delete with node | Need prev | O(1) | Need prev |
| Use case | Simple lists | Undo/redo | Round-robin |

### 2. Head/tail pointers and sentinel nodes
Optimization techniques for linked list management:

#### **Head pointer only**:
```python
class SimpleList:
    def __init__(self):
        self.head = None
    
    # Append is O(n) - must traverse to end
    def append(self, data):
        new_node = Node(data)
        if not self.head:
            self.head = new_node
            return
        
        current = self.head
        while current.next:
            current = current.next
        current.next = new_node
```

#### **Head and tail pointers**:
```python
class OptimizedList:
    def __init__(self):
        self.head = None
        self.tail = None
    
    # Append is O(1) - direct access to tail
    def append(self, data):
        new_node = Node(data)
        if not self.head:
            self.head = self.tail = new_node
            return
        
        self.tail.next = new_node
        self.tail = new_node
    
    # Prepend is O(1)
    def prepend(self, data):
        new_node = Node(data)
        new_node.next = self.head
        self.head = new_node
        if not self.tail:
            self.tail = new_node
```

**Benefits of tail pointer**:
- ✓ O(1) append instead of O(n)
- ✓ Efficient queue implementation
- ✓ Direct access to last element

#### **Sentinel (Dummy) Nodes**:
- **Idea**: Use dummy node at head (and optionally tail) to simplify edge cases
- **Benefit**: No need to check for empty list

**With sentinel**:
```python
class SentinelList:
    def __init__(self):
        self.sentinel = Node(None)  # Dummy head
        self.sentinel.next = None
    
    def insert_after(self, prev_node, data):
        # No need to check if prev_node is None
        new_node = Node(data)
        new_node.next = prev_node.next
        prev_node.next = new_node
    
    def delete_after(self, prev_node):
        # No need to check if prev_node.next is None
        if prev_node.next:
            prev_node.next = prev_node.next.next
    
    def is_empty(self):
        return self.sentinel.next is None
```

**Doubly linked with sentinels**:
```python
class DoublyLinkedListWithSentinel:
    def __init__(self):
        self.head_sentinel = DNode(None)
        self.tail_sentinel = DNode(None)
        self.head_sentinel.next = self.tail_sentinel
        self.tail_sentinel.prev = self.head_sentinel
    
    def insert_before(self, node, data):
        # Always valid, no edge cases
        new_node = DNode(data)
        new_node.prev = node.prev
        new_node.next = node
        node.prev.next = new_node
        node.prev = new_node
    
    def delete(self, node):
        # Always valid, no edge cases
        node.prev.next = node.next
        node.next.prev = node.prev
```

**Visual with sentinels**:
```
[HEAD_SENTINEL] ⇄ [1] ⇄ [2] ⇄ [3] ⇄ [TAIL_SENTINEL]
```

**Benefits**:
- ✓ Eliminates special cases for empty list
- ✓ Simplifies insertion/deletion code
- ✓ No null pointer checks needed

**Trade-offs**:
- ✗ Extra memory for sentinel(s)
- ✗ Slightly more complex initialization

### 3. Insertion and deletion complexities
Understanding performance of common operations:

#### **Insertion operations**:

**1. Insert at beginning (prepend)**:
```python
def prepend(self, data):
    new_node = Node(data)
    new_node.next = self.head
    self.head = new_node
    # Time: O(1)
```

**2. Insert at end (append)**:
```python
# Without tail pointer: O(n)
def append_slow(self, data):
    new_node = Node(data)
    if not self.head:
        self.head = new_node
        return
    
    current = self.head
    while current.next:  # Traverse to end
        current = current.next
    current.next = new_node

# With tail pointer: O(1)
def append_fast(self, data):
    new_node = Node(data)
    if not self.tail:
        self.head = self.tail = new_node
    else:
        self.tail.next = new_node
        self.tail = new_node
```

**3. Insert at position i**:
```python
def insert_at(self, index, data):
    if index == 0:
        self.prepend(data)
        return
    
    current = self.head
    for _ in range(index - 1):
        if not current:
            raise IndexError("Index out of bounds")
        current = current.next
    
    new_node = Node(data)
    new_node.next = current.next
    current.next = new_node
    # Time: O(i) to reach position
```

**4. Insert after given node**:
```python
def insert_after(self, prev_node, data):
    if not prev_node:
        return
    
    new_node = Node(data)
    new_node.next = prev_node.next
    prev_node.next = new_node
    # Time: O(1) if we have the node reference
```

#### **Deletion operations**:

**1. Delete first node**:
```python
def delete_first(self):
    if not self.head:
        return
    
    self.head = self.head.next
    # Time: O(1)
```

**2. Delete last node**:
```python
# Singly linked: O(n) - need to find second-to-last
def delete_last_singly(self):
    if not self.head:
        return
    
    if not self.head.next:
        self.head = None
        return
    
    current = self.head
    while current.next.next:
        current = current.next
    current.next = None

# Doubly linked with tail: O(1)
def delete_last_doubly(self):
    if not self.tail:
        return
    
    if self.tail.prev:
        self.tail = self.tail.prev
        self.tail.next = None
    else:
        self.head = self.tail = None
```

**3. Delete node with value**:
```python
def delete_value(self, value):
    if not self.head:
        return
    
    # Special case: delete head
    if self.head.data == value:
        self.head = self.head.next
        return
    
    # Find node before target
    current = self.head
    while current.next and current.next.data != value:
        current = current.next
    
    if current.next:
        current.next = current.next.next
    # Time: O(n) to search
```

**4. Delete given node (doubly linked)**:
```python
def delete_node(self, node):
    if node.prev:
        node.prev.next = node.next
    else:
        self.head = node.next
    
    if node.next:
        node.next.prev = node.prev
    else:
        self.tail = node.prev
    # Time: O(1) with node reference
```

#### **Complexity summary**:

| Operation | Singly (no tail) | Singly (with tail) | Doubly (with tail) |
|-----------|------------------|--------------------|--------------------|
| Prepend | O(1) | O(1) | O(1) |
| Append | O(n) | O(1) | O(1) |
| Insert at i | O(i) | O(i) | O(min(i, n-i)) |
| Delete first | O(1) | O(1) | O(1) |
| Delete last | O(n) | O(n) | O(1) |
| Delete at i | O(i) | O(i) | O(min(i, n-i)) |
| Search | O(n) | O(n) | O(n) |
| Access by index | O(i) | O(i) | O(min(i, n-i)) |

### 4. Reversal and middle finding
Common algorithmic problems on linked lists:

#### **Reverse a linked list**:

**Iterative approach**:
```python
def reverse_iterative(self):
    prev = None
    current = self.head
    
    while current:
        next_node = current.next  # Save next
        current.next = prev       # Reverse pointer
        prev = current            # Move prev forward
        current = next_node       # Move current forward
    
    self.head = prev
    # Time: O(n), Space: O(1)
```

**Visual**:
```
Before: 1 → 2 → 3 → 4 → None
After:  None ← 1 ← 2 ← 3 ← 4
        (head)              (new head)
```

**Recursive approach**:
```python
def reverse_recursive(self, node):
    # Base case: empty or single node
    if not node or not node.next:
        self.head = node
        return node
    
    # Recursive case
    rest = self.reverse_recursive(node.next)
    node.next.next = node  # Reverse pointer
    node.next = None
    
    return rest
    # Time: O(n), Space: O(n) for recursion stack
```

**Reverse in groups of k**:
```python
def reverse_k_group(head, k):
    # Count nodes
    count = 0
    current = head
    while current and count < k:
        current = current.next
        count += 1
    
    if count < k:
        return head  # Not enough nodes
    
    # Reverse first k nodes
    prev = None
    current = head
    for _ in range(k):
        next_node = current.next
        current.next = prev
        prev = current
        current = next_node
    
    # Recursively reverse rest
    head.next = reverse_k_group(current, k)
    
    return prev
```

#### **Find middle of linked list**:

**Two-pointer (slow-fast) technique**:
```python
def find_middle(self):
    if not self.head:
        return None
    
    slow = fast = self.head
    
    while fast and fast.next:
        slow = slow.next
        fast = fast.next.next
    
    return slow
    # Time: O(n), Space: O(1)
```

**Visual**:
```
List: 1 → 2 → 3 → 4 → 5
      ↑           ↑
    slow        fast (initially)

After iterations:
1 → 2 → 3 → 4 → 5
        ↑           ↑
      slow        fast

Middle: 3
```

**Find k-th node from end**:
```python
def find_kth_from_end(self, k):
    fast = slow = self.head
    
    # Move fast k steps ahead
    for _ in range(k):
        if not fast:
            return None
        fast = fast.next
    
    # Move both until fast reaches end
    while fast:
        slow = slow.next
        fast = fast.next
    
    return slow
```

**Detect cycle (Floyd's algorithm)**:
```python
def has_cycle(self):
    if not self.head:
        return False
    
    slow = fast = self.head
    
    while fast and fast.next:
        slow = slow.next
        fast = fast.next.next
        
        if slow == fast:
            return True
    
    return False
```

**Find cycle start**:
```python
def find_cycle_start(self):
    if not self.head:
        return None
    
    slow = fast = self.head
    
    # Find meeting point
    while fast and fast.next:
        slow = slow.next
        fast = fast.next.next
        if slow == fast:
            break
    else:
        return None  # No cycle
    
    # Move slow to head, keep fast at meeting point
    slow = self.head
    while slow != fast:
        slow = slow.next
        fast = fast.next
    
    return slow  # Cycle start
```

### 5. Comparison with arrays
Understanding when to use linked lists vs arrays:

#### **Access patterns**:
| Operation | Array | Linked List |
|-----------|-------|-------------|
| Random access | O(1) | O(n) |
| Sequential access | O(n) | O(n) |
| Insert at beginning | O(n) | O(1) |
| Insert at end | O(1) amortized | O(1) with tail |
| Insert at position i | O(n) | O(i) |
| Delete at beginning | O(n) | O(1) |
| Delete at end | O(1) | O(n) singly, O(1) doubly |
| Search | O(n) or O(log n) sorted | O(n) |

#### **Memory characteristics**:
```python
# Array
arr = [1, 2, 3, 4, 5]
# Memory: Contiguous block
# [1][2][3][4][5]
# Address: base + i * sizeof(element)

# Linked List
# Memory: Scattered nodes
# [1|→] ... [2|→] ... [3|→] ... [4|→] ... [5|None]
# Each node: data + pointer(s)
```

#### **Detailed comparison**:

**Arrays advantages**:
- ✓ O(1) random access by index
- ✓ Better cache locality (contiguous memory)
- ✓ Less memory overhead (no pointers)
- ✓ Binary search possible if sorted
- ✓ Better for iteration

**Linked lists advantages**:
- ✓ O(1) insertion/deletion at known position
- ✓ No wasted space (dynamic size)
- ✓ No need to shift elements
- ✓ Easy to split/merge
- ✓ No reallocation needed

**When to use arrays**:
- Need frequent random access
- Data size known in advance
- Memory locality important
- Need to sort or binary search
- Iteration is primary operation

**When to use linked lists**:
- Frequent insertions/deletions
- Unknown or highly variable size
- Don't need random access
- Implementing stacks/queues
- Need to frequently split/merge

### 6. Memory overhead and locality
Understanding performance implications:

#### **Memory overhead**:

**Array**:
```python
# 5 integers
arr = [1, 2, 3, 4, 5]
# Memory: 5 * 4 bytes = 20 bytes (just data)
# Plus: small overhead for array metadata
```

**Singly linked list**:
```python
# 5 nodes, each with int + pointer
# Memory per node: 4 bytes (int) + 8 bytes (pointer) = 12 bytes
# Total: 5 * 12 = 60 bytes
# Overhead: 200% more than array!
```

**Doubly linked list**:
```python
# 5 nodes, each with int + 2 pointers
# Memory per node: 4 bytes (int) + 16 bytes (2 pointers) = 20 bytes
# Total: 5 * 20 = 100 bytes
# Overhead: 400% more than array!
```

#### **Cache locality**:

**Array (good locality)**:
```
Memory layout:
[1][2][3][4][5] - contiguous

Cache line (64 bytes):
[1][2][3][4][5]... - all loaded together

Access pattern:
for i in range(len(arr)):
    process(arr[i])  # Sequential, cache-friendly
```

**Linked list (poor locality)**:
```
Memory layout:
[1|→] ... [2|→] ... [3|→] ... [4|→] ... [5|None]
  ↑         ↑         ↑         ↑         ↑
Random addresses in memory

Cache line:
[1|→][garbage...] - only one node per cache line

Access pattern:
current = head
while current:
    process(current.data)  # Pointer chasing, cache misses
    current = current.next
```

#### **Performance impact**:
```python
import time

# Array iteration (fast)
arr = list(range(1000000))
start = time.time()
total = sum(arr)
print(f"Array: {time.time() - start:.4f}s")

# Linked list iteration (slower)
class Node:
    def __init__(self, data):
        self.data = data
        self.next = None

head = Node(0)
current = head
for i in range(1, 1000000):
    current.next = Node(i)
    current = current.next

start = time.time()
total = 0
current = head
while current:
    total += current.data
    current = current.next
print(f"Linked list: {time.time() - start:.4f}s")

# Typical result: Linked list 5-10x slower due to cache misses
```

#### **Optimization techniques**:
1. **Memory pools**: Allocate nodes from contiguous pool
2. **XOR linked lists**: Use XOR to store both pointers in one
3. **Unrolled linked lists**: Store multiple elements per node
4. **Skip lists**: Add express lanes for faster search

### 7. Real-world uses
Practical applications of linked lists:

#### **1. Implementation of other data structures**:
```python
# Stack using linked list
class Stack:
    def __init__(self):
        self.top = None
    
    def push(self, data):
        new_node = Node(data)
        new_node.next = self.top
        self.top = new_node
    
    def pop(self):
        if not self.top:
            return None
        data = self.top.data
        self.top = self.top.next
        return data

# Queue using linked list
class Queue:
    def __init__(self):
        self.front = None
        self.rear = None
    
    def enqueue(self, data):
        new_node = Node(data)
        if not self.rear:
            self.front = self.rear = new_node
        else:
            self.rear.next = new_node
            self.rear = new_node
    
    def dequeue(self):
        if not self.front:
            return None
        data = self.front.data
        self.front = self.front.next
        if not self.front:
            self.rear = None
        return data
```

#### **2. Browser history (back/forward)**:
```python
class BrowserHistory:
    def __init__(self):
        self.current = DNode("homepage")
        self.head = self.current
    
    def visit(self, url):
        new_page = DNode(url)
        self.current.next = new_page
        new_page.prev = self.current
        self.current = new_page
    
    def back(self):
        if self.current.prev:
            self.current = self.current.prev
        return self.current.data
    
    def forward(self):
        if self.current.next:
            self.current = self.current.next
        return self.current.data
```

#### **3. Music playlist**:
```python
class Playlist:
    def __init__(self):
        self.head = None
        self.current = None
    
    def add_song(self, song):
        new_node = Node(song)
        if not self.head:
            self.head = new_node
            new_node.next = new_node  # Circular
            self.current = new_node
        else:
            # Insert at end of circular list
            temp = self.head
            while temp.next != self.head:
                temp = temp.next
            temp.next = new_node
            new_node.next = self.head
    
    def next_song(self):
        if self.current:
            self.current = self.current.next
        return self.current.data if self.current else None
```

#### **4. Undo/Redo functionality**:
```python
class UndoRedo:
    def __init__(self):
        self.current = None
    
    def do_action(self, action):
        new_node = DNode(action)
        if self.current:
            new_node.prev = self.current
            self.current.next = new_node
        self.current = new_node
    
    def undo(self):
        if self.current and self.current.prev:
            action = self.current.data
            self.current = self.current.prev
            return action
        return None
    
    def redo(self):
        if self.current and self.current.next:
            self.current = self.current.next
            return self.current.data
        return None
```

#### **5. LRU Cache**:
```python
class LRUCache:
    def __init__(self, capacity):
        self.capacity = capacity
        self.cache = {}  # key -> node
        self.head = DNode(0, 0)  # Sentinel
        self.tail = DNode(0, 0)  # Sentinel
        self.head.next = self.tail
        self.tail.prev = self.head
    
    def _remove(self, node):
        node.prev.next = node.next
        node.next.prev = node.prev
    
    def _add_to_head(self, node):
        node.next = self.head.next
        node.prev = self.head
        self.head.next.prev = node
        self.head.next = node
    
    def get(self, key):
        if key in self.cache:
            node = self.cache[key]
            self._remove(node)
            self._add_to_head(node)
            return node.value
        return -1
    
    def put(self, key, value):
        if key in self.cache:
            self._remove(self.cache[key])
        
        node = DNode(key, value)
        self._add_to_head(node)
        self.cache[key] = node
        
        if len(self.cache) > self.capacity:
            lru = self.tail.prev
            self._remove(lru)
            del self.cache[lru.key]
```

#### **6. Operating system applications**:
- **Process scheduling**: Ready queue, waiting queue
- **Memory management**: Free list of memory blocks
- **File systems**: Directory entries, file allocation
- **Device drivers**: I/O request queues

#### **7. Hash table chaining**:
```python
class HashTable:
    def __init__(self, size=10):
        self.size = size
        self.table = [None] * size  # Each slot is a linked list
    
    def insert(self, key, value):
        index = hash(key) % self.size
        new_node = Node((key, value))
        
        if not self.table[index]:
            self.table[index] = new_node
        else:
            # Add to front of linked list
            new_node.next = self.table[index]
            self.table[index] = new_node
```
