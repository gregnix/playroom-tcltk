### Short Manual for Using the Tcl Script

#### 1. Introduction

This script allows the creation, management, and traversal of tree structures using Tcl dictionaries. It provides functions for adding, removing, moving, and replacing nodes, as well as retrieving and displaying information from the tree.

#### 2. Procedures

1. **is-dict**
   - **Description:** Checks if a value is a dictionary.
   - **Parameters:** `value` - The value to check.
   - **Returns:** 1 (true) or 0 (false).

2. **addToTree**
   - **Description:** Adds a value and attrib to the tree at a specific path position.
   - **Parameters:** `tree`, `path`, `value`, 'attr'.

3. **deleteNode**
   - **Description:** Removes a node at a specific path from the tree.
   - **Parameters:** `tree`, `path`.

4. **moveNode**
   - **Description:** Moves a node from one path to another.
   - **Parameters:** `tree`, `fromPath`, `toPath`.

5. **replaceNode**
   - **Description:** Replaces a node at a specific path with a new value.
   - **Parameters:** `tree`, `path`, `value`.

6. **clearTree**
   - **Description:** Deletes all nodes in the tree.
   - **Parameters:** `tree`.

7. **getChildren**
   - **Description:** Returns the child nodes of a node at a specific path.
   - **Parameters:** `tree`, `path`.

8. **getParent**
   - **Description:** Returns the parent node of a node at a specific path.
   - **Parameters:** `tree`, `path`.

9. **getAllNodes**
   - **Description:** Returns all nodes below a specific path.
   - **Parameters:** `tree`, `path`.

10. **getNodeFromTree**
    - **Description:** Returns the value of a node at a specific path.
    - **Parameters:** `tree`, `path`.

11. **getNodeValue**
    - **Description:** Returns the value of a node at a specific path.
    - **Parameters:** `tree`, `path`.

12. **setNodeValue**
    - **Description:** Sets the value of a node at a specific path.
    - **Parameters:** `tree`, `path`, `newValue`.

13. **printTree**
    - **Description:** Recursively prints the entire tree.
    - **Parameters:** `tree`, `indent`.

14. **cmdPrintNode**
    - **Description:** Format for printing a node (Path, Value, Attr).
    - **Parameters:** `path`, `value`, `attr`.

15. **cmdListNode**
    - **Description:** Returns a node as a list (Path, Value, Attr).
    - **Parameters:** `path`, `value`, `attr`.

16. **size**
    - **Description:** Returns the number of nodes in the tree.
    - **Parameters:** `tree`.

17. **depth**
    - **Description:** Returns the maximum depth of the tree.
    - **Parameters:** `tree`.

18. **walkTree**
    - **Description:** Recursively traverses the tree and performs an action for each node.
    - **Parameters:** `tree`, `path`, `action`, `recursiv`, `args`.
19. **getAttrValue**
20. **setAttrValue**
21. 

#### 3. Usage Example

Initialize an empty tree and add data to it. Traverse the tree using various actions to print nodes or retrieve node lists.

#### 4. Output Format

The output shows the path, value, and attributes of nodes in the tree.

#### 5. Notes

- The `walkTree` procedure is flexible and can be used with different action procedures (cmd...) to perform various tasks during tree traversal.
- The `attr` field allows the addition of extra attributes to the nodes, which can be considered during tree traversal.

