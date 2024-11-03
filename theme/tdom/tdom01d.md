Tcl/Tk `tdom` :

### NAME
- **dom**: Erstellung eines DOM-Baums im Speicher aus XML.

### SYNOPSIS
- **Paket-Anforderung**: `package require tdom`
- **Befehlsstruktur**: `dom method ?arg arg ...?`

### BESCHREIBUNG
Der `dom`-Befehl ermöglicht das Parsen von XML (oder HTML/JSON) und die Erstellung eines DOM-Baums im Speicher. Der DOM-Baum kann dann über Tcl-Objektbefehle manipuliert werden.

### Wichtige Methoden

1. **dom parse ?optionen? ?daten?**: Parst XML, erstellt einen DOM-Baum und gibt eine Referenz auf das Dokument zurück.
   ```tcl
   set doc [dom parse $xml]
   set root [$doc documentElement]
   ```
   Optionen umfassen:
   - `-simple`: Verwendet einen schnellen, aber weniger konformen Parser.
   - `-html`: Parst HTML, auch wenn es fehlerhaft ist, in einen DOM-Baum.
   - `-json`: Parst JSON in eine DOM-Struktur.
   - `-channel <channel-ID>`: Liest Eingaben aus einem bestimmten Kanal.
   - `-keepEmpties`, `-keepCDATA` usw.: Bestimmt, was im resultierenden DOM behalten wird.

2. **dom createDocument docElemName ?objVar?**: Erstellt ein neues DOM-Dokument mit dem angegebenen Wurzelelement.

3. **dom setStoreLineColumn ?boolean?**: Speichert optional Zeilen- und Spaltenpositionen für jeden Knoten.

4. **dom createNodeCmd (element|comment|text|cdata|pi)Node commandName**: Erstellt Tcl-Befehle zum Erstellen von Knoten, die in `appendFromScript` verwendet werden können.

### Dokumenten-Manipulation (`domDoc`)
Dieser Befehl wird zur Manipulation einer Instanz eines Dokumentobjekts verwendet:

1. **documentElement**: Gibt das Wurzelelement des Dokuments zurück.

2. **createElement, createTextNode, createComment**: Erstellt und fügt ein neues Element, Text oder einen Kommentar dem versteckten Fragment im Dokument hinzu.

3. **delete**: Löscht das Dokument und gibt den zugehörigen Speicher frei.

4. **asXML, asHTML, asJSON, asText**: Serialisiert den DOM-Baum zu XML, HTML, JSON oder Text, optional mit Formatierung.

5. **selectNodes**: Führt eine XPath-Abfrage auf dem Dokument aus und gibt die passenden Knoten oder Werte zurück.

### Knoten-Manipulation (`domNode`)
Verwenden Sie diesen Befehl, um einzelne Knoten zu manipulieren:

1. **nodeType**: Gibt den Typ des Knotens zurück, z. B. `ELEMENT_NODE` oder `TEXT_NODE`.

2. **appendChild, removeChild, insertBefore, replaceChild**: Standard-DOM-Methoden zur Verwaltung von Kindknoten.

3. **setAttribute, getAttribute, removeAttribute**: Verwalten von Attributen von Elementknoten.

4. **selectNodes**: Führt eine XPath-Abfrage im Teilbaum des Knotens aus.

5. **asXML, asHTML, asJSON, asText**: Serialisiert den Knoten-Teilbaum in verschiedene Formate.

6. **hasChildNodes, firstChild, lastChild, parentNode**: Gibt Informationen zu Knotenbeziehungen zurück.

### XSLT-Transformation
- **xslt**: Wendet eine XSLT-Transformation auf das DOM-Dokument an und gibt ein transformiertes Dokument zurück.

### Zusammenfassung
- **`tdom`** ist ein leistungsstarkes Tool zur Arbeit mit XML, HTML und JSON in Tcl, das vollständige DOM-Manipulationsmöglichkeiten bietet.
- Es gibt Methoden zum Parsen von Daten, Erstellen von Dokumenten und Knoten, Manipulieren des Baums und Serialisieren in verschiedene Ausgabeformate.

