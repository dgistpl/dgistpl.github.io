---
layout: splash
author_profile: false
---

# Tries (Prefix Trees)

Tree structure for efficient prefix-based queries.

### 1. Node structure and links
Understanding the fundamental trie structure:

#### **Trie (Prefix Tree) Concept**:
- **Definition**: Tree where each node represents a character
- **Path**: Root to node forms a string/prefix
- **Children**: Map from character to child node
- **End marker**: Flag indicating complete word

#### **Basic node structure**:
```python
class TrieNode:
    def __init__(self):
        self.children = {}  # Map: char -> TrieNode
        self.is_end_of_word = False
```

**Visual example**:
```
Words: ["cat", "car", "card", "dog"]

Trie structure:
         root
        /    \
       c      d
       |      |
       a      o
      / \     |
     t   r    g*
    *    |
         d*

* = end of word
```

#### **Alternative implementations**:

**Array-based (fixed alphabet)**:
```python
class TrieNodeArray:
    def __init__(self):
        self.children = [None] * 26  # For lowercase a-z
        self.is_end_of_word = False
    
    def get_index(self, char):
        return ord(char) - ord('a')
```

**With parent pointers**:
```python
class TrieNodeWithParent:
    def __init__(self, char='', parent=None):
        self.char = char
        self.parent = parent
        self.children = {}
        self.is_end_of_word = False
```

#### **Complete Trie class**:
```python
class Trie:
    def __init__(self):
        self.root = TrieNode()
    
    def __repr__(self):
        return f"Trie with root: {self.root}"
```

### 2. Insert/search/delete operations
Core trie operations:

#### **Insert**:
```python
def insert(self, word):
    """Insert word into trie - O(m) where m = word length"""
    node = self.root
    
    for char in word:
        if char not in node.children:
            node.children[char] = TrieNode()
        node = node.children[char]
    
    node.is_end_of_word = True

# Example usage
trie = Trie()
trie.insert("cat")
trie.insert("car")
trie.insert("card")
```

**Step-by-step insert "car"**:
```
Initial: root
         /
        c
        |
        a
        |
        t*

After insert "car":
         root
        /
       c
       |
       a
      / \
     t*  r*
```

#### **Search**:
```python
def search(self, word):
    """Search for exact word - O(m)"""
    node = self.root
    
    for char in word:
        if char not in node.children:
            return False
        node = node.children[char]
    
    return node.is_end_of_word

# Examples
trie.search("cat")   # True
trie.search("ca")    # False (not marked as end)
trie.search("cats")  # False (doesn't exist)
```

#### **Starts with (prefix search)**:
```python
def starts_with(self, prefix):
    """Check if any word starts with prefix - O(m)"""
    node = self.root
    
    for char in prefix:
        if char not in node.children:
            return False
        node = node.children[char]
    
    return True

# Examples
trie.starts_with("ca")   # True (cat, car, card)
trie.starts_with("do")   # True (dog)
trie.starts_with("bat")  # False
```

#### **Delete**:
```python
def delete(self, word):
    """Delete word from trie - O(m)"""
    def _delete(node, word, index):
        if index == len(word):
            # Reached end of word
            if not node.is_end_of_word:
                return False  # Word doesn't exist
            
            node.is_end_of_word = False
            
            # Return True if node has no children (can be deleted)
            return len(node.children) == 0
        
        char = word[index]
        if char not in node.children:
            return False  # Word doesn't exist
        
        child = node.children[char]
        should_delete_child = _delete(child, word, index + 1)
        
        if should_delete_child:
            del node.children[char]
            # Return True if current node can be deleted
            return len(node.children) == 0 and not node.is_end_of_word
        
        return False
    
    _delete(self.root, word, 0)

# Example
trie.delete("car")  # Removes "car" but keeps "card"
```

**Delete visualization**:
```
Before delete "car":
       root
      /
     c
     |
     a
    / \
   t*  r*
       |
       d*

After delete "car":
       root
      /
     c
     |
     a
    / \
   t*  r
       |
       d*
(r* becomes r, not deleted because "card" needs it)
```

### 3. Prefix queries and autocomplete
Powerful prefix-based operations:

#### **Find all words with prefix**:
```python
def find_words_with_prefix(self, prefix):
    """Return all words starting with prefix"""
    node = self.root
    
    # Navigate to prefix node
    for char in prefix:
        if char not in node.children:
            return []
        node = node.children[char]
    
    # Collect all words from this node
    words = []
    self._collect_words(node, prefix, words)
    return words

def _collect_words(self, node, current_word, words):
    """DFS to collect all words from node"""
    if node.is_end_of_word:
        words.append(current_word)
    
    for char, child in node.children.items():
        self._collect_words(child, current_word + char, words)

# Example
trie.insert("cat")
trie.insert("car")
trie.insert("card")
trie.insert("care")

trie.find_words_with_prefix("car")  # ["car", "card", "care"]
```

#### **Autocomplete with limit**:
```python
def autocomplete(self, prefix, max_results=5):
    """Return top N autocomplete suggestions"""
    node = self.root
    
    # Navigate to prefix
    for char in prefix:
        if char not in node.children:
            return []
        node = node.children[char]
    
    # BFS to find closest words
    from collections import deque
    results = []
    queue = deque([(node, prefix)])
    
    while queue and len(results) < max_results:
        current, word = queue.popleft()
        
        if current.is_end_of_word:
            results.append(word)
        
        for char, child in sorted(current.children.items()):
            queue.append((child, word + char))
    
    return results
```

#### **Longest common prefix**:
```python
def longest_common_prefix(self, words):
    """Find longest common prefix of all words"""
    if not words:
        return ""
    
    # Insert all words
    for word in words:
        self.insert(word)
    
    # Traverse until branching or end
    node = self.root
    prefix = ""
    
    while len(node.children) == 1 and not node.is_end_of_word:
        char = next(iter(node.children))
        prefix += char
        node = node.children[char]
    
    return prefix

# Example
words = ["flower", "flow", "flight"]
lcp = longest_common_prefix(words)  # "fl"
```

#### **Word search with wildcard**:
```python
def search_with_wildcard(self, pattern):
    """Search with '.' as wildcard for any character"""
    def dfs(node, index):
        if index == len(pattern):
            return node.is_end_of_word
        
        char = pattern[index]
        
        if char == '.':
            # Try all children
            for child in node.children.values():
                if dfs(child, index + 1):
                    return True
            return False
        else:
            if char not in node.children:
                return False
            return dfs(node.children[char], index + 1)
    
    return dfs(self.root, 0)

# Example
trie.search_with_wildcard("c.r")  # Matches "car"
trie.search_with_wildcard("c..")  # Matches "cat", "car"
```

### 4. Memory usage and compression (radix)
Optimizing trie space efficiency:

#### **Memory analysis**:
```python
# Standard trie for words ["cat", "car", "card"]
# Nodes: root + c + a + t + r + d = 6 nodes
# Each node: dict + bool ≈ 100+ bytes
# Total: ~600 bytes for 3 words

# Worst case: No shared prefixes
# Words: ["abc", "def", "ghi"]
# Nodes: 1 + 3*3 = 10 nodes
# Space: O(ALPHABET_SIZE * N * M) where N = words, M = avg length
```

#### **Radix Tree (Compressed Trie)**:
- **Idea**: Merge chains of single-child nodes
- **Space**: O(N) nodes where N = number of words
- **Trade-off**: More complex implementation

**Radix node structure**:
```python
class RadixNode:
    def __init__(self, label=""):
        self.label = label  # String, not single char
        self.children = {}
        self.is_end_of_word = False
```

**Comparison**:
```
Standard Trie for ["test", "testing"]:
    root
     |
     t
     |
     e
     |
     s
     |
     t*
     |
     i
     |
     n
     |
     g*

Radix Tree:
    root
     |
    test*
     |
    ing*

Nodes: 9 → 3 (67% reduction)
```

**Radix tree implementation**:
```python
class RadixTree:
    def __init__(self):
        self.root = RadixNode()
    
    def insert(self, word):
        node = self.root
        i = 0
        
        while i < len(word):
            char = word[i]
            
            if char not in node.children:
                # No matching child, insert rest of word
                node.children[char] = RadixNode(word[i:])
                node.children[char].is_end_of_word = True
                return
            
            child = node.children[char]
            label = child.label
            
            # Find common prefix
            j = 0
            while j < len(label) and i + j < len(word) and \
                  label[j] == word[i + j]:
                j += 1
            
            if j == len(label):
                # Full label matches, continue with child
                node = child
                i += j
            else:
                # Partial match, split node
                # Split child node
                split_node = RadixNode(label[:j])
                split_node.children[label[j]] = RadixNode(label[j:])
                split_node.children[label[j]].children = child.children
                split_node.children[label[j]].is_end_of_word = child.is_end_of_word
                
                if i + j < len(word):
                    # Add remaining part
                    split_node.children[word[i + j]] = RadixNode(word[i + j:])
                    split_node.children[word[i + j]].is_end_of_word = True
                else:
                    split_node.is_end_of_word = True
                
                node.children[char] = split_node
                return
```

#### **Space optimization techniques**:
```python
# 1. Use arrays for small alphabets
class CompactTrieNode:
    def __init__(self):
        self.children = [None] * 26  # vs dict
        self.is_end = False

# 2. Bit packing for flags
class BitPackedNode:
    def __init__(self):
        self.children = {}
        self.flags = 0  # Pack multiple bools into int

# 3. Lazy initialization
class LazyTrieNode:
    def __init__(self):
        self.children = None  # Create only when needed
        self.is_end = False
```

### 5. Storing counts and metadata
Extending tries with additional information:

#### **Word frequency trie**:
```python
class FrequencyTrieNode:
    def __init__(self):
        self.children = {}
        self.count = 0  # Number of times word inserted

class FrequencyTrie:
    def __init__(self):
        self.root = FrequencyTrieNode()
    
    def insert(self, word):
        node = self.root
        for char in word:
            if char not in node.children:
                node.children[char] = FrequencyTrieNode()
            node = node.children[char]
        node.count += 1
    
    def get_frequency(self, word):
        node = self.root
        for char in word:
            if char not in node.children:
                return 0
            node = node.children[char]
        return node.count
    
    def top_k_with_prefix(self, prefix, k):
        """Get top k most frequent words with prefix"""
        node = self.root
        
        # Navigate to prefix
        for char in prefix:
            if char not in node.children:
                return []
            node = node.children[char]
        
        # Collect all words with frequencies
        words = []
        self._collect_with_freq(node, prefix, words)
        
        # Sort by frequency and return top k
        words.sort(key=lambda x: x[1], reverse=True)
        return [word for word, freq in words[:k]]
    
    def _collect_with_freq(self, node, word, words):
        if node.count > 0:
            words.append((word, node.count))
        
        for char, child in node.children.items():
            self._collect_with_freq(child, word + char, words)
```

#### **Trie with word indices**:
```python
class IndexedTrieNode:
    def __init__(self):
        self.children = {}
        self.word_indices = []  # List of document IDs

class SearchEngine:
    def __init__(self):
        self.trie = Trie()
        self.documents = []
    
    def add_document(self, doc_id, text):
        """Index document for search"""
        words = text.lower().split()
        
        for word in words:
            node = self.trie.root
            for char in word:
                if char not in node.children:
                    node.children[char] = IndexedTrieNode()
                node = node.children[char]
            
            if doc_id not in node.word_indices:
                node.word_indices.append(doc_id)
    
    def search(self, query):
        """Find documents containing query"""
        node = self.trie.root
        
        for char in query.lower():
            if char not in node.children:
                return []
            node = node.children[char]
        
        return node.word_indices
```

#### **Suffix trie for pattern matching**:
```python
class SuffixTrie:
    """Store all suffixes of a string"""
    def __init__(self, text):
        self.root = TrieNode()
        self.text = text
        
        # Insert all suffixes
        for i in range(len(text)):
            self._insert_suffix(text[i:], i)
    
    def _insert_suffix(self, suffix, start_index):
        node = self.root
        for char in suffix:
            if char not in node.children:
                node.children[char] = TrieNode()
            node = node.children[char]
        node.start_index = start_index
    
    def find_pattern(self, pattern):
        """Find all occurrences of pattern"""
        node = self.root
        
        for char in pattern:
            if char not in node.children:
                return []
            node = node.children[char]
        
        # Collect all start indices from this subtree
        indices = []
        self._collect_indices(node, indices)
        return indices
    
    def _collect_indices(self, node, indices):
        if hasattr(node, 'start_index'):
            indices.append(node.start_index)
        for child in node.children.values():
            self._collect_indices(child, indices)
```

### 6. Applications: spell-check, IP routing
Real-world uses of tries:

#### **Spell checker**:
```python
class SpellChecker:
    def __init__(self, dictionary):
        self.trie = Trie()
        for word in dictionary:
            self.trie.insert(word.lower())
    
    def is_correct(self, word):
        """Check if word is spelled correctly"""
        return self.trie.search(word.lower())
    
    def suggest_corrections(self, word, max_distance=2):
        """Suggest corrections using edit distance"""
        suggestions = []
        
        def dfs(node, current, remaining_edits):
            if remaining_edits < 0:
                return
            
            if node.is_end_of_word and current:
                suggestions.append((current, max_distance - remaining_edits))
            
            for char, child in node.children.items():
                # Exact match
                if len(current) < len(word) and word[len(current)] == char:
                    dfs(child, current + char, remaining_edits)
                else:
                    # Substitution
                    dfs(child, current + char, remaining_edits - 1)
                
                # Insertion
                dfs(child, current + char, remaining_edits - 1)
            
            # Deletion
            if len(current) < len(word):
                dfs(node, current + word[len(current)], remaining_edits - 1)
        
        dfs(self.trie.root, "", max_distance)
        
        # Sort by edit distance
        suggestions.sort(key=lambda x: x[1])
        return [word for word, dist in suggestions[:5]]

# Example
dictionary = ["cat", "car", "card", "care", "careful"]
checker = SpellChecker(dictionary)

checker.is_correct("car")  # True
checker.is_correct("cra")  # False
checker.suggest_corrections("cra")  # ["car", "care", "card"]
```

#### **IP routing (Longest Prefix Match)**:
```python
class IPRoutingTable:
    """Trie for IP address routing"""
    def __init__(self):
        self.root = TrieNode()
    
    def add_route(self, ip_prefix, next_hop):
        """Add routing entry"""
        # Convert IP to binary string
        binary = self._ip_to_binary(ip_prefix)
        
        node = self.root
        for bit in binary:
            if bit not in node.children:
                node.children[bit] = TrieNode()
            node = node.children[bit]
        
        node.next_hop = next_hop
        node.is_end_of_word = True
    
    def lookup(self, ip_address):
        """Find longest matching prefix"""
        binary = self._ip_to_binary(ip_address)
        
        node = self.root
        last_match = None
        
        for bit in binary:
            if bit not in node.children:
                break
            node = node.children[bit]
            
            if node.is_end_of_word:
                last_match = node.next_hop
        
        return last_match
    
    def _ip_to_binary(self, ip):
        """Convert IP address to binary string"""
        parts = ip.split('/')
        address = parts[0]
        prefix_len = int(parts[1]) if len(parts) > 1 else 32
        
        octets = address.split('.')
        binary = ''.join(format(int(octet), '08b') for octet in octets)
        
        return binary[:prefix_len]

# Example
routing_table = IPRoutingTable()
routing_table.add_route("192.168.0.0/16", "Router A")
routing_table.add_route("192.168.1.0/24", "Router B")
routing_table.add_route("192.168.1.128/25", "Router C")

routing_table.lookup("192.168.1.200")  # "Router B" (longest match)
routing_table.lookup("192.168.2.1")    # "Router A"
```

#### **Autocomplete system**:
```python
class AutocompleteSystem:
    """Google-style autocomplete"""
    def __init__(self):
        self.trie = FrequencyTrie()
        self.current_prefix = ""
    
    def input(self, char):
        """Process one character input"""
        if char == '#':
            # End of sentence, save it
            self.trie.insert(self.current_prefix)
            self.current_prefix = ""
            return []
        
        self.current_prefix += char
        
        # Return top 3 suggestions
        return self.trie.top_k_with_prefix(self.current_prefix, 3)

# Example
system = AutocompleteSystem()
system.input('c')  # ["cat", "car", "card"]
system.input('a')  # ["cat", "car", "card"]
system.input('r')  # ["car", "card", "care"]
system.input('#')  # Save "car", return []
```

#### **Word break problem**:
```python
def word_break(s, word_dict):
    """Check if string can be segmented into dictionary words"""
    trie = Trie()
    for word in word_dict:
        trie.insert(word)
    
    n = len(s)
    dp = [False] * (n + 1)
    dp[0] = True
    
    for i in range(1, n + 1):
        node = trie.root
        for j in range(i - 1, -1, -1):
            if not dp[j]:
                continue
            
            char = s[j]
            if char not in node.children:
                break
            
            node = node.children[char]
            
            if node.is_end_of_word:
                dp[i] = True
                break
    
    return dp[n]

# Example
word_dict = ["leet", "code"]
word_break("leetcode", word_dict)  # True
```

#### **File system path matching**:
```python
class FileSystemTrie:
    """Match file paths efficiently"""
    def __init__(self):
        self.root = TrieNode()
    
    def add_path(self, path):
        """Add file path"""
        parts = path.strip('/').split('/')
        node = self.root
        
        for part in parts:
            if part not in node.children:
                node.children[part] = TrieNode()
            node = node.children[part]
        
        node.is_end_of_word = True
    
    def find_files(self, pattern):
        """Find all files matching pattern"""
        parts = pattern.strip('/').split('/')
        results = []
        
        def dfs(node, index, current_path):
            if index == len(parts):
                if node.is_end_of_word:
                    results.append(current_path)
                return
            
            part = parts[index]
            
            if part == '*':
                # Wildcard matches any directory
                for name, child in node.children.items():
                    dfs(child, index + 1, current_path + '/' + name)
            else:
                if part in node.children:
                    dfs(node.children[part], index + 1, 
                        current_path + '/' + part)
        
        dfs(self.root, 0, "")
        return results
```

#### **Complexity summary**:

| Operation | Time | Space |
|-----------|------|-------|
| Insert | O(m) | O(m) worst case |
| Search | O(m) | O(1) |
| Delete | O(m) | O(1) |
| Prefix search | O(p + n) | O(1) |
| Autocomplete | O(p + k) | O(k) |

Where:
- m = length of word
- p = length of prefix
- n = number of words with prefix
- k = number of results returned
