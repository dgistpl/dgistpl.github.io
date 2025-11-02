---
layout: splash
author_profile: false
---

# Advanced Data Structures

Specialized structures for performance and specific problem domains.


### Hash tables and hashing

A **hash table** (hash map) is a data structure that provides extremely fast O(1) average-case insertion, deletion, and lookup by mapping keys to values using a **hash function**.

**Core Concept**:
```
Key → Hash Function → Index → Value

Example:
"apple" → hash("apple") = 5 → array[5] = 120
```

**Hash Function**:

A function that converts a key into an array index:
```python
def simple_hash(key, table_size):
    """Simple hash function"""
    return hash(key) % table_size

# Python's built-in hash:
hash("apple") % 10  # Returns an index 0-9
```

**Good Hash Function Properties**:
1. **Deterministic**: Same key always produces same hash
2. **Uniform distribution**: Spreads keys evenly across table
3. **Fast to compute**: O(1) time
4. **Minimize collisions**: Different keys should have different hashes

**Basic Implementation**:
```python
class HashTable:
    def __init__(self, size=10):
        self.size = size
        self.table = [None] * size
        self.count = 0

    def _hash(self, key):
        """Hash function to get index"""
        return hash(key) % self.size

    def insert(self, key, value):
        """Insert key-value pair"""
        index = self._hash(key)
        self.table[index] = value
        self.count += 1

    def get(self, key):
        """Retrieve value by key"""
        index = self._hash(key)
        return self.table[index]

    def delete(self, key):
        """Delete key-value pair"""
        index = self._hash(key)
        if self.table[index] is not None:
            self.table[index] = None
            self.count -= 1

# Usage:
ht = HashTable()
ht.insert("apple", 5)
ht.insert("banana", 7)
print(ht.get("apple"))  # 5
```

**Problem: Collisions**

When two different keys hash to the same index:
```
hash("apple") = 5
hash("orange") = 5  # Collision!
```

**Load Factor**:

Ratio of filled slots to total slots:
```
Load Factor = n / m
where n = number of elements, m = table size

Example: 7 elements in table of size 10 → Load factor = 0.7
```

**When to Resize**:
- Typically resize when load factor > 0.7
- Double the table size
- Rehash all existing elements

**Resizing Example**:
```python
def _resize(self):
    """Double table size and rehash all elements"""
    old_table = self.table
    self.size *= 2
    self.table = [None] * self.size
    self.count = 0

    # Rehash all elements
    for item in old_table:
        if item is not None:
            # Re-insert using new hash values
            self.insert(item.key, item.value)
```

**Common Hash Functions**:

**1. Division Method**:
```python
def hash_division(key, m):
    """h(key) = key % m"""
    return key % m

# Choose m as prime number for better distribution
```

**2. Multiplication Method**:
```python
def hash_multiplication(key, m):
    """h(key) = floor(m * (key * A mod 1))"""
    A = 0.6180339887  # Golden ratio constant
    return int(m * ((key * A) % 1))
```

**3. String Hashing**:
```python
def hash_string(s, m):
    """Polynomial hash for strings"""
    hash_value = 0
    p = 31  # Prime number

    for char in s:
        hash_value = (hash_value * p + ord(char)) % m

    return hash_value

# Example:
# "abc" → (0*31 + 97)*31 + 98)*31 + 99
```

**4. Universal Hashing**:
```python
import random

class UniversalHash:
    def __init__(self, m):
        self.m = m
        self.p = 1000000007  # Large prime
        self.a = random.randint(1, self.p - 1)
        self.b = random.randint(0, self.p - 1)

    def hash(self, key):
        """h(key) = ((a*key + b) mod p) mod m"""
        return ((self.a * key + self.b) % self.p) % self.m
```

**Python's Dictionary (Hash Table)**:
```python
# Python dict uses hash table internally
d = {}
d["apple"] = 5      # O(1) insert
d["banana"] = 7
print(d["apple"])   # O(1) lookup
del d["banana"]     # O(1) delete
"apple" in d        # O(1) membership test

# Hash of objects:
print(hash("hello"))    # String hash
print(hash(42))         # Integer hash
print(hash((1, 2, 3)))  # Tuple hash
```

**Complexity**:

| Operation | Average | Worst Case |
|-----------|---------|------------|
| Insert | O(1) | O(n) |
| Delete | O(1) | O(n) |
| Search | O(1) | O(n) |
| Space | O(n) | O(n) |

Worst case occurs when all keys collide.

**Applications**:
- Databases (indexing)
- Caching
- Symbol tables (compilers)
- Sets (unique elements)
- Counting frequencies
- Detecting duplicates

**Example: Word Frequency Counter**:
```python
def word_frequency(text):
    """Count frequency of each word"""
    freq = {}

    for word in text.split():
        word = word.lower()
        freq[word] = freq.get(word, 0) + 1

    return freq

text = "hello world hello python world"
print(word_frequency(text))
# {'hello': 2, 'world': 2, 'python': 1}
```

**Example: Two Sum Problem**:
```python
def two_sum(nums, target):
    """Find two numbers that sum to target"""
    seen = {}  # Hash table

    for i, num in enumerate(nums):
        complement = target - num
        if complement in seen:
            return [seen[complement], i]
        seen[num] = i

    return None

# O(n) time with hash table vs O(n²) with nested loops
print(two_sum([2, 7, 11, 15], 9))  # [0, 1]
```

### Collision handling: chaining/open addressing

When two keys hash to the same index, we need a **collision resolution strategy**.

**Two Main Approaches**:
1. **Chaining** (Separate Chaining)
2. **Open Addressing**

**1. Chaining (Separate Chaining)**:

Each table slot contains a linked list (or other structure) of all elements that hash to that index.

```
Visual:
Index 0: None
Index 1: [("apple", 5)] → [("orange", 8)]  # Collision!
Index 2: [("banana", 7)]
Index 3: None
```

**Implementation**:
```python
class HashTableChaining:
    def __init__(self, size=10):
        self.size = size
        # Each slot is a list (chain)
        self.table = [[] for _ in range(size)]
        self.count = 0

    def _hash(self, key):
        return hash(key) % self.size

    def insert(self, key, value):
        """Insert key-value pair - O(1) average"""
        index = self._hash(key)

        # Check if key already exists
        for i, (k, v) in enumerate(self.table[index]):
            if k == key:
                self.table[index][i] = (key, value)  # Update
                return

        # Add new entry
        self.table[index].append((key, value))
        self.count += 1

        # Resize if load factor > 0.7
        if self.count / self.size > 0.7:
            self._resize()

    def get(self, key):
        """Get value by key - O(1) average"""
        index = self._hash(key)

        # Search in chain
        for k, v in self.table[index]:
            if k == key:
                return v

        raise KeyError(f"Key '{key}' not found")

    def delete(self, key):
        """Delete key-value pair - O(1) average"""
        index = self._hash(key)

        for i, (k, v) in enumerate(self.table[index]):
            if k == key:
                del self.table[index][i]
                self.count -= 1
                return True

        return False

    def _resize(self):
        """Resize and rehash"""
        old_table = self.table
        self.size *= 2
        self.table = [[] for _ in range(self.size)]
        self.count = 0

        for chain in old_table:
            for key, value in chain:
                self.insert(key, value)

# Usage:
ht = HashTableChaining()
ht.insert("apple", 5)
ht.insert("banana", 7)
ht.insert("orange", 8)  # May collide with apple
print(ht.get("apple"))  # 5
```

**Chaining Advantages**:
- ✅ Simple to implement
- ✅ Never fills up (can exceed load factor)
- ✅ Good for unknown number of elements
- ✅ Deletion is easy

**Chaining Disadvantages**:
- ❌ Extra memory for pointers
- ❌ Poor cache performance (scattered memory)
- ❌ Chains can become long if hash function is poor

**2. Open Addressing**:

All elements stored in the table itself. When collision occurs, **probe** for another empty slot.

**Probing Strategies**:

**A. Linear Probing**:

Try next slot: `h(k), h(k)+1, h(k)+2, ...`

```python
class HashTableLinearProbing:
    def __init__(self, size=10):
        self.size = size
        self.table = [None] * size
        self.count = 0

    def _hash(self, key):
        return hash(key) % self.size

    def insert(self, key, value):
        """Insert with linear probing"""
        if self.count / self.size > 0.7:
            self._resize()

        index = self._hash(key)

        # Linear probing: try next slot
        while self.table[index] is not None:
            # Update if key exists
            if self.table[index][0] == key:
                self.table[index] = (key, value)
                return

            index = (index + 1) % self.size  # Wrap around

        # Found empty slot
        self.table[index] = (key, value)
        self.count += 1

    def get(self, key):
        """Get value with linear probing"""
        index = self._hash(key)
        start_index = index

        while self.table[index] is not None:
            if self.table[index][0] == key:
                return self.table[index][1]

            index = (index + 1) % self.size

            # Wrapped around entire table
            if index == start_index:
                break

        raise KeyError(f"Key '{key}' not found")

    def delete(self, key):
        """Delete with linear probing (uses tombstone)"""
        index = self._hash(key)
        start_index = index

        while self.table[index] is not None:
            if self.table[index][0] == key:
                self.table[index] = "DELETED"  # Tombstone marker
                self.count -= 1
                return True

            index = (index + 1) % self.size

            if index == start_index:
                break

        return False

# Usage:
ht = HashTableLinearProbing()
ht.insert("apple", 5)
ht.insert("banana", 7)
print(ht.get("apple"))
```

**Problem: Primary Clustering**

Keys cluster together, causing long probe sequences.

```
Table: [A, B, C, _, _, ...]
       ^^^^^^^^ Cluster!
New key hashing to A must check A, B, C before finding empty slot
```

**B. Quadratic Probing**:

Try slots at quadratic intervals: `h(k), h(k)+1², h(k)+2², h(k)+3², ...`

```python
def insert_quadratic(self, key, value):
    """Insert with quadratic probing"""
    index = self._hash(key)
    i = 0

    while self.table[(index + i*i) % self.size] is not None:
        if self.table[(index + i*i) % self.size][0] == key:
            self.table[(index + i*i) % self.size] = (key, value)
            return
        i += 1

    self.table[(index + i*i) % self.size] = (key, value)
    self.count += 1
```

Reduces primary clustering but can cause **secondary clustering**.

**C. Double Hashing**:

Use second hash function for probe interval:

```
h(k, i) = (h₁(k) + i * h₂(k)) % m
```

```python
def insert_double_hashing(self, key, value):
    """Insert with double hashing"""
    h1 = hash(key) % self.size
    h2 = 1 + (hash(key) % (self.size - 1))  # Second hash

    index = h1
    i = 0

    while self.table[index] is not None:
        if self.table[index][0] == key:
            self.table[index] = (key, value)
            return

        index = (h1 + i * h2) % self.size
        i += 1

    self.table[index] = (key, value)
    self.count += 1
```

Best collision resolution for open addressing.

**Chaining vs Open Addressing Comparison**:

| Feature | Chaining | Open Addressing |
|---------|----------|-----------------|
| Memory | Extra (pointers) | More compact |
| Cache performance | Poor | Better |
| Load factor | Can exceed 1.0 | Must stay < 1.0 |
| Deletion | Easy | Complex (tombstones) |
| Implementation | Simple | More complex |
| Best for | Unknown size | Known size, high performance |

**When to Use Each**:

**Use Chaining when**:
- Size unknown
- Deletions frequent
- Simple implementation preferred
- Memory not critical

**Use Open Addressing when**:
- Size relatively fixed
- Cache performance critical
- Memory limited
- Few deletions

**Python's dict** uses open addressing with pseudo-random probing (optimized version of double hashing).

**Real-World Example: LRU Cache**:
```python
from collections import OrderedDict

class LRUCache:
    """Least Recently Used cache using hash table"""
    def __init__(self, capacity):
        self.cache = OrderedDict()
        self.capacity = capacity

    def get(self, key):
        """Get value and mark as recently used"""
        if key not in self.cache:
            return -1

        # Move to end (most recent)
        self.cache.move_to_end(key)
        return self.cache[key]

    def put(self, key, value):
        """Put value, evict LRU if needed"""
        if key in self.cache:
            self.cache.move_to_end(key)

        self.cache[key] = value

        if len(self.cache) > self.capacity:
            # Remove least recently used (first item)
            self.cache.popitem(last=False)

# Usage:
cache = LRUCache(2)
cache.put(1, 1)
cache.put(2, 2)
print(cache.get(1))  # 1
cache.put(3, 3)      # Evicts key 2
print(cache.get(2))  # -1 (not found)
```

### Tries (prefix trees)

A **trie** (pronounced "try") is a tree-like data structure for storing strings where each node represents a character. Excellent for prefix-based operations.

**Structure**:
```
Storing: "cat", "car", "dog"

        root
       /    \
      c      d
      |      |
      a      o
     / \     |
    t   r    g
```

**Key Properties**:
- Each path from root to leaf represents a word
- Common prefixes share paths
- Fast prefix lookups
- Space-efficient for large sets with common prefixes

**Node Implementation**:
```python
class TrieNode:
    def __init__(self):
        self.children = {}  # Maps character → TrieNode
        self.is_end_of_word = False  # True if valid word ends here
        self.word_count = 0  # Optional: count of words with this prefix

class Trie:
    def __init__(self):
        self.root = TrieNode()

    def insert(self, word):
        """Insert word into trie - O(m) where m = len(word)"""
        node = self.root

        for char in word:
            if char not in node.children:
                node.children[char] = TrieNode()
            node = node.children[char]

        node.is_end_of_word = True

    def search(self, word):
        """Search for exact word - O(m)"""
        node = self.root

        for char in word:
            if char not in node.children:
                return False
            node = node.children[char]

        return node.is_end_of_word

    def starts_with(self, prefix):
        """Check if any word starts with prefix - O(m)"""
        node = self.root

        for char in prefix:
            if char not in node.children:
                return False
            node = node.children[char]

        return True

# Usage:
trie = Trie()
trie.insert("apple")
trie.insert("app")
trie.insert("application")

print(trie.search("app"))          # True
print(trie.search("appl"))         # False (not complete word)
print(trie.starts_with("app"))     # True (prefix exists)
```

**Advanced Operations**:

**1. Autocomplete (Get all words with prefix)**:
```python
def autocomplete(self, prefix):
    """Return all words starting with prefix"""
    node = self.root

    # Navigate to prefix end
    for char in prefix:
        if char not in node.children:
            return []
        node = node.children[char]

    # DFS to collect all words
    results = []
    self._dfs_words(node, prefix, results)
    return results

def _dfs_words(self, node, current_word, results):
    """DFS to collect all words from current node"""
    if node.is_end_of_word:
        results.append(current_word)

    for char, child_node in node.children.items():
        self._dfs_words(child_node, current_word + char, results)

# Usage:
trie = Trie()
words = ["apple", "app", "application", "apply", "banana"]
for word in words:
    trie.insert(word)

print(trie.autocomplete("app"))
# ['app', 'apple', 'application', 'apply']
```

**2. Delete Word**:
```python
def delete(self, word):
    """Delete word from trie"""
    def _delete_helper(node, word, index):
        if index == len(word):
            # Reached end of word
            if not node.is_end_of_word:
                return False  # Word doesn't exist

            node.is_end_of_word = False

            # Delete node if it has no children
            return len(node.children) == 0

        char = word[index]
        if char not in node.children:
            return False  # Word doesn't exist

        child_node = node.children[char]
        should_delete = _delete_helper(child_node, word, index + 1)

        if should_delete:
            del node.children[char]
            # Delete current node if no children and not end of another word
            return len(node.children) == 0 and not node.is_end_of_word

        return False

    _delete_helper(self.root, word, 0)
```

**3. Count Words with Prefix**:
```python
def count_words_with_prefix(self, prefix):
    """Count how many words start with prefix"""
    node = self.root

    for char in prefix:
        if char not in node.children:
            return 0
        node = node.children[char]

    # Count all words in subtree
    return self._count_words(node)

def _count_words(self, node):
    count = 1 if node.is_end_of_word else 0

    for child in node.children.values():
        count += self._count_words(child)

    return count
```

**4. Longest Common Prefix**:
```python
def longest_common_prefix(self, words):
    """Find longest common prefix of all words"""
    if not words:
        return ""

    # Insert all words
    trie = Trie()
    for word in words:
        trie.insert(word)

    # Traverse trie until branching or word end
    node = trie.root
    prefix = []

    while len(node.children) == 1 and not node.is_end_of_word:
        char = list(node.children.keys())[0]
        prefix.append(char)
        node = node.children[char]

    return ''.join(prefix)

# Example:
words = ["flower", "flow", "flight"]
print(longest_common_prefix(words))  # "fl"
```

**Complexity**:

| Operation | Time | Space |
|-----------|------|-------|
| Insert word | O(m) | O(m) |
| Search word | O(m) | O(1) |
| Prefix search | O(m) | O(1) |
| Autocomplete | O(m + k) | O(k) |
| Delete | O(m) | O(1) |

where m = word length, k = number of results

**Memory Optimization: Compressed Trie (Radix Tree)**:

Merge chains of single-child nodes:

```
Regular Trie:           Compressed Trie:
    root                    root
     |                       |
     c                       c
     |                      / \
     a                    ar   at
    / \
   r   t
```

**Applications**:

**1. Autocomplete Systems**:
```python
class AutocompleteSystem:
    def __init__(self, sentences, times):
        self.trie = Trie()
        # Insert with frequency
        for sentence, time in zip(sentences, times):
            self.trie.insert_with_count(sentence, time)

    def search(self, prefix):
        """Return top 3 suggestions"""
        results = self.trie.autocomplete(prefix)
        # Sort by frequency, return top 3
        return sorted(results, key=lambda x: x[1], reverse=True)[:3]
```

**2. Spell Checker**:
```python
def spell_check(self, word):
    """Check spelling and suggest corrections"""
    if self.search(word):
        return "Correct"

    # Find words within edit distance 1
    suggestions = []
    for i in range(len(word)):
        # Try deleting each character
        candidate = word[:i] + word[i+1:]
        if self.search(candidate):
            suggestions.append(candidate)

        # Try replacing each character
        for c in 'abcdefghijklmnopqrstuvwxyz':
            candidate = word[:i] + c + word[i+1:]
            if self.search(candidate):
                suggestions.append(candidate)

    return suggestions
```

**3. IP Routing Table**:
```
Store IP prefixes for longest prefix matching
192.168.*.*
```

**4. Phone Contact Search**:
```python
# Map T9 keypad to letters
# 2=ABC, 3=DEF, 4=GHI, etc.
def t9_search(self, digits):
    """Search contacts by T9 input"""
    # Build trie with T9 mapping
    # Search for all words matching digit sequence
```

**Trie vs Hash Table**:

| Feature | Trie | Hash Table |
|---------|------|------------|
| Exact search | O(m) | O(1) average |
| Prefix search | O(m) | O(n) |
| Autocomplete | O(m+k) | O(n) |
| Sorted order | Yes (DFS) | No |
| Memory | Higher | Lower |
| Best for | Prefix operations | Exact lookups |

**When to Use Tries**:
- Autocomplete / type-ahead
- Spell checking
- IP routing
- Dictionary implementations
- Prefix-based searches
- String matching problems

### Disjoint Set / Union-Find

**Disjoint Set** (Union-Find) is a data structure that efficiently handles partitioning of elements into disjoint (non-overlapping) sets.

**Key Operations**:
1. **Find**: Which set does an element belong to?
2. **Union**: Merge two sets into one

**Use Cases**:
- Connected components in graphs
- Kruskal's MST algorithm
- Network connectivity
- Image processing (connected regions)
- Equivalence relations

**Visual Example**:
```
Initial: {0}, {1}, {2}, {3}, {4}

After union(0, 1): {0, 1}, {2}, {3}, {4}
After union(2, 3): {0, 1}, {2, 3}, {4}
After union(0, 3): {0, 1, 2, 3}, {4}

find(0) = find(1) = find(2) = find(3) = same set
find(4) = different set
```

**Naive Implementation**:
```python
class DisjointSetNaive:
    def __init__(self, n):
        # Each element is its own set initially
        self.parent = list(range(n))

    def find(self, x):
        """Find root/representative of x's set - O(n)"""
        while self.parent[x] != x:
            x = self.parent[x]
        return x

    def union(self, x, y):
        """Merge sets containing x and y - O(n)"""
        root_x = self.find(x)
        root_y = self.find(y)

        if root_x != root_y:
            self.parent[root_x] = root_y

    def connected(self, x, y):
        """Check if x and y are in same set - O(n)"""
        return self.find(x) == self.find(y)

# Usage:
ds = DisjointSetNaive(5)
ds.union(0, 1)
ds.union(2, 3)
print(ds.connected(0, 1))  # True
print(ds.connected(0, 2))  # False
```

**Problem**: Unbalanced trees can cause O(n) operations

```
Worst case: 0 → 1 → 2 → 3 → 4  (chain)
```

**Optimization 1: Union by Rank**:

Always attach smaller tree under larger tree's root.

```python
class DisjointSetRank:
    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n  # Height of tree

    def find(self, x):
        """Find root - O(log n)"""
        while self.parent[x] != x:
            x = self.parent[x]
        return x

    def union(self, x, y):
        """Union by rank - O(log n)"""
        root_x = self.find(x)
        root_y = self.find(y)

        if root_x == root_y:
            return

        # Attach smaller tree under larger tree
        if self.rank[root_x] < self.rank[root_y]:
            self.parent[root_x] = root_y
        elif self.rank[root_x] > self.rank[root_y]:
            self.parent[root_y] = root_x
        else:
            self.parent[root_y] = root_x
            self.rank[root_x] += 1
```

**Optimization 2: Path Compression**:

During find, make every node point directly to root.

```python
def find_with_compression(self, x):
    """Find with path compression - O(α(n))"""
    if self.parent[x] != x:
        # Recursively find root and compress path
        self.parent[x] = self.find_with_compression(self.parent[x])
    return self.parent[x]

# Before:  1 → 2 → 3 → 4 (root)
# After:   1 → 4
#          2 → 4
#          3 → 4
```

**Optimized Implementation (Rank + Path Compression)**:
```python
class DisjointSet:
    """Optimized Union-Find with rank and path compression"""

    def __init__(self, n):
        self.parent = list(range(n))
        self.rank = [0] * n
        self.num_sets = n  # Track number of disjoint sets

    def find(self, x):
        """Find root with path compression - O(α(n)) ≈ O(1)"""
        if self.parent[x] != x:
            self.parent[x] = self.find(self.parent[x])  # Path compression
        return self.parent[x]

    def union(self, x, y):
        """Union by rank - O(α(n)) ≈ O(1)"""
        root_x = self.find(x)
        root_y = self.find(y)

        if root_x == root_y:
            return False  # Already in same set

        # Union by rank
        if self.rank[root_x] < self.rank[root_y]:
            self.parent[root_x] = root_y
        elif self.rank[root_x] > self.rank[root_y]:
            self.parent[root_y] = root_x
        else:
            self.parent[root_y] = root_x
            self.rank[root_x] += 1

        self.num_sets -= 1
        return True

    def connected(self, x, y):
        """Check if x and y are connected - O(α(n))"""
        return self.find(x) == self.find(y)

    def count_sets(self):
        """Return number of disjoint sets"""
        return self.num_sets

# Usage:
ds = DisjointSet(6)
ds.union(0, 1)
ds.union(1, 2)  # {0,1,2}, {3}, {4}, {5}
ds.union(3, 4)  # {0,1,2}, {3,4}, {5}
print(ds.connected(0, 2))  # True
print(ds.connected(0, 3))  # False
print(ds.count_sets())     # 3
```

**Time Complexity**:
- With both optimizations: **O(α(n))** where α is inverse Ackermann function
- α(n) grows **extremely slowly** (< 5 for any practical n)
- Essentially O(1) in practice

**Applications**:

**1. Network Connectivity**:
```python
def is_connected(n, connections):
    """Check if network is fully connected"""
    ds = DisjointSet(n)

    for u, v in connections:
        ds.union(u, v)

    return ds.count_sets() == 1

# Example:
connections = [(0,1), (1,2), (3,4)]
print(is_connected(5, connections))  # False (5 nodes, 2 components)
```

**2. Kruskal's Minimum Spanning Tree**:
```python
def kruskal_mst(n, edges):
    """Find minimum spanning tree using Union-Find"""
    # Sort edges by weight
    edges.sort(key=lambda x: x[2])

    ds = DisjointSet(n)
    mst = []
    total_weight = 0

    for u, v, weight in edges:
        # Add edge if it doesn't create cycle
        if ds.union(u, v):
            mst.append((u, v, weight))
            total_weight += weight

    return mst, total_weight

# Example:
edges = [(0,1,4), (0,2,3), (1,2,1), (1,3,2), (2,3,5)]
mst, weight = kruskal_mst(4, edges)
print(f"MST edges: {mst}, Total weight: {weight}")
```

**3. Number of Islands**:
```python
def num_islands(grid):
    """Count connected components of land in 2D grid"""
    if not grid:
        return 0

    rows, cols = len(grid), len(grid[0])
    ds = DisjointSet(rows * cols)

    def get_id(r, c):
        return r * cols + c

    # Union adjacent land cells
    for r in range(rows):
        for c in range(cols):
            if grid[r][c] == '1':
                # Check right and down neighbors
                for dr, dc in [(0,1), (1,0)]:
                    nr, nc = r + dr, c + dc
                    if (0 <= nr < rows and 0 <= nc < cols and
                        grid[nr][nc] == '1'):
                        ds.union(get_id(r,c), get_id(nr,nc))

    # Count unique land components
    islands = set()
    for r in range(rows):
        for c in range(cols):
            if grid[r][c] == '1':
                islands.add(ds.find(get_id(r, c)))

    return len(islands)

# Example:
grid = [
    ['1','1','0','0'],
    ['1','0','0','1'],
    ['0','0','1','0']
]
print(num_islands(grid))  # 3 islands
```

**4. Detect Cycle in Undirected Graph**:
```python
def has_cycle(n, edges):
    """Detect if undirected graph has cycle"""
    ds = DisjointSet(n)

    for u, v in edges:
        # If both vertices already in same set, adding edge creates cycle
        if ds.connected(u, v):
            return True
        ds.union(u, v)

    return False

# Example:
edges = [(0,1), (1,2), (2,0)]  # Forms triangle → cycle
print(has_cycle(3, edges))  # True
```

**5. Accounts Merge**:
```python
def accounts_merge(accounts):
    """Merge accounts belonging to same person"""
    ds = DisjointSet(len(accounts))
    email_to_id = {}

    # Map emails to account IDs
    for i, account in enumerate(accounts):
        for email in account[1:]:
            if email in email_to_id:
                ds.union(i, email_to_id[email])
            else:
                email_to_id[email] = i

    # Group emails by root account
    merged = {}
    for email, acc_id in email_to_id.items():
        root = ds.find(acc_id)
        if root not in merged:
            merged[root] = []
        merged[root].append(email)

    # Build result
    result = []
    for acc_id, emails in merged.items():
        name = accounts[acc_id][0]
        result.append([name] + sorted(emails))

    return result

# Example:
accounts = [
    ["John", "john@mail.com", "john@gmail.com"],
    ["John", "john@yahoo.com"],
    ["John", "john@mail.com", "john@work.com"]
]
print(accounts_merge(accounts))
# [["John", "john@gmail.com", "john@mail.com", "john@work.com"],
#  ["John", "john@yahoo.com"]]
```

**When to Use Union-Find**:
- Dynamic connectivity queries
- Grouping/clustering elements
- Cycle detection in undirected graphs
- Minimum spanning tree (Kruskal's)
- Connected components
- Equivalence relations

### Segment Trees and Fenwick Trees

Both structures efficiently handle **range queries** on arrays.

**Problem**: Given array, answer queries like:
- Sum of elements in range [L, R]
- Minimum/maximum in range [L, R]
- Update single element

**Naive Approach**:
- Range query: O(n) - iterate through range
- Update: O(1)

**Goal**: Both operations in O(log n)

**Segment Tree**:

Binary tree where each node represents an interval/segment.

```
Array: [1, 3, 5, 7, 9, 11]

Segment Tree (sum):
           36[0-5]
          /        \
      9[0-2]      27[3-5]
      /   \        /    \
   4[0-1] 5[2] 16[3-4] 11[5]
   /  \         /   \
 1[0] 3[1]   7[3]  9[4]
```

**Implementation (Sum Queries)**:
```python
class SegmentTree:
    def __init__(self, arr):
        self.n = len(arr)
        self.tree = [0] * (4 * self.n)  # 4n is safe size
        self._build(arr, 0, 0, self.n - 1)

    def _build(self, arr, node, start, end):
        """Build segment tree - O(n)"""
        if start == end:
            # Leaf node
            self.tree[node] = arr[start]
        else:
            mid = (start + end) // 2
            left_child = 2 * node + 1
            right_child = 2 * node + 2

            self._build(arr, left_child, start, mid)
            self._build(arr, right_child, mid + 1, end)

            # Internal node = sum of children
            self.tree[node] = self.tree[left_child] + self.tree[right_child]

    def query(self, L, R):
        """Query sum in range [L, R] - O(log n)"""
        return self._query(0, 0, self.n - 1, L, R)

    def _query(self, node, start, end, L, R):
        # No overlap
        if R < start or L > end:
            return 0

        # Complete overlap
        if L <= start and end <= R:
            return self.tree[node]

        # Partial overlap
        mid = (start + end) // 2
        left_child = 2 * node + 1
        right_child = 2 * node + 2

        left_sum = self._query(left_child, start, mid, L, R)
        right_sum = self._query(right_child, mid + 1, end, L, R)

        return left_sum + right_sum

    def update(self, index, value):
        """Update element at index - O(log n)"""
        self._update(0, 0, self.n - 1, index, value)

    def _update(self, node, start, end, index, value):
        if start == end:
            # Leaf node
            self.tree[node] = value
        else:
            mid = (start + end) // 2
            left_child = 2 * node + 1
            right_child = 2 * node + 2

            if index <= mid:
                self._update(left_child, start, mid, index, value)
            else:
                self._update(right_child, mid + 1, end, index, value)

            # Update internal node
            self.tree[node] = self.tree[left_child] + self.tree[right_child]

# Usage:
arr = [1, 3, 5, 7, 9, 11]
seg_tree = SegmentTree(arr)

print(seg_tree.query(1, 3))  # Sum of arr[1:4] = 3+5+7 = 15
seg_tree.update(1, 10)       # arr[1] = 10
print(seg_tree.query(1, 3))  # Now 10+5+7 = 22
```

**Segment Tree for Min/Max**:
```python
class SegmentTreeMin:
    def _build(self, arr, node, start, end):
        if start == end:
            self.tree[node] = arr[start]
        else:
            mid = (start + end) // 2
            left_child = 2 * node + 1
            right_child = 2 * node + 2

            self._build(arr, left_child, start, mid)
            self._build(arr, right_child, mid + 1, end)

            # Internal node = min of children
            self.tree[node] = min(self.tree[left_child], self.tree[right_child])
```

**Fenwick Tree (Binary Indexed Tree)**:

More space-efficient than segment tree, but less versatile.

```python
class FenwickTree:
    def __init__(self, arr):
        self.n = len(arr)
        self.tree = [0] * (self.n + 1)  # 1-indexed

        # Build tree
        for i in range(self.n):
            self.update(i, arr[i])

    def update(self, index, delta):
        """Add delta to arr[index] - O(log n)"""
        index += 1  # Convert to 1-indexed

        while index <= self.n:
            self.tree[index] += delta
            index += index & (-index)  # Add last set bit

    def prefix_sum(self, index):
        """Sum of arr[0:index+1] - O(log n)"""
        index += 1  # Convert to 1-indexed
        result = 0

        while index > 0:
            result += self.tree[index]
            index -= index & (-index)  # Remove last set bit

        return result

    def range_sum(self, left, right):
        """Sum of arr[left:right+1] - O(log n)"""
        if left == 0:
            return self.prefix_sum(right)
        return self.prefix_sum(right) - self.prefix_sum(left - 1)

# Usage:
arr = [1, 3, 5, 7, 9, 11]
fenwick = FenwickTree(arr)

print(fenwick.range_sum(1, 3))  # 3+5+7 = 15
fenwick.update(1, 7)            # Add 7 to arr[1], now arr[1] = 10
print(fenwick.range_sum(1, 3))  # 10+5+7 = 22
```

**Comparison**:

| Feature | Segment Tree | Fenwick Tree |
|---------|--------------|--------------|
| Space | O(4n) | O(n) |
| Build | O(n) | O(n log n) |
| Query | O(log n) | O(log n) |
| Update | O(log n) | O(log n) |
| Range update | Yes (lazy prop) | No |
| Versatility | High | Limited |
| Implementation | Complex | Simple |

**When to Use**:

**Segment Tree**:
- Need min/max/GCD queries
- Range updates required
- Multiple types of queries

**Fenwick Tree**:
- Only prefix sums needed
- Want simpler implementation
- Memory constrained

**Applications**:

**1. Range Sum Queries**:
```python
# Given array and Q queries:
# Query: sum of elements in range [L, R]
# Without segment tree: O(Q * n)
# With segment tree: O(n + Q * log n)
```

**2. Count Inversions**:
```python
def count_inversions(arr):
    """Count pairs (i,j) where i<j and arr[i]>arr[j]"""
    # Use Fenwick tree
    # Sort unique values, use as indices
    # For each element, query how many larger elements seen so far
```

**3. Range Minimum Query (RMQ)**:
```python
# Find minimum in any range [L, R]
# Used in Lowest Common Ancestor (LCA) algorithms
```

### B-Trees and B+ Trees

**B-Trees** are self-balancing search trees optimized for disk/external storage. Used extensively in databases and file systems.

**Why B-Trees?**

Regular BSTs aren't efficient for disk storage:
- Disk access is **slow** (milliseconds vs nanoseconds for RAM)
- Want to minimize disk reads
- Read large blocks of data at once

**B-Tree Properties**:

1. Each node can have **multiple keys** (not just one)
2. Each node has **(M+1) children** where M = number of keys
3. All leaves at same level (perfectly balanced)
4. Minimum degree `t` ≥ 2:
   - Each node has at least `t-1` keys (except root)
   - Each node has at most `2t-1` keys
   - Each node has at least `t` children (except root and leaves)
   - Each node has at most `2t` children

**Example B-Tree** (t=3):
```
                    [30, 60]
                   /    |    \
              [10,20] [40,50] [70,80,90]
```

**B-Tree Operations**:

**Search** - O(log n):
```python
def search(self, node, key):
    i = 0
    # Find first key >= search key
    while i < node.num_keys and key > node.keys[i]:
        i += 1

    # Found key
    if i < node.num_keys and key == node.keys[i]:
        return node, i

    # Leaf node, key doesn't exist
    if node.is_leaf:
        return None

    # Recurse to child
    return self.search(node.children[i], key)
```

**Insert** - O(log n):
- If node is full, split it
- Promote middle key to parent
- Recursively split if needed

**B+ Tree**:

Variation where:
1. **All data stored in leaves** (internal nodes only store keys)
2. **Leaves linked together** (sequential access)
3. Better for **range queries**

```
B+ Tree:
                [30|60]
               /   |   \
         [10|20] [30|40|50] [60|70|80]
                                       ↓
         Leaf linked list: [10,20] → [30,40,50] → [60,70,80]
```

**B+ Tree Advantages**:
- All leaf nodes at same level
- Efficient range queries (traverse linked leaves)
- Internal nodes have more keys (less height)
- Used in most databases (MySQL, PostgreSQL)

**When to Use B-Trees**:
- Database indexing
- File systems
- Large datasets on disk
- Need efficient range queries

**Database Index Example**:
```sql
CREATE INDEX idx_name ON users(name);

-- Internally creates B+ tree:
-- Keys: user names
-- Values: pointers to rows
-- Fast lookup: O(log n) disk reads
```

### Real-world applications

Advanced data structures power many real-world systems:

**1. Hash Tables**:
- **Databases**: Indexing with hash indexes
- **Caching**: Redis, Memcached
- **Programming Languages**: Python dict, Java HashMap
- **Blockchain**: Bitcoin uses hash tables
- **Symbol Tables**: Compilers for variable lookup

**2. Tries**:
- **Autocomplete**: Google search suggestions
- **Spell Check**: Microsoft Word
- **IP Routing**: Longest prefix matching
- **Phone Contacts**: T9 predictive text
- **DNS**: Domain name resolution

**3. Union-Find**:
- **Network Analysis**: Social network components
- **Image Processing**: Connected regions
- **Kruskal's Algorithm**: Minimum spanning trees
- **Compiler**: Variable equivalence
- **Percolation**: Physics simulations

**4. Segment Trees**:
- **Competitive Programming**: Range queries
- **Graphics**: Range searches in games
- **GIS Systems**: Geospatial range queries
- **Stock Market**: Price range analysis

**5. B-Trees**:
- **MySQL**: InnoDB storage engine
- **PostgreSQL**: Primary index structure
- **MongoDB**: Index structure
- **File Systems**: HFS+, NTFS
- **SQLite**: Database indexing

**System Design Example: URL Shortener**:
```python
class URLShortener:
    def __init__(self):
        self.url_to_code = {}  # Hash table
        self.code_to_url = {}  # Hash table
        self.counter = 0

    def shorten(self, long_url):
        """Convert long URL to short code"""
        if long_url in self.url_to_code:
            return self.url_to_code[long_url]

        # Generate short code
        code = self._encode(self.counter)
        self.counter += 1

        # Store mappings
        self.url_to_code[long_url] = code
        self.code_to_url[code] = long_url

        return f"short.ly/{code}"

    def expand(self, short_url):
        """Get original URL from short code"""
        code = short_url.split('/')[-1]
        return self.code_to_url.get(code)

    def _encode(self, num):
        """Convert number to base-62 string"""
        chars = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        result = []
        while num > 0:
            result.append(chars[num % 62])
            num //= 62
        return ''.join(reversed(result)) or '0'

# Uses hash tables for O(1) lookups
```

**Key Takeaway**: Advanced data structures are essential for building scalable, high-performance systems. Choose the right structure based on your specific access patterns and requirements.
