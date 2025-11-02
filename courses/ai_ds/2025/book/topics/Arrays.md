---
layout: splash
author_profile: false
---

# Arrays

Contiguous memory blocks supporting O(1) indexing.


### 1. Static vs dynamic arrays
Understanding fixed-size and resizable array implementations:
- **Static arrays**:
  - **Definition**: Fixed size determined at compile time or initialization
  - **Memory**: Allocated on stack (small) or heap (large)
  - **Examples**: C arrays `int arr[100]`, Java arrays `int[] arr = new int[100]`
  - **Advantages**:
    - No overhead for resizing
    - Predictable memory usage
    - Slightly faster access (no indirection)
  - **Disadvantages**:
    - Cannot grow or shrink
    - Must know size in advance
    - Wasted space if overallocated
  
- **Dynamic arrays**:
  - **Definition**: Resizable arrays that grow as needed
  - **Examples**: C++ `std::vector`, Java `ArrayList`, Python `list`
  - **Implementation**: Array with capacity tracking
    ```python
    class DynamicArray:
        def __init__(self):
            self.capacity = 1
            self.size = 0
            self.array = [None] * self.capacity
    ```
  - **Growth strategy**: Double capacity when full (typical)
  - **Advantages**:
    - Flexible size
    - Easy to use
    - Amortized O(1) append
  - **Disadvantages**:
    - Occasional expensive resize operation
    - Extra memory overhead (capacity > size)
    - Pointer indirection

- **Comparison table**:

  | Operation | Static Array | Dynamic Array |
  |-----------|--------------|---------------|
  | Access | O(1) | O(1) |
  | Append | N/A | O(1) amortized |
  | Insert | O(n) | O(n) |
  | Delete | O(n) | O(n) |
  | Memory | Exact | 1.5-2x actual size |

### 2. Amortized analysis of dynamic resizing
Understanding the cost of growing dynamic arrays:
- **Resizing strategy**:
  - When array is full, allocate new array with 2x capacity
  - Copy all elements to new array
  - Free old array
  
- **Cost analysis**:
  - Single resize operation: O(n) where n = current size
  - But resizes happen infrequently
  
- **Amortized analysis** (aggregate method):
  - Insert n elements starting from empty array
  - Resizes occur at sizes: 1, 2, 4, 8, 16, ..., n
  - Total copy cost: 1 + 2 + 4 + 8 + ... + n = 2n - 1 = O(n)
  - Average cost per insertion: O(n)/n = O(1)
  - **Result**: O(1) amortized time per append
  
- **Accounting method**:
  - Charge $3 per insertion
  - $1 for actual insertion
  - $2 saved as "credit" for future resize
  - When resize happens, use accumulated credits
  
- **Growth factors**:

  | Factor | Memory Overhead | Resize Frequency |
  |--------|----------------|------------------|
  | 1.5x | Lower (~33%) | More frequent |
  | 2x | Higher (~50%) | Less frequent |
  | **Trade-off**: Space vs time
  
- **Shrinking strategy**:
  - Shrink when size < capacity/4 (not capacity/2 to avoid thrashing)
  - Reduce capacity to capacity/2

### 3. Common operations: insert/delete/search
Analyzing fundamental array operations:
- **Access by index**:
  ```python
  element = arr[i]  # O(1)
  ```
  - Direct memory address calculation: `base_address + i * element_size`
  - Constant time regardless of array size
  
- **Search**:
  - **Linear search**: O(n) - check each element
    ```python
    def linear_search(arr, target):
        for i in range(len(arr)):
            if arr[i] == target:
                return i
        return -1
    ```
  - **Binary search**: O(log n) - only for sorted arrays
    ```python
    def binary_search(arr, target):
        left, right = 0, len(arr) - 1
        while left <= right:
            mid = left + (right - left) // 2
            if arr[mid] == target:
                return mid
            elif arr[mid] < target:
                left = mid + 1
            else:
                right = mid - 1
        return -1
    ```
  
- **Insert**:
  - **At end**: O(1) amortized (if space available)
  - **At position i**: O(n) - shift elements right
    ```python
    def insert(arr, index, value):
        arr.append(None)  # Ensure space
        for i in range(len(arr)-1, index, -1):
            arr[i] = arr[i-1]
        arr[index] = value
    ```
  - **At beginning**: O(n) - worst case, shift all elements
  
- **Delete**:
  - **At end**: O(1) - just decrement size
  - **At position i**: O(n) - shift elements left
    ```python
    def delete(arr, index):
        for i in range(index, len(arr)-1):
            arr[i] = arr[i+1]
        arr.pop()  # Remove last element
    ```
  - **By value**: O(n) - search + delete
  
- **Update**:
  ```python
  arr[i] = new_value  # O(1)
  ```

### 4. Multidimensional arrays and matrices
Working with arrays of arrays:
- **2D arrays (matrices)**:
  - **Declaration**:
    ```python
    # Python
    matrix = [[0] * cols for _ in range(rows)]
    
    # Java
    int[][] matrix = new int[rows][cols];
    
    # C++
    vector<vector<int>> matrix(rows, vector<int>(cols));
    ```
  
- **Memory layouts**:
  - **Row-major order** (C, C++, Python):
    - Store rows contiguously: `[row0][row1][row2]...`
    - Address: `base + (i * cols + j) * element_size`
    - Better cache locality when iterating by rows
  - **Column-major order** (Fortran, MATLAB):
    - Store columns contiguously: `[col0][col1][col2]...`
    - Address: `base + (j * rows + i) * element_size`
    - Better for column operations
  
- **Common operations**:
  - **Transpose**: O(rows × cols)
    ```python
    def transpose(matrix):
        rows, cols = len(matrix), len(matrix[0])
        result = [[0] * rows for _ in range(cols)]
        for i in range(rows):
            for j in range(cols):
                result[j][i] = matrix[i][j]
        return result
    ```
  - **Matrix multiplication**: O(n³) naive, O(n^2.37) Strassen
  - **Rotation**: 90° clockwise in-place
    ```python
    def rotate_90(matrix):
        n = len(matrix)
        # Transpose
        for i in range(n):
            for j in range(i, n):
                matrix[i][j], matrix[j][i] = matrix[j][i], matrix[i][j]
        # Reverse each row
        for i in range(n):
            matrix[i].reverse()
    ```
  
- **Jagged arrays**: Arrays with varying row lengths
  ```python
  jagged = [[1, 2], [3, 4, 5], [6]]
  ```
  
- **Higher dimensions**:
  - 3D: `arr[depth][row][col]` - e.g., RGB images
  - 4D: `arr[batch][depth][row][col]` - e.g., video batches

### 5. Memory layout and cache locality
Understanding performance implications of memory access patterns:
- **Contiguous memory**:
  - Arrays stored in consecutive memory locations
  - Address of `arr[i]` = `base_address + i × sizeof(element)`
  - Enables efficient sequential access
  
- **Cache hierarchy**:
  - **L1 cache**: ~32-64 KB, ~1-4 cycles
  - **L2 cache**: ~256 KB - 1 MB, ~10-20 cycles
  - **L3 cache**: ~8-32 MB, ~40-75 cycles
  - **RAM**: GBs, ~200+ cycles
  
- **Cache lines**:
  - Typical size: 64 bytes
  - Fetching one element loads entire cache line
  - Sequential access benefits from prefetching
  
- **Spatial locality**:
  - Accessing nearby memory locations
  - **Good**: Iterating array sequentially
    ```python
    # Good cache locality
    for i in range(n):
        sum += arr[i]
    ```
  - **Bad**: Random access patterns
    ```python
    # Poor cache locality
    for i in random_indices:
        sum += arr[i]
    ```
  
- **Matrix traversal**:
  - **Row-major order** (C/C++):
    ```cpp
    // Good: iterate by rows
    for (int i = 0; i < rows; i++)
        for (int j = 0; j < cols; j++)
            sum += matrix[i][j];
    
    // Bad: iterate by columns (cache misses)
    for (int j = 0; j < cols; j++)
        for (int i = 0; i < rows; i++)
            sum += matrix[i][j];
    ```
  
- **Performance impact**:
  - Good locality: 10-100x faster than poor locality
  - Critical for large datasets
  
- **Optimization techniques**:
  - **Loop blocking/tiling**: Process data in cache-sized chunks
  - **Structure of Arrays (SoA)** vs **Array of Structures (AoS)**:
    ```cpp
    // AoS - may have poor locality for specific fields
    struct Point { int x, y, z; };
    Point points[1000];
    
    // SoA - better locality when accessing single field
    struct Points {
        int x[1000];
        int y[1000];
        int z[1000];
    };
    ```

### 6. Applications and limitations
When to use arrays and when to choose alternatives:
- **Applications**:
  - **Lookup tables**: Fast O(1) access by index
    - ASCII character mappings
    - Precomputed values (factorials, primes)
  - **Buffers**: Fixed-size data storage
    - Circular buffers for streaming
    - I/O buffers
  - **Stacks and queues**: Array-based implementations
  - **Dynamic programming**: Memoization tables
  - **Sorting algorithms**: In-place sorting
  - **Image processing**: Pixel arrays (2D/3D)
  - **Scientific computing**: Vectors, matrices, tensors
  
- **Advantages**:
  - ✓ O(1) random access by index
  - ✓ Cache-friendly (contiguous memory)
  - ✓ Simple and intuitive
  - ✓ Low memory overhead
  - ✓ Good for iteration
  
- **Limitations**:
  - ✗ Fixed size (static) or resize overhead (dynamic)
  - ✗ O(n) insertion/deletion in middle
  - ✗ Wasted space if sparse
  - ✗ Cannot efficiently grow in middle
  - ✗ No O(1) insertion at arbitrary positions
  
- **When to use alternatives**:

  | Use Case | Better Alternative | Reason |
  |----------|-------------------|---------|
  | Frequent insertions/deletions | Linked List | O(1) insert/delete |
  | Unknown size, many insertions | Dynamic Array | Amortized O(1) append |
  | Key-value lookups | Hash Table | O(1) average lookup |
  | Sorted data with insertions | Binary Search Tree | O(log n) operations |
  | Priority queue | Heap | O(log n) insert/extract-min |
  | Sparse data | Hash Table / Sparse Matrix | Space efficient |
  
- **Real-world examples**:
  - **ArrayList** (Java): Dynamic array for general use
  - **NumPy arrays** (Python): Scientific computing
  - **std::vector** (C++): Default container choice
  - **Circular buffer**: Ring buffer for producers/consumers
  - **Bitmap**: Compact boolean arrays
