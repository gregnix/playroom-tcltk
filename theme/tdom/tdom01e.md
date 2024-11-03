Tcl/Tk `tdom` : 

### NAME
- **dom**: Create an in-memory DOM tree from XML.

### SYNOPSIS
- **Package requirement**: `package require tdom`
- **Command structure**: `dom method ?arg arg ...?`

### DESCRIPTION
The `dom` command allows you to parse XML (or HTML/JSON) and create a DOM tree in memory. The DOM tree can be manipulated through Tcl object commands.

### Common Methods

1. **dom parse ?options? ?data?**: Parses XML, builds a DOM tree, and returns a reference to the document.
   ```tcl
   set doc [dom parse $xml]
   set root [$doc documentElement]
   ```
   Options include:
   - `-simple`: Use a fast but less compliant parser.
   - `-html`: Parses HTML, even malformed, into a DOM.
   - `-json`: Parses JSON into a DOM structure.
   - `-channel <channel-ID>`: Reads input from a specified channel.
   - `-keepEmpties`, `-keepCDATA`, etc.: Control what is kept in the resulting DOM.

2. **dom createDocument docElemName ?objVar?**: Creates a new DOM document with the specified root element.

3. **dom setStoreLineColumn ?boolean?**: Optionally stores line and column positions for each node.

4. **dom createNodeCmd (element|comment|text|cdata|pi)Node commandName**: Creates Tcl commands for building nodes that can be used in `appendFromScript`.

### Document Manipulation (`domDoc`)
This command is used for manipulating an instance of a document object:

1. **documentElement**: Returns the root element of the document.

2. **createElement, createTextNode, createComment**: Creates and appends a new element, text, or comment node to the hidden fragment list in the document.

3. **delete**: Deletes the document and frees associated memory.

4. **asXML, asHTML, asJSON, asText**: Serializes the DOM to XML, HTML, JSON, or text, with optional pretty-printing.

5. **selectNodes**: Executes an XPath query on the document to return matching nodes or values.

### Node Manipulation (`domNode`)
Use this command to manipulate individual nodes:

1. **nodeType**: Returns the type of the node, such as `ELEMENT_NODE` or `TEXT_NODE`.

2. **appendChild, removeChild, insertBefore, replaceChild**: Standard DOM methods for managing child nodes.

3. **setAttribute, getAttribute, removeAttribute**: Manages attributes of element nodes.

4. **selectNodes**: Executes an XPath query within the subtree of the node.

5. **asXML, asHTML, asJSON, asText**: Serializes the node subtree to various formats.

6. **hasChildNodes, firstChild, lastChild, parentNode**: Returns information about node relationships.

### XSLT Transformation
- **xslt**: Applies an XSLT transformation to the DOM document, returning a transformed document.

### Summary
- **`tdom`** is a powerful tool for working with XML, HTML, and JSON in Tcl, providing full DOM manipulation capabilities.
- Methods are available to parse data, create documents and nodes, manipulate the tree, and serialize to various output formats.

For specific details, refer to the Tcl documentation on `tdom`.
