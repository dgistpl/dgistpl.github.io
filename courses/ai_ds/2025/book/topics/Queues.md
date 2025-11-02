---
layout: splash
author_profile: false
---


# Queues

FIFO structure for scheduling and buffering.

## Knowledge Points

### 1. Core operations: enqueue/dequeue

**Enqueue** (add to rear):
- Adds an element to the back/rear of the queue
- Time complexity: O(1)
- Example: `queue.enqueue(5)` adds 5 to the end

**Dequeue** (remove from front):
- Removes and returns the element at the front of the queue
- Time complexity: O(1)
- Maintains FIFO (First-In-First-Out) principle
- Example: `queue.dequeue()` removes the oldest element

**Additional operations**: `peek()`/`front()`, `isEmpty()`, `size()`

### 2. Circular queue and deque

**Circular Queue**:
- Uses fixed-size array with wrap-around using modulo arithmetic
- `rear = (rear + 1) % capacity`
- Efficiently reuses space after dequeue operations
- Prevents "false full" condition in linear queues

**Deque (Double-Ended Queue)**:
- Allows insertion/deletion at both ends
- Operations: `addFront()`, `addRear()`, `removeFront()`, `removeRear()`
- More flexible than standard queue
- Use cases: sliding window problems, palindrome checking

### 3. Priority queue overview

- Elements have associated priorities
- Higher priority elements dequeued first (regardless of insertion order)
- Typically implemented using **heaps** (binary heap)
- Operations: `insert()` O(log n), `extractMax/Min()` O(log n)
- Applications: task scheduling, Dijkstra's algorithm, A* search, event simulation

### 4. Producer-consumer patterns

- **Producer**: Generates data and enqueues it
- **Consumer**: Dequeues and processes data
- Queue acts as a **buffer** between different-speed processes
- Handles synchronization in concurrent systems
- Examples: print spooler, message queues, streaming data pipelines
- Prevents data loss when producer is faster than consumer

### 5. Queues in OS and networking

**Operating Systems**:
- CPU scheduling (ready queue, waiting queue)
- Process management
- I/O request buffering
- Interrupt handling

**Networking**:
- Packet routing and buffering
- Network switch queues
- Rate limiting and traffic shaping
- TCP send/receive buffers

### 6. Array vs linked-list implementation

**Array-based**:
- ✓ Cache-friendly, better locality
- ✓ Simple implementation
- ✗ Fixed size (or requires resizing)
- ✗ Wasted space in linear implementation

**Linked-list based**:
- ✓ Dynamic size, no wasted space
- ✓ No resizing overhead
- ✗ Extra memory for pointers
- ✗ Poor cache performance
- ✗ More complex memory management

### 7. Time/space complexity

**Time Complexity**:
- Enqueue: O(1)
- Dequeue: O(1)
- Peek: O(1)
- Search: O(n) - not a primary queue operation

**Space Complexity**:
- O(n) where n is the number of elements
- Array: may have unused capacity
- Linked-list: additional O(n) for pointers

**Priority Queue**:
- Insert: O(log n)
- Extract min/max: O(log n)
- Peek: O(1)

