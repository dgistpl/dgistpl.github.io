---
layout: splash
author_profile: false
---

# B-Trees and B+ Trees

Disk-friendly balanced trees for indexing and storage.


### 1. Node structure and order
Understanding the fundamental organization of B-Trees:
- **Order (m)**: Maximum number of children a node can have
  - Also called branching factor or degree
  - Common values: 100-1000 for disk-based systems
  
- **Node properties**:
  - Each node contains up to `m-1` keys
  - Each node has up to `m` children
  - Keys are stored in sorted order
  - Internal nodes: keys + child pointers
  - Leaf nodes: keys + data (or pointers to data)
  
- **B-Tree node structure**:
  ```python
  class BTreeNode:
      def __init__(self, order, is_leaf=False):
          self.order = order              # Maximum children
          self.keys = []                  # Sorted keys
          self.children = []              # Child pointers
          self.is_leaf = is_leaf          # Leaf flag
          self.n = 0                      # Current number of keys
  ```
  
- **Node constraints**:
  - **Root**: 1 to m-1 keys, 2 to m children (if not leaf)
  - **Internal nodes**: ⌈m/2⌉-1 to m-1 keys, ⌈m/2⌉ to m children
  - **Leaf nodes**: ⌈m/2⌉-1 to m-1 keys
  - All leaves at same depth (balanced)
  
- **Example: B-Tree of order 5 (m=5)**:
  ```
  Node structure:
  - Min keys (internal): ⌈5/2⌉-1 = 2
  - Max keys: 4
  - Min children (internal): ⌈5/2⌉ = 3
  - Max children: 5
  
  Example node: [10 | 20 | 30 | 40]
                 /   |   |   |   \
               <10  10-20 20-30 30-40 >40
  ```
  
- **Memory layout considerations**:
  - Node size typically matches disk block size (4KB, 8KB)
  - Maximizes keys per node for given block size
  - Example: 4KB block, 8-byte keys, 8-byte pointers
    - Available space: ~4000 bytes
    - Order m ≈ 250 (250 pointers + 249 keys)

### 2. Insertion, split, and deletion
Core operations for maintaining B-Tree properties:

#### **Insertion**:
1. **Search for leaf**: Traverse tree to find appropriate leaf node
2. **Insert in leaf**: Add key in sorted position
3. **Check overflow**: If node has m keys (too many), split
4. **Split operation**:
   - Create new node
   - Move upper half of keys to new node
   - Promote middle key to parent
   - If parent overflows, split recursively up to root
   
- **Insertion algorithm**:
  ```python
  def insert(root, key):
      # If root is full, split it
      if root.n == root.order - 1:
          new_root = BTreeNode(root.order)
          new_root.children.append(root)
          split_child(new_root, 0)
          root = new_root
      
      insert_non_full(root, key)
      return root
  
  def insert_non_full(node, key):
      if node.is_leaf:
          # Insert key in sorted position
          node.keys.insert(bisect_left(node.keys, key), key)
          node.n += 1
      else:
          # Find child to insert into
          i = bisect_left(node.keys, key)
          if node.children[i].n == node.order - 1:
              split_child(node, i)
              if key > node.keys[i]:
                  i += 1
          insert_non_full(node.children[i], key)
  
  def split_child(parent, index):
      full_child = parent.children[index]
      new_child = BTreeNode(full_child.order, full_child.is_leaf)
      
      mid = full_child.order // 2
      # Promote middle key to parent
      parent.keys.insert(index, full_child.keys[mid])
      parent.children.insert(index + 1, new_child)
      
      # Split keys and children
      new_child.keys = full_child.keys[mid+1:]
      full_child.keys = full_child.keys[:mid]
      
      if not full_child.is_leaf:
          new_child.children = full_child.children[mid+1:]
          full_child.children = full_child.children[:mid+1]
  ```

#### **Deletion**:
More complex than insertion, three cases:
1. **Key in leaf**: Simply remove
2. **Key in internal node**: Replace with predecessor/successor, then delete from leaf
3. **Underflow handling**: If node has fewer than ⌈m/2⌉-1 keys:
   - **Borrow from sibling**: If sibling has extra keys
   - **Merge with sibling**: If sibling is at minimum

- **Deletion cases**:
  ```
  Case 1: Delete from leaf (simple)
  Before: [10 | 20 | 30]
  Delete 20
  After:  [10 | 30]
  
  Case 2: Delete from internal (replace with predecessor)
  Before:      [20]
              /    \
          [10]      [30]
  Delete 20 → Replace with 10
  After:       [10]
              /    \
          []        [30]
  Then handle underflow in left child
  
  Case 3: Merge siblings (underflow)
  Before:      [30]
              /    \
          [10]      [40 | 50]
  Delete 10 → Underflow in left
  After:   [40 | 50]  (merged, 30 pulled down)
  ```

### 3. Height and complexity
Analyzing performance characteristics:
- **Height formula**:
  - For n keys and order m:
  - Minimum height: `log_m(n+1)` (fully packed)
  - Maximum height: `log_⌈m/2⌉((n+1)/2)` (minimum occupancy)
  
- **Height example**:
  - 1 million keys, order m=100
  - Height ≤ log₅₀(1,000,000) ≈ 3.5 → 4 levels
  - Only 4 disk accesses to find any key!
  
- **Time complexity**:
  | Operation | Time Complexity | Disk I/Os |
  |-----------|----------------|-----------|
  | Search | O(log_m n) | O(log_m n) |
  | Insert | O(log_m n) | O(log_m n) |
  | Delete | O(log_m n) | O(log_m n) |
  | Range scan | O(log_m n + k) | O(log_m n + k/b) |
  
  Where:
  - n = number of keys
  - m = order (branching factor)
  - k = number of results
  - b = keys per block
  
- **Space complexity**: O(n)
  - Minimum 50% space utilization (except root)
  - Average 67-75% utilization in practice
  
- **Comparison with binary search trees**:

  | Tree Type | Height for 1M keys | Disk I/Os |
  |-----------|-------------------|-----------|
  | Binary tree (balanced) | log₂(1M) ≈ 20 | 20 |
  | B-Tree (m=100) | log₁₀₀(1M) ≈ 3 | 3 |
  | B-Tree (m=1000) | log₁₀₀₀(1M) ≈ 2 | 2 |
  
- **Why B-Trees are efficient**:
  - High branching factor → shallow tree
  - Fewer disk accesses (dominant cost)
  - Each node fits in one disk block
  - Sequential access within nodes (cache-friendly)

### 4. Differences: B-Tree vs B+ Tree
Understanding the two main variants:

#### **B-Tree**:
- **Structure**:
  - Keys and data in all nodes (internal + leaf)
  - Each key appears exactly once
  - No linked list between leaves
  
- **Advantages**:
  - Better for exact-match queries (may find in internal node)
  - Slightly less space (no duplicate keys)
  
- **Disadvantages**:
  - Range queries less efficient
  - Variable-size records complicate node management

#### **B+ Tree**:
- **Structure**:
  - All data in leaf nodes only
  - Internal nodes contain only keys (for routing)
  - Keys may be duplicated (in internal + leaf)
  - Leaves linked in sorted order (doubly linked list)
  
- **Advantages**:
  - Excellent for range queries (scan linked leaves)
  - More keys per internal node (no data)
  - Sequential access via leaf chain
  - Consistent performance (always reach leaf)
  
- **Disadvantages**:
  - Duplicate keys use extra space
  - Always traverse to leaf (even if key in internal node)

#### **Visual comparison**:
```
B-Tree (order 3):
         [20]
        /    \
    [10]      [30, 40]
    
All nodes contain data.

B+ Tree (order 3):
         [20, 30]
        /    |    \
    [10]  [20,25] [30,40]
     ↔      ↔       ↔
    
Only leaves contain data.
Leaves linked for range scans.
```

#### **Detailed comparison table**:

| Feature | B-Tree | B+ Tree |
|---------|--------|---------|
| Data location | All nodes | Leaf nodes only |
| Internal nodes | Keys + data | Keys only (routing) |
| Key duplication | No | Yes (internal + leaf) |
| Leaf linkage | No | Yes (linked list) |
| Keys per internal node | Fewer | More |
| Range queries | O(log n + k) | O(log n + k/b) better |
| Point queries | Faster (may stop early) | Always to leaf |
| Sequential access | Poor | Excellent |
| Use case | General purpose | Databases, filesystems |

#### **Why databases prefer B+ Trees**:
1. **Range queries**: Common in SQL (`SELECT * WHERE age BETWEEN 20 AND 30`)
2. **Sequential scans**: Full table scans via leaf chain
3. **Higher fanout**: More keys per internal node → shorter tree
4. **Predictable performance**: Always same depth to leaf
5. **Easier concurrency**: Lock leaves independently

### 5. Range scans and storage locality
Optimizing for sequential access patterns:

#### **Range query in B+ Tree**:
1. **Find start key**: O(log_m n) - traverse to leaf
2. **Scan leaves**: Follow linked list until end key
3. **Total cost**: O(log_m n + k) where k = results

- **Example query**: `SELECT * FROM users WHERE age BETWEEN 25 AND 35`
  ```
  Step 1: Search for age=25 → reach leaf L1
  Step 2: Scan L1 → L2 → L3 until age > 35
  Step 3: Return all records found
  
  Disk I/Os: 1 (root) + 1 (internal) + 1 (leaf) + k/b (scan)
  ```

#### **Range query in B-Tree**:
- Must perform in-order traversal
- Jump between internal and leaf nodes
- Less efficient: O(log_m n + k log_m n)

#### **Storage locality benefits**:
- **Sequential disk access**:
  - Leaves stored contiguously on disk
  - Prefetching: OS loads adjacent blocks
  - Minimizes seek time (mechanical disks)
  
- **Cache-friendly**:
  - Scanning leaves keeps data in cache
  - No random jumps between levels
  
- **Bulk loading**:
  - Build B+ Tree bottom-up
  - Sort all keys, create leaves left-to-right
  - Then build internal levels
  - Result: 100% space utilization, optimal locality

#### **Optimization techniques**:
1. **Leaf node chaining**:
   ```python
   class BPlusTreeLeaf:
       def __init__(self):
           self.keys = []
           self.values = []
           self.next = None      # Next leaf
           self.prev = None      # Previous leaf
   ```

2. **Sibling pointers in internal nodes**:
   - Faster splits and merges
   - Better concurrency control

3. **Bulk loading algorithm**:
   ```python
   def bulk_load(sorted_keys):
       # Create leaf level
       leaves = []
       for i in range(0, len(sorted_keys), LEAF_SIZE):
           leaf = create_leaf(sorted_keys[i:i+LEAF_SIZE])
           leaves.append(leaf)
       
       # Link leaves
       for i in range(len(leaves)-1):
           leaves[i].next = leaves[i+1]
       
       # Build internal levels bottom-up
       return build_internal_levels(leaves)
   ```

4. **Prefix compression**:
   - Store only distinguishing prefix in internal nodes
   - Example: ["apple", "application"] → ["app", "appl"]
   - Saves space, increases fanout

### 6. Database and filesystem applications
Real-world usage of B-Trees and B+ Trees:

#### **Database indexes**:
- **Primary index**: B+ Tree on primary key
  - Leaf nodes contain actual data rows (clustered index)
  - Example: MySQL InnoDB primary key index
  
- **Secondary index**: B+ Tree on non-primary key
  - Leaf nodes contain pointers to primary key
  - Example: Index on email column
  
- **Composite index**: Multi-column B+ Tree
  - Keys are tuples: (last_name, first_name)
  - Supports queries on prefix: `WHERE last_name = 'Smith'`

#### **Database systems using B+ Trees**:

| Database | Index Type | Details |
|----------|-----------|---------|
| **MySQL InnoDB** | B+ Tree | Clustered primary key, secondary indexes |
| **PostgreSQL** | B-Tree (actually B+ Tree) | Default index type |
| **SQLite** | B+ Tree | Both table and index storage |
| **Oracle** | B+ Tree | Index-organized tables |
| **SQL Server** | B+ Tree | Clustered and non-clustered indexes |

#### **Filesystem applications**:
- **File allocation**:
  - B+ Tree maps file blocks to disk blocks
  - Fast random access within files
  
- **Directory structure**:
  - B+ Tree for large directories
  - Efficient filename lookups
  
- **Filesystem examples**:

  | Filesystem | Usage |
  |------------|-------|
  | **ext4** | HTree (B-Tree variant) for directories |
  | **XFS** | B+ Trees for free space, inodes |
  | **Btrfs** | B-Trees for all metadata |
  | **NTFS** | B+ Trees for file records (MFT) |
  | **HFS+** | B-Trees for catalog file |

#### **Specific use cases**:

1. **MySQL InnoDB**:
   ```sql
   -- Clustered index (B+ Tree on primary key)
   CREATE TABLE users (
       id INT PRIMARY KEY,      -- B+ Tree root
       name VARCHAR(100),
       email VARCHAR(100),
       INDEX idx_email (email)  -- Secondary B+ Tree
   );
   
   -- Range query (efficient)
   SELECT * FROM users WHERE id BETWEEN 1000 AND 2000;
   -- Uses B+ Tree leaf chain
   ```

2. **PostgreSQL B-Tree index**:
   ```sql
   -- Create index
   CREATE INDEX idx_users_age ON users(age);
   
   -- Index scan
   EXPLAIN SELECT * FROM users WHERE age > 25;
   -- Index Scan using idx_users_age
   -- Filter: (age > 25)
   ```

3. **Filesystem directory lookup**:
   ```
   Directory: /usr/bin (10,000 files)
   Lookup: find "python3"
   
   Without B-Tree: O(n) linear scan
   With B-Tree: O(log n) ≈ 4 disk accesses
   ```

#### **Performance characteristics**:
- **Insert performance**:
  - Random inserts: ~1000-10000 ops/sec
  - Bulk inserts: ~100000+ ops/sec (bulk loading)
  
- **Query performance**:
  - Point query: 1-3 disk I/Os (typical)
  - Range query: 1-3 + k/b I/Os (k results, b per block)
  
- **Space overhead**:
  - 50-75% space utilization
  - Internal nodes: ~1-2% of total space
  - Leaf nodes: ~98-99% of total space

#### **Advanced features**:
- **Write-ahead logging (WAL)**: Crash recovery
- **MVCC (Multi-Version Concurrency Control)**: Concurrent access
- **Compression**: Prefix compression, page compression
- **Partitioning**: Distribute B+ Tree across multiple disks
- **Caching**: Buffer pool for hot nodes
