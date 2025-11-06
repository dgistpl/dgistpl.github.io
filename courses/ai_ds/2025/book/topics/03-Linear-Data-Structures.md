---
layout: splash
author_profile: false
---

# Linear Data Structures

Structures where elements are arranged sequentially.


### Arrays: static vs dynamic

An **array** is a contiguous block of memory that stores elements of the same type in sequential memory locations. Arrays are the most fundamental data structure, providing constant-time access to elements by index.

**Static Arrays** (Fixed-size arrays):
- Size is determined at creation time and cannot be changed
- Memory is allocated once
- Used in languages like C, Java (primitive arrays)
- Efficient but inflexible

**Dynamic Arrays** (Resizable arrays):
- Size can grow or shrink as needed
- Automatically resize when capacity is reached
- Used in Python (list), Java (ArrayList), C++ (vector)
- Slight overhead for resizing operations

**How Dynamic Arrays Work**:

1. **Initial allocation**: Start with a small capacity (e.g., 4 elements)
2. **Growth**: When full, allocate a new array (typically 2x the size)
3. **Copy**: Copy all elements to the new array
4. **Replace**: Replace old array with new array

```python
# Conceptual implementation of dynamic array growth
class DynamicArray:
    def __init__(self):
        self._capacity = 4
        self._size = 0
        self._data = [None] * self._capacity

    def append(self, item):
        if self._size == self._capacity:
            self._resize(2 * self._capacity)  # Double the capacity
        self._data[self._size] = item
        self._size += 1

    def _resize(self, new_capacity):
        new_data = [None] * new_capacity
        for i in range(self._size):
            new_data[i] = self._data[i]  # Copy all elements - O(n)
        self._data = new_data
        self._capacity = new_capacity
```

**Performance Comparison**:

| Operation | Static Array | Dynamic Array |
|-----------|--------------|---------------|
| Access by index | O(1) | O(1) |
| Search | O(n) | O(n) |
| Insert at end | N/A (fixed size) | O(1) amortized |
| Insert at middle | O(n) | O(n) |
| Delete | O(n) | O(n) |
| Memory usage | Exact size | Extra capacity |

**Amortized Analysis**:

Although resizing takes O(n) time, it happens infrequently. Over many insertions, the average (amortized) cost is O(1).

Example: Starting with capacity 1, inserting 16 elements:
- Resize at positions: 1, 2, 4, 8, 16
- Total copies: 1 + 2 + 4 + 8 + 16 = 31 operations for 16 insertions
- Average: 31/16 ≈ 2 operations per insertion = O(1) amortized

**Advantages of Arrays**:
- ✅ Fast random access: O(1) by index
- ✅ Cache-friendly: contiguous memory improves CPU cache performance
- ✅ Memory-efficient: no extra pointers (unlike linked lists)
- ✅ Simple to use and understand

**Disadvantages of Arrays**:
- ❌ Fixed size (static arrays) or occasional expensive resize (dynamic arrays)
- ❌ Insertion/deletion in middle is O(n) due to shifting
- ❌ Wasted space in dynamic arrays (allocated but unused capacity)

**Real-world examples**:
```python
# Python list (dynamic array)
scores = [85, 90, 78, 92]
scores.append(88)  # O(1) amortized
first_score = scores[0]  # O(1) access
scores.insert(2, 95)  # O(n) - shifts elements

# NumPy array (static array for numerical computing)
import numpy as np
matrix = np.array([[1, 2], [3, 4]])
value = matrix[1, 0]  # O(1) access, but size is fixed
```

**When to use**:
- Use **static arrays** when: size is known and fixed, maximum performance needed
- Use **dynamic arrays** when: size is unknown, need flexibility, moderate insertions at end

### Linked lists: singly/doubly/circular

A **linked list** is a linear data structure where elements (nodes) are stored non-contiguously in memory. Each node contains data and a reference (pointer) to the next node.

**Types of Linked Lists**:

**1. Singly Linked List**:
Each node points to the next node only.

```
Structure: [data|next] -> [data|next] -> [data|next] -> None

Example:
Head -> [10|•] -> [20|•] -> [30|•] -> None
```

```python
class Node:
    def __init__(self, data):
        self.data = data
        self.next = None

class SinglyLinkedList:
    def __init__(self):
        self.head = None
        self.size = 0

    def insert_at_beginning(self, data):
        new_node = Node(data)
        new_node.next = self.head
        self.head = new_node
        self.size += 1

    def insert_at_end(self, data):
        new_node = Node(data)
        if not self.head:
            self.head = new_node
        else:
            current = self.head
            while current.next:  # Traverse to end - O(n)
                current = current.next
            current.next = new_node
        self.size += 1

    def delete(self, data):
        if not self.head:
            return False

        if self.head.data == data:
            self.head = self.head.next
            self.size -= 1
            return True

        current = self.head
        while current.next:
            if current.next.data == data:
                current.next = current.next.next
                self.size -= 1
                return True
            current = current.next
        return False
```

**2. Doubly Linked List**:
Each node has pointers to both next and previous nodes.

```
Structure: None <- [prev|data|next] <-> [prev|data|next] <-> [prev|data|next] -> None

Example:
None <- [•|10|•] <-> [•|20|•] <-> [•|30|•] -> None
        Head                              Tail
```

```python
class DoublyNode:
    def __init__(self, data):
        self.data = data
        self.next = None
        self.prev = None

class DoublyLinkedList:
    def __init__(self):
        self.head = None
        self.tail = None
        self.size = 0

    def insert_at_beginning(self, data):
        new_node = DoublyNode(data)
        if not self.head:
            self.head = self.tail = new_node
        else:
            new_node.next = self.head
            self.head.prev = new_node
            self.head = new_node
        self.size += 1

    def insert_at_end(self, data):
        new_node = DoublyNode(data)
        if not self.tail:
            self.head = self.tail = new_node
        else:
            new_node.prev = self.tail
            self.tail.next = new_node
            self.tail = new_node
        self.size += 1

    def delete_node(self, node):
        """Delete a specific node (O(1) if we have reference to it)"""
        if node.prev:
            node.prev.next = node.next
        else:
            self.head = node.next

        if node.next:
            node.next.prev = node.prev
        else:
            self.tail = node.prev

        self.size -= 1
```

**3. Circular Linked List**:
The last node points back to the first node, forming a circle.

```
Singly Circular:
     ┌─────────────────────┐
     ↓                     │
Head [10|•] -> [20|•] -> [30|•]

Doubly Circular:
     ┌──────────────────────────────┐
     ↓                              │
     [•|10|•] <-> [•|20|•] <-> [•|30|•]
     │                              ↑
     └──────────────────────────────┘
```

```python
class CircularLinkedList:
    def __init__(self):
        self.head = None
        self.size = 0

    def insert_at_end(self, data):
        new_node = Node(data)
        if not self.head:
            self.head = new_node
            new_node.next = self.head  # Point to itself
        else:
            current = self.head
            while current.next != self.head:  # Traverse until back to head
                current = current.next
            current.next = new_node
            new_node.next = self.head  # Complete the circle
        self.size += 1

    def traverse(self):
        if not self.head:
            return

        current = self.head
        while True:
            print(current.data, end=" -> ")
            current = current.next
            if current == self.head:  # Back to start
                break
        print("(back to head)")
```

**Comparison Table**:

| Feature | Singly | Doubly | Circular |
|---------|--------|--------|----------|
| Memory per node | 1 pointer | 2 pointers | 1-2 pointers |
| Traverse forward | ✅ Easy | ✅ Easy | ✅ Easy |
| Traverse backward | ❌ No | ✅ Easy | ❌ No (singly), ✅ Yes (doubly) |
| Insert at beginning | O(1) | O(1) | O(1) |
| Insert at end | O(n) or O(1)* | O(1) | O(n) or O(1)* |
| Delete node (with reference) | O(1)** | O(1) | O(1)** |
| Memory overhead | Low | Medium | Low-Medium |

*O(1) if tail pointer is maintained
**Requires previous node reference for singly linked lists

**Advantages of Linked Lists**:
- ✅ Dynamic size: no pre-allocation needed
- ✅ Efficient insertion/deletion at beginning: O(1)
- ✅ No wasted capacity (unlike dynamic arrays)
- ✅ Easy to implement complex structures (stacks, queues)

**Disadvantages of Linked Lists**:
- ❌ No random access: must traverse from head (O(n))
- ❌ Extra memory for pointers
- ❌ Poor cache performance: nodes scattered in memory
- ❌ More complex to implement and debug

**Use Cases**:
- **Singly linked list**: When memory is tight, only forward traversal needed (undo functionality, simple stacks)
- **Doubly linked list**: When bidirectional traversal needed (browser history with back/forward, LRU cache, text editors)
- **Circular linked list**: Round-robin scheduling, multiplayer games (turn rotation), circular buffers

### Stacks and LIFO

A **stack** is a linear data structure that follows the **LIFO (Last In, First Out)** principle. The last element added is the first one to be removed, like a stack of plates.

**Core Operations**:
- **push(item)**: Add an item to the top - O(1)
- **pop()**: Remove and return the top item - O(1)
- **peek()** or **top()**: View the top item without removing - O(1)
- **is_empty()**: Check if stack is empty - O(1)
- **size()**: Get the number of elements - O(1)

**Visual Representation**:
```
Push operations:          Pop operations:
    Push 30                   Pop → 30
    ↓                         ↑
  ┌───┐                     ┌───┐
  │30 │ ← top              │20 │ ← top
  ├───┤                     ├───┤
  │20 │                     │10 │
  ├───┤                     └───┘
  │10 │
  └───┘
```

**Implementation Using Array**:
```python
class ArrayStack:
    def __init__(self):
        self._data = []

    def push(self, item):
        self._data.append(item)  # O(1) amortized

    def pop(self):
        if self.is_empty():
            raise IndexError("pop from empty stack")
        return self._data.pop()  # O(1)

    def peek(self):
        if self.is_empty():
            raise IndexError("peek from empty stack")
        return self._data[-1]  # O(1)

    def is_empty(self):
        return len(self._data) == 0

    def size(self):
        return len(self._data)
```

**Implementation Using Linked List**:
```python
class LinkedStack:
    def __init__(self):
        self._head = None
        self._size = 0

    def push(self, item):
        new_node = Node(item)
        new_node.next = self._head
        self._head = new_node
        self._size += 1  # O(1)

    def pop(self):
        if self.is_empty():
            raise IndexError("pop from empty stack")
        item = self._head.data
        self._head = self._head.next
        self._size -= 1
        return item  # O(1)

    def peek(self):
        if self.is_empty():
            raise IndexError("peek from empty stack")
        return self._head.data

    def is_empty(self):
        return self._head is None

    def size(self):
        return self._size
```

**Common Applications**:

**1. Function Call Stack**:
```python
def factorial(n):
    if n <= 1:
        return 1
    return n * factorial(n - 1)

# Call stack for factorial(3):
# factorial(3)
#   ├─ factorial(2)
#   │   ├─ factorial(1)  ← Top of stack
#   │   │   └─ returns 1
#   │   └─ returns 2 * 1 = 2
#   └─ returns 3 * 2 = 6
```

**2. Expression Evaluation**:
```python
def evaluate_postfix(expression):
    """Evaluate postfix expression: '3 4 + 2 *' → 14"""
    stack = []
    for token in expression.split():
        if token.isdigit():
            stack.append(int(token))
        else:
            b = stack.pop()
            a = stack.pop()
            if token == '+':
                stack.append(a + b)
            elif token == '*':
                stack.append(a * b)
            # ... other operators
    return stack.pop()

# Example: "3 4 + 2 *"
# Step 1: push 3         → [3]
# Step 2: push 4         → [3, 4]
# Step 3: +, pop 4,3     → [7]
# Step 4: push 2         → [7, 2]
# Step 5: *, pop 2,7     → [14]
# Result: 14
```

**3. Balanced Parentheses**:
```python
def is_balanced(expression):
    """Check if parentheses are balanced: '([{}])' → True"""
    stack = []
    pairs = {'(': ')', '[': ']', '{': '}'}

    for char in expression:
        if char in pairs:
            stack.append(char)  # Opening bracket
        elif char in pairs.values():
            if not stack or pairs[stack.pop()] != char:
                return False  # Closing bracket doesn't match

    return len(stack) == 0  # All opened brackets closed?

# Examples:
# "([{}])" → True  (properly nested)
# "([)]"   → False (not properly nested)
# "((("    → False (unclosed)
```

**4. Undo/Redo Functionality**:
```python
class TextEditor:
    def __init__(self):
        self.text = ""
        self.undo_stack = []
        self.redo_stack = []

    def write(self, text):
        self.undo_stack.append(self.text)
        self.text += text
        self.redo_stack.clear()  # Clear redo when new action taken

    def undo(self):
        if self.undo_stack:
            self.redo_stack.append(self.text)
            self.text = self.undo_stack.pop()

    def redo(self):
        if self.redo_stack:
            self.undo_stack.append(self.text)
            self.text = self.redo_stack.pop()

# Usage:
editor = TextEditor()
editor.write("Hello")     # text = "Hello"
editor.write(" World")    # text = "Hello World"
editor.undo()             # text = "Hello"
editor.redo()             # text = "Hello World"
```

**5. Browser History (Back Button)**:
```python
class BrowserHistory:
    def __init__(self):
        self.back_stack = []
        self.forward_stack = []
        self.current_page = "home"

    def visit(self, url):
        self.back_stack.append(self.current_page)
        self.current_page = url
        self.forward_stack.clear()

    def back(self):
        if self.back_stack:
            self.forward_stack.append(self.current_page)
            self.current_page = self.back_stack.pop()

    def forward(self):
        if self.forward_stack:
            self.back_stack.append(self.current_page)
            self.current_page = self.forward_stack.pop()
```

**Stack vs Array**:
- Stack is more **restrictive** (only top access)
- This restriction is **intentional** and useful for many algorithms
- Prevents accidental modification of internal elements

**When to use stacks**:
- Depth-first search (DFS) in graphs
- Backtracking algorithms
- Parsing expressions and syntax
- Managing function calls and recursion
- Undo mechanisms
- Browser navigation

### Queues and FIFO

A **queue** is a linear data structure that follows the **FIFO (First In, First Out)** principle. The first element added is the first one to be removed, like a line of people waiting.

**Core Operations**:
- **enqueue(item)**: Add an item to the rear - O(1)
- **dequeue()**: Remove and return the front item - O(1)
- **front()** or **peek()**: View the front item - O(1)
- **is_empty()**: Check if queue is empty - O(1)
- **size()**: Get the number of elements - O(1)

**Visual Representation**:
```
Enqueue operations:
Front                     Rear
  ↓                       ↓
┌───┬───┬───┬───┐    Enqueue 40
│10 │20 │30 │   │    ───────→
└───┴───┴───┴───┘
     ↓
┌───┬───┬───┬───┐
│10 │20 │30 │40 │
└───┴───┴───┴───┘

Dequeue operations:
  ↓
┌───┬───┬───┬───┐    Dequeue
│10 │20 │30 │40 │    ───────→ Returns 10
└───┴───┴───┴───┘
         ↓
     ┌───┬───┬───┐
     │20 │30 │40 │
     └───┴───┴───┘
```

**Implementation Using List (Inefficient)**:
```python
class NaiveQueue:
    """Simple but inefficient queue"""
    def __init__(self):
        self._data = []

    def enqueue(self, item):
        self._data.append(item)  # O(1) - add to end

    def dequeue(self):
        if self.is_empty():
            raise IndexError("dequeue from empty queue")
        return self._data.pop(0)  # O(n) - BAD! Must shift all elements

    def is_empty(self):
        return len(self._data) == 0
```

**Implementation Using collections.deque (Efficient)**:
```python
from collections import deque

class Queue:
    """Efficient queue using deque"""
    def __init__(self):
        self._data = deque()

    def enqueue(self, item):
        self._data.append(item)  # O(1)

    def dequeue(self):
        if self.is_empty():
            raise IndexError("dequeue from empty queue")
        return self._data.popleft()  # O(1) - efficient!

    def front(self):
        if self.is_empty():
            raise IndexError("front from empty queue")
        return self._data[0]

    def is_empty(self):
        return len(self._data) == 0

    def size(self):
        return len(self._data)
```

**Implementation Using Linked List**:
```python
class LinkedQueue:
    def __init__(self):
        self._head = None
        self._tail = None
        self._size = 0

    def enqueue(self, item):
        new_node = Node(item)
        if self._tail is None:
            self._head = self._tail = new_node
        else:
            self._tail.next = new_node
            self._tail = new_node
        self._size += 1  # O(1)

    def dequeue(self):
        if self.is_empty():
            raise IndexError("dequeue from empty queue")
        item = self._head.data
        self._head = self._head.next
        if self._head is None:
            self._tail = None
        self._size -= 1
        return item  # O(1)

    def front(self):
        if self.is_empty():
            raise IndexError("front from empty queue")
        return self._head.data

    def is_empty(self):
        return self._head is None

    def size(self):
        return self._size
```

**Common Applications**:

**1. Task Scheduling**:
```python
class TaskScheduler:
    def __init__(self):
        self.queue = Queue()

    def add_task(self, task):
        self.queue.enqueue(task)
        print(f"Task '{task}' added to queue")

    def process_next_task(self):
        if not self.queue.is_empty():
            task = self.queue.dequeue()
            print(f"Processing task: '{task}'")
            return task
        return None

# Usage:
scheduler = TaskScheduler()
scheduler.add_task("Send email")
scheduler.add_task("Generate report")
scheduler.add_task("Backup database")
scheduler.process_next_task()  # Processes "Send email" first
```

**2. Breadth-First Search (BFS)**:
```python
def bfs(graph, start):
    """Explore graph level by level"""
    visited = set()
    queue = Queue()
    queue.enqueue(start)
    visited.add(start)

    while not queue.is_empty():
        node = queue.dequeue()
        print(node, end=" ")

        for neighbor in graph[node]:
            if neighbor not in visited:
                visited.add(neighbor)
                queue.enqueue(neighbor)

# Example graph (adjacency list):
#     1
#    / \
#   2   3
#  / \
# 4   5

graph = {
    1: [2, 3],
    2: [4, 5],
    3: [],
    4: [],
    5: []
}
bfs(graph, 1)  # Output: 1 2 3 4 5 (level by level)
```

**3. Print Queue**:
```python
class PrintQueue:
    def __init__(self):
        self.queue = Queue()

    def add_document(self, document):
        self.queue.enqueue(document)
        print(f"Added to print queue: {document}")

    def print_next(self):
        if not self.queue.is_empty():
            doc = self.queue.dequeue()
            print(f"Printing: {doc}")
        else:
            print("Print queue is empty")

# Usage:
printer = PrintQueue()
printer.add_document("Report.pdf")
printer.add_document("Invoice.docx")
printer.add_document("Photo.jpg")
printer.print_next()  # Prints "Report.pdf" first
```

**4. Customer Service Queue**:
```python
class CustomerService:
    def __init__(self):
        self.queue = Queue()
        self.ticket_number = 1

    def join_queue(self, customer_name):
        ticket = f"#{self.ticket_number} - {customer_name}"
        self.queue.enqueue(ticket)
        self.ticket_number += 1
        print(f"{customer_name} joined queue: ticket {ticket}")
        return ticket

    def serve_next(self):
        if not self.queue.is_empty():
            customer = self.queue.dequeue()
            print(f"Now serving: {customer}")
        else:
            print("No customers in queue")

    def queue_status(self):
        print(f"Customers waiting: {self.queue.size()}")

# Usage:
service = CustomerService()
service.join_queue("Alice")
service.join_queue("Bob")
service.join_queue("Charlie")
service.queue_status()  # 3 customers
service.serve_next()    # Serves Alice first
```

**When to use queues**:
- Breadth-first search (BFS) in graphs
- Task scheduling and job queues
- Request handling in servers
- Buffer for data streaming
- Message queues in distributed systems
- Simulation of real-world waiting lines

### Deque and circular queue

**Deque (Double-Ended Queue)** and **Circular Queue** are specialized queue variants that provide additional functionality.

**Deque (Pronounced "deck")**:

A **deque** allows insertion and deletion at both ends (front and rear). It combines the capabilities of both stacks and queues.

**Operations**:
- **add_front(item)**: Add item to front - O(1)
- **add_rear(item)**: Add item to rear - O(1)
- **remove_front()**: Remove from front - O(1)
- **remove_rear()**: Remove from rear - O(1)
- **front()**: View front item - O(1)
- **rear()**: View rear item - O(1)

**Visual Representation**:
```
      add_front    add_rear
           ↓         ↓
    ┌───┬───┬───┬───┐
    │10 │20 │30 │40 │
    └───┴───┴───┴───┘
       ↑         ↑
  remove_front  remove_rear
```

**Implementation Using Python's collections.deque**:
```python
from collections import deque

class Deque:
    def __init__(self):
        self._data = deque()

    def add_front(self, item):
        self._data.appendleft(item)  # O(1)

    def add_rear(self, item):
        self._data.append(item)  # O(1)

    def remove_front(self):
        if self.is_empty():
            raise IndexError("remove from empty deque")
        return self._data.popleft()  # O(1)

    def remove_rear(self):
        if self.is_empty():
            raise IndexError("remove from empty deque")
        return self._data.pop()  # O(1)

    def front(self):
        if self.is_empty():
            raise IndexError("front from empty deque")
        return self._data[0]

    def rear(self):
        if self.is_empty():
            raise IndexError("rear from empty deque")
        return self._data[-1]

    def is_empty(self):
        return len(self._data) == 0

    def size(self):
        return len(self._data)
```

**Deque Applications**:

**1. Palindrome Checker**:
```python
def is_palindrome(string):
    """Check if string is palindrome using deque"""
    dq = deque(string.lower().replace(" ", ""))

    while len(dq) > 1:
        if dq.popleft() != dq.pop():  # Compare front and rear
            return False
    return True

# Examples:
print(is_palindrome("racecar"))  # True
print(is_palindrome("hello"))    # False
print(is_palindrome("A man a plan a canal Panama"))  # True
```

**2. Sliding Window Maximum**:
```python
def sliding_window_max(arr, k):
    """Find maximum in each window of size k"""
    result = []
    dq = deque()  # Store indices

    for i in range(len(arr)):
        # Remove elements outside window
        while dq and dq[0] <= i - k:
            dq.popleft()

        # Remove elements smaller than current (they won't be max)
        while dq and arr[dq[-1]] < arr[i]:
            dq.pop()

        dq.append(i)

        if i >= k - 1:
            result.append(arr[dq[0]])  # Front has index of max

    return result

# Example: arr = [1,3,-1,-3,5,3,6,7], k = 3
# Windows: [1,3,-1] [3,-1,-3] [-1,-3,5] [-3,5,3] [5,3,6] [3,6,7]
# Maxima:     3        3          5         5        6       7
```

**3. Browser History with Fast Back/Forward**:
```python
class BrowserHistory:
    def __init__(self):
        self.history = deque()
        self.history.append("home")
        self.current_index = 0

    def visit(self, url):
        # Remove any forward history
        while len(self.history) > self.current_index + 1:
            self.history.pop()
        self.history.append(url)
        self.current_index += 1

    def back(self):
        if self.current_index > 0:
            self.current_index -= 1
        return self.history[self.current_index]

    def forward(self):
        if self.current_index < len(self.history) - 1:
            self.current_index += 1
        return self.history[self.current_index]
```

**Circular Queue**:

A **circular queue** is a queue that reuses empty spaces when elements are dequeued. The rear wraps around to the beginning when it reaches the end of the array.

**Why Circular Queue?**

In a regular array-based queue:
- Dequeue leaves empty spaces at the front
- Eventually run out of space even if array isn't full
- Circular queue solves this by wrapping around

**Visual Representation**:
```
Initial state (size=5):
Front=0, Rear=0
┌───┬───┬───┬───┬───┐
│   │   │   │   │   │
└───┴───┴───┴───┴───┘
  0   1   2   3   4

After enqueue(10, 20, 30):
Front=0, Rear=3
┌───┬───┬───┬───┬───┐
│10 │20 │30 │   │   │
└───┴───┴───┴───┴───┘
  0   1   2   3   4

After dequeue() twice:
Front=2, Rear=3
┌───┬───┬───┬───┬───┐
│   │   │30 │   │   │
└───┴───┴───┴───┴───┘
  0   1   2   3   4

After enqueue(40, 50, 60):
Front=2, Rear=1 (wrapped around!)
┌───┬───┬───┬───┬───┐
│60 │   │30 │40 │50 │
└───┴───┴───┴───┴───┘
  0   1   2   3   4
     ↑Rear    ↑Front
```

**Implementation**:
```python
class CircularQueue:
    def __init__(self, capacity):
        self._data = [None] * capacity
        self._front = 0
        self._size = 0
        self._capacity = capacity

    def enqueue(self, item):
        if self._size == self._capacity:
            raise OverflowError("Queue is full")

        rear = (self._front + self._size) % self._capacity
        self._data[rear] = item
        self._size += 1

    def dequeue(self):
        if self.is_empty():
            raise IndexError("dequeue from empty queue")

        item = self._data[self._front]
        self._data[self._front] = None  # Optional: clear reference
        self._front = (self._front + 1) % self._capacity  # Wrap around
        self._size -= 1
        return item

    def front(self):
        if self.is_empty():
            raise IndexError("front from empty queue")
        return self._data[self._front]

    def is_empty(self):
        return self._size == 0

    def is_full(self):
        return self._size == self._capacity

    def size(self):
        return self._size

# Usage:
cq = CircularQueue(5)
cq.enqueue(10)
cq.enqueue(20)
cq.enqueue(30)
print(cq.dequeue())  # 10
print(cq.dequeue())  # 20
cq.enqueue(40)
cq.enqueue(50)
cq.enqueue(60)  # Now using wrapped-around space
```

**Circular Queue Applications**:
- **CPU scheduling**: Round-robin scheduling
- **Buffering**: Audio/video streaming buffers
- **Traffic systems**: Traffic light control
- **Memory management**: Circular buffers in embedded systems

**Comparison**:

| Feature | Queue | Deque | Circular Queue |
|---------|-------|-------|----------------|
| Add to front | ❌ | ✅ O(1) | ❌ |
| Add to rear | ✅ O(1) | ✅ O(1) | ✅ O(1) |
| Remove from front | ✅ O(1) | ✅ O(1) | ✅ O(1) |
| Remove from rear | ❌ | ✅ O(1) | ❌ |
| Fixed size | No | No | Yes |
| Space efficiency | Medium | Medium | High (reuses space) |
| Use case | FIFO only | Flexible both ends | Fixed capacity FIFO |

### Priority queue overview

A **priority queue** is an abstract data type where each element has an associated priority. Elements with higher priority are dequeued before elements with lower priority, regardless of insertion order.

**Key Difference from Regular Queue**:
- Regular queue: FIFO (first in, first out)
- Priority queue: "Highest priority out first"

**Operations**:
- **insert(item, priority)**: Add item with priority - O(log n)
- **extract_min()** or **extract_max()**: Remove and return highest priority item - O(log n)
- **peek()**: View highest priority item - O(1)
- **is_empty()**: Check if empty - O(1)
- **size()**: Get number of elements - O(1)

**Visual Representation** (Min Priority Queue):
```
Regular Queue:          Priority Queue:
Enqueue 5, 3, 8, 1     Insert 5, 3, 8, 1
┌───┬───┬───┬───┐      ┌───┬───┬───┬───┐
│5  │3  │8  │1  │      │1  │3  │5  │8  │  (sorted by priority)
└───┴───┴───┴───┘      └───┴───┴───┴───┘
Dequeue → 5            Extract_min → 1
```

**Implementation Using Python's heapq (Min-Heap)**:
```python
import heapq

class PriorityQueue:
    def __init__(self):
        self._heap = []
        self._index = 0  # For breaking ties

    def insert(self, item, priority):
        # heapq is min-heap, so lower priority value = higher priority
        heapq.heappush(self._heap, (priority, self._index, item))
        self._index += 1  # Ensure FIFO for same priorities

    def extract_min(self):
        if self.is_empty():
            raise IndexError("extract from empty priority queue")
        priority, _, item = heapq.heappop(self._heap)
        return item

    def peek(self):
        if self.is_empty():
            raise IndexError("peek from empty priority queue")
        return self._heap[0][2]

    def is_empty(self):
        return len(self._heap) == 0

    def size(self):
        return len(self._heap)

# Usage:
pq = PriorityQueue()
pq.insert("Low priority task", priority=5)
pq.insert("High priority task", priority=1)
pq.insert("Medium priority task", priority=3)

print(pq.extract_min())  # "High priority task" (priority 1)
print(pq.extract_min())  # "Medium priority task" (priority 3)
print(pq.extract_min())  # "Low priority task" (priority 5)
```

**Max Priority Queue** (for max-heap behavior):
```python
class MaxPriorityQueue:
    def __init__(self):
        self._heap = []
        self._index = 0

    def insert(self, item, priority):
        # Negate priority to use min-heap as max-heap
        heapq.heappush(self._heap, (-priority, self._index, item))
        self._index += 1

    def extract_max(self):
        if self.is_empty():
            raise IndexError("extract from empty priority queue")
        neg_priority, _, item = heapq.heappop(self._heap)
        return item

    def is_empty(self):
        return len(self._heap) == 0

# Usage:
max_pq = MaxPriorityQueue()
max_pq.insert("Task A", priority=5)
max_pq.insert("Task B", priority=10)
max_pq.insert("Task C", priority=3)

print(max_pq.extract_max())  # "Task B" (priority 10 - highest)
```

**Implementation Using Simple List** (Inefficient but simple):
```python
class SimplePriorityQueue:
    def __init__(self):
        self._data = []  # List of (priority, item) tuples

    def insert(self, item, priority):
        self._data.append((priority, item))  # O(1)

    def extract_min(self):
        if not self._data:
            raise IndexError("extract from empty priority queue")

        # Find minimum priority - O(n)
        min_index = 0
        for i in range(1, len(self._data)):
            if self._data[i][0] < self._data[min_index][0]:
                min_index = i

        priority, item = self._data.pop(min_index)  # O(n)
        return item

    # Total: O(n) for extract - inefficient!
```

**Common Applications**:

**1. Hospital Emergency Room**:
```python
class EmergencyRoom:
    def __init__(self):
        self.queue = PriorityQueue()

    def admit_patient(self, patient_name, severity):
        # Lower severity number = more critical
        self.queue.insert(patient_name, severity)
        print(f"Admitted {patient_name} (severity: {severity})")

    def treat_next_patient(self):
        if not self.queue.is_empty():
            patient = self.queue.extract_min()
            print(f"Treating: {patient}")
            return patient
        print("No patients waiting")

# Usage:
er = EmergencyRoom()
er.admit_patient("Alice", severity=5)     # Minor injury
er.admit_patient("Bob", severity=1)       # Critical
er.admit_patient("Charlie", severity=3)   # Moderate
er.treat_next_patient()  # Treats Bob first (critical)
er.treat_next_patient()  # Treats Charlie (moderate)
er.treat_next_patient()  # Treats Alice (minor)
```

**2. Dijkstra's Shortest Path Algorithm**:
```python
def dijkstra(graph, start):
    """Find shortest paths from start to all nodes"""
    distances = {node: float('inf') for node in graph}
    distances[start] = 0
    pq = PriorityQueue()
    pq.insert(start, 0)

    while not pq.is_empty():
        current = pq.extract_min()

        for neighbor, weight in graph[current]:
            distance = distances[current] + weight
            if distance < distances[neighbor]:
                distances[neighbor] = distance
                pq.insert(neighbor, distance)

    return distances

# Example graph:
graph = {
    'A': [('B', 1), ('C', 4)],
    'B': [('C', 2), ('D', 5)],
    'C': [('D', 1)],
    'D': []
}
print(dijkstra(graph, 'A'))  # Shortest paths from A
```

**3. Task Scheduling with Deadlines**:
```python
class TaskScheduler:
    def __init__(self):
        self.pq = PriorityQueue()

    def add_task(self, task, deadline):
        # Earlier deadline = higher priority (lower number)
        self.pq.insert(task, deadline)
        print(f"Added: {task} (deadline: {deadline}h)")

    def do_next_task(self):
        if not self.pq.is_empty():
            task = self.pq.extract_min()
            print(f"Doing: {task}")
        else:
            print("No tasks")

# Usage:
scheduler = TaskScheduler()
scheduler.add_task("Write report", deadline=8)
scheduler.add_task("Reply to email", deadline=2)
scheduler.add_task("Review code", deadline=5)
scheduler.do_next_task()  # Reply to email (deadline 2h)
```

**4. Merge K Sorted Lists**:
```python
def merge_k_sorted_lists(lists):
    """Merge k sorted lists into one sorted list"""
    pq = PriorityQueue()
    result = []

    # Add first element from each list
    for i, lst in enumerate(lists):
        if lst:
            pq.insert((i, 0), lst[0])  # (list_index, element_index)

    while not pq.is_empty():
        list_idx, elem_idx = pq.extract_min()
        result.append(lists[list_idx][elem_idx])

        # Add next element from same list
        if elem_idx + 1 < len(lists[list_idx]):
            next_val = lists[list_idx][elem_idx + 1]
            pq.insert((list_idx, elem_idx + 1), next_val)

    return result

# Example:
lists = [[1, 4, 7], [2, 5, 8], [3, 6, 9]]
print(merge_k_sorted_lists(lists))  # [1, 2, 3, 4, 5, 6, 7, 8, 9]
```

**Complexity Comparison**:

| Implementation | Insert | Extract Min/Max | Peek | Space |
|----------------|--------|-----------------|------|-------|
| Unsorted List | O(1) | O(n) | O(n) | O(n) |
| Sorted List | O(n) | O(1) | O(1) | O(n) |
| Binary Heap | O(log n) | O(log n) | O(1) | O(n) |
| Fibonacci Heap* | O(1) | O(log n) amortized | O(1) | O(n) |

*Advanced structure, rarely used in practice

**When to use priority queues**:
- Event-driven simulation (process next event by time)
- Job scheduling (process highest priority jobs)
- Graph algorithms (Dijkstra's, Prim's, A*)
- Huffman coding (build optimal tree)
- Median maintenance (using two heaps)

### Use cases and trade-offs

Understanding when to use each linear data structure is crucial for writing efficient code.

**Quick Decision Guide**:

```
Need random access by index?
├─ YES → Use Array/Dynamic Array
└─ NO → Continue...
    │
    Need frequent insertion/deletion at ends only?
    ├─ Beginning only → Use Linked List
    ├─ End only → Use Array or Linked List
    └─ Both ends → Use Deque
        │
        Need LIFO (Last In, First Out)?
        ├─ YES → Use Stack
        └─ NO → Continue...
            │
            Need FIFO (First In, First Out)?
            ├─ YES, simple → Use Queue
            ├─ YES, priority-based → Use Priority Queue
            └─ Both LIFO and FIFO → Use Deque
```

**Detailed Comparison Table**:

| Structure | Best For | Strengths | Weaknesses | Time Complexity |
|-----------|----------|-----------|------------|-----------------|
| **Array** | Random access, known size | • O(1) access<br>• Cache-friendly<br>• Simple | • Fixed size<br>• O(n) insertion/deletion | Access: O(1)<br>Insert: O(n) |
| **Dynamic Array** | Random access, unknown size | • O(1) access<br>• Flexible size<br>• Cache-friendly | • O(n) insertion/deletion<br>• Occasional resize | Access: O(1)<br>Append: O(1) amortized |
| **Linked List** | Frequent insertions/deletions | • O(1) insert/delete at known position<br>• No resize needed | • O(n) access<br>• Extra memory for pointers<br>• Poor cache | Access: O(n)<br>Insert: O(1)* |
| **Doubly Linked List** | Bidirectional traversal | • O(1) insert/delete at both ends<br>• Easy reverse | • More memory (2 pointers)<br>• O(n) access | Same as singly, but bidirectional |
| **Stack** | LIFO operations, recursion | • Simple interface<br>• O(1) all operations | • Restricted access (top only) | All ops: O(1) |
| **Queue** | FIFO operations, BFS | • Fair ordering<br>• O(1) all operations | • Restricted access (ends only) | All ops: O(1) |
| **Deque** | Both ends access | • Flexible<br>• O(1) at both ends | • Slightly more complex | All end ops: O(1) |
| **Priority Queue** | Priority-based processing | • Always get highest priority<br>• Efficient for many items | • O(log n) operations<br>• No random access | Insert/Extract: O(log n) |
| **Circular Queue** | Fixed-size buffering | • Space efficient<br>• No wasted space | • Fixed capacity<br>• More complex implementation | All ops: O(1) |

*assuming position is known

**Real-World Scenario Decision Making**:

**Scenario 1: Student Grade Management System**
```
Requirements:
- Store grades for 100 students
- Frequently access grades by student ID
- Occasionally add/remove students
- Need to calculate average

Choice: Dynamic Array (Python list)
Reason:
- Known approximate size
- Need random access by index
- Insertions/deletions are rare
- Simple iteration for calculations
```

**Scenario 2: Text Editor Undo/Redo**
```
Requirements:
- Store history of text states
- Undo: revert to previous state
- Redo: go forward in history
- Clear redo stack on new edit

Choice: Two Stacks
Reason:
- Undo stack: stores previous states
- Redo stack: stores undone states
- LIFO matches undo/redo behavior
- O(1) push/pop operations
```

**Scenario 3: Web Server Request Handler**
```
Requirements:
- Handle requests in order received
- Process one request at a time
- Fair processing (first come, first served)

Choice: Queue
Reason:
- FIFO ensures fairness
- Simple enqueue/dequeue
- Natural model for waiting line
```

**Scenario 4: Music Player Playlist**
```
Requirements:
- Play songs in order
- Skip to next song
- Go back to previous song
- Add songs at end or beginning

Choice: Doubly Linked List or Deque
Reason:
- Easy traversal both directions
- Efficient add at both ends
- Don't need random access (no "jump to song 37")
- Can easily insert/remove anywhere
```

**Scenario 5: CPU Process Scheduling**
```
Requirements:
- Multiple processes with different priorities
- Always run highest priority process
- Processes arrive dynamically

Choice: Priority Queue
Reason:
- Need priority-based selection
- Efficient insertion of new processes
- O(log n) is acceptable for this use case
```

**Scenario 6: Real-time Video Streaming Buffer**
```
Requirements:
- Fixed buffer size (memory constraint)
- Continuous read/write
- Circular behavior (reuse freed space)

Choice: Circular Queue
Reason:
- Fixed size matches constraint
- Efficient space reuse
- Constant-time operations
- Models circular buffer perfectly
```

**Scenario 7: Expression Parser (Calculator)**
```
Requirements:
- Parse mathematical expressions
- Handle operator precedence
- Check balanced parentheses

Choice: Stack
Reason:
- Natural for nested structures
- Easy parenthesis matching
- Operator precedence handling
- Postfix evaluation
```

**Trade-off Matrix**:

| Factor | Optimize For | Choose |
|--------|-------------|---------|
| **Access Pattern** | Random access | Array/Dynamic Array |
| | Sequential only | Linked List |
| | Both ends | Deque |
| | One end | Stack/Queue |
| **Memory** | Minimize overhead | Array |
| | Flexible size | Linked List/Dynamic Array |
| | Fixed budget | Circular Queue |
| **Operations** | Lots of insertions | Linked List |
| | Mostly reads | Array |
| | Priority-based | Priority Queue |
| **Predictability** | Consistent O(1) | Linked List |
| | Amortized O(1) OK | Dynamic Array |
| **Cache Performance** | Maximize | Array/Dynamic Array |
| | Doesn't matter | Linked List |

**Common Mistakes**:

❌ **Using list.pop(0) for queue** → O(n) operation!
```python
# Bad
queue = []
queue.append(1)
queue.pop(0)  # O(n) - shifts all elements!

# Good
from collections import deque
queue = deque()
queue.append(1)
queue.popleft()  # O(1)
```

❌ **Using linked list when you need random access** → O(n) access!
```python
# Bad - if you need frequent access by index
linked_list = LinkedList()
item = linked_list.get(100)  # O(n) traversal

# Good
array = [...]
item = array[100]  # O(1)
```

❌ **Not considering cache performance** → Slower in practice
```python
# Array: better cache locality
# [1][2][3][4][5] - contiguous in memory

# Linked List: poor cache locality
# [1]→[5]→[3]→[2]→[4] - scattered in memory
```

**Performance Summary**:

| Structure | Access | Insert (beginning) | Insert (end) | Delete (beginning) | Delete (end) | Search |
|-----------|--------|-------------------|--------------|-------------------|--------------|--------|
| Array | O(1) | O(n) | O(n) | O(n) | O(n) | O(n) |
| Dynamic Array | O(1) | O(n) | O(1)* | O(n) | O(1) | O(n) |
| Linked List | O(n) | O(1) | O(n)** | O(1) | O(n) | O(n) |
| Doubly Linked | O(n) | O(1) | O(1) | O(1) | O(1) | O(n) |
| Stack | N/A | O(1) | N/A | O(1) | N/A | N/A |
| Queue | N/A | N/A | O(1) | O(1) | N/A | N/A |
| Deque | N/A | O(1) | O(1) | O(1) | O(1) | N/A |
| Priority Queue | N/A | O(log n) | O(log n) | O(log n) | N/A | O(n) |

*amortized
**O(1) with tail pointer

### Implementation from scratch

Understanding how to implement linear data structures from scratch solidifies your understanding of how they work internally.

**1. Dynamic Array Implementation**:

```python
class DynamicArray:
    """Array that automatically resizes when full"""

    def __init__(self, capacity=4):
        self._capacity = capacity
        self._size = 0
        self._data = self._make_array(capacity)

    def __len__(self):
        return self._size

    def __getitem__(self, index):
        """Access element by index"""
        if not 0 <= index < self._size:
            raise IndexError("index out of range")
        return self._data[index]

    def __setitem__(self, index, value):
        """Set element at index"""
        if not 0 <= index < self._size:
            raise IndexError("index out of range")
        self._data[index] = value

    def append(self, value):
        """Add element to end - O(1) amortized"""
        if self._size == self._capacity:
            self._resize(2 * self._capacity)  # Double capacity
        self._data[self._size] = value
        self._size += 1

    def insert(self, index, value):
        """Insert element at index - O(n)"""
        if not 0 <= index <= self._size:
            raise IndexError("index out of range")

        if self._size == self._capacity:
            self._resize(2 * self._capacity)

        # Shift elements to right
        for i in range(self._size, index, -1):
            self._data[i] = self._data[i - 1]

        self._data[index] = value
        self._size += 1

    def remove(self, value):
        """Remove first occurrence of value - O(n)"""
        for i in range(self._size):
            if self._data[i] == value:
                # Shift elements to left
                for j in range(i, self._size - 1):
                    self._data[j] = self._data[j + 1]
                self._data[self._size - 1] = None
                self._size -= 1
                return True
        return False

    def pop(self, index=-1):
        """Remove and return element at index - O(n)"""
        if index == -1:
            index = self._size - 1

        if not 0 <= index < self._size:
            raise IndexError("index out of range")

        value = self._data[index]

        # Shift elements to left
        for i in range(index, self._size - 1):
            self._data[i] = self._data[i + 1]

        self._data[self._size - 1] = None
        self._size -= 1

        # Shrink if too empty (optional optimization)
        if self._size < self._capacity // 4:
            self._resize(self._capacity // 2)

        return value

    def _resize(self, new_capacity):
        """Resize internal array - O(n)"""
        new_data = self._make_array(new_capacity)
        for i in range(self._size):
            new_data[i] = self._data[i]
        self._data = new_data
        self._capacity = new_capacity

    def _make_array(self, capacity):
        """Create low-level array"""
        import ctypes
        return (capacity * ctypes.py_object)()

    def __str__(self):
        return '[' + ', '.join(str(self._data[i]) for i in range(self._size)) + ']'

# Usage:
arr = DynamicArray()
arr.append(10)
arr.append(20)
arr.append(30)
print(arr)  # [10, 20, 30]
arr.insert(1, 15)
print(arr)  # [10, 15, 20, 30]
arr.remove(15)
print(arr)  # [10, 20, 30]
```

**2. Singly Linked List Implementation**:

```python
class Node:
    """Node for singly linked list"""
    def __init__(self, data):
        self.data = data
        self.next = None

class SinglyLinkedList:
    """Singly linked list with head pointer"""

    def __init__(self):
        self._head = None
        self._size = 0

    def __len__(self):
        return self._size

    def is_empty(self):
        return self._head is None

    def prepend(self, data):
        """Add element at beginning - O(1)"""
        new_node = Node(data)
        new_node.next = self._head
        self._head = new_node
        self._size += 1

    def append(self, data):
        """Add element at end - O(n)"""
        new_node = Node(data)

        if self.is_empty():
            self._head = new_node
        else:
            current = self._head
            while current.next:
                current = current.next
            current.next = new_node

        self._size += 1

    def insert_after(self, prev_node, data):
        """Insert after given node - O(1)"""
        if prev_node is None:
            raise ValueError("Previous node cannot be None")

        new_node = Node(data)
        new_node.next = prev_node.next
        prev_node.next = new_node
        self._size += 1

    def delete(self, data):
        """Delete first occurrence of data - O(n)"""
        if self.is_empty():
            return False

        # Special case: head contains data
        if self._head.data == data:
            self._head = self._head.next
            self._size -= 1
            return True

        # Search for node
        current = self._head
        while current.next:
            if current.next.data == data:
                current.next = current.next.next
                self._size -= 1
                return True
            current = current.next

        return False

    def find(self, data):
        """Find first node with data - O(n)"""
        current = self._head
        while current:
            if current.data == data:
                return current
            current = current.next
        return None

    def reverse(self):
        """Reverse the linked list - O(n)"""
        prev = None
        current = self._head

        while current:
            next_node = current.next
            current.next = prev
            prev = current
            current = next_node

        self._head = prev

    def __str__(self):
        """String representation - O(n)"""
        if self.is_empty():
            return "[]"

        result = []
        current = self._head
        while current:
            result.append(str(current.data))
            current = current.next
        return " -> ".join(result)

# Usage:
ll = SinglyLinkedList()
ll.append(10)
ll.append(20)
ll.append(30)
ll.prepend(5)
print(ll)  # 5 -> 10 -> 20 -> 30
ll.reverse()
print(ll)  # 30 -> 20 -> 10 -> 5
```

**3. Doubly Linked List Implementation**:

```python
class DoublyNode:
    """Node for doubly linked list"""
    def __init__(self, data):
        self.data = data
        self.next = None
        self.prev = None

class DoublyLinkedList:
    """Doubly linked list with head and tail pointers"""

    def __init__(self):
        self._head = None
        self._tail = None
        self._size = 0

    def __len__(self):
        return self._size

    def is_empty(self):
        return self._head is None

    def prepend(self, data):
        """Add element at beginning - O(1)"""
        new_node = DoublyNode(data)

        if self.is_empty():
            self._head = self._tail = new_node
        else:
            new_node.next = self._head
            self._head.prev = new_node
            self._head = new_node

        self._size += 1

    def append(self, data):
        """Add element at end - O(1)"""
        new_node = DoublyNode(data)

        if self.is_empty():
            self._head = self._tail = new_node
        else:
            new_node.prev = self._tail
            self._tail.next = new_node
            self._tail = new_node

        self._size += 1

    def delete_node(self, node):
        """Delete specific node - O(1) if we have reference"""
        if node is None:
            return

        # Update previous node
        if node.prev:
            node.prev.next = node.next
        else:
            self._head = node.next

        # Update next node
        if node.next:
            node.next.prev = node.prev
        else:
            self._tail = node.prev

        self._size -= 1

    def delete(self, data):
        """Delete first occurrence of data - O(n)"""
        current = self._head
        while current:
            if current.data == data:
                self.delete_node(current)
                return True
            current = current.next
        return False

    def __str__(self):
        """Forward string representation"""
        if self.is_empty():
            return "[]"

        result = []
        current = self._head
        while current:
            result.append(str(current.data))
            current = current.next
        return " <-> ".join(result)

    def reverse_str(self):
        """Backward string representation"""
        if self.is_empty():
            return "[]"

        result = []
        current = self._tail
        while current:
            result.append(str(current.data))
            current = current.prev
        return " <-> ".join(result)

# Usage:
dll = DoublyLinkedList()
dll.append(10)
dll.append(20)
dll.append(30)
print(dll)  # 10 <-> 20 <-> 30
print(dll.reverse_str())  # 30 <-> 20 <-> 10
dll.delete(20)
print(dll)  # 10 <-> 30
```

**4. Stack Implementation (Array-based)**:

```python
class Stack:
    """Stack using Python list"""

    def __init__(self):
        self._items = []

    def push(self, item):
        """Add item to top - O(1)"""
        self._items.append(item)

    def pop(self):
        """Remove and return top item - O(1)"""
        if self.is_empty():
            raise IndexError("pop from empty stack")
        return self._items.pop()

    def peek(self):
        """Return top item without removing - O(1)"""
        if self.is_empty():
            raise IndexError("peek from empty stack")
        return self._items[-1]

    def is_empty(self):
        return len(self._items) == 0

    def size(self):
        return len(self._items)

    def __str__(self):
        return f"Stack({self._items})"

# Usage:
stack = Stack()
stack.push(10)
stack.push(20)
stack.push(30)
print(stack.pop())  # 30 (LIFO)
print(stack.peek())  # 20
```

**5. Queue Implementation (Deque-based)**:

```python
from collections import deque

class Queue:
    """Efficient queue using deque"""

    def __init__(self):
        self._items = deque()

    def enqueue(self, item):
        """Add item to rear - O(1)"""
        self._items.append(item)

    def dequeue(self):
        """Remove and return front item - O(1)"""
        if self.is_empty():
            raise IndexError("dequeue from empty queue")
        return self._items.popleft()

    def front(self):
        """Return front item without removing - O(1)"""
        if self.is_empty():
            raise IndexError("front from empty queue")
        return self._items[0]

    def is_empty(self):
        return len(self._items) == 0

    def size(self):
        return len(self._items)

    def __str__(self):
        return f"Queue({list(self._items)})"

# Usage:
queue = Queue()
queue.enqueue(10)
queue.enqueue(20)
queue.enqueue(30)
print(queue.dequeue())  # 10 (FIFO)
print(queue.front())  # 20
```

**Key Implementation Insights**:

1. **Dynamic Array**: Uses amortized analysis - occasional O(n) resize, but O(1) on average
2. **Linked Lists**: Trade memory (pointers) for flexibility (easy insert/delete)
3. **Doubly Linked List**: Extra pointer enables O(1) operations at both ends
4. **Stack**: Restricting access to one end makes it simpler and more efficient
5. **Queue**: Use deque or linked list for O(1) operations at both ends

These implementations demonstrate the core concepts. Production code would include additional features like iterators, better error handling, and more methods.
