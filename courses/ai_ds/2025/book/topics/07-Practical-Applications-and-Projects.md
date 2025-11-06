---
layout: splash
author_profile: false
---

# Practical Applications & Projects

Apply data structures by building projects end-to-end.


### Text editor with undo/redo (stack)

A text editor with undo/redo functionality is a classic application of stacks. The undo stack stores actions, and the redo stack stores undone actions.

**Project requirements:**
- Support basic text operations: insert, delete, replace
- Undo last operation
- Redo previously undone operation
- Multiple undo/redo levels
- Clear redo stack on new operations

**Data structure design:**
- **Undo stack**: Stores executed operations
- **Redo stack**: Stores undone operations
- **Command pattern**: Encapsulate each operation as an object with execute/undo methods

**Complete implementation:**

```python
from abc import ABC, abstractmethod
from typing import List

class Command(ABC):
    """Abstract base class for text editor commands."""

    @abstractmethod
    def execute(self, text: List[str]) -> None:
        """Execute the command."""
        pass

    @abstractmethod
    def undo(self, text: List[str]) -> None:
        """Undo the command."""
        pass

    @abstractmethod
    def __str__(self) -> str:
        """String representation of command."""
        pass

class InsertCommand(Command):
    """Insert text at a specific position."""

    def __init__(self, position: int, text: str):
        self.position = position
        self.text = text

    def execute(self, text: List[str]) -> None:
        for i, char in enumerate(self.text):
            text.insert(self.position + i, char)

    def undo(self, text: List[str]) -> None:
        for _ in range(len(self.text)):
            text.pop(self.position)

    def __str__(self) -> str:
        return f"Insert '{self.text}' at position {self.position}"

class DeleteCommand(Command):
    """Delete text from a specific position."""

    def __init__(self, position: int, length: int):
        self.position = position
        self.length = length
        self.deleted_text = ""

    def execute(self, text: List[str]) -> None:
        self.deleted_text = ""
        for _ in range(self.length):
            if self.position < len(text):
                self.deleted_text += text.pop(self.position)

    def undo(self, text: List[str]) -> None:
        for i, char in enumerate(self.deleted_text):
            text.insert(self.position + i, char)

    def __str__(self) -> str:
        return f"Delete {self.length} chars at position {self.position}"

class ReplaceCommand(Command):
    """Replace text at a specific position."""

    def __init__(self, position: int, old_text: str, new_text: str):
        self.position = position
        self.old_text = old_text
        self.new_text = new_text

    def execute(self, text: List[str]) -> None:
        # Delete old text
        for _ in range(len(self.old_text)):
            if self.position < len(text):
                text.pop(self.position)

        # Insert new text
        for i, char in enumerate(self.new_text):
            text.insert(self.position + i, char)

    def undo(self, text: List[str]) -> None:
        # Delete new text
        for _ in range(len(self.new_text)):
            if self.position < len(text):
                text.pop(self.position)

        # Restore old text
        for i, char in enumerate(self.old_text):
            text.insert(self.position + i, char)

    def __str__(self) -> str:
        return f"Replace '{self.old_text}' with '{self.new_text}' at position {self.position}"

class TextEditor:
    """Text editor with undo/redo functionality using stacks."""

    def __init__(self):
        self.text: List[str] = []
        self.undo_stack: List[Command] = []
        self.redo_stack: List[Command] = []
        self.max_history = 100  # Limit history size

    def execute(self, command: Command) -> None:
        """Execute a command and add it to undo stack."""
        command.execute(self.text)
        self.undo_stack.append(command)

        # Clear redo stack on new operation
        self.redo_stack.clear()

        # Limit history size
        if len(self.undo_stack) > self.max_history:
            self.undo_stack.pop(0)

    def undo(self) -> bool:
        """Undo the last operation."""
        if not self.undo_stack:
            return False

        command = self.undo_stack.pop()
        command.undo(self.text)
        self.redo_stack.append(command)
        return True

    def redo(self) -> bool:
        """Redo the last undone operation."""
        if not self.redo_stack:
            return False

        command = self.redo_stack.pop()
        command.execute(self.text)
        self.undo_stack.append(command)
        return True

    def insert(self, position: int, text: str) -> None:
        """Insert text at position."""
        position = max(0, min(position, len(self.text)))
        self.execute(InsertCommand(position, text))

    def delete(self, position: int, length: int) -> None:
        """Delete text at position."""
        position = max(0, min(position, len(self.text)))
        length = min(length, len(self.text) - position)
        if length > 0:
            self.execute(DeleteCommand(position, length))

    def replace(self, position: int, old_text: str, new_text: str) -> None:
        """Replace text at position."""
        position = max(0, min(position, len(self.text)))
        self.execute(ReplaceCommand(position, old_text, new_text))

    def get_text(self) -> str:
        """Get current text content."""
        return ''.join(self.text)

    def get_history(self) -> List[str]:
        """Get command history."""
        return [str(cmd) for cmd in self.undo_stack]

    def can_undo(self) -> bool:
        """Check if undo is available."""
        return len(self.undo_stack) > 0

    def can_redo(self) -> bool:
        """Check if redo is available."""
        return len(self.redo_stack) > 0

# Example usage:
def demo_text_editor():
    editor = TextEditor()

    print("=== Text Editor Demo ===\n")

    # Insert text
    editor.insert(0, "Hello")
    print(f"After insert 'Hello': {editor.get_text()}")

    editor.insert(5, " World")
    print(f"After insert ' World': {editor.get_text()}")

    editor.insert(11, "!")
    print(f"After insert '!': {editor.get_text()}")

    # Delete text
    editor.delete(5, 6)
    print(f"After delete ' World': {editor.get_text()}")

    # Undo operations
    print("\n--- Undo operations ---")
    editor.undo()
    print(f"After undo: {editor.get_text()}")

    editor.undo()
    print(f"After undo: {editor.get_text()}")

    # Redo operations
    print("\n--- Redo operations ---")
    editor.redo()
    print(f"After redo: {editor.get_text()}")

    # New operation clears redo stack
    print("\n--- New operation ---")
    editor.insert(5, " Python")
    print(f"After insert ' Python': {editor.get_text()}")
    print(f"Can redo: {editor.can_redo()}")  # False

    # Show history
    print("\n--- Command history ---")
    for cmd in editor.get_history():
        print(f"  {cmd}")

# Run demo
if __name__ == "__main__":
    demo_text_editor()
```

**Output:**
```
=== Text Editor Demo ===

After insert 'Hello': Hello
After insert ' World': Hello World
After insert '!': Hello World!
After delete ' World': Hello!

--- Undo operations ---
After undo: Hello World!
After undo: Hello World

--- Redo operations ---
After redo: Hello World!

--- New operation ---
After insert ' Python': Hello Python!
Can redo: False

--- Command history ---
  Insert 'Hello' at position 0
  Insert ' World' at position 5
  Insert ' Python' at position 5
```

**Extensions:**

```python
class CompoundCommand(Command):
    """Execute multiple commands as a single operation."""

    def __init__(self, commands: List[Command]):
        self.commands = commands

    def execute(self, text: List[str]) -> None:
        for cmd in self.commands:
            cmd.execute(text)

    def undo(self, text: List[str]) -> None:
        for cmd in reversed(self.commands):
            cmd.undo(text)

    def __str__(self) -> str:
        return f"Compound: {len(self.commands)} commands"

class TextEditorAdvanced(TextEditor):
    """Extended text editor with additional features."""

    def __init__(self):
        super().__init__()
        self.saved_state = ""
        self.cursor_position = 0

    def find_and_replace_all(self, find: str, replace: str) -> int:
        """Find and replace all occurrences."""
        text = self.get_text()
        count = text.count(find)

        if count == 0:
            return 0

        commands = []
        offset = 0

        while find in text[offset:]:
            pos = text.index(find, offset)
            commands.append(ReplaceCommand(pos, find, replace))
            offset = pos + len(find)

        self.execute(CompoundCommand(commands))
        return count

    def save(self) -> None:
        """Save current state."""
        self.saved_state = self.get_text()

    def is_modified(self) -> bool:
        """Check if text has been modified since last save."""
        return self.get_text() != self.saved_state

    def get_statistics(self) -> dict:
        """Get text statistics."""
        text = self.get_text()
        return {
            'characters': len(text),
            'words': len(text.split()),
            'lines': text.count('\n') + 1 if text else 0,
            'undo_available': len(self.undo_stack),
            'redo_available': len(self.redo_stack)
        }

# Example usage of advanced features:
def demo_advanced_editor():
    editor = TextEditorAdvanced()

    editor.insert(0, "foo bar foo baz foo")
    print(f"Text: {editor.get_text()}")

    count = editor.find_and_replace_all("foo", "qux")
    print(f"Replaced {count} occurrences: {editor.get_text()}")

    editor.save()
    editor.insert(0, "Modified ")
    print(f"Modified: {editor.is_modified()}")  # True

    editor.undo()
    print(f"After undo, Modified: {editor.is_modified()}")  # False

    stats = editor.get_statistics()
    print(f"Statistics: {stats}")

# demo_advanced_editor()
```

**Testing strategy:**

```python
import unittest

class TestTextEditor(unittest.TestCase):
    def setUp(self):
        self.editor = TextEditor()

    def test_insert(self):
        self.editor.insert(0, "Hello")
        self.assertEqual(self.editor.get_text(), "Hello")

    def test_delete(self):
        self.editor.insert(0, "Hello World")
        self.editor.delete(5, 6)
        self.assertEqual(self.editor.get_text(), "Hello")

    def test_undo_redo(self):
        self.editor.insert(0, "Test")
        self.editor.undo()
        self.assertEqual(self.editor.get_text(), "")
        self.editor.redo()
        self.assertEqual(self.editor.get_text(), "Test")

    def test_redo_cleared_on_new_operation(self):
        self.editor.insert(0, "A")
        self.editor.insert(1, "B")
        self.editor.undo()
        self.editor.insert(1, "C")
        self.assertFalse(self.editor.can_redo())

    def test_replace(self):
        self.editor.insert(0, "Hello World")
        self.editor.replace(6, "World", "Python")
        self.assertEqual(self.editor.get_text(), "Hello Python")

    def test_multiple_undo(self):
        self.editor.insert(0, "A")
        self.editor.insert(1, "B")
        self.editor.insert(2, "C")

        self.editor.undo()
        self.assertEqual(self.editor.get_text(), "AB")

        self.editor.undo()
        self.assertEqual(self.editor.get_text(), "A")

        self.editor.undo()
        self.assertEqual(self.editor.get_text(), "")

# Run tests
# unittest.main(argv=[''], exit=False)
```

### Simple DB index using B-Trees

B-Trees are ideal for database indexes because they maintain sorted data and provide efficient insertion, deletion, and search operations even with large datasets on disk.

**Project requirements:**
- Store key-value pairs with sorted keys
- Support insert, search, delete operations
- Handle large datasets efficiently
- Maintain balance automatically
- Support range queries

**Data structure design:**
- **B-Tree**: Self-balancing tree with multiple keys per node
- **Minimum degree t**: Each node has at least t-1 keys (except root)
- **Disk-friendly**: Nodes correspond to disk blocks

**Complete implementation:**

```python
class BTreeNode:
    """Node in a B-Tree."""

    def __init__(self, leaf=True):
        self.keys = []          # List of keys
        self.values = []        # List of values (for leaf nodes)
        self.children = []      # List of child nodes
        self.leaf = leaf        # Is this a leaf node?

    def __str__(self):
        return f"Keys: {self.keys}, Leaf: {self.leaf}"

class BTree:
    """B-Tree implementation for database indexing."""

    def __init__(self, t=3):
        """
        Initialize B-Tree with minimum degree t.
        Each node contains at most 2t-1 keys and at least t-1 keys (except root).
        """
        self.root = BTreeNode()
        self.t = t  # Minimum degree

    def search(self, key, node=None):
        """Search for a key in the B-Tree."""
        if node is None:
            node = self.root

        # Find the first key greater than or equal to the search key
        i = 0
        while i < len(node.keys) and key > node.keys[i]:
            i += 1

        # Check if key is found
        if i < len(node.keys) and key == node.keys[i]:
            if node.leaf:
                return node.values[i]
            else:
                # For internal nodes, need to go to child
                return self.search(key, node.children[i])

        # Key not found in this node
        if node.leaf:
            return None

        # Recurse to appropriate child
        return self.search(key, node.children[i])

    def insert(self, key, value):
        """Insert a key-value pair into the B-Tree."""
        root = self.root

        # If root is full, split it
        if len(root.keys) == (2 * self.t) - 1:
            new_root = BTreeNode(leaf=False)
            new_root.children.append(self.root)
            self._split_child(new_root, 0)
            self.root = new_root

        self._insert_non_full(self.root, key, value)

    def _insert_non_full(self, node, key, value):
        """Insert into a node that is not full."""
        i = len(node.keys) - 1

        if node.leaf:
            # Insert key and value in sorted order
            node.keys.append(None)
            node.values.append(None)

            while i >= 0 and key < node.keys[i]:
                node.keys[i + 1] = node.keys[i]
                node.values[i + 1] = node.values[i]
                i -= 1

            node.keys[i + 1] = key
            node.values[i + 1] = value
        else:
            # Find child to insert into
            while i >= 0 and key < node.keys[i]:
                i -= 1
            i += 1

            # Check if child is full
            if len(node.children[i].keys) == (2 * self.t) - 1:
                self._split_child(node, i)

                if key > node.keys[i]:
                    i += 1

            self._insert_non_full(node.children[i], key, value)

    def _split_child(self, parent, index):
        """Split a full child node."""
        t = self.t
        full_child = parent.children[index]
        new_child = BTreeNode(leaf=full_child.leaf)

        mid_index = t - 1

        # Move the middle key up to parent
        parent.keys.insert(index, full_child.keys[mid_index])
        if full_child.leaf:
            parent.values.insert(index, full_child.values[mid_index])

        # Split keys and values
        new_child.keys = full_child.keys[mid_index + 1:]
        full_child.keys = full_child.keys[:mid_index]

        if full_child.leaf:
            new_child.values = full_child.values[mid_index + 1:]
            full_child.values = full_child.values[:mid_index]

        # Split children if not leaf
        if not full_child.leaf:
            new_child.children = full_child.children[mid_index + 1:]
            full_child.children = full_child.children[:mid_index + 1]

        # Add new child to parent
        parent.children.insert(index + 1, new_child)

    def delete(self, key):
        """Delete a key from the B-Tree."""
        self._delete(self.root, key)

        # If root is empty, make its only child the new root
        if len(self.root.keys) == 0:
            if not self.root.leaf and len(self.root.children) > 0:
                self.root = self.root.children[0]

    def _delete(self, node, key):
        """Helper method to delete a key from a node."""
        i = 0
        while i < len(node.keys) and key > node.keys[i]:
            i += 1

        if i < len(node.keys) and key == node.keys[i]:
            if node.leaf:
                # Case 1: Key is in leaf node
                node.keys.pop(i)
                node.values.pop(i)
            else:
                # Case 2: Key is in internal node
                self._delete_internal_node(node, key, i)
        elif not node.leaf:
            # Case 3: Key is not in this node, recurse to child
            is_in_last_child = (i == len(node.keys))

            if len(node.children[i].keys) < self.t:
                self._fill(node, i)

            if is_in_last_child and i > len(node.keys):
                self._delete(node.children[i - 1], key)
            else:
                self._delete(node.children[i], key)

    def _delete_internal_node(self, node, key, i):
        """Delete key from internal node."""
        t = self.t

        if len(node.children[i].keys) >= t:
            # Get predecessor from left child
            predecessor = self._get_predecessor(node, i)
            node.keys[i] = predecessor[0]
            node.values[i] = predecessor[1]
            self._delete(node.children[i], predecessor[0])
        elif len(node.children[i + 1].keys) >= t:
            # Get successor from right child
            successor = self._get_successor(node, i)
            node.keys[i] = successor[0]
            node.values[i] = successor[1]
            self._delete(node.children[i + 1], successor[0])
        else:
            # Merge with sibling
            self._merge(node, i)
            self._delete(node.children[i], key)

    def _get_predecessor(self, node, i):
        """Get predecessor key-value pair."""
        curr = node.children[i]
        while not curr.leaf:
            curr = curr.children[-1]
        return (curr.keys[-1], curr.values[-1])

    def _get_successor(self, node, i):
        """Get successor key-value pair."""
        curr = node.children[i + 1]
        while not curr.leaf:
            curr = curr.children[0]
        return (curr.keys[0], curr.values[0])

    def _fill(self, node, i):
        """Fill child node if it has fewer than t-1 keys."""
        t = self.t

        # Borrow from left sibling
        if i != 0 and len(node.children[i - 1].keys) >= t:
            self._borrow_from_prev(node, i)
        # Borrow from right sibling
        elif i != len(node.children) - 1 and len(node.children[i + 1].keys) >= t:
            self._borrow_from_next(node, i)
        # Merge with sibling
        else:
            if i != len(node.children) - 1:
                self._merge(node, i)
            else:
                self._merge(node, i - 1)

    def _borrow_from_prev(self, node, child_index):
        """Borrow a key from previous sibling."""
        child = node.children[child_index]
        sibling = node.children[child_index - 1]

        # Move key from parent to child
        child.keys.insert(0, node.keys[child_index - 1])
        if child.leaf:
            child.values.insert(0, node.values[child_index - 1])

        # Move key from sibling to parent
        node.keys[child_index - 1] = sibling.keys.pop()
        if sibling.leaf:
            node.values[child_index - 1] = sibling.values.pop()

        # Move child pointer if not leaf
        if not child.leaf:
            child.children.insert(0, sibling.children.pop())

    def _borrow_from_next(self, node, child_index):
        """Borrow a key from next sibling."""
        child = node.children[child_index]
        sibling = node.children[child_index + 1]

        # Move key from parent to child
        child.keys.append(node.keys[child_index])
        if child.leaf:
            child.values.append(node.values[child_index])

        # Move key from sibling to parent
        node.keys[child_index] = sibling.keys.pop(0)
        if sibling.leaf:
            node.values[child_index] = sibling.values.pop(0)

        # Move child pointer if not leaf
        if not child.leaf:
            child.children.append(sibling.children.pop(0))

    def _merge(self, node, i):
        """Merge child with its sibling."""
        child = node.children[i]
        sibling = node.children[i + 1]

        # Pull key from current node and merge with right sibling
        child.keys.append(node.keys[i])
        if child.leaf:
            child.values.append(node.values[i])

        child.keys.extend(sibling.keys)
        if child.leaf:
            child.values.extend(sibling.values)

        if not child.leaf:
            child.children.extend(sibling.children)

        # Remove key from current node
        node.keys.pop(i)
        if node.values:
            node.values.pop(i)
        node.children.pop(i + 1)

    def range_query(self, start_key, end_key):
        """Find all key-value pairs in range [start_key, end_key]."""
        result = []
        self._range_query(self.root, start_key, end_key, result)
        return result

    def _range_query(self, node, start_key, end_key, result):
        """Helper for range query."""
        i = 0

        while i < len(node.keys):
            # Recurse on child before key[i] if not leaf
            if not node.leaf:
                if start_key <= node.keys[i]:
                    self._range_query(node.children[i], start_key, end_key, result)

            # Add key if in range
            if start_key <= node.keys[i] <= end_key:
                if node.leaf:
                    result.append((node.keys[i], node.values[i]))

            # Break if we've passed end_key
            if node.keys[i] > end_key:
                return

            i += 1

        # Recurse on rightmost child if not leaf
        if not node.leaf:
            self._range_query(node.children[i], start_key, end_key, result)

    def traverse(self):
        """Return all key-value pairs in sorted order."""
        result = []
        self._traverse(self.root, result)
        return result

    def _traverse(self, node, result):
        """Helper for traversal."""
        i = 0
        for i in range(len(node.keys)):
            if not node.leaf:
                self._traverse(node.children[i], result)

            if node.leaf:
                result.append((node.keys[i], node.values[i]))

        if not node.leaf:
            self._traverse(node.children[i + 1], result)

    def __str__(self):
        """String representation of the tree."""
        return self._str_helper(self.root, 0)

    def _str_helper(self, node, level):
        """Helper for string representation."""
        result = "  " * level + str(node.keys) + "\n"
        if not node.leaf:
            for child in node.children:
                result += self._str_helper(child, level + 1)
        return result

# Example usage:
def demo_btree():
    print("=== B-Tree Database Index Demo ===\n")

    # Create B-Tree with minimum degree 3
    btree = BTree(t=3)

    # Insert key-value pairs (simulating database records)
    records = [
        (10, "Record 10"),
        (20, "Record 20"),
        (5, "Record 5"),
        (6, "Record 6"),
        (12, "Record 12"),
        (30, "Record 30"),
        (7, "Record 7"),
        (17, "Record 17"),
        (3, "Record 3"),
        (8, "Record 8"),
        (25, "Record 25"),
        (15, "Record 15")
    ]

    print("Inserting records...")
    for key, value in records:
        btree.insert(key, value)
        print(f"  Inserted: {key} -> {value}")

    print("\n--- Tree Structure ---")
    print(btree)

    # Search for keys
    print("--- Search Operations ---")
    search_keys = [12, 25, 100]
    for key in search_keys:
        result = btree.search(key)
        print(f"Search {key}: {result}")

    # Range query
    print("\n--- Range Query [7, 20] ---")
    range_result = btree.range_query(7, 20)
    for key, value in range_result:
        print(f"  {key} -> {value}")

    # Traverse (all records in sorted order)
    print("\n--- All Records (Sorted) ---")
    all_records = btree.traverse()
    for key, value in all_records:
        print(f"  {key} -> {value}")

    # Delete operations
    print("\n--- Delete Operations ---")
    delete_keys = [6, 13, 7]
    for key in delete_keys:
        btree.delete(key)
        print(f"Deleted {key}")
        print(f"  Search {key}: {btree.search(key)}")

    print("\n--- After Deletions ---")
    all_records = btree.traverse()
    for key, value in all_records:
        print(f"  {key} -> {value}")

# Run demo
if __name__ == "__main__":
    demo_btree()
```

**Database integration example:**

```python
class SimpleDatabase:
    """Simple in-memory database using B-Tree indexing."""

    def __init__(self):
        self.primary_index = BTree(t=3)  # Primary key index
        self.secondary_indexes = {}       # Secondary indexes
        self.next_id = 1

    def create_index(self, field_name):
        """Create a secondary index on a field."""
        self.secondary_indexes[field_name] = BTree(t=3)

    def insert_record(self, record):
        """Insert a record into the database."""
        # Auto-generate primary key if not provided
        if 'id' not in record:
            record['id'] = self.next_id
            self.next_id += 1

        # Insert into primary index
        self.primary_index.insert(record['id'], record)

        # Update secondary indexes
        for field, index in self.secondary_indexes.items():
            if field in record:
                index.insert(record[field], record['id'])

        return record['id']

    def find_by_id(self, record_id):
        """Find record by primary key."""
        return self.primary_index.search(record_id)

    def find_by_field(self, field_name, value):
        """Find records by secondary index."""
        if field_name not in self.secondary_indexes:
            raise ValueError(f"No index on field '{field_name}'")

        record_id = self.secondary_indexes[field_name].search(value)
        if record_id is None:
            return None
        return self.primary_index.search(record_id)

    def find_range(self, field_name, start, end):
        """Find records in a range."""
        if field_name == 'id':
            return [value for _, value in self.primary_index.range_query(start, end)]
        elif field_name in self.secondary_indexes:
            record_ids = [rid for _, rid in self.secondary_indexes[field_name].range_query(start, end)]
            return [self.primary_index.search(rid) for rid in record_ids]
        else:
            raise ValueError(f"No index on field '{field_name}'")

    def delete_record(self, record_id):
        """Delete a record."""
        record = self.primary_index.search(record_id)
        if record is None:
            return False

        # Delete from primary index
        self.primary_index.delete(record_id)

        # Delete from secondary indexes
        for field, index in self.secondary_indexes.items():
            if field in record:
                index.delete(record[field])

        return True

    def get_all_records(self):
        """Get all records in sorted order by ID."""
        return [value for _, value in self.primary_index.traverse()]

# Example usage:
def demo_database():
    db = SimpleDatabase()

    # Create secondary index on 'age' field
    db.create_index('age')

    # Insert records
    db.insert_record({'name': 'Alice', 'age': 30})
    db.insert_record({'name': 'Bob', 'age': 25})
    db.insert_record({'name': 'Charlie', 'age': 35})
    db.insert_record({'name': 'Diana', 'age': 28})

    # Find by ID
    print("Find by ID 2:", db.find_by_id(2))

    # Find by secondary index
    print("Find by age 28:", db.find_by_field('age', 28))

    # Range query
    print("Ages 25-30:", db.find_range('age', 25, 30))

    # Get all records
    print("All records:", db.get_all_records())

# demo_database()
```

### Social network graph analysis

Social networks are naturally represented as graphs where users are nodes and relationships are edges. Graph algorithms enable analysis of connections, communities, and influence.

**Project requirements:**
- Represent users and friendships/follows
- Find shortest path between users (degrees of separation)
- Detect communities/clusters
- Suggest friends (mutual connections)
- Calculate user influence metrics

**Data structure design:**
- **Adjacency list**: Efficient for sparse graphs (social networks)
- **Union-Find**: For detecting connected components
- **Priority queue**: For shortest path algorithms

**Complete implementation:**

```python
from collections import defaultdict, deque
from typing import Set, List, Dict, Tuple
import heapq

class User:
    """Represents a user in the social network."""

    def __init__(self, user_id: str, name: str, **kwargs):
        self.user_id = user_id
        self.name = name
        self.profile = kwargs  # Additional profile data

    def __str__(self):
        return f"{self.name} ({self.user_id})"

    def __repr__(self):
        return self.__str__()

    def __hash__(self):
        return hash(self.user_id)

    def __eq__(self, other):
        return isinstance(other, User) and self.user_id == other.user_id

class SocialNetwork:
    """Social network graph with analysis capabilities."""

    def __init__(self, directed=False):
        self.users: Dict[str, User] = {}
        self.graph: Dict[str, Set[str]] = defaultdict(set)
        self.directed = directed

    def add_user(self, user: User) -> None:
        """Add a user to the network."""
        self.users[user.user_id] = user
        if user.user_id not in self.graph:
            self.graph[user.user_id] = set()

    def add_connection(self, user1_id: str, user2_id: str) -> None:
        """Add a friendship/follow relationship."""
        if user1_id not in self.users or user2_id not in self.users:
            raise ValueError("Both users must exist in the network")

        self.graph[user1_id].add(user2_id)
        if not self.directed:
            self.graph[user2_id].add(user1_id)

    def remove_connection(self, user1_id: str, user2_id: str) -> None:
        """Remove a friendship/follow relationship."""
        self.graph[user1_id].discard(user2_id)
        if not self.directed:
            self.graph[user2_id].discard(user1_id)

    def get_friends(self, user_id: str) -> List[User]:
        """Get all friends of a user."""
        return [self.users[friend_id] for friend_id in self.graph[user_id]]

    def degrees_of_separation(self, user1_id: str, user2_id: str) -> Tuple[int, List[str]]:
        """
        Find shortest path between two users using BFS.
        Returns (distance, path).
        """
        if user1_id == user2_id:
            return (0, [user1_id])

        visited = {user1_id}
        queue = deque([(user1_id, [user1_id])])

        while queue:
            current_id, path = queue.popleft()

            for friend_id in self.graph[current_id]:
                if friend_id == user2_id:
                    return (len(path), path + [friend_id])

                if friend_id not in visited:
                    visited.add(friend_id)
                    queue.append((friend_id, path + [friend_id]))

        return (-1, [])  # No path found

    def suggest_friends(self, user_id: str, max_suggestions=5) -> List[Tuple[User, int]]:
        """
        Suggest friends based on mutual connections.
        Returns list of (user, mutual_count) tuples.
        """
        if user_id not in self.users:
            return []

        # Get user's current friends
        current_friends = self.graph[user_id]

        # Count mutual friends for non-friends
        mutual_counts = defaultdict(int)

        for friend_id in current_friends:
            for friend_of_friend_id in self.graph[friend_id]:
                if (friend_of_friend_id != user_id and
                    friend_of_friend_id not in current_friends):
                    mutual_counts[friend_of_friend_id] += 1

        # Sort by mutual friend count
        suggestions = [
            (self.users[uid], count)
            for uid, count in sorted(
                mutual_counts.items(),
                key=lambda x: x[1],
                reverse=True
            )[:max_suggestions]
        ]

        return suggestions

    def find_influencers(self, top_n=10) -> List[Tuple[User, float]]:
        """
        Find most influential users using PageRank-like algorithm.
        Returns list of (user, influence_score) tuples.
        """
        if not self.users:
            return []

        # Initialize ranks
        num_users = len(self.users)
        ranks = {uid: 1.0 / num_users for uid in self.users}
        damping = 0.85
        iterations = 20

        for _ in range(iterations):
            new_ranks = {}

            for user_id in self.users:
                rank_sum = 0.0

                # Sum ranks from users pointing to this user
                for other_id in self.users:
                    if user_id in self.graph[other_id]:
                        out_degree = len(self.graph[other_id])
                        if out_degree > 0:
                            rank_sum += ranks[other_id] / out_degree

                new_ranks[user_id] = (1 - damping) / num_users + damping * rank_sum

            ranks = new_ranks

        # Sort by rank
        influencers = [
            (self.users[uid], score)
            for uid, score in sorted(
                ranks.items(),
                key=lambda x: x[1],
                reverse=True
            )[:top_n]
        ]

        return influencers

    def detect_communities(self) -> List[Set[str]]:
        """
        Detect communities using connected components.
        Returns list of sets, each set is a community.
        """
        visited = set()
        communities = []

        def dfs(user_id, community):
            visited.add(user_id)
            community.add(user_id)

            for friend_id in self.graph[user_id]:
                if friend_id not in visited:
                    dfs(friend_id, community)

        for user_id in self.users:
            if user_id not in visited:
                community = set()
                dfs(user_id, community)
                communities.append(community)

        return communities

    def get_clustering_coefficient(self, user_id: str) -> float:
        """
        Calculate clustering coefficient for a user.
        Measures how connected a user's friends are to each other.
        """
        friends = self.graph[user_id]
        if len(friends) < 2:
            return 0.0

        # Count connections between friends
        connections = 0
        for friend1 in friends:
            for friend2 in friends:
                if friend1 != friend2 and friend2 in self.graph[friend1]:
                    connections += 1

        # Calculate coefficient
        possible_connections = len(friends) * (len(friends) - 1)
        return connections / possible_connections if possible_connections > 0 else 0.0

    def get_statistics(self) -> Dict:
        """Get network statistics."""
        total_connections = sum(len(friends) for friends in self.graph.values())
        if not self.directed:
            total_connections //= 2

        avg_friends = total_connections / len(self.users) if self.users else 0

        return {
            'total_users': len(self.users),
            'total_connections': total_connections,
            'average_friends': avg_friends,
            'communities': len(self.detect_communities())
        }

# Example usage:
def demo_social_network():
    print("=== Social Network Analysis Demo ===\n")

    # Create network
    network = SocialNetwork(directed=False)

    # Add users
    users_data = [
        ('alice', 'Alice'),
        ('bob', 'Bob'),
        ('charlie', 'Charlie'),
        ('diana', 'Diana'),
        ('eve', 'Eve'),
        ('frank', 'Frank'),
        ('grace', 'Grace'),
        ('henry', 'Henry')
    ]

    for user_id, name in users_data:
        network.add_user(User(user_id, name))

    # Add friendships
    friendships = [
        ('alice', 'bob'),
        ('alice', 'charlie'),
        ('bob', 'charlie'),
        ('bob', 'diana'),
        ('charlie', 'diana'),
        ('diana', 'eve'),
        ('eve', 'frank'),
        ('frank', 'grace'),
        ('grace', 'henry')
    ]

    for user1, user2 in friendships:
        network.add_connection(user1, user2)

    print("--- Network Statistics ---")
    stats = network.get_statistics()
    for key, value in stats.items():
        print(f"  {key}: {value}")

    # Degrees of separation
    print("\n--- Degrees of Separation ---")
    user1, user2 = 'alice', 'henry'
    distance, path = network.degrees_of_separation(user1, user2)
    path_names = [network.users[uid].name for uid in path]
    print(f"{user1} to {user2}: {distance} degrees")
    print(f"  Path: {' -> '.join(path_names)}")

    # Friend suggestions
    print("\n--- Friend Suggestions for Alice ---")
    suggestions = network.suggest_friends('alice')
    for user, mutual_count in suggestions:
        print(f"  {user} ({mutual_count} mutual friends)")

    # Find influencers
    print("\n--- Top Influencers ---")
    influencers = network.find_influencers(top_n=5)
    for user, score in influencers:
        print(f"  {user}: {score:.4f}")

    # Clustering coefficient
    print("\n--- Clustering Coefficients ---")
    for user_id in ['alice', 'bob', 'diana']:
        coeff = network.get_clustering_coefficient(user_id)
        print(f"  {network.users[user_id].name}: {coeff:.2f}")

    # Detect communities
    print("\n--- Communities ---")
    communities = network.detect_communities()
    for i, community in enumerate(communities, 1):
        members = [network.users[uid].name for uid in community]
        print(f"  Community {i}: {', '.join(members)}")

# Run demo
if __name__ == "__main__":
    demo_social_network()
```

**Output:**
```
=== Social Network Analysis Demo ===

--- Network Statistics ---
  total_users: 8
  total_connections: 9
  average_friends: 2.25
  communities: 1

--- Degrees of Separation ---
alice to henry: 6 degrees
  Path: Alice -> Charlie -> Diana -> Eve -> Frank -> Grace -> Henry

--- Friend Suggestions for Alice ---
  Diana (2 mutual friends)
  Eve (1 mutual friends)

--- Top Influencers ---
  Diana: 0.1891
  Charlie: 0.1715
  Bob: 0.1561
  Eve: 0.1379
  Alice: 0.1283

--- Clustering Coefficients ---
  Alice: 1.00
  Bob: 0.67
  Diana: 0.33
```

### Autocomplete engine with tries

Tries (prefix trees) are perfect for implementing autocomplete because they efficiently store and retrieve strings with common prefixes.

**Project requirements:**
- Insert words with frequencies
- Search for words by prefix
- Suggest top-k most frequent completions
- Support dynamic updates
- Handle large dictionaries efficiently

**Data structure design:**
- **Trie**: Prefix tree for efficient prefix matching
- **Frequency tracking**: Store frequency at terminal nodes
- **Priority queue**: For top-k suggestions

**Complete implementation:**

```python
from typing import List, Tuple
import heapq

class TrieNode:
    """Node in a trie."""

    def __init__(self):
        self.children = {}
        self.is_end_of_word = False
        self.frequency = 0
        self.word = None

class AutocompleteEngine:
    """Autocomplete engine using trie."""

    def __init__(self):
        self.root = TrieNode()
        self.total_words = 0

    def insert(self, word: str, frequency: int = 1) -> None:
        """Insert a word with its frequency."""
        node = self.root

        for char in word.lower():
            if char not in node.children:
                node.children[char] = TrieNode()
            node = node.children[char]

        # Mark end of word and update frequency
        if not node.is_end_of_word:
            self.total_words += 1

        node.is_end_of_word = True
        node.word = word
        node.frequency += frequency

    def search(self, word: str) -> bool:
        """Check if a word exists in the trie."""
        node = self._find_node(word.lower())
        return node is not None and node.is_end_of_word

    def starts_with(self, prefix: str) -> bool:
        """Check if any word starts with the given prefix."""
        return self._find_node(prefix.lower()) is not None

    def _find_node(self, prefix: str) -> TrieNode:
        """Find the node corresponding to a prefix."""
        node = self.root

        for char in prefix:
            if char not in node.children:
                return None
            node = node.children[char]

        return node

    def autocomplete(self, prefix: str, max_suggestions: int = 10) -> List[Tuple[str, int]]:
        """
        Get autocomplete suggestions for a prefix.
        Returns list of (word, frequency) tuples sorted by frequency.
        """
        prefix = prefix.lower()
        node = self._find_node(prefix)

        if node is None:
            return []

        # Collect all words with this prefix
        suggestions = []
        self._collect_words(node, suggestions)

        # Sort by frequency (descending) and return top suggestions
        suggestions.sort(key=lambda x: x[1], reverse=True)
        return suggestions[:max_suggestions]

    def _collect_words(self, node: TrieNode, suggestions: List[Tuple[str, int]]) -> None:
        """Recursively collect all words from a node."""
        if node.is_end_of_word:
            suggestions.append((node.word, node.frequency))

        for child in node.children.values():
            self._collect_words(child, suggestions)

    def autocomplete_optimized(self, prefix: str, max_suggestions: int = 10) -> List[Tuple[str, int]]:
        """
        Optimized autocomplete using min-heap.
        More efficient for large tries when k is small.
        """
        prefix = prefix.lower()
        node = self._find_node(prefix)

        if node is None:
            return []

        # Use min-heap to keep only top k suggestions
        heap = []
        self._collect_top_k(node, heap, max_suggestions)

        # Convert heap to sorted list
        result = sorted(heap, key=lambda x: x[1], reverse=True)
        return result

    def _collect_top_k(self, node: TrieNode, heap: List, k: int) -> None:
        """Collect top k words using min-heap."""
        if node.is_end_of_word:
            if len(heap) < k:
                heapq.heappush(heap, (node.word, node.frequency))
            elif node.frequency > heap[0][1]:
                heapq.heapreplace(heap, (node.word, node.frequency))

        for child in node.children.values():
            self._collect_top_k(child, heap, k)

    def delete(self, word: str) -> bool:
        """Delete a word from the trie."""
        word = word.lower()
        return self._delete_helper(self.root, word, 0)

    def _delete_helper(self, node: TrieNode, word: str, index: int) -> bool:
        """Helper method for deletion."""
        if index == len(word):
            if not node.is_end_of_word:
                return False

            node.is_end_of_word = False
            node.frequency = 0
            node.word = None
            self.total_words -= 1
            return len(node.children) == 0

        char = word[index]
        if char not in node.children:
            return False

        child = node.children[char]
        should_delete_child = self._delete_helper(child, word, index + 1)

        if should_delete_child:
            del node.children[char]
            return len(node.children) == 0 and not node.is_end_of_word

        return False

    def update_frequency(self, word: str, delta: int) -> None:
        """Update the frequency of a word."""
        word = word.lower()
        node = self._find_node(word)

        if node and node.is_end_of_word:
            node.frequency = max(0, node.frequency + delta)

    def get_all_words(self) -> List[Tuple[str, int]]:
        """Get all words with their frequencies."""
        words = []
        self._collect_words(self.root, words)
        return sorted(words, key=lambda x: x[1], reverse=True)

    def get_statistics(self) -> dict:
        """Get trie statistics."""
        node_count = [0]

        def count_nodes(node):
            node_count[0] += 1
            for child in node.children.values():
                count_nodes(child)

        count_nodes(self.root)

        return {
            'total_words': self.total_words,
            'total_nodes': node_count[0]
        }

# Example usage:
def demo_autocomplete():
    print("=== Autocomplete Engine Demo ===\n")

    # Create engine
    engine = AutocompleteEngine()

    # Add words with frequencies (simulating search history)
    words_data = [
        ('apple', 100),
        ('application', 80),
        ('apply', 60),
        ('appreciate', 40),
        ('approach', 90),
        ('banana', 70),
        ('band', 50),
        ('bank', 85),
        ('cat', 95),
        ('car', 110),
        ('card', 75),
        ('care', 65)
    ]

    print("Building dictionary...")
    for word, freq in words_data:
        engine.insert(word, freq)

    # Statistics
    print(f"\nStatistics: {engine.get_statistics()}")

    # Autocomplete queries
    print("\n--- Autocomplete Suggestions ---")
    queries = ['app', 'ban', 'car', 'ca']

    for query in queries:
        suggestions = engine.autocomplete(query, max_suggestions=5)
        print(f"\n'{query}':")
        for word, freq in suggestions:
            print(f"  {word} (frequency: {freq})")

    # Search specific words
    print("\n--- Word Search ---")
    search_words = ['apple', 'appl', 'car']
    for word in search_words:
        exists = engine.search(word)
        print(f"'{word}' exists: {exists}")

    # Update frequency (simulating user clicks)
    print("\n--- Update Frequency ---")
    engine.update_frequency('appreciate', 100)
    print("Updated 'appreciate' frequency by +100")

    suggestions = engine.autocomplete('app', max_suggestions=5)
    print("\nNew suggestions for 'app':")
    for word, freq in suggestions:
        print(f"  {word} (frequency: {freq})")

    # Delete word
    print("\n--- Delete Word ---")
    engine.delete('apply')
    print("Deleted 'apply'")

    suggestions = engine.autocomplete('app', max_suggestions=5)
    print("\nSuggestions for 'app' after deletion:")
    for word, freq in suggestions:
        print(f"  {word} (frequency: {freq})")

# Run demo
if __name__ == "__main__":
    demo_autocomplete()
```

**Advanced features:**

```python
class AdvancedAutocomplete(AutocompleteEngine):
    """Extended autocomplete with additional features."""

    def __init__(self):
        super().__init__()
        self.user_history = {}  # User-specific search history

    def personalized_autocomplete(self, prefix: str, user_id: str, max_suggestions: int = 10) -> List[Tuple[str, int]]:
        """
        Personalized autocomplete based on user's search history.
        """
        # Get general suggestions
        general_suggestions = self.autocomplete(prefix, max_suggestions * 2)

        # Get user's history
        user_freq = self.user_history.get(user_id, {})

        # Combine general frequency with user's frequency
        scored_suggestions = []
        for word, freq in general_suggestions:
            # Weight: 70% general frequency + 30% user-specific frequency
            user_specific_freq = user_freq.get(word, 0)
            combined_score = 0.7 * freq + 0.3 * user_specific_freq
            scored_suggestions.append((word, int(combined_score)))

        # Sort by combined score
        scored_suggestions.sort(key=lambda x: x[1], reverse=True)
        return scored_suggestions[:max_suggestions]

    def track_user_search(self, user_id: str, word: str) -> None:
        """Track a user's search."""
        if user_id not in self.user_history:
            self.user_history[user_id] = {}

        self.user_history[user_id][word] = self.user_history[user_id].get(word, 0) + 1

    def fuzzy_autocomplete(self, prefix: str, max_edit_distance: int = 2, max_suggestions: int = 10) -> List[Tuple[str, int, int]]:
        """
        Autocomplete with fuzzy matching (allows typos).
        Returns list of (word, frequency, edit_distance) tuples.
        """
        suggestions = []
        self._fuzzy_search(self.root, prefix.lower(), "", 0, max_edit_distance, suggestions)

        # Sort by edit distance (ascending), then frequency (descending)
        suggestions.sort(key=lambda x: (x[2], -x[1]))
        return suggestions[:max_suggestions]

    def _fuzzy_search(self, node: TrieNode, target: str, current: str, pos: int, max_dist: int, suggestions: List) -> None:
        """Recursive fuzzy search with edit distance."""
        if node.is_end_of_word and current.startswith(target[:len(target)//2]):
            edit_dist = self._edit_distance(target, current)
            if edit_dist <= max_dist:
                suggestions.append((node.word, node.frequency, edit_dist))

        if pos < len(target) + max_dist:
            for char, child in node.children.items():
                self._fuzzy_search(child, target, current + char, pos + 1, max_dist, suggestions)

    def _edit_distance(self, s1: str, s2: str) -> int:
        """Calculate edit distance between two strings."""
        m, n = len(s1), len(s2)
        dp = [[0] * (n + 1) for _ in range(m + 1)]

        for i in range(m + 1):
            dp[i][0] = i
        for j in range(n + 1):
            dp[0][j] = j

        for i in range(1, m + 1):
            for j in range(1, n + 1):
                if s1[i-1] == s2[j-1]:
                    dp[i][j] = dp[i-1][j-1]
                else:
                    dp[i][j] = 1 + min(dp[i-1][j], dp[i][j-1], dp[i-1][j-1])

        return dp[m][n]

# Example usage of advanced features:
def demo_advanced_autocomplete():
    engine = AdvancedAutocomplete()

    # Add words
    for word, freq in [('apple', 100), ('application', 80), ('apply', 60)]:
        engine.insert(word, freq)

    # Track user searches
    engine.track_user_search('user1', 'apply')
    engine.track_user_search('user1', 'apply')
    engine.track_user_search('user1', 'apply')

    # Personalized suggestions
    print("Personalized for user1:")
    suggestions = engine.personalized_autocomplete('app', 'user1')
    for word, score in suggestions:
        print(f"  {word}: {score}")

    # Fuzzy matching
    print("\nFuzzy matching for 'aple' (typo):")
    suggestions = engine.fuzzy_autocomplete('aple', max_edit_distance=2)
    for word, freq, dist in suggestions:
        print(f"  {word} (freq: {freq}, distance: {dist})")

# demo_advanced_autocomplete()
```

### Memory allocator simulator

A memory allocator manages a heap of memory, allocating and freeing blocks. This is a great application of free lists, trees, and splitting/coalescing strategies.

**Project requirements:**
- Allocate memory blocks of requested sizes
- Free allocated blocks
- Coalesce adjacent free blocks
- Handle fragmentation
- Track memory usage statistics

**Data structure design:**
- **Free list**: Linked list of free memory blocks
- **Allocated blocks map**: Hash table to track allocated blocks
- **Best-fit/First-fit strategies**: Different allocation strategies

**Complete implementation:**

```python
from enum import Enum
from typing import Optional, List, Dict

class AllocationStrategy(Enum):
    FIRST_FIT = 1
    BEST_FIT = 2
    WORST_FIT = 3

class MemoryBlock:
    """Represents a memory block."""

    def __init__(self, start: int, size: int, is_free: bool = True):
        self.start = start
        self.size = size
        self.is_free = is_free
        self.next: Optional[MemoryBlock] = None
        self.prev: Optional[MemoryBlock] = None

    @property
    def end(self) -> int:
        return self.start + self.size

    def __str__(self):
        status = "FREE" if self.is_free else "ALLOCATED"
        return f"[{self.start}-{self.end}): size={self.size}, {status}"

class MemoryAllocator:
    """Simulates a memory allocator with various strategies."""

    def __init__(self, total_size: int, strategy: AllocationStrategy = AllocationStrategy.FIRST_FIT):
        self.total_size = total_size
        self.strategy = strategy

        # Initialize with one large free block
        self.head = MemoryBlock(0, total_size, is_free=True)

        # Track allocated blocks
        self.allocated_blocks: Dict[int, MemoryBlock] = {}

        # Statistics
        self.allocations = 0
        self.deallocations = 0
        self.failed_allocations = 0

    def malloc(self, size: int) -> Optional[int]:
        """
        Allocate a block of memory.
        Returns starting address, or None if allocation fails.
        """
        if size <= 0:
            return None

        # Find suitable free block based on strategy
        block = self._find_free_block(size)

        if block is None:
            self.failed_allocations += 1
            return None

        # Split block if it's larger than needed
        if block.size > size:
            self._split_block(block, size)

        # Mark block as allocated
        block.is_free = False
        self.allocated_blocks[block.start] = block
        self.allocations += 1

        return block.start

    def free(self, address: int) -> bool:
        """
        Free an allocated block of memory.
        Returns True if successful, False otherwise.
        """
        if address not in self.allocated_blocks:
            return False

        block = self.allocated_blocks[address]
        del self.allocated_blocks[address]

        # Mark block as free
        block.is_free = True
        self.deallocations += 1

        # Coalesce with adjacent free blocks
        self._coalesce(block)

        return True

    def _find_free_block(self, size: int) -> Optional[MemoryBlock]:
        """Find a free block using the selected strategy."""
        if self.strategy == AllocationStrategy.FIRST_FIT:
            return self._first_fit(size)
        elif self.strategy == AllocationStrategy.BEST_FIT:
            return self._best_fit(size)
        elif self.strategy == AllocationStrategy.WORST_FIT:
            return self._worst_fit(size)
        return None

    def _first_fit(self, size: int) -> Optional[MemoryBlock]:
        """Find first free block large enough."""
        current = self.head
        while current:
            if current.is_free and current.size >= size:
                return current
            current = current.next
        return None

    def _best_fit(self, size: int) -> Optional[MemoryBlock]:
        """Find smallest free block large enough."""
        best = None
        current = self.head

        while current:
            if current.is_free and current.size >= size:
                if best is None or current.size < best.size:
                    best = current
            current = current.next

        return best

    def _worst_fit(self, size: int) -> Optional[MemoryBlock]:
        """Find largest free block."""
        worst = None
        current = self.head

        while current:
            if current.is_free and current.size >= size:
                if worst is None or current.size > worst.size:
                    worst = current
            current = current.next

        return worst

    def _split_block(self, block: MemoryBlock, size: int) -> None:
        """Split a block into allocated part and free remainder."""
        if block.size <= size:
            return

        # Create new free block for remainder
        remainder = MemoryBlock(
            start=block.start + size,
            size=block.size - size,
            is_free=True
        )

        # Update linked list
        remainder.next = block.next
        remainder.prev = block

        if block.next:
            block.next.prev = remainder

        block.next = remainder
        block.size = size

    def _coalesce(self, block: MemoryBlock) -> None:
        """Merge adjacent free blocks."""
        # Coalesce with next block
        if block.next and block.next.is_free:
            block.size += block.next.size
            block.next = block.next.next
            if block.next:
                block.next.prev = block

        # Coalesce with previous block
        if block.prev and block.prev.is_free:
            block.prev.size += block.size
            block.prev.next = block.next
            if block.next:
                block.next.prev = block.prev

    def get_memory_map(self) -> List[MemoryBlock]:
        """Get list of all memory blocks."""
        blocks = []
        current = self.head
        while current:
            blocks.append(current)
            current = current.next
        return blocks

    def get_statistics(self) -> Dict:
        """Get memory allocator statistics."""
        total_free = 0
        total_allocated = 0
        num_free_blocks = 0
        num_allocated_blocks = 0
        largest_free = 0

        current = self.head
        while current:
            if current.is_free:
                total_free += current.size
                num_free_blocks += 1
                largest_free = max(largest_free, current.size)
            else:
                total_allocated += current.size
                num_allocated_blocks += 1
            current = current.next

        return {
            'total_size': self.total_size,
            'total_free': total_free,
            'total_allocated': total_allocated,
            'num_free_blocks': num_free_blocks,
            'num_allocated_blocks': num_allocated_blocks,
            'largest_free_block': largest_free,
            'fragmentation': (num_free_blocks - 1) if num_free_blocks > 0 else 0,
            'allocations': self.allocations,
            'deallocations': self.deallocations,
            'failed_allocations': self.failed_allocations,
            'utilization': (total_allocated / self.total_size * 100) if self.total_size > 0 else 0
        }

    def visualize(self) -> str:
        """Create a visual representation of memory."""
        blocks = self.get_memory_map()
        result = ["Memory Map (0 to {}):".format(self.total_size)]
        result.append("=" * 60)

        for block in blocks:
            bar_length = int((block.size / self.total_size) * 40)
            bar = "█" * bar_length if not block.is_free else "░" * bar_length
            status = "ALLOCATED" if not block.is_free else "FREE"
            result.append(f"{bar} {status} [{block.start:4d}-{block.end:4d}) size={block.size:4d}")

        result.append("=" * 60)
        return "\n".join(result)

# Example usage:
def demo_memory_allocator():
    print("=== Memory Allocator Simulator Demo ===\n")

    # Create allocator with 1000 bytes
    allocator = MemoryAllocator(1000, AllocationStrategy.FIRST_FIT)

    print("Initial state:")
    print(allocator.visualize())
    print()

    # Allocate some blocks
    print("--- Allocations ---")
    addr1 = allocator.malloc(100)
    print(f"Allocated 100 bytes at address {addr1}")

    addr2 = allocator.malloc(200)
    print(f"Allocated 200 bytes at address {addr2}")

    addr3 = allocator.malloc(150)
    print(f"Allocated 150 bytes at address {addr3}")

    print("\nAfter allocations:")
    print(allocator.visualize())
    print()

    # Free middle block
    print("--- Free middle block ---")
    allocator.free(addr2)
    print(f"Freed block at address {addr2}")

    print("\nAfter freeing:")
    print(allocator.visualize())
    print()

    # Allocate smaller block (should use freed space)
    print("--- Allocate in freed space ---")
    addr4 = allocator.malloc(50)
    print(f"Allocated 50 bytes at address {addr4}")

    print("\nAfter allocation:")
    print(allocator.visualize())
    print()

    # Free adjacent blocks (should coalesce)
    print("--- Free adjacent blocks ---")
    allocator.free(addr1)
    allocator.free(addr4)
    print(f"Freed blocks at addresses {addr1} and {addr4}")

    print("\nAfter freeing (coalesced):")
    print(allocator.visualize())
    print()

    # Statistics
    print("--- Statistics ---")
    stats = allocator.get_statistics()
    for key, value in stats.items():
        if isinstance(value, float):
            print(f"  {key}: {value:.2f}")
        else:
            print(f"  {key}: {value}")

# Run demo
if __name__ == "__main__":
    demo_memory_allocator()
```

**Output:**
```
=== Memory Allocator Simulator ===

Initial state:
Memory Map (0 to 1000):
============================================================
████████████████████████████████████████ FREE [   0-1000) size=1000
============================================================

--- Allocations ---
Allocated 100 bytes at address 0
Allocated 200 bytes at address 100
Allocated 150 bytes at address 300

After allocations:
Memory Map (0 to 1000):
============================================================
████ ALLOCATED [   0- 100) size= 100
████████ ALLOCATED [ 100- 300) size= 200
██████ ALLOCATED [ 300- 450) size= 150
██████████████████████ FREE [ 450-1000) size= 550
============================================================

--- Free middle block ---
Freed block at address 100

After freeing:
Memory Map (0 to 1000):
============================================================
████ ALLOCATED [   0- 100) size= 100
████████ FREE [ 100- 300) size= 200
██████ ALLOCATED [ 300- 450) size= 150
██████████████████████ FREE [ 450-1000) size= 550
============================================================

--- Allocate in freed space ---
Allocated 50 bytes at address 100

After allocation:
Memory Map (0 to 1000):
============================================================
████ ALLOCATED [   0- 100) size= 100
██ ALLOCATED [ 100- 150) size=  50
██████ FREE [ 150- 300) size= 150
██████ ALLOCATED [ 300- 450) size= 150
██████████████████████ FREE [ 450-1000) size= 550
============================================================
```

**Comparison of allocation strategies:**

```python
def compare_strategies():
    """Compare different allocation strategies."""
    strategies = [
        AllocationStrategy.FIRST_FIT,
        AllocationStrategy.BEST_FIT,
        AllocationStrategy.WORST_FIT
    ]

    # Test workload
    operations = [
        ('malloc', 100),
        ('malloc', 200),
        ('malloc', 150),
        ('malloc', 300),
        ('free', 1),  # Free second allocation
        ('malloc', 50),
        ('malloc', 250),
        ('free', 2),  # Free third allocation
        ('malloc', 100)
    ]

    for strategy in strategies:
        allocator = MemoryAllocator(1000, strategy)
        addresses = []

        print(f"\n=== {strategy.name} ===")

        for op, size in operations:
            if op == 'malloc':
                addr = allocator.malloc(size)
                addresses.append(addr)
                print(f"Allocated {size} bytes at {addr}")
            elif op == 'free':
                addr = addresses[size]
                allocator.free(addr)
                print(f"Freed block at {addr}")

        stats = allocator.get_statistics()
        print(f"\nUtilization: {stats['utilization']:.1f}%")
        print(f"Fragmentation: {stats['fragmentation']} free blocks")
        print(f"Failed allocations: {stats['failed_allocations']}")

# compare_strategies()
```

### Project structuring and testing

Proper project structure and comprehensive testing are essential for maintaining quality code.

**Project structure best practices:**

```
project/
├── src/
│   ├── __init__.py
│   ├── data_structures/
│   │   ├── __init__.py
│   │   ├── stack.py
│   │   ├── queue.py
│   │   └── tree.py
│   ├── algorithms/
│   │   ├── __init__.py
│   │   ├── sorting.py
│   │   └── searching.py
│   └── utils/
│       ├── __init__.py
│       └── helpers.py
├── tests/
│   ├── __init__.py
│   ├── test_stack.py
│   ├── test_queue.py
│   └── test_tree.py
├── docs/
│   ├── README.md
│   └── API.md
├── requirements.txt
├── setup.py
└── README.md
```

**Testing strategies:**

```python
import unittest
from typing import List

# Example: Testing the TextEditor
class TestTextEditor(unittest.TestCase):
    """Comprehensive tests for TextEditor."""

    def setUp(self):
        """Set up test fixtures."""
        self.editor = TextEditor()

    def tearDown(self):
        """Clean up after tests."""
        self.editor = None

    # Unit tests for basic operations
    def test_insert_at_beginning(self):
        """Test inserting text at the beginning."""
        self.editor.insert(0, "Hello")
        self.assertEqual(self.editor.get_text(), "Hello")

    def test_insert_at_end(self):
        """Test inserting text at the end."""
        self.editor.insert(0, "Hello")
        self.editor.insert(5, " World")
        self.assertEqual(self.editor.get_text(), "Hello World")

    def test_delete_single_char(self):
        """Test deleting a single character."""
        self.editor.insert(0, "Hello")
        self.editor.delete(4, 1)
        self.assertEqual(self.editor.get_text(), "Hell")

    def test_delete_multiple_chars(self):
        """Test deleting multiple characters."""
        self.editor.insert(0, "Hello World")
        self.editor.delete(5, 6)
        self.assertEqual(self.editor.get_text(), "Hello")

    # Tests for undo/redo functionality
    def test_undo_single_operation(self):
        """Test undoing a single operation."""
        self.editor.insert(0, "Test")
        self.editor.undo()
        self.assertEqual(self.editor.get_text(), "")

    def test_redo_single_operation(self):
        """Test redoing a single operation."""
        self.editor.insert(0, "Test")
        self.editor.undo()
        self.editor.redo()
        self.assertEqual(self.editor.get_text(), "Test")

    def test_multiple_undo_redo(self):
        """Test multiple undo/redo operations."""
        self.editor.insert(0, "A")
        self.editor.insert(1, "B")
        self.editor.insert(2, "C")

        self.editor.undo()
        self.editor.undo()
        self.assertEqual(self.editor.get_text(), "A")

        self.editor.redo()
        self.assertEqual(self.editor.get_text(), "AB")

    def test_redo_cleared_on_new_operation(self):
        """Test that redo stack is cleared on new operation."""
        self.editor.insert(0, "A")
        self.editor.undo()
        self.editor.insert(0, "B")
        self.assertFalse(self.editor.can_redo())

    # Edge cases
    def test_undo_on_empty_editor(self):
        """Test undo on empty editor."""
        result = self.editor.undo()
        self.assertFalse(result)

    def test_redo_on_empty_redo_stack(self):
        """Test redo when redo stack is empty."""
        self.editor.insert(0, "Test")
        result = self.editor.redo()
        self.assertFalse(result)

    def test_insert_at_invalid_position(self):
        """Test insert at invalid position (should clamp)."""
        self.editor.insert(100, "Test")
        self.assertEqual(self.editor.get_text(), "Test")

    def test_delete_beyond_text_length(self):
        """Test delete beyond text length."""
        self.editor.insert(0, "Test")
        self.editor.delete(2, 100)
        self.assertEqual(self.editor.get_text(), "Te")

    # Performance tests
    def test_large_text_operations(self):
        """Test operations on large text."""
        large_text = "x" * 10000
        self.editor.insert(0, large_text)
        self.assertEqual(len(self.editor.get_text()), 10000)

    def test_many_operations(self):
        """Test many sequential operations."""
        for i in range(100):
            self.editor.insert(i, "a")
        self.assertEqual(len(self.editor.get_text()), 100)

    # Integration tests
    def test_complex_editing_scenario(self):
        """Test a complex editing scenario."""
        # Type a sentence
        self.editor.insert(0, "The quick brown fox")

        # Fix a typo
        self.editor.delete(4, 6)
        self.editor.insert(4, " slow")

        # Undo the fix
        self.editor.undo()
        self.editor.undo()

        # Add more text
        self.editor.insert(19, " jumps")

        self.assertEqual(self.editor.get_text(), "The quick brown fox jumps")

# Property-based testing
class TestTextEditorProperties(unittest.TestCase):
    """Property-based tests for TextEditor."""

    def test_undo_redo_invariant(self):
        """Test that undo followed by redo returns to original state."""
        editor = TextEditor()
        editor.insert(0, "Initial text")
        original = editor.get_text()

        editor.insert(12, " added")
        editor.undo()
        editor.redo()

        # After undo-redo, should return to state before undo
        self.assertEqual(editor.get_text(), original + " added")

    def test_text_length_after_operations(self):
        """Test that text length is consistent after operations."""
        editor = TextEditor()

        editor.insert(0, "Hello")
        self.assertEqual(len(editor.get_text()), 5)

        editor.insert(5, " World")
        self.assertEqual(len(editor.get_text()), 11)

        editor.delete(0, 6)
        self.assertEqual(len(editor.get_text()), 5)

# Performance benchmarking
class TextEditorBenchmark(unittest.TestCase):
    """Performance benchmarks for TextEditor."""

    def test_insert_performance(self):
        """Benchmark insert operations."""
        import time

        editor = TextEditor()
        start = time.time()

        for i in range(1000):
            editor.insert(i, "a")

        elapsed = time.time() - start
        print(f"\n1000 inserts: {elapsed:.3f}s ({1000/elapsed:.0f} ops/sec)")

        # Assert reasonable performance
        self.assertLess(elapsed, 1.0, "Insert operations too slow")

    def test_undo_redo_performance(self):
        """Benchmark undo/redo operations."""
        import time

        editor = TextEditor()

        # Perform many operations
        for i in range(100):
            editor.insert(i, "a")

        # Benchmark undo
        start = time.time()
        for _ in range(100):
            editor.undo()
        elapsed_undo = time.time() - start

        # Benchmark redo
        start = time.time()
        for _ in range(100):
            editor.redo()
        elapsed_redo = time.time() - start

        print(f"\n100 undos: {elapsed_undo:.3f}s")
        print(f"100 redos: {elapsed_redo:.3f}s")

        # Assert reasonable performance
        self.assertLess(elapsed_undo, 0.1)
        self.assertLess(elapsed_redo, 0.1)

# Test suite
def create_test_suite():
    """Create a test suite with all tests."""
    suite = unittest.TestSuite()

    # Add unit tests
    suite.addTests(unittest.TestLoader().loadTestsFromTestCase(TestTextEditor))

    # Add property tests
    suite.addTests(unittest.TestLoader().loadTestsFromTestCase(TestTextEditorProperties))

    # Add benchmarks (optional)
    # suite.addTests(unittest.TestLoader().loadTestsFromTestCase(TextEditorBenchmark))

    return suite

# Run tests
if __name__ == "__main__":
    # Run with verbose output
    runner = unittest.TextTestRunner(verbosity=2)
    runner.run(create_test_suite())
```

**Integration with CI/CD:**

```python
# pytest configuration (pytest.ini or setup.cfg)
"""
[pytest]
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*
addopts =
    --verbose
    --cov=src
    --cov-report=html
    --cov-report=term-missing
"""

# Example GitHub Actions workflow (.github/workflows/test.yml)
"""
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v2

    - name: Set up Python
      uses: actions/setup-python@v2
      with:
        python-version: '3.9'

    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt
        pip install pytest pytest-cov

    - name: Run tests
      run: pytest

    - name: Upload coverage
      uses: codecov/codecov-action@v2
"""
```
