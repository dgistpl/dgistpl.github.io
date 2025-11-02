---
layout: splash
author_profile: false
---

# Introduction to Data Structures

Understand what data structures are and why they matter.

### Definition and role of data structures

A **data structure** is a specialized format for organizing, storing, and managing data in a computer so that it can be accessed and modified efficiently. Data structures provide a means to manage large amounts of data efficiently for uses such as large databases and internet indexing services.

**Why do we need data structures?**

1. **Efficiency**: Different data structures excel at different operations. Choosing the right one can make the difference between an algorithm that runs in milliseconds versus hours.

2. **Organization**: Data structures provide a systematic way to organize data, making code more readable and maintainable.

3. **Reusability**: Well-designed data structures can be reused across different problems and applications.

4. **Abstraction**: They allow us to think about data at a higher level, hiding implementation details.

**Real-world analogy**: Think of data structures like furniture in a house:
- A **bookshelf** organizes books for easy retrieval (like an array)
- A **filing cabinet** with labeled drawers (like a hash table)
- A **stack of plates** where you take from the top (like a stack)
- A **line at a store** where first person in line is served first (like a queue)

Example demonstrating the importance:
```python
# Checking if an element exists

# Approach 1: Using a list (array)
my_list = [1, 2, 3, 4, 5, ..., 1000000]
if 999999 in my_list:  # O(n) - must scan through all elements
    print("Found!")

# Approach 2: Using a set (hash table)
my_set = {1, 2, 3, 4, 5, ..., 1000000}
if 999999 in my_set:   # O(1) - direct lookup
    print("Found!")
```

For a million elements, the set lookup is nearly instantaneous while the list scan could take significant time.

### Time vs space trade-offs

**Time complexity** measures how the runtime of an algorithm grows with input size. **Space complexity** measures how much memory is required.

**The Trade-off**: Often, we can make an algorithm faster by using more memory, or save memory by accepting slower execution. This is called the **time-space trade-off**.

**Key Principle**: There's rarely a solution that is both the fastest AND uses the least memory. Engineers must choose based on the constraints of their problem.

**Common Trade-off Examples**:

1. **Caching/Memoization** (Trading space for time):

```python
# Without memoization - slower, less memory
def fibonacci(n):
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)  # O(2^n) time, O(n) space

# With memoization - faster, more memory
cache = {}
def fibonacci_memo(n):
    if n in cache:
        return cache[n]
    if n <= 1:
        return n
    cache[n] = fibonacci_memo(n-1) + fibonacci_memo(n-2)  # O(n) time, O(n) space
    return cache[n]
```

2. **Lookup Tables** (Trading space for time):

```python
# Computing square roots each time - slow, minimal space
def process_numbers(numbers):
    results = []
    for n in numbers:
        results.append(n ** 0.5)  # Compute each time
    return results

# Pre-computed lookup table - fast, more space
import math
sqrt_table = {i: math.sqrt(i) for i in range(10000)}  # Pre-compute

def process_numbers_fast(numbers):
    results = []
    for n in numbers:
        results.append(sqrt_table[n])  # O(1) lookup
    return results
```

3. **In-place vs Out-of-place Algorithms** (Trading time for space):

```python
# Out-of-place: Creates new array - O(n) space
def reverse_list(arr):
    return arr[::-1]  # Creates a copy

# In-place: Modifies original - O(1) space
def reverse_list_inplace(arr):
    left, right = 0, len(arr) - 1
    while left < right:
        arr[left], arr[right] = arr[right], arr[left]
        left += 1
        right -= 1
    return arr
```

**When to choose what?**
- **Choose time optimization** when: dealing with large datasets, user experience matters, memory is abundant
- **Choose space optimization** when: memory is limited (embedded systems), data is too large to fit in RAM, running on resource-constrained devices

### Asymptotic analysis and Big-O

**Asymptotic analysis** is a method of describing the performance of an algorithm as the input size approaches infinity. It focuses on growth rates rather than exact counts.

**Big-O Notation** describes the **upper bound** of an algorithm's growth rate - the worst-case scenario.

**Why asymptotic?**
- Actual runtime depends on hardware, language, compiler optimizations
- We care about **scalability**: how does it perform with huge inputs?
- Constants and lower-order terms become insignificant with large n

**Common Big-O Classes** (from fastest to slowest):

| Notation | Name | Example | Growth |
|----------|------|---------|--------|
| O(1) | Constant | Array access, hash lookup | Doesn't grow |
| O(log n) | Logarithmic | Binary search | Very slow growth |
| O(n) | Linear | Linear search, array scan | Proportional |
| O(n log n) | Linearithmic | Merge sort, quicksort | Moderate |
| O(n²) | Quadratic | Nested loops, bubble sort | Fast growth |
| O(n³) | Cubic | Triple nested loops | Very fast growth |
| O(2ⁿ) | Exponential | Recursive fibonacci | Explosive growth |
| O(n!) | Factorial | Generate all permutations | Extremely explosive |

**Visual comparison** for n = 100:
- O(1) = 1 operation
- O(log n) ≈ 7 operations
- O(n) = 100 operations
- O(n log n) ≈ 664 operations
- O(n²) = 10,000 operations
- O(2ⁿ) ≈ 1.27 × 10³⁰ operations (universe-ending!)

**Big-O Rules**:

1. **Drop constants**: O(2n) → O(n), O(100) → O(1)
2. **Drop lower-order terms**: O(n² + n) → O(n²)
3. **Different variables for different inputs**: O(a + b), O(a × b)
4. **Worst case**: Big-O describes the worst-case scenario

**Examples**:

```python
# O(1) - Constant time
def get_first_element(arr):
    return arr[0]  # Always 1 operation

# O(n) - Linear time
def find_max(arr):
    max_val = arr[0]
    for num in arr:  # n iterations
        if num > max_val:
            max_val = num
    return max_val

# O(n²) - Quadratic time
def bubble_sort(arr):
    n = len(arr)
    for i in range(n):        # n iterations
        for j in range(n-1):  # n iterations
            if arr[j] > arr[j+1]:
                arr[j], arr[j+1] = arr[j+1], arr[j]
    return arr

# O(log n) - Logarithmic time
def binary_search(sorted_arr, target):
    left, right = 0, len(sorted_arr) - 1
    while left <= right:
        mid = (left + right) // 2
        if sorted_arr[mid] == target:
            return mid
        elif sorted_arr[mid] < target:
            left = mid + 1
        else:
            right = mid - 1  # Halve the search space each iteration
    return -1

# O(n log n) - Linearithmic time
def merge_sort(arr):
    if len(arr) <= 1:
        return arr
    mid = len(arr) // 2
    left = merge_sort(arr[:mid])    # log n divisions
    right = merge_sort(arr[mid:])
    return merge(left, right)       # n work per level
```

**Other notations** (less commonly used):
- **Big-Omega (Ω)**: Lower bound (best case)
- **Big-Theta (Θ)**: Tight bound (average case)
- **Little-o (o)**: Strict upper bound

### Big-O of common operations

Understanding the complexity of common operations helps you choose the right data structure for your problem.

**Arrays (Lists in Python)**:

| Operation | Time Complexity | Notes |
|-----------|----------------|-------|
| Access by index | O(1) | Direct memory access |
| Search (unsorted) | O(n) | Must check each element |
| Search (sorted) | O(log n) | Can use binary search |
| Insert at end | O(1) amortized | May need to resize |
| Insert at beginning | O(n) | Must shift all elements |
| Delete at end | O(1) | Simple removal |
| Delete at beginning | O(n) | Must shift all elements |

```python
arr = [1, 2, 3, 4, 5]
x = arr[2]           # O(1) - direct access
arr.append(6)        # O(1) amortized
arr.insert(0, 0)     # O(n) - shifts all elements
```

**Linked Lists**:

| Operation | Time Complexity | Notes |
|-----------|----------------|-------|
| Access by index | O(n) | Must traverse from head |
| Search | O(n) | Must traverse sequentially |
| Insert at beginning | O(1) | Just update head pointer |
| Insert at end | O(n) or O(1) | O(1) if tail pointer exists |
| Delete at beginning | O(1) | Update head pointer |
| Delete at end | O(n) | Need to find second-to-last |

**Hash Tables (Dictionaries in Python)**:

| Operation | Average | Worst Case | Notes |
|-----------|---------|------------|-------|
| Search | O(1) | O(n) | Worst case: all collisions |
| Insert | O(1) | O(n) | Worst case: rehashing |
| Delete | O(1) | O(n) | Worst case: many collisions |

```python
hash_map = {}
hash_map['key'] = 'value'  # O(1) insert
value = hash_map['key']    # O(1) lookup
del hash_map['key']        # O(1) delete
```

**Binary Search Trees (Balanced)**:

| Operation | Average | Worst Case (Unbalanced) |
|-----------|---------|------------------------|
| Search | O(log n) | O(n) |
| Insert | O(log n) | O(n) |
| Delete | O(log n) | O(n) |

**Stacks and Queues**:

| Operation | Time Complexity |
|-----------|----------------|
| Push/Enqueue | O(1) |
| Pop/Dequeue | O(1) |
| Peek/Front | O(1) |
| Search | O(n) |

**Heaps (Priority Queues)**:

| Operation | Time Complexity |
|-----------|----------------|
| Find min/max | O(1) |
| Insert | O(log n) |
| Delete min/max | O(log n) |
| Build heap | O(n) |

**Sorting Algorithms**:

| Algorithm | Average | Worst | Space | Stable? |
|-----------|---------|-------|-------|---------|
| Quick Sort | O(n log n) | O(n²) | O(log n) | No |
| Merge Sort | O(n log n) | O(n log n) | O(n) | Yes |
| Heap Sort | O(n log n) | O(n log n) | O(1) | No |
| Bubble Sort | O(n²) | O(n²) | O(1) | Yes |
| Insertion Sort | O(n²) | O(n²) | O(1) | Yes |

**Quick Reference** for choosing operations:
- Need **fast random access**? → Use arrays
- Need **fast insertion/deletion at beginning**? → Use linked lists
- Need **fast key-value lookup**? → Use hash tables
- Need **sorted data with fast operations**? → Use balanced BSTs
- Need **LIFO access**? → Use stacks
- Need **FIFO access**? → Use queues
- Need **min/max quickly**? → Use heaps

### When to choose a structure

Choosing the right data structure is crucial for efficient algorithm design. Here's a decision guide:

**Ask these questions**:

1. **What operations will be most frequent?**
   - Lots of lookups? → Hash table or BST
   - Lots of insertions/deletions? → Linked list or balanced tree
   - Processing in order? → Queue
   - Need to undo operations? → Stack

2. **Do you need ordered data?**
   - Yes, sorted order → BST, sorted array
   - Yes, insertion order → Array, linked list
   - No → Hash table (fastest)

3. **Do you know the size in advance?**
   - Yes, fixed size → Array
   - No, dynamic → Linked list, dynamic array, hash table

4. **What are your constraints?**
   - Limited memory → Choose space-efficient structures
   - Need speed → Choose time-efficient structures
   - Need both → Make trade-offs based on primary use case

**Decision Tree Examples**:

**Scenario 1: Building a phone book**
- Need: Fast lookup by name
- Need: Alphabetical order useful but not required
- Operations: Search (frequent), Insert (rare), Delete (rare)
- **Choice**: Hash table (O(1) lookup) or BST (O(log n) with ordering)

```python
# Using hash table
phone_book = {
    "Alice": "555-1234",
    "Bob": "555-5678"
}
print(phone_book["Alice"])  # O(1) lookup
```

**Scenario 2: Browser history**
- Need: Recent pages accessed frequently
- Need: Add new page, go back/forward
- Operations: Push (frequent), Pop (frequent), Random access (rare)
- **Choice**: Stack for back button, Stack for forward button

```python
back_stack = []
forward_stack = []

def visit_page(url):
    back_stack.append(current_page)
    forward_stack.clear()  # Can't go forward after new visit

def go_back():
    if back_stack:
        forward_stack.append(current_page)
        return back_stack.pop()
```

**Scenario 3: Print queue**
- Need: First document submitted prints first
- Operations: Add to queue (frequent), Remove from queue (frequent)
- **Choice**: Queue (FIFO behavior)

```python
from collections import deque
print_queue = deque()
print_queue.append("document1.pdf")  # Enqueue
print_queue.append("document2.pdf")
current_job = print_queue.popleft()  # Dequeue - first in, first out
```

**Scenario 4: Autocomplete suggestions**
- Need: Find all words with common prefix
- Operations: Prefix search (frequent), Insert new words (occasional)
- **Choice**: Trie (prefix tree)

```python
# Conceptual trie structure
# "cat", "car", "dog" stored as:
#     root
#    /   \
#   c     d
#   |     |
#   a     o
#  / \    |
# t   r   g
```

**Scenario 5: Finding shortest path in maps**
- Need: Graph structure with weighted edges
- Operations: Find neighbors, find shortest path
- **Choice**: Adjacency list + Priority queue (for Dijkstra's)

**Scenario 6: LRU Cache**
- Need: Fast access, track recent usage, evict least recent
- Operations: Get (O(1)), Put (O(1)), Track order
- **Choice**: Hash table + Doubly linked list

```python
# Conceptual structure
cache = {}  # Hash table for O(1) access
dll = DoublyLinkedList()  # Track usage order
```

**Common Pitfalls**:
- ❌ Using lists for frequent lookups (O(n) instead of O(1))
- ❌ Using arrays when size is unknown (costly resizing)
- ❌ Using BST when order doesn't matter (hash table is faster)
- ❌ Using recursive structures without considering stack overflow

**General Guidelines**:
- **Default to hash tables** for key-value storage (most versatile)
- **Use arrays** when you need index-based access and size is manageable
- **Use linked lists** when you have many insertions/deletions
- **Use trees** when you need both ordering and fast operations
- **Use specialized structures** (stacks, queues, heaps) when they match your access pattern

### Abstraction and ADTs

**Abstract Data Type (ADT)** is a theoretical concept that defines a data type by its behavior (operations) rather than its implementation. It specifies **what** operations can be performed, not **how** they are implemented.

**Key Principle**: Separate the **interface** (what operations are available) from the **implementation** (how they work internally).

**Benefits of Abstraction**:
1. **Flexibility**: Can change implementation without affecting users
2. **Simplicity**: Users don't need to understand internal complexity
3. **Reusability**: Same interface can work with different implementations
4. **Maintainability**: Easier to update and fix bugs

**Common ADTs**:

**1. Stack ADT**
- **Interface**: `push()`, `pop()`, `peek()`, `is_empty()`
- **Implementations**: Array-based, Linked-list-based
- **Behavior**: LIFO (Last In, First Out)

```python
# ADT Definition (Interface)
class StackADT:
    def push(self, item): pass
    def pop(self): pass
    def peek(self): pass
    def is_empty(self): pass

# Implementation 1: Array-based
class ArrayStack(StackADT):
    def __init__(self):
        self._data = []

    def push(self, item):
        self._data.append(item)

    def pop(self):
        return self._data.pop()

# Implementation 2: Linked-list-based
class LinkedStack(StackADT):
    def __init__(self):
        self._head = None
        self._size = 0

    def push(self, item):
        new_node = Node(item, self._head)
        self._head = new_node
        self._size += 1

    def pop(self):
        if self._head is None:
            raise IndexError("pop from empty stack")
        value = self._head.value
        self._head = self._head.next
        self._size -= 1
        return value
```

**2. Queue ADT**
- **Interface**: `enqueue()`, `dequeue()`, `front()`, `is_empty()`
- **Behavior**: FIFO (First In, First Out)

**3. List ADT**
- **Interface**: `get(index)`, `set(index, value)`, `insert(index, value)`, `delete(index)`, `size()`
- **Implementations**: Array-based (Python list), Linked-list-based

**4. Map/Dictionary ADT**
- **Interface**: `get(key)`, `put(key, value)`, `remove(key)`, `contains(key)`
- **Implementations**: Hash table, BST, Skip list

**5. Priority Queue ADT**
- **Interface**: `insert(item)`, `remove_min()`, `min()`, `is_empty()`
- **Implementations**: Heap, Unsorted array, Sorted array

**Example: Why Abstraction Matters**

Suppose you're building a task scheduler. You start with a simple list:

```python
# Version 1: Direct implementation (no abstraction)
tasks = []

def add_task(task):
    tasks.append(task)

def get_next_task():
    return tasks.pop(0)  # O(n) - inefficient!
```

Later, you realize this is slow. With abstraction, you can swap implementations:

```python
# Version 2: Using ADT abstraction
from collections import deque

class TaskQueue:
    def __init__(self):
        self._tasks = deque()  # Changed implementation

    def add_task(self, task):
        self._tasks.append(task)

    def get_next_task(self):
        return self._tasks.popleft()  # O(1) - much better!

# User code stays the same!
queue = TaskQueue()
queue.add_task("Task 1")
next_task = queue.get_next_task()
```

**Encapsulation in ADTs**:

Good ADTs hide implementation details:

```python
# Good: Implementation hidden
class Stack:
    def __init__(self):
        self._data = []  # Private variable (by convention)

    def push(self, item):
        self._data.append(item)

    # Users can't directly access self._data

# Bad: Implementation exposed
class BadStack:
    def __init__(self):
        self.data = []  # Public - users can mess with it!

    def push(self, item):
        self.data.append(item)

# Problem with bad design:
bad_stack = BadStack()
bad_stack.data = "oops!"  # Breaks the stack!
```

**ADT vs Data Structure vs Implementation**:

- **ADT** (Abstract): The concept/interface (e.g., "Stack")
- **Data Structure** (Logical): How data is organized (e.g., "Array" or "Linked List")
- **Implementation** (Physical): Actual code in a programming language

Example:
```
ADT: List
├─ Data Structure: Array
│  └─ Implementation: Python's list class
└─ Data Structure: Linked List
   └─ Implementation: Custom LinkedList class
```

**Real-world analogy**:
- **ADT** = "Car" (steering wheel, gas pedal, brake)
- **Implementation** = Electric car vs Gas car (different engines, same interface)
- You can drive both because the interface is the same, even though the internal mechanisms differ

**Key Takeaway**: When designing systems, think in terms of ADTs first. Define the operations you need, then choose or create an implementation. This makes your code more flexible, maintainable, and easier to optimize later.
