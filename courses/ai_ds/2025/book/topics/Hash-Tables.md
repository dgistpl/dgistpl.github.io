---
layout: splash
author_profile: false
---

# Hash Tables

Key-value structure enabling expected O(1) operations.


### 1. Hash functions and properties
The foundation of hash table performance:

#### **What is a hash function?**
- **Definition**: Function that maps keys to array indices
- **Signature**: `hash(key) → integer in range [0, table_size-1]`
- **Goal**: Distribute keys uniformly across table

#### **Good hash function properties**:
1. **Deterministic**: Same key always produces same hash
2. **Uniform distribution**: Keys spread evenly across table
3. **Fast to compute**: O(1) or O(k) where k = key length
4. **Minimize collisions**: Different keys rarely map to same index
5. **Avalanche effect**: Small key change → large hash change

#### **Common hash functions**:

**1. Division method**:
```python
def hash_division(key, table_size):
    return key % table_size

# Best when table_size is prime
# Example: key=42, size=13 → 42 % 13 = 3
```

**2. Multiplication method**:
```python
def hash_multiplication(key, table_size):
    A = 0.6180339887  # (√5 - 1) / 2, golden ratio
    return int(table_size * ((key * A) % 1))

# Works well with any table size
```

**3. Universal hashing**:
```python
import random

class UniversalHash:
    def __init__(self, table_size):
        self.table_size = table_size
        self.p = 2**31 - 1  # Large prime
        self.a = random.randint(1, self.p - 1)
        self.b = random.randint(0, self.p - 1)
    
    def hash(self, key):
        return ((self.a * key + self.b) % self.p) % self.table_size
```

**4. String hashing (polynomial rolling hash)**:
```python
def hash_string(s, table_size):
    hash_val = 0
    p = 31  # Prime base
    p_pow = 1
    
    for char in s:
        hash_val = (hash_val + ord(char) * p_pow) % table_size
        p_pow = (p_pow * p) % table_size
    
    return hash_val

# Example: "hello" → hash value
```

**5. Python's built-in hash**:
```python
# For integers
hash(42) % table_size

# For strings
hash("hello") % table_size

# For tuples (immutable)
hash((1, 2, 3)) % table_size

# Note: Python's hash is randomized per session for security
```

#### **Handling non-integer keys**:
```python
def hash_any_key(key, table_size):
    # Convert to integer first
    if isinstance(key, str):
        return hash_string(key, table_size)
    elif isinstance(key, int):
        return key % table_size
    elif isinstance(key, tuple):
        # Combine hashes of elements
        h = 0
        for item in key:
            h = (h * 31 + hash(item)) % table_size
        return h
    else:
        return hash(key) % table_size
```

#### **Bad hash function example**:
```python
# BAD: Only uses first character
def bad_hash(s, table_size):
    return ord(s[0]) % table_size

# Problem: "apple", "ant", "arrow" all hash to same value
# Causes many collisions!
```

### 2. Load factor and resizing
Managing table capacity and performance:

#### **Load factor (α)**:
- **Definition**: α = n / m where n = elements, m = table size
- **Meaning**: Average number of elements per slot
- **Impact**: Higher α → more collisions → slower operations

#### **Typical thresholds**:
- **Chaining**: Resize when α > 0.75 (Python dict uses 0.67)
- **Open addressing**: Resize when α > 0.5 (to avoid clustering)

#### **Resizing strategy**:
```python
class HashTable:
    def __init__(self, initial_size=16):
        self.size = initial_size
        self.count = 0
        self.table = [[] for _ in range(self.size)]  # Chaining
    
    def load_factor(self):
        return self.count / self.size
    
    def resize(self):
        # Double the size (use next prime for better distribution)
        old_table = self.table
        self.size *= 2
        self.table = [[] for _ in range(self.size)]
        self.count = 0
        
        # Rehash all elements
        for bucket in old_table:
            for key, value in bucket:
                self.insert(key, value)
    
    def insert(self, key, value):
        if self.load_factor() > 0.75:
            self.resize()
        
        index = hash(key) % self.size
        # Insert logic here
        self.count += 1
```

#### **Amortized analysis of resizing**:
```
Operations: n insertions
Resizes at: 1, 2, 4, 8, 16, ..., n
Total rehashing cost: 1 + 2 + 4 + ... + n = 2n - 1 = O(n)
Amortized cost per insertion: O(n) / n = O(1)
```

#### **Shrinking strategy**:
```python
def delete(self, key):
    # Delete logic here
    self.count -= 1
    
    # Shrink if load factor too low (avoid wasting space)
    if self.count > 0 and self.load_factor() < 0.25:
        self.size //= 2
        self.rehash()
```

#### **Choosing table size**:
- **Prime numbers**: Better distribution, fewer collisions
- **Powers of 2**: Faster modulo (use bitwise AND)
- **Trade-off**: Primes better for quality, powers of 2 faster

```python
# Prime table sizes
PRIMES = [53, 97, 193, 389, 769, 1543, 3079, 6151, 12289, 24593]

# Power of 2 with bitmask
def hash_power_of_2(key, size):
    return hash(key) & (size - 1)  # Equivalent to % size when size is power of 2
```

### 3. Collision strategies: chaining vs open addressing
Two main approaches when multiple keys hash to same index:

#### **Separate Chaining**:
- **Idea**: Each table slot stores a linked list (or dynamic array) of colliding elements
- **Collision**: Add to list at that index

**Implementation**:
```python
class HashTableChaining:
    def __init__(self, size=10):
        self.size = size
        self.table = [[] for _ in range(size)]
    
    def insert(self, key, value):
        index = hash(key) % self.size
        bucket = self.table[index]
        
        # Update if key exists
        for i, (k, v) in enumerate(bucket):
            if k == key:
                bucket[i] = (key, value)
                return
        
        # Add new key-value pair
        bucket.append((key, value))
    
    def search(self, key):
        index = hash(key) % self.size
        bucket = self.table[index]
        
        for k, v in bucket:
            if k == key:
                return v
        
        return None
    
    def delete(self, key):
        index = hash(key) % self.size
        bucket = self.table[index]
        
        for i, (k, v) in enumerate(bucket):
            if k == key:
                del bucket[i]
                return True
        
        return False
```

**Advantages**:
- ✓ Simple to implement
- ✓ Never fills up (can exceed load factor 1.0)
- ✓ Deletion is straightforward
- ✓ Less sensitive to hash function quality

**Disadvantages**:
- ✗ Extra memory for pointers/lists
- ✗ Poor cache locality (pointer chasing)
- ✗ Performance degrades gradually with high load

#### **Open Addressing**:
- **Idea**: All elements stored in table itself, no external structures
- **Collision**: Probe for next available slot using a sequence

**General structure**:
```python
class HashTableOpenAddressing:
    def __init__(self, size=10):
        self.size = size
        self.table = [None] * size
        self.count = 0
    
    def probe_sequence(self, key, i):
        # Override in subclasses
        raise NotImplementedError
    
    def insert(self, key, value):
        for i in range(self.size):
            index = self.probe_sequence(key, i)
            
            if self.table[index] is None or self.table[index] == "DELETED":
                self.table[index] = (key, value)
                self.count += 1
                return True
        
        return False  # Table full
    
    def search(self, key):
        for i in range(self.size):
            index = self.probe_sequence(key, i)
            
            if self.table[index] is None:
                return None  # Not found
            
            if self.table[index] != "DELETED" and self.table[index][0] == key:
                return self.table[index][1]
        
        return None
```

**Advantages**:
- ✓ Better cache locality (array access)
- ✓ No extra memory for pointers
- ✓ Faster for small tables (fits in cache)

**Disadvantages**:
- ✗ Must maintain load factor < 0.5-0.7
- ✗ Deletion is complex (need tombstones)
- ✗ Performance degrades sharply near capacity
- ✗ Clustering issues

#### **Comparison**:

| Feature | Chaining | Open Addressing |
|---------|----------|-----------------|
| Memory | More (pointers) | Less (no pointers) |
| Cache locality | Poor | Good |
| Load factor | Can exceed 1.0 | Must stay < 0.7 |
| Deletion | Simple | Complex (tombstones) |
| Clustering | No | Yes |
| Implementation | Easier | Harder |
| Best for | General use | Cache-friendly, known size |

### 4. Linear probing, quadratic probing, double hashing
Different probe sequences for open addressing:

#### **Linear Probing**:
- **Formula**: `h(k, i) = (h(k) + i) % m`
- **Sequence**: Try h(k), h(k)+1, h(k)+2, ...

**Implementation**:
```python
class LinearProbing(HashTableOpenAddressing):
    def probe_sequence(self, key, i):
        return (hash(key) + i) % self.size
```

**Example**:
```
Table size: 10
Insert key with hash(key) = 3

Probe sequence: 3, 4, 5, 6, 7, 8, 9, 0, 1, 2
```

**Advantages**:
- ✓ Simple to implement
- ✓ Good cache locality (sequential access)

**Disadvantages**:
- ✗ Primary clustering: Long runs of occupied slots
- ✗ Performance degrades with high load factor

**Primary clustering example**:
```
Table: [_, _, X, X, X, X, _, _, _, _]
       Cluster forms here ↑
New insertion at 2 → probes 2,3,4,5,6 → inserts at 6
Cluster grows longer!
```

#### **Quadratic Probing**:
- **Formula**: `h(k, i) = (h(k) + c₁*i + c₂*i²) % m`
- **Common**: `h(k, i) = (h(k) + i²) % m`

**Implementation**:
```python
class QuadraticProbing(HashTableOpenAddressing):
    def probe_sequence(self, key, i):
        return (hash(key) + i * i) % self.size
```

**Example**:
```
Table size: 10
Insert key with hash(key) = 3

Probe sequence: 3, 4, 7, 2, 9, 8, 9, 2, ... (wraps around)
Offsets:        0, 1, 4, 9, 16, 25, ...
```

**Advantages**:
- ✓ Reduces primary clustering
- ✓ Better distribution than linear

**Disadvantages**:
- ✗ Secondary clustering: Keys with same hash follow same probe sequence
- ✗ May not probe all slots (need table size to be prime or power of 2)

**Secondary clustering example**:
```
Keys k1, k2 with hash(k1) = hash(k2) = 5
Both follow same probe sequence: 5, 6, 9, 4, 1, ...
```

#### **Double Hashing**:
- **Formula**: `h(k, i) = (h₁(k) + i * h₂(k)) % m`
- **Two hash functions**: h₁ for initial position, h₂ for step size

**Implementation**:
```python
class DoubleHashing(HashTableOpenAddressing):
    def __init__(self, size=10):
        super().__init__(size)
        self.prime = self._prev_prime(size)
    
    def _prev_prime(self, n):
        # Find largest prime < n
        for p in range(n-1, 1, -1):
            if self._is_prime(p):
                return p
        return 2
    
    def _is_prime(self, n):
        if n < 2:
            return False
        for i in range(2, int(n**0.5) + 1):
            if n % i == 0:
                return False
        return True
    
    def hash1(self, key):
        return hash(key) % self.size
    
    def hash2(self, key):
        # h2(k) must be non-zero and coprime with table size
        return self.prime - (hash(key) % self.prime)
    
    def probe_sequence(self, key, i):
        return (self.hash1(key) + i * self.hash2(key)) % self.size
```

**Example**:
```
Table size: 10
h1(k) = 3, h2(k) = 7

Probe sequence: 3, 0, 7, 4, 1, 8, 5, 2, 9, 6
Offsets:        0, 7, 14, 21, 28, ...
```

**Advantages**:
- ✓ Eliminates both primary and secondary clustering
- ✓ Best distribution among open addressing methods
- ✓ Probes entire table (if h2 and m are coprime)

**Disadvantages**:
- ✗ More complex to implement
- ✗ Two hash function computations
- ✗ Slightly slower per probe

#### **Comparison**:

| Method | Clustering | Complexity | Distribution |
|--------|-----------|------------|--------------|
| Linear | Primary | Simple | Poor |
| Quadratic | Secondary | Moderate | Good |
| Double Hashing | None | Complex | Excellent |

### 5. Deletion nuances in open addressing
Handling deletions without breaking probe sequences:

#### **The problem**:
```python
# Initial state
table = [None, (k1, v1), (k2, v2), None, ...]
# k1 and k2 hash to index 1, k2 probed to index 2

# Delete k1
table[1] = None  # WRONG!

# Now search for k2
# Probe: index 1 → None → stop searching
# k2 is lost even though it's at index 2!
```

#### **Solution: Tombstones (lazy deletion)**:
```python
class HashTableWithDeletion:
    DELETED = object()  # Sentinel value
    
    def __init__(self, size=10):
        self.size = size
        self.table = [None] * size
    
    def insert(self, key, value):
        for i in range(self.size):
            index = (hash(key) + i) % self.size
            
            # Can insert at None or DELETED slot
            if self.table[index] is None or self.table[index] is self.DELETED:
                self.table[index] = (key, value)
                return True
            
            # Update existing key
            if self.table[index][0] == key:
                self.table[index] = (key, value)
                return True
        
        return False
    
    def search(self, key):
        for i in range(self.size):
            index = (hash(key) + i) % self.size
            
            if self.table[index] is None:
                return None  # Not found
            
            # Skip DELETED, continue probing
            if self.table[index] is not self.DELETED:
                if self.table[index][0] == key:
                    return self.table[index][1]
        
        return None
    
    def delete(self, key):
        for i in range(self.size):
            index = (hash(key) + i) % self.size
            
            if self.table[index] is None:
                return False  # Not found
            
            if self.table[index] is not self.DELETED:
                if self.table[index][0] == key:
                    self.table[index] = self.DELETED
                    return True
        
        return False
```

#### **Tombstone issues**:
1. **Space accumulation**: DELETED markers take up space
2. **Performance degradation**: Must probe through tombstones
3. **Load factor**: Should count tombstones in load calculation?

#### **Solutions**:
```python
def needs_rehash(self):
    # Rehash if too many tombstones
    active = sum(1 for slot in self.table 
                 if slot is not None and slot is not self.DELETED)
    deleted = sum(1 for slot in self.table if slot is self.DELETED)
    
    return deleted > self.size * 0.25 or active / self.size > 0.7

def rehash(self):
    old_table = self.table
    self.table = [None] * self.size
    
    for slot in old_table:
        if slot is not None and slot is not self.DELETED:
            key, value = slot
            self.insert(key, value)
```

#### **Alternative: Robin Hood hashing**:
- Minimize variance in probe lengths
- When inserting, "steal" from rich (short probe) to give to poor (long probe)
- Improves worst-case performance

### 6. Applications: caches, dictionaries
Real-world uses of hash tables:

#### **Dictionaries / Maps**:
```python
# Python dict (hash table implementation)
phonebook = {
    "Alice": "555-1234",
    "Bob": "555-5678",
    "Charlie": "555-9012"
}

# O(1) average case operations
phonebook["Alice"]  # Lookup
phonebook["David"] = "555-3456"  # Insert
del phonebook["Bob"]  # Delete
"Charlie" in phonebook  # Membership test
```

#### **Caches (LRU Cache)**:
```python
from collections import OrderedDict

class LRUCache:
    def __init__(self, capacity):
        self.cache = OrderedDict()
        self.capacity = capacity
    
    def get(self, key):
        if key not in self.cache:
            return -1
        # Move to end (most recently used)
        self.cache.move_to_end(key)
        return self.cache[key]
    
    def put(self, key, value):
        if key in self.cache:
            self.cache.move_to_end(key)
        self.cache[key] = value
        if len(self.cache) > self.capacity:
            # Remove least recently used (first item)
            self.cache.popitem(last=False)
```

#### **Sets (unique elements)**:
```python
# Python set (hash table for keys only)
seen = set()
for item in data:
    if item not in seen:
        seen.add(item)
        process(item)
```

#### **Frequency counting**:
```python
from collections import Counter

# Count word frequencies
text = "the quick brown fox jumps over the lazy dog"
word_count = Counter(text.split())
# Counter({'the': 2, 'quick': 1, 'brown': 1, ...})
```

#### **Database indexing**:
```python
# Hash index for fast lookups
class HashIndex:
    def __init__(self):
        self.index = {}
    
    def insert(self, key, row_id):
        if key not in self.index:
            self.index[key] = []
        self.index[key].append(row_id)
    
    def lookup(self, key):
        return self.index.get(key, [])
```

#### **Deduplication**:
```python
def remove_duplicates(arr):
    seen = set()
    result = []
    for item in arr:
        if item not in seen:
            seen.add(item)
            result.append(item)
    return result
```

#### **Two Sum problem**:
```python
def two_sum(nums, target):
    seen = {}
    for i, num in enumerate(nums):
        complement = target - num
        if complement in seen:
            return [seen[complement], i]
        seen[num] = i
    return None
```

### 7. Complexity and pitfalls
Understanding performance and common mistakes:

#### **Time complexity**:

| Operation | Average | Worst Case | Notes |
|-----------|---------|------------|-------|
| Insert | O(1) | O(n) | Worst: all keys collide |
| Search | O(1) | O(n) | Worst: all keys collide |
| Delete | O(1) | O(n) | Worst: all keys collide |
| Resize | O(n) | O(n) | Amortized O(1) per insert |

#### **Space complexity**:
- **Chaining**: O(n + m) where n = elements, m = table size
- **Open addressing**: O(m), must keep load factor low

#### **Common pitfalls**:

**1. Using mutable keys**:
```python
# BAD: Lists are mutable, can't be hashed
d = {[1, 2]: "value"}  # TypeError!

# GOOD: Use immutable types
d = {(1, 2): "value"}  # Tuples work
d = {frozenset([1, 2]): "value"}  # Frozen sets work
```

**2. Poor hash function**:
```python
# BAD: All strings hash to same value
def bad_hash(s):
    return len(s) % 10

# All 5-letter words collide!
```

**3. Ignoring load factor**:
```python
# BAD: Never resize
class BadHashTable:
    def insert(self, key, value):
        # Just keep inserting...
        # Performance degrades to O(n)!
        pass
```

**4. Forgetting tombstones in open addressing**:
```python
# BAD: Delete by setting to None
def delete(self, key):
    index = self.find(key)
    self.table[index] = None  # Breaks probe sequences!
```

**5. Hash flooding attack**:
```python
# Attacker sends keys that all hash to same value
# Causes O(n) operations, DoS attack
# Solution: Use randomized hash functions (Python 3.3+)
```

#### **Performance tips**:
1. **Choose good initial size**: Avoid early resizes
2. **Use prime table sizes**: Better distribution
3. **Monitor load factor**: Resize before performance degrades
4. **Profile hash function**: Ensure uniform distribution
5. **Consider alternatives**: For ordered data, use trees

#### **When NOT to use hash tables**:
- ✗ Need ordered iteration (use BST or sorted array)
- ✗ Need range queries (use BST or B-tree)
- ✗ Need minimum/maximum (use heap)
- ✗ Memory constrained (hash tables waste space)
- ✗ Worst-case guarantees needed (use balanced trees)
